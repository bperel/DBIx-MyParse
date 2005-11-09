package DBIx::MyParse::Query;

use strict;
use warnings;

our $VERSION = '0.40';

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
document before attempting to make sense of C<DBIx::MyParse::Query> objects.

=head1 METHODS

=over

=item C<< my $string = $query->getCommand(); >>

Returns, as string, the name of SQL command that was parsed. All possible values
can be found in enum enum_sql_command in F<sql/sql_lex.h> from the MySQL source.

The commands that are currently supported (that is, a parse tree is created for them) are as follows:

	"SQLCOM_SELECT",
	"SQLCOM_INSERT",	"SQLCOM_INSERT_SELECT"
	"SQLCOM_REPLACE",	"SQLCOM_REPLACE_SELECT"
	"SQLCOM_UPDATE",	"SQLCOM_UPDATE_MULTI"
	"SQLCOM_DELETE",	"SQLCOM_DELETE_MULTI"

Please note that the returned value is a string, and not an integer. Please read the section
COMMANDS below for notes on individual commands

=item C<< my $string_array_ref = $query->getOptions(); >>

Returns a reference to an array containing, as strings, the various options specified for the query, such as
HIGH_PRIORITY, LOW_PRIORITY, DELAYED, IGNORE and the like. Some of the options are not returned with the names
you expect, but rather using their internal MySQL names. [[FIXME]]

=back

=head1 ERROR HANDLING

If there has been a parse error, C<< $query->getCommand() eq "SQLCOM_ERROR" >>. From there on, you can:

=over

=item C<< my $string = $query->getError() >>

Returns the error code as string, in English, as defined in F<include/mysql_error.h>.

=item C<< my $integer = $query->getErrno() >>

Returns the error code as integer

=item C<< my $string = $query->getErrstr() >>

Returns the entire error message, in the language of the MySQL installation. This is the same text the C<mysql>
client will print for an identical error.

=back

Since we currently only do parsing and no access checks or check if the referenced tables and fields exist, etc.
C<getError()> will most likely always return C<"ER_PARSE_ERROR">.

=head1 COMMANDS

=head2 C<"SQLCOM_SELECT">

=over

=item C<< my $array_ref = $query->getSelectItems() >>

Returns a reference to the array of the items the C<SELECT> query will return, each being a L<Item|DBIx::MyParse::Item> object.

=item C<< my $array_ref = $query->getTables() >>

Rreturns a reference to the array of tables specified in the query. Each table is also an L<Item|DBIx::MyParse::Item>
object for which C<< $item->getType() eq "TABLE_ITEM" >> which contains information on the Join type, join conditions,
indexes, etc. See L<DBIx::MyParse::Item|DBIx::MyParse::Item> for information on how to extract the individual properties.

=item C<< my $item = $query->getWhere() >>

Returns an L<Item|DBIx::MyParse::Item> object that is the root of the tree containing the WHERE conditions.

=item C<< my $item = $query->getHaving() >>

Operates the same way as C<getWhere()> but for the HAVING clause.

=item C<< my $array_ref = $query->getGroup() >>

Returns a reference to an array containing one L<Item|DBIx::MyParse::Item> object for each GROUP BY condition.

=item C<< my $array_ref = $query->getOrder() >>

Returns a reference to an array containing the individual Items from the ORDER BY clause.

=item C<< my $array_ref = $query->getLimit() >>

Returns a reference to a two-item array containing the two parts of the LIMIT clause as DBIx::MyParse::Item objects.

=back

=head2 C<"SQLCOM_UPDATE"> and C<"SQLCOM_UPDATE_MULTI">

=over

=item C<< my $array_ref = $query->getUpdateFields() >>

Returns a reference to an array containing the fields that the query would update.

=item C<< my $array_ref = $query->getUpdateValues() >>

Returns a reference to an array containing the values that will be assigned to the fields being updated.

=back

C<getTables()>, C<getWhere()>, C<getOrder()> and C<getLimit()> can also be used for update queries.

C<getTables()> will return a reference to a one-item array for SQLCOM_UPDATE. Multiple-item array will be returned
for SQLCOM_UPDATE_MULTI, since multiple tables will be involved.

=head2 C<"SQLCOM_DELETE"> and C<"SQLCOM_DELETE_MULTI">

For a single-table delete, C<< $query->getCommand() eq "SQLCOM_DELETE" >>

=over

=item C<< my $array_ref = $query->getDeleteTables() >>

Will return a reference to an array containing the table(s) we are deleting records from.

=item C<< my $array_ref = $query->getTables() >>

For a multiple-table delete, C<getTables()> will return the tables listed in the FROM clause,
which are used to provide referential integrity.

=back

C<getWhere()>, C<getOrder()> and C<getLimit()> can also be used.

=head2 C<"SQLCOM_INSERT">, C<"SQLCOM_INSERT_SELECT">, C<"SQLCOM_REPLACE"> and C<"SQLCOM_REPLACE_SELECT">

=over

=item C<< my $array_ref = $query->getInsertFields() >>

Returns a list of the fields you are inserting to.

=item C<< my $array_ref = $query->getInsertValues() >> 

For C<"SQLCOM_INSERT"> and C<"SQLCOM_REPLACE">, C<getInsertValues()> will return a reference to an array,
containing one sub-array for each row being inserted or replaced (even if there is only one row).

=back

For C<"SQLCOM_INSERT_SELECT"> and C<"SQLCOM_REPLACE_SELECT">, C<getSelectItems()>, C<getTables()>,
C<getWhere()> and the other SELECT-related properties will describe the C<SELECT> query used to provide values for the C<INSERT>.

If C<ON DUPLICATE KEY UPDATE> is also specified, then C<getUpdateFields()> and C<getUpdateValues()> can also be used.

=cut
