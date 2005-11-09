# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl vars.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 5;
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

my $vars_query = $parser->parse('SELECT @a := 20');

ok(ref($vars_query) eq 'DBIx::MyParse::Query', 'vars_query1');

my $vars_query2 = $parser->parse('SELECT @a');

use Data::Dumper;
print Dumper $vars_query2;
