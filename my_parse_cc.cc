/*
   DBIx::MyParse - a glue between Perl and MySQL's SQL parser
   Copyright (C) 2005 Philip Stoev

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#define EMBEDDED_LIBRARY
#define NO_EMBEDDED_ACCESS_CHECKS

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

#include <include/mysql.h>
#include <sql/mysql_priv.h>
#include <libmysqld/embedded_priv.h>

#include <my_parse.h>

#include <my_enum.h>
#include <my_define.h>

#include <assert.h>

static char *server_options[] = { "myparse", "--skip-bdb", "--skip-grant-tables", "--skip-innodb", "--skip-isam", "--skip-ndbcluster", "--skip-networking" };
static int num_elements = sizeof(server_options) / sizeof(char *);
static char *server_groups[] = { "myparse" };

void * my_parse_item(Item * item);

void * my_parse_list_items(List<Item> list) {

	void * array = my_parse_create_array();

	List_iterator_fast<Item> iterator(list);
	Item *item;
	while ((item = iterator++)) {
		my_parse_set_array( array, MYPARSE_ARRAY_APPEND, my_parse_item(item), MYPARSE_ARRAY_REF, "DBIx::MyParse::Item" );
	}

	return array;
}

void * my_parse_list_strings(List<String> list) {
	void * string_array = my_parse_create_array();
	List_iterator_fast<String> iterator(list);
	String *str;
	while ((str = iterator++)) {
		my_parse_set_array( string_array, MYPARSE_ARRAY_APPEND, (void *) str->ptr(), MYPARSE_ARRAY_STRING, NULL);
	}

	return string_array;
	
}

void * my_parse_table( st_table_list * table) {
	void * table_array = my_parse_create_array();
	my_parse_set_array( table_array, MYPARSE_ITEM_ITEM_TYPE, (void *) "TABLE_ITEM", MYPARSE_ARRAY_STRING, NULL) ;
	my_parse_set_array( table_array, MYPARSE_ITEM_TABLE_NAME, (void *) table->real_name, MYPARSE_ARRAY_STRING, NULL );
	my_parse_set_array( table_array, MYPARSE_ITEM_DB_NAME, (void *) table->db, MYPARSE_ARRAY_STRING, NULL) ;
	my_parse_set_array( table_array, MYPARSE_ITEM_ALIAS, (void *) table->alias, MYPARSE_ARRAY_STRING, NULL) ;

	return table_array;
}



void * my_parse_item(Item * item) {

	char item_type[255];
	int item_type_int = (int) item->type();

	my_parse_Type(item_type_int, item_type);

	void * perl_item = my_parse_create_array();

	my_parse_set_array( perl_item, MYPARSE_ITEM_ITEM_TYPE, item_type, MYPARSE_ARRAY_STRING, NULL );
	
	char item_value_str[255];
	void * item_value_ref = NULL;
	void * item_args_ref = NULL;

	if (
		(item->type() == Item::STRING_ITEM) ||
		(item->type() == Item::VARBIN_ITEM)
	) {
		String *value_str = item->val_str((String *) 0);
		item_value_ref = (void *) value_str->ptr();
	} else if (item->type() == Item::INT_ITEM) {
		snprintf (item_value_str, 255, "%lld", item->val_int());
		item_value_ref = (void *) item_value_str;
	} else if (item->type() == Item::REAL_ITEM) {
		snprintf( item_value_str, 255, "%f", item->val());
		item_value_ref = (void *) item_value_str;
	} else if (
		(item->type() == Item::FIELD_ITEM) ||
		(item->type() == Item::REF_ITEM)
	) {
		Item_ident * field = (Item_field *) item;

		if (field->db_name) {
			my_parse_set_array( perl_item, MYPARSE_ITEM_DB_NAME, (void *) field->db_name, MYPARSE_ARRAY_STRING, NULL );
		}

		if (field->table_name) {
			my_parse_set_array( perl_item, MYPARSE_ITEM_TABLE_NAME, (void *) field->table_name, MYPARSE_ARRAY_STRING, NULL );
		}

		if (field->field_name) {
			my_parse_set_array( perl_item, MYPARSE_ITEM_FIELD_NAME, (void *) field->field_name, MYPARSE_ARRAY_STRING, NULL );
		}

	} else if (
		(item->type() == Item::COND_ITEM) ||
		(item->type() == Item::FUNC_ITEM)
	) {

		char func_type[255];
		char func_name[255];

		Item_cond * cond = (Item_cond *) item;

		my_parse_Functype( cond->functype(), func_type);

		strcpy(func_name, cond->func_name());

		my_parse_set_array( perl_item, MYPARSE_ITEM_FUNC_TYPE, func_type, MYPARSE_ARRAY_STRING, NULL );

		my_parse_set_array( perl_item, MYPARSE_ITEM_FUNC_NAME, func_name, MYPARSE_ARRAY_STRING, NULL );

		if ((item->type() == Item::COND_ITEM)) {
			List_iterator_fast<Item> li(*((Item_cond *) item)->argument_list());
			Item *sub_item;
			while ((sub_item = li++)) {
				if (!item_args_ref) item_args_ref = my_parse_create_array();

				void * argument_ref = my_parse_item( sub_item );

				my_parse_set_array( item_args_ref, MYPARSE_ARRAY_APPEND, argument_ref, MYPARSE_ARRAY_REF, "DBIx::MyParse::Item" );

			}
		}
	
		if (item->type() == Item::FUNC_ITEM) {
			Item_func * func = (Item_func *) item;

/* This will only work on a patched MySQL source, so we are commenting it out of the distribution

			if (!strcmp(func_name, "date_add_interval")) {
				Item_date_add_interval * date_add_interval = (Item_date_add_interval *) func;
				char interval_type[255];
				my_parse_interval_type(date_add_interval->int_type, interval_type);

				if (!item_args_ref) item_args_ref = my_parse_create_array();

				my_parse_set_array( item_args_ref, MYPARSE_ARRAY_APPEND, interval_type, MYPARSE_ARRAY_STRING, NULL);
			}

*/

			if (func->arg_count) {
				Item **arg,**arg_end;
				for (arg = func->arguments(), arg_end = func->arguments() + func->arg_count; arg != arg_end; arg++) {

					if (!item_args_ref) item_args_ref = my_parse_create_array();

					void * argument_ref = my_parse_item( (Item *) *arg );

					my_parse_set_array( item_args_ref, MYPARSE_ARRAY_APPEND, argument_ref, MYPARSE_ARRAY_REF, "DBIx::MyParse::Item" );
				}
			}
		}
	} else if (item->type() == Item::SUM_FUNC_ITEM) {
		Item_sum * sum = (Item_sum *) item;
		char sum_func_name[255];

		my_parse_Sumfunctype( sum->sum_func(), sum_func_name);

		my_parse_set_array( perl_item, MYPARSE_ITEM_FUNC_TYPE, sum_func_name, MYPARSE_ARRAY_STRING, NULL);

		if (sum->arg_count) {
			Item **arg, **arg_end;
			for (arg = sum->args,arg_end = sum->args + sum->arg_count; arg != arg_end ; arg++) {
				if (!item_args_ref) item_args_ref = my_parse_create_array();
				void * argument_ref = my_parse_item( (Item *) *arg );
				my_parse_set_array( item_args_ref, MYPARSE_ARRAY_APPEND, argument_ref, MYPARSE_ARRAY_REF, "DBIx::MyParse::Item" );
			}
		}
	}	

	if (item_args_ref) {
		my_parse_set_array( perl_item, MYPARSE_ITEM_ARGUMENTS, item_args_ref, MYPARSE_ARRAY_REF, NULL);
	}

	if (item_value_ref) {
		my_parse_set_array( perl_item, MYPARSE_ITEM_VALUE, item_value_ref, MYPARSE_ARRAY_STRING, NULL);
	}

	return perl_item;
}

void * my_parse_init() {

	mysql_server_init(num_elements, server_options, server_groups);

	char *db_name = NULL;

	THD * thd = (THD *) create_embedded_thd(0, db_name);

	return thd;

}

int my_parse_inner(void * perl_array, char * query) {

	THD * thd = (THD *) my_parse_get_thd();

	alloc_query(thd, query, strlen(query) + 1);

	mysql_init_query(thd, (uchar *) thd->query, thd->query_length);
	
	LEX * lex = thd->lex;

	int error = yyparse((void *)thd) || thd->is_fatal_error || thd->net.report_error;

	if (error) {
		my_parse_set_array( perl_array, MYPARSE_COMMAND, (void *) "SQLCOM_ERROR", MYPARSE_ARRAY_STRING, NULL);
	
		my_parse_set_array( perl_array, MYPARSE_ERRNO, &thd->net.last_errno, MYPARSE_ARRAY_LONG, NULL);
		my_parse_set_array( perl_array, MYPARSE_ERRSTR, thd->net.last_error, MYPARSE_ARRAY_STRING, NULL);

		char errno_as_string[255];
		my_parse_errno(thd->net.last_errno, errno_as_string);
		my_parse_set_array( perl_array, MYPARSE_ERROR, (void *) errno_as_string, MYPARSE_ARRAY_STRING, NULL);

		return error;
	}

	char sql_command[255];

	my_parse_enum_sql_command(lex->sql_command, sql_command);

	my_parse_set_array( perl_array, MYPARSE_COMMAND, sql_command, MYPARSE_ARRAY_STRING, NULL);

	void * options_array = my_parse_query_options( lex->select_lex.options );

	if (lex->ignore) {
		my_parse_set_array( options_array, MYPARSE_ARRAY_APPEND, (void *) "IGNORE", MYPARSE_ARRAY_STRING, NULL );
	}

	if (lex->lock_option == TL_READ_HIGH_PRIORITY) {
		char lock_option[255];
		my_parse_thr_lock_type( lex->lock_option, lock_option);
		my_parse_set_array( options_array, MYPARSE_ARRAY_APPEND, (void *) lock_option, MYPARSE_ARRAY_STRING, NULL );
	}

	if (
		(lex->sql_command == SQLCOM_SELECT) ||
		(lex->sql_command == SQLCOM_INSERT_SELECT) ||
		(lex->sql_command == SQLCOM_REPLACE_SELECT) ||
		(lex->sql_command == SQLCOM_UPDATE) ||
		(lex->sql_command == SQLCOM_UPDATE_MULTI)
	) {
		void * items_array = my_parse_list_items(lex->select_lex.item_list);

		if (
			(lex->sql_command == SQLCOM_SELECT) ||
			(lex->sql_command == SQLCOM_INSERT_SELECT)
		) {
			my_parse_set_array( perl_array, MYPARSE_SELECT_ITEMS, items_array, MYPARSE_ARRAY_REF, NULL);
		} else if (
			(lex->sql_command == SQLCOM_UPDATE) ||
			(lex->sql_command == SQLCOM_UPDATE_MULTI)
		) {
			my_parse_set_array( perl_array, MYPARSE_UPDATE_VALUES, items_array, MYPARSE_ARRAY_REF, NULL);
		}
	};

	if (
		(lex->sql_command == SQLCOM_INSERT) ||
		(lex->sql_command == SQLCOM_REPLACE) ||
		(lex->sql_command == SQLCOM_INSERT_SELECT) ||
		(lex->sql_command == SQLCOM_REPLACE_SELECT) ||
		(lex->sql_command == SQLCOM_UPDATE)
	) {

		void * fields_array = my_parse_list_items(lex->field_list);

		if (
			(lex->sql_command == SQLCOM_INSERT) ||
			(lex->sql_command == SQLCOM_REPLACE) ||
			(lex->sql_command == SQLCOM_INSERT_SELECT) ||
			(lex->sql_command == SQLCOM_REPLACE_SELECT)
		) {
			my_parse_set_array( perl_array, MYPARSE_INSERT_FIELDS, fields_array, MYPARSE_ARRAY_REF, NULL );
		} else if (lex->sql_command == SQLCOM_UPDATE) {
			my_parse_set_array( perl_array, MYPARSE_UPDATE_FIELDS, fields_array, MYPARSE_ARRAY_REF, NULL );
		} else {
			assert(sql_command);
		}

	}

	if (lex->value_list.elements > 0) {

		void * values_array = my_parse_list_items(lex->value_list);

		my_parse_set_array( perl_array, MYPARSE_UPDATE_VALUES, values_array, MYPARSE_ARRAY_REF, NULL );

	}

	if (
		(lex->sql_command == SQLCOM_INSERT) ||
		(lex->sql_command == SQLCOM_REPLACE)
	) {

		void * big_values_array = NULL;

		if (lex->insert_list) {
			big_values_array = my_parse_create_array();
			void * small_values_array = my_parse_list_items(*lex->insert_list);
			my_parse_set_array( big_values_array, MYPARSE_ARRAY_APPEND, small_values_array, MYPARSE_ARRAY_REF, NULL );
		}

		if (lex->many_values.elements > 0) {
			big_values_array = my_parse_create_array();
			
			List_iterator_fast<List_item> iterator_lists(lex->many_values);
			List_item *list_item;
			while ((list_item = iterator_lists++)) {
				void * small_values_array = my_parse_list_items(*list_item);
				my_parse_set_array( big_values_array, MYPARSE_ARRAY_APPEND, small_values_array, MYPARSE_ARRAY_REF, NULL );
			}
		}

		if (big_values_array) my_parse_set_array( perl_array, MYPARSE_INSERT_VALUES, big_values_array, MYPARSE_ARRAY_REF, NULL );

		if (lex->update_list.elements > 0) {
			void * update_list = my_parse_list_items(lex->update_list);
			my_parse_set_array( perl_array, MYPARSE_UPDATE_FIELDS, update_list, MYPARSE_ARRAY_REF, NULL );
		}
	}

	if (lex->select_lex.table_list.elements > 0) {
		TABLE_LIST * start_table = (TABLE_LIST *)lex->select_lex.table_list.first;
		TABLE_LIST * tables = NULL;

		void * tables_array = my_parse_create_array();

		for (tables = start_table ; tables ; tables = tables->next) {

			/* TODO: The parser creates a Table_ident object to describe the name and the db of the table.
			   TODO: so we should use it as well, rather than real_name and db from TABLE_LIST */

			void * table_array = my_parse_table(tables);
	
			if (tables->on_expr) {
				my_parse_set_array( table_array, MYPARSE_ITEM_JOIN_COND, my_parse_item( tables->on_expr ), MYPARSE_ARRAY_REF, "DBIx::MyParse::Item") ;
			} else if (tables->natural_join) {
				void * natural_table = my_parse_table(tables->natural_join);
				my_parse_set_array( table_array, MYPARSE_ITEM_JOIN_COND, natural_table, MYPARSE_ARRAY_REF, "DBIx::MyParse::Item") ;			
			}

			if (tables->outer_join == JOIN_TYPE_LEFT) {
				my_parse_set_array( table_array, MYPARSE_ITEM_JOIN_TYPE, (void *) "JOIN_TYPE_LEFT", MYPARSE_ARRAY_STRING, NULL);
			} else if (tables->outer_join == JOIN_TYPE_RIGHT) {
				my_parse_set_array( table_array, MYPARSE_ITEM_JOIN_TYPE, (void *) "JOIN_TYPE_RIGHT", MYPARSE_ARRAY_STRING, NULL);
			} else if (tables->straight == 1) {
				my_parse_set_array( table_array, MYPARSE_ITEM_JOIN_TYPE, (void *) "JOIN_TYPE_STRAIGHT", MYPARSE_ARRAY_STRING, NULL);
			}

			if (tables->lock_type) {
				char lock_option[255];
				my_parse_thr_lock_type( tables->lock_type, lock_option);
				my_parse_set_array( options_array, MYPARSE_ARRAY_APPEND, (void *) lock_option, MYPARSE_ARRAY_STRING, NULL);
			}

			if (tables->use_index) {
				List<String> use_index = *tables->use_index;
				void * use_array = my_parse_list_strings( use_index );
				my_parse_set_array( table_array, MYPARSE_ITEM_USE_INDEX, use_array, MYPARSE_ARRAY_REF, NULL);
			}

			if (tables->ignore_index) {
				List<String> ignore_index = *tables->ignore_index;
				void * ignore_array = my_parse_list_strings( ignore_index );
				my_parse_set_array( table_array, MYPARSE_ITEM_IGNORE_INDEX, ignore_array, MYPARSE_ARRAY_REF, NULL);
			}

			my_parse_set_array( tables_array, MYPARSE_ARRAY_APPEND, table_array, MYPARSE_ARRAY_REF, "DBIx::MyParse::Item");
		}

		my_parse_set_array( perl_array, MYPARSE_TABLES, tables_array, MYPARSE_ARRAY_REF, NULL);

	}

	/* This is used to obtain the list of the tables on which multiple-table DELETE actually operates */

	if (lex->sql_command == SQLCOM_DELETE_MULTI) {
		TABLE_LIST * start_delete_table = (TABLE_LIST *) lex->auxilliary_table_list.first;
		TABLE_LIST * delete_tables = NULL;
		void * delete_tables_array = my_parse_create_array();
		for (delete_tables = start_delete_table; delete_tables; delete_tables = delete_tables->next) {
			void * delete_table_array = my_parse_table(delete_tables);
			my_parse_set_array( delete_tables_array, MYPARSE_ARRAY_APPEND, delete_table_array, MYPARSE_ARRAY_REF, "DBIx::MyParse::Item");
		}

		my_parse_set_array( perl_array, MYPARSE_DELETE_TABLES, delete_tables_array, MYPARSE_ARRAY_REF, NULL);
				
	}

	my_parse_set_array( perl_array, MYPARSE_OPTIONS, options_array, MYPARSE_ARRAY_REF, NULL);

	COND * start_where = (COND *) lex->select_lex.where;
	
	if (start_where) {
		void * where_array = my_parse_item((Item_cond *) start_where);
		my_parse_set_array( perl_array, MYPARSE_WHERE, where_array, MYPARSE_ARRAY_REF, "DBIx::MyParse::Item" );
	}

	COND * start_having = (COND *) lex->select_lex.having;

	if (start_having) {
		void * having_array = my_parse_item((Item_cond *) start_having);
		my_parse_set_array( perl_array, MYPARSE_HAVING, having_array, MYPARSE_ARRAY_REF, "DBIx::MyParse::Item" );
	}

	ORDER * start_order = (ORDER *) lex->select_lex.order_list.first;

	if (start_order) {
		ORDER * orders;
		void * orders_array = my_parse_create_array();
		for (orders = start_order ; orders ; orders = orders->next) {
			void * order_array = my_parse_item((Item_cond *) *orders->item);

			char order_dir[32];

			if (orders->asc) {
				strcpy( order_dir, "ASC");
			} else {
				strcpy( order_dir, "DESC");
			}

			my_parse_set_array( order_array, MYPARSE_ITEM_ORDER_DIR, (void *) order_dir, MYPARSE_ARRAY_STRING, NULL);
	
			my_parse_set_array( orders_array, MYPARSE_ARRAY_APPEND, order_array, MYPARSE_ARRAY_REF, "DBIx::MyParse::Item");

		}

		my_parse_set_array( perl_array, MYPARSE_ORDER, orders_array, MYPARSE_ARRAY_REF, NULL);
	}

	ORDER * start_group = (ORDER *) lex->select_lex.group_list.first;

	if (start_group) {
		ORDER * groups;
		void * groups_array = my_parse_create_array();
		for (groups = start_group ; groups ; groups = groups->next) {
			void * group_array = my_parse_item((Item_cond *) *groups->item);

			char group_dir[32];

			if (groups->asc) {
				strcpy(group_dir,"ASCENDING");
			} else {
				strcpy(group_dir,"DESCENDING");
			}

			my_parse_set_array( group_array, MYPARSE_ITEM_ORDER_DIR, (void *) group_dir, MYPARSE_ARRAY_STRING, NULL);
	
			my_parse_set_array( groups_array, MYPARSE_ARRAY_APPEND, group_array, MYPARSE_ARRAY_REF, "DBIx::MyParse::Item");
		}

		my_parse_set_array( perl_array, MYPARSE_GROUP, groups_array, MYPARSE_ARRAY_REF, NULL);
	}

	if (lex->select_lex.explicit_limit) {
		void * limit_array = my_parse_create_array();

		my_parse_set_array( limit_array, MYPARSE_LIMIT_SELECT, &lex->select_lex.select_limit, MYPARSE_ARRAY_LONG, NULL);
		my_parse_set_array( limit_array, MYPARSE_LIMIT_OFFSET, &lex->select_lex.offset_limit, MYPARSE_ARRAY_LONG, NULL);

		my_parse_set_array( perl_array, MYPARSE_LIMIT, limit_array, MYPARSE_ARRAY_REF, NULL );
	}

	lex_end(lex);
	close_thread_tables(thd);
	free_items(thd->free_list);
	thd->end_statement();

	return 0;
}
