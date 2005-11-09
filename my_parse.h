extern void * my_parse_init();

void * my_parse_get_thd();

extern int my_parse_inner(void * array_ref, char * query);

void * my_parse_get_subarray (void * master_array_ref, int index);

/*
 * If you change those constants, also update the corresponding constants in the .pm files
 */

#define MYPARSE_COMMAND	0
#define MYPARSE_OPTIONS	1
#define MYPARSE_SELECT_ITEMS	2
#define MYPARSE_INSERT_FIELDS	3
#define MYPARSE_UPDATE_FIELDS	4
#define MYPARSE_INSERT_VALUES	5
#define MYPARSE_UPDATE_VALUES	6

#define MYPARSE_TABLES	7
#define MYPARSE_ORDER	8
#define MYPARSE_GROUP	9
#define MYPARSE_WHERE	10
#define MYPARSE_HAVING	11
#define MYPARSE_LIMIT	12
#define MYPARSE_ERROR	13
#define MYPARSE_ERRNO	14
#define MYPARSE_ERRSTR	15

/* This is only used in multiple-table DELETE */

#define MYPARSE_DELETE_TABLES	16


#define MYPARSE_ITEM_ITEM_TYPE	0
#define MYPARSE_ITEM_FUNC_TYPE	1
#define MYPARSE_ITEM_FUNC_NAME	2
#define MYPARSE_ITEM_VALUE	3
#define MYPARSE_ITEM_ARGUMENTS	4
#define MYPARSE_ITEM_ORDER_DIR	5
#define MYPARSE_ITEM_GROUP_DIR	5
#define MYPARSE_ITEM_DB_NAME	6
#define MYPARSE_ITEM_TABLE_NAME	7
#define MYPARSE_ITEM_FIELD_NAME	8
#define MYPARSE_ITEM_ALIAS	9
#define MYPARSE_ITEM_JOIN_COND	10
#define MYPARSE_ITEM_JOIN_TYPE	11
#define MYPARSE_ITEM_USE_INDEX	12
#define MYPARSE_ITEM_IGNORE_INDEX 13

#define MYPARSE_LIMIT_SELECT	0
#define MYPARSE_LIMIT_OFFSET	1


#define MYPARSE_ARRAY_APPEND	65535
#define MYPARSE_ARRAY_STRING	0
#define MYPARSE_ARRAY_REF	1
#define MYPARSE_ARRAY_LONG	2
#define MYPARSE_ARRAY_INT	3

void my_parse_die();

void * my_parse_create_array ();

void * my_parse_set_array ( void * array_ref, int index, void * item_ref, int item_type, char * class_name );
