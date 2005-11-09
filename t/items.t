# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl items.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 16;
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
# MySQL variables are not supported yet
#

my $items_query = $parser->parse("
	SELECT
		123,
		1.25,
		NULL,
		0x4D7953514C
");

ok(ref($items_query) eq 'DBIx::MyParse::Query', 'items_query1');

my $select_items = $items_query->getSelectItems();  
ok(ref($select_items) eq 'ARRAY', 'items_query2');

my $int_item = $select_items->[0];

ok(ref($int_item) eq 'DBIx::MyParse::Item' ,'int_item1');
ok($int_item->getType() eq 'INT_ITEM', 'int_item2');
ok($int_item->getValue() == 123, 'int_item3');

my $real_item = $select_items->[1];

ok(ref($real_item) eq 'DBIx::MyParse::Item', 'real_item1');
ok($real_item->getType() eq 'REAL_ITEM' || $real_item->getType() eq 'DECIMAL_ITEM', 'real_item2');
ok(abs($real_item->getValue() - 1.25) < 0.001, 'real_item3');

my $null_item = $select_items->[2];
ok(ref($null_item) eq 'DBIx::MyParse::Item', 'null_item1');
ok($null_item->getType() eq 'NULL_ITEM', 'null_item2');

my $hex_item = $select_items->[3];
ok(ref($hex_item) eq 'DBIx::MyParse::Item','hex_item1');
ok($hex_item->getValue() eq 'MySQL', 'hex_item2');
