
package DBIx::MyParse::Item;

use strict;
use warnings;

#
# If you change those constants, do not forget to change
# the corresponding C #defines in my_parse.h
#

use constant MYPARSE_ITEM_ITEM_TYPE	=> 0;
use constant MYPARSE_ITEM_FUNC_TYPE	=> 1;
use constant MYPARSE_ITEM_FUNC_NAME	=> 2;
use constant MYPARSE_ITEM_VALUE		=> 3;
use constant MYPARSE_ITEM_ARGUMENTS	=> 4;
use constant MYPARSE_ITEM_ORDER_DIR	=> 5;
use constant MYPARSE_ITEM_GROUP_DIR	=> 5;

use constant MYPARSE_ITEM_DB_NAME	=> 6;
use constant MYPARSE_ITEM_TABLE_NAME	=> 7;
use constant MYPARSE_ITEM_FIELD_NAME	=> 8;
use constant MYPARSE_ITEM_ALIAS		=> 9;
use constant MYPARSE_ITEM_JOIN_COND	=> 10;
use constant MYPARSE_ITEM_JOIN_TYPE	=> 11;
use constant MYPARSE_ITEM_USE_INDEX	=> 12;
use constant MYPARSE_ITEM_IGNORE_INDEX	=> 13;

1;

sub getType {
	return $_[0]->[MYPARSE_ITEM_ITEM_TYPE];
}

sub getFuncType {
	my $item_type = $_[0]->[MYPARSE_ITEM_ITEM_TYPE];
	if (
		($item_type eq 'COND_ITEM') ||
		($item_type eq 'FUNC_ITEM') ||
		($item_type eq 'SUM_FUNC_ITEM')
	) {
		return $_[0]->[MYPARSE_ITEM_FUNC_TYPE];
	} else {
		warn("$_[0] getFuncType() called, but getItemType() = $item_type.\n");
		return undef;
	}
}

sub getFuncName {
	my $item_type = $_[0]->[MYPARSE_ITEM_ITEM_TYPE];
	if (
		($item_type eq 'COND_ITEM') ||
		($item_type eq 'FUNC_ITEM')
	) {
		return $_[0]->[MYPARSE_ITEM_FUNC_NAME];
	} else {
		warn("$_[0]: getFuncName() called, but getItemType() = $item_type\n");
		return undef;
	}
}

sub getValue {
	my $item_type = $_[0]->[MYPARSE_ITEM_ITEM_TYPE];

	if (
		($item_type eq 'STRING_ITEM') ||
		($item_type eq 'INT_ITEM') ||
		($item_type eq 'REAL_ITEM') ||
		($item_type eq 'VARBIN_ITEM')
	) {
		return $_[0]->[MYPARSE_ITEM_VALUE];
	} else {
		warn("$_[0]: getItemValueStr() called, but getItemType() = $item_type\n");
		return undef;
	}
}

sub getArguments {

	my $item_type = $_[0]->[MYPARSE_ITEM_ITEM_TYPE];

	if (
		($item_type eq 'STRING_ITEM') ||
		($item_type eq 'INT_ITEM') ||
		($item_type eq 'REAL_ITEM')
	) {
		warn("$_[0]: getItemArguments() called, but getItemType() = $item_type\n");
		return undef;
	} else {
		return $_[0]->[MYPARSE_ITEM_ARGUMENTS];
	}
}

sub getOrderDir {
	
	return $_[0]->[MYPARSE_ITEM_ORDER_DIR];
}

sub getGroupDir {
	
	return $_[0]->[MYPARSE_ITEM_GROUP_DIR];
}


sub getDatabaseName {
	return $_[0]->getFieldAttr(MYPARSE_ITEM_DB_NAME, 'getDatabaseName()');
}
sub getTableName {
	return $_[0]->getFieldAttr(MYPARSE_ITEM_TABLE_NAME, 'getTableName()');
}
sub getFieldName {
	return $_[0]->getFieldAttr(MYPARSE_ITEM_FIELD_NAME, 'getFieldName()');
}

sub getAlias {
	return $_[0]->[MYPARSE_ITEM_ALIAS];
}

sub getFieldAttr {

	my ($item, $attr, $func) = @_;

	my $item_type = $item->[MYPARSE_ITEM_ITEM_TYPE];

	if (
		($item_type eq 'REF_ITEM') ||
		($item_type eq 'FIELD_ITEM')
	) {
		return $item->[$attr];
	} elsif (
		($item_type eq 'TABLE_ITEM') &&
		($attr ne MYPARSE_ITEM_FIELD_NAME)
	) {
		return $item->[$attr];
	} else {
		warn("$item: $func called, but getItemType() = $item_type\n");
		return undef;
	}
}

sub getJoinCond {
	return $_[0]->[MYPARSE_ITEM_JOIN_COND];
}

1;

__END__

=head1 NAME

DBIx::MyParse::Item - Accessing the items from a C<DBIx::MyParse> parse tree

=head1 SYNOPSIS

	use DBIx::MyParse;
	use DBIx::MyParse::Query;
	use DBIx::MyParse::Item;

	my $parser = DBIx::MyParse->new();
	my $query = $parser->parse("SELECT field_name FROM table_name");
	my $item_list = $query->getSelectItems();
	my $first_item = $item_list->[0];
	print $first_item->getType();		# Prints "FIELD_ITEM"
	print $first_item->getFieldName()	# Prints "field_name"
	

=head1 DESCRIPTION

MySQL uses a few dozen Item objects to store the various nodes possible in a
parse tree. For the sake of simplicity, we only use a single object interface
in Perl to access things.

=head1 METHODS

=over 4

=item my $item_type = $item->getType();

This returns the type of the Item as a string, to facilitate dumping and debugging.

	if ($item_type eq 'FIELD_ITEM') { ... }	# Correct
	if ($item_type == FIELD_ITEM) { ... }	# Will not work

The possible values are listed in enum Type in sql/item.h in the MySQL source.

	enum Type {FIELD_ITEM, FUNC_ITEM, SUM_FUNC_ITEM, STRING_ITEM,
		INT_ITEM, REAL_ITEM, NULL_ITEM, VARBIN_ITEM,
		COPY_STR_ITEM, FIELD_AVG_ITEM, DEFAULT_VALUE_ITEM,
		PROC_ITEM,COND_ITEM, REF_ITEM, FIELD_STD_ITEM,
		FIELD_VARIANCE_ITEM, INSERT_VALUE_ITEM,
		SUBSELECT_ITEM, ROW_ITEM, CACHE_ITEM, TYPE_HOLDER,
		PARAM_ITEM
	};

From those, the following are explicitly supported:

	FIELD_ITEM, FUNC_ITEM, SUM_FUNC_ITEM,
	STRING_ITEM, INT_ITEM, REAL_ITEM, NULL_ITEM, VARBIN_ITEM
	REF_ITEM, COND_ITEM

In addition, DBIx::MyParse defines its own TABLE_ITEM in case a table, rather than a field, is being
referenced.

REF_ITEM is a FIELD_ITEM that is used in a HAVING clause. VARBIN_ITEM is
created when a Hex value is passed to MySQL (e.g. 0x5061756c).

=item my $func_type = $item->getFuncType();

if $item->getType() eq "FUNC_ITEM", you can call getFuncType() to determine what type of
function it is. For MySQL, all operators are also of type FUNC_ITEM.

The possible values are again strings (see above) and are listed in sql/item_func.h under enum Functype

	enum Functype {
		UNKNOWN_FUNC,EQ_FUNC,EQUAL_FUNC,NE_FUNC,LT_FUNC,LE_FUNC,
		GE_FUNC,GT_FUNC,FT_FUNC,
		LIKE_FUNC,NOTLIKE_FUNC,ISNULL_FUNC,ISNOTNULL_FUNC,
		COND_AND_FUNC, COND_OR_FUNC, COND_XOR_FUNC, BETWEEN, IN_FUNC,
		INTERVAL_FUNC, ISNOTNULLTEST_FUNC,
		SP_EQUALS_FUNC, SP_DISJOINT_FUNC,SP_INTERSECTS_FUNC,
		SP_TOUCHES_FUNC,SP_CROSSES_FUNC,SP_WITHIN_FUNC,
		SP_CONTAINS_FUNC,SP_OVERLAPS_FUNC,
		SP_STARTPOINT,SP_ENDPOINT,SP_EXTERIORRING,
		SP_POINTN,SP_GEOMETRYN,SP_INTERIORRINGN,
		NOT_FUNC, NOT_ALL_FUNC, NOW_FUNC, VAR_VALUE_FUNC
	};

if $item->getType() eq "SUM_FUNC_ITEM", $item->getFuncType() can be any of the aggregate functions listed
in enum Sumfunctype in sql/item_sum.h:

	enum Sumfunctype { COUNT_FUNC,COUNT_DISTINCT_FUNC,SUM_FUNC,AVG_FUNC,MIN_FUNC,
		MAX_FUNC, UNIQUE_USERS_FUNC,STD_FUNC,VARIANCE_FUNC,SUM_BIT_FUNC,
		UDF_SUM_FUNC, GROUP_CONCAT_FUNC
	};

For MySQL, all functions not specifically listed above are UNKNOWN_FUNC and you must call getFuncName().

=item my $func_name = $item->getFuncName();

Returns the name of the function called, such as "concat_ws", "md5", etc. If $item is not a function,
but an operator, the symbol of the operator is returned, such as "+", "||", etc. The name of the function
will be lowercase regardless of the orginal case in the SQL string.

=item my $arguments_ref = $item->getArguments();

Returns a reference to an array containing all the arguments to the function/operator. Each item from
the array is also an DBIx::MyParse::Item object, even if it is a simple string or a field name.

=item my $database_name = $item->getDatabaseName();

if $item is FIELD_ITEM, REF_ITEM or a TABLE_ITEM, getDatabaseName() returns the database the field belongs to,
if it was explicitly specified. If it was not specified explicitly, such as was given previously with a
"USE DATABASE" command, getDatabaseName() will return undef. This may change in the future if we
incorporate some more of MySQL's logic

=item my $table_name = $item->getTableName();

Returns the name of the table for a FIELD_ITEM or TABLE_ITEM object. For FIELD_ITEM, the table name must be
explicitly specified with "table_name.field_name" notation. Otherwise returns undef and does not attempt to
guess the name of the table.

=item my $field_name = $item->getTableName();

Returns the name of the field for a FIELD_ITEM object.

=item my $value = $item->getValue();

Returns, as string, the value of STRING_ITEM, INT_ITEM, REAL_ITEM and VARBIN_ITEM objects. 

=item my $direction = $item->getOrderDir();
=item my $direction = $item->getGroupDir();

For an FIELD_ITEM used in GROUP BY or ORDER BY, those two identical functions return either the string
"ASC" or the string "DESC" depending on the group/ordering direction. Default is "ASC" and will be
returned even if the query does not specify a direction.

=item my $alias = $item->getAlias();

Returns the name of the Item if provided with an AS clause, such as SELECT field AS alias.

=cut

