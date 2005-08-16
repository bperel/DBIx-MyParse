package DBIx::MyParse::Query;

use strict;
use warnings;

#
# If you change those constants, do not forget to change
# the corresponding C #defines in my_parse.h
#

use constant MYPARSE_COMMAND		=> 0;
use constant MYPARSE_OPTIONS		=> 1;
use constant MYPARSE_SELECT_ITEMS	=> 2;
use constant MYPARSE_INSERT_FIELDS	=> 3;
use constant MYPARSE_UPDATE_FIELDS	=> 4;
use constant MYPARSE_INSERT_VALUES	=> 5;
use constant MYPARSE_UPDATE_VALUES	=> 6;

use constant MYPARSE_TABLES		=> 7;
use constant MYPARSE_ORDER		=> 8;
use constant MYPARSE_GROUP		=> 9;
use constant MYPARSE_WHERE		=> 10;
use constant MYPARSE_HAVING		=> 11;
use constant MYPARSE_LIMIT		=> 12;
use constant MYPARSE_ERROR		=> 13;
use constant MYPARSE_ERRNO		=> 14;
use constant MYPARSE_ERRSTR		=> 15;
use constant MYPARSE_DELETE_TABLES	=> 16;

1;



sub getCommand {
	return $_[0]->[MYPARSE_COMMAND];
}

sub getOptions {
	return $_[0]->[MYPARSE_OPTIONS];
}

sub getSelectItems {
	return $_[0]->[MYPARSE_SELECT_ITEMS];
}

sub getInsertFields {
	return $_[0]->[MYPARSE_INSERT_FIELDS];
}

sub getInsertValues {
	return $_[0]->[MYPARSE_INSERT_VALUES];
}

sub getUpdateFields {
	return $_[0]->[MYPARSE_UPDATE_FIELDS];
}

sub getUpdateValues {
	return $_[0]->[MYPARSE_UPDATE_VALUES];
}

sub getTables {
	return $_[0]->[MYPARSE_TABLES];
}

sub getDeleteTables {
	return $_[0]->[MYPARSE_DELETE_TABLES];
}

sub getOrder {
	return $_[0]->[MYPARSE_ORDER];
}

sub getGroup {
	return $_[0]->[MYPARSE_GROUP];
}

sub getWhere {
	return $_[0]->[MYPARSE_WHERE];
}

sub getHaving {
	return $_[0]->[MYPARSE_HAVING];
}

sub getLimit {
	return $_[0]->[MYPARSE_LIMIT];
};

sub getError {
	return $_[0]->[MYPARSE_ERROR];
}

sub getErrno {
	return $_[0]->[MYPARSE_ERRNO];
}

sub getErrstr {
	return $_[0]->[MYPARSE_ERRSTR];
}

1;

__END__

=head1 NAME

DBIx::MyParse::Query - Access the parse tree produced by DBIx::MyParse

=head1 SYNOPSIS

        use DBIx::MyParse;
        my $parser = DBIx::MyParse->new();
        my $query = $parser->parse("SELECT 1");
        print $query->getCommand();

=head1 DESCRIPTION

This module attempts to provide structured access to the parse tree
that is produced by MySQL's SQL parser. Since the parser itself is not
exactly perfectly structured, please make sure you read this entire
document before attempting to make sense of DBIx::MyParse::Query objects.

=head1 METHODS

=over

=item my $command = $query->getCommand();

Returns, as string, the name of SQL command that was parsed. All possible values
can be found in enum enum_sql_command in sql/sql_lex.h from the MySQL source.

The commands that are currently supported (that is, a parse tree is created for them) are as follows:

	"SQLCOM_SELECT",
	"SQLCOM_INSERT",	"SQLCOM_INSERT_SELECT"
	"SQLCOM_REPLACE",	"SQLCOM_REPLACE_SELECT"
	"SQLCOM_UPDATE",	"SQLCOM_UPDATE_MULTI"
	"SQLCOM_DELETE",	"SQLCOM_DELETE_MULTI"

Please note that the returned value is a string, and not an integer. Please read the section COMMANDS below for notes on individual commands

=item my $options_ref = $query->getOptions()

Returns a reference to an array containing, as strings, the various options specified for the query, such as
HIGH_PRIORITY, LOW_PRIORITY, DELAYED, IGNORE and the like. Some of the options are not returned with the names
you expect, but rather using their internal MySQL names. [[FIXME]]

=head1 ERROR HANDLING

If there has been a parse error, $query->getCommand() eq "SQLCOM_ERROR". From there on, you can:

Call $query->getError() to obtain the string error code, in English, as defined in include/mysql_error.h. Or,
call $query->getErrno() to obtain the integer error code, as defined in the same file or,
call $query->getErrstr() to obtain the entire error message, in the native language of the MySQL installation
(which is the one the mysql client would print on error).

Since we currently only do parsing and no access checks or check if the referenced tables and fields exist, etc.
getError() will most likely always return "ER_PARSE_ERROR" as string.

=head1 COMMANDS

=over

=item SQLCOM_SELECT

By calling $query->getSelectItems() you obtain a reference to the array of the items SELECT will return, each being a
DBIx::MyParse::Item object.

$query->getTables() returns a reference to the array of tables specified in the query. Each table is also an Item object of type
TABLE_ITEM which carries in it information on the Join type, join conditions, indexes, etc. See DBIx::MyParse::Item
for information on how to extract the individual properties.

$query->getWhere() returns an Item object that is the root of the tree containing the WHERE conditions.
$query->getHaving() operates the same way but for the HAVING clause.

$query->getGroup() returns a reference to an array containing an Item object for each GROUP BY condition.
$query->getOrder() returns a reference to an array containing the individual Items from the ORDER BY clause.
$query->getLimit() returns a reference to a two-item array containing the two integers from the LIMIT clause.

=item SQLCOM_UPDATE and SQLCOM_UPDATE_MULTI

getUpdateFields() returns a reference to an array containing the fields that the query would update.
getUpdateValues() retunrs a reference to an array containing the values that will be assigned to those fields.

getTables(), getWhere(), getOrderBy() and getLimit() and getOptions() can also be used.

getTables() will return a reference to a one-item array for SQLCOM_UPDATE. Multiple-item array will be returned
for SQLCOM_UPDATE_MULTI, since multiple tables will be involved.

=item SQLCOM_DELETE and SQLCOM_DELETE_MULTI

For a single-table delete, getCommand() eq "SQLCOM_DELETE" and getDeleteTables() will return a reference to an
one-item array containing the table we are deleting from. getWhere(), getOrder() and getLimit() can also be used.

For a multiple-table delete, getDeleteTables() will return the tables things will be delete from, whereas getTables()
will return the tables listed in the FROM clause, which are used to provide referential integrity. getWhere() can also be used.

=item SQLCOM_INSERT, SQLCOM_INSERT_SELECT, SQLCOM_REPLACE and SQLCOM_REPLACE_SELECT

getInsertFields() will return a list of the fields you are inserting to. For SQLCOM_INSERT and SQLCOM_REPLACE,
getInsertValues() will return a reference to an array, containing one sub-array for each row being inserted or
replaced (even if there is only one row).

For SQLCOM_INSERT_SELECT and SQLCOM_REPLACE_SELECT, getSelectItems(), getTables(), getWhere() and the other SELECT-related properties will describe
the SELECT query used to provide values for the INSERT.

If ON DUPLICATE KEY UPDATE is also specified, then getUpdateFields() and getUpdateValues() can be used.

=cut


