# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl MyParse.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 34;
BEGIN {
	use_ok('DBIx::MyParse');
	use_ok('DBIx::MyParse::Query');
	use_ok('DBIx::MyParse::Item')
};

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $parser = DBIx::MyParse->new();

ok(ref($parser) eq 'DBIx::MyParse', 'new_parser');

#
# INSERT tests
#

my $insert_query = DBIx::MyParse->parse("
	INSERT INTO database_name.table_name (field_name) VALUES ('value1')
");

ok(ref($insert_query) eq 'DBIx::MyParse::Query', 'new_insert');

my $tables = $insert_query->getTables();
ok(ref($tables) eq 'ARRAY', 'insert_tables1');
ok(scalar(@{$tables}) == 1, 'insert_tables2');
my $table = $tables->[0];
ok(ref($table) eq 'DBIx::MyParse::Item', 'insert_table1');
ok($table->getType() eq 'TABLE_ITEM', 'insert_table2');
ok($table->getDatabaseName() eq 'database_name', 'insert_table3');
ok($table->getTableName() eq 'table_name', 'insert_table4');

my $fields = $insert_query->getInsertFields();
ok(ref($fields) eq 'ARRAY', 'insert_fields1');
ok(scalar(@{$fields}) == 1, 'insert_fields2');

my $field = $fields->[0];
ok(ref($field) eq 'DBIx::MyParse::Item', 'insert_field1');
ok($field->getType() eq 'FIELD_ITEM', 'insert_field2');
ok($field->getFieldName() eq 'field_name', 'insert_field3');

my $all_values = $insert_query->getInsertValues();
ok(ref($all_values) eq 'ARRAY', 'insert_all_values1');

my $values = $all_values->[0];
ok(ref($values) eq 'ARRAY', 'insert_values1');

my $value = $values->[0];
ok(ref($value) eq 'DBIx::MyParse::Item', 'insert_value1');
ok($value->getType() eq 'STRING_ITEM', 'insert_value2');
ok($value->getValue() eq 'value1', 'insert_value3');

#
# Multiple-row INSERT
#

my $multiple_insert_query = DBIx::MyParse->parse("
	INSERT INTO database_name.table_name (field_name) VALUES ('value1'),('value2')
");

my $multiple_all_values = $multiple_insert_query->getInsertValues();
my $second_row = $multiple_all_values->[1];
my $second_value = $second_row->[0];
ok($second_value->getValue() eq 'value2', 'insert_multiple');

#
# Alternative-syntax INSERT
#

my $alternative_insert_query = DBIx::MyParse->parse("
	INSERT INTO table_name SET field_name = 'value1'
");

my $alternative_all_values = $alternative_insert_query->getInsertValues();
my $first_row = $alternative_all_values->[0];
my $first_value = $first_row->[0];
ok($first_value->getValue() eq 'value1', 'insert_alternative1');

my $alternative_fields = $alternative_insert_query->getInsertFields();
my $first_field = $alternative_fields->[0];
ok($first_field->getFieldName() eq 'field_name', 'insert_alternative1');

#
# ON DUPLICATE KEY UPDATE 
#

my $duplicate_query = DBIx::MyParse->parse("
	INSERT INTO table_name VALUES (1) ON DUPLICATE KEY UPDATE field = 'value'
");

ok(ref($duplicate_query) eq 'DBIx::MyParse::Query', 'duplicate_insert1');
ok($duplicate_query->getCommand() eq 'SQLCOM_INSERT', 'duplicate_insert2');

my $update_fields = $duplicate_query->getUpdateFields();
my $update_values = $duplicate_query->getUpdateValues();

ok($update_fields->[0]->getFieldName() eq 'field', 'duplicate_insert2');
ok($update_values->[0]->getValue() eq 'value', 'duplicate_insert3');

#
# INSERT ... SELECT ... construction
#

my $insert_select = DBIx::MyParse->parse("
	INSERT INTO first_table SELECT field_name FROM second_table
");

ok(ref($insert_select) eq 'DBIx::MyParse::Query', 'select_insert1');
ok($insert_select->getCommand() eq 'SQLCOM_INSERT_SELECT', 'select_insert2');

my $multiple_tables = $insert_select->getTables();
my $insert_table = $multiple_tables->[0];
my $select_table = $multiple_tables->[1];

ok(ref($insert_table) eq 'DBIx::MyParse::Item', 'select_insert3');
ok(ref($select_table) eq 'DBIx::MyParse::Item', 'select_insert4');
ok($insert_table->getTableName() eq 'first_table', 'select_insert5');
ok($select_table->getTableName() eq 'second_table', 'select_insert6');







