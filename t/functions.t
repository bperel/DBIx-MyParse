# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl functions.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 4;
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

use Data::Dumper;

#
# CASE
#

my $case = DBIx::MyParse->parse("
	SELECT CASE 3 WHEN 1 THEN 'one' WHEN 2 THEN 'two' ELSE 'more' END;
");

my $soundex = DBIx::MyParse->parse("
	SELECT 'Microsoft' SOUNDS LIKE 'Linix'
");

my $trim = DBIx::MyParse->parse("
	SELECT TRIM(LEADING 'x' FROM 'xxxbarxxx')
");

my $like = DBIx::MyParse->parse("
	SELECT expr LIKE '%test_' ESCAPE '|'
");

my $regexp = DBIx::MyParse->parse("
	SELECT 'a' REGEXP BINARY 'A'
");

my $date_add = DBIx::MyParse->parse("
	SELECT DATE_ADD('1998-01-02', INTERVAL 31 DAY)
");

my $adddate = DBIx::MyParse->parse("
	SELECT ADDDATE('1998-01-02', INTERVAL 31 DAY)
");

my $interval = DBIx::MyParse->parse("
	SELECT '1997-12-31 23:59:59' + INTERVAL 1 SECOND
");

my $extract = DBIx::MyParse->parse("
	SELECT EXTRACT(YEAR_MONTH FROM '1999-07-02 01:02:03');
");

my $get_format = DBIx::MyParse->parse("
	SELECT GET_FORMAT(DATE,'INTERNAL')
");

#
# Mysql 5.0
#
# my $timestampadd = DBIx::MyParse->parse("
# 	SELECT TIMESTAMPADD(MINUTE,1,'2003-01-02')
# ");

my $fulltext1 = DBIx::MyParse->parse("
	SELECT * FROM articles WHERE MATCH (title,body) AGAINST ('database' IN BOOLEAN MODE)
");

my $fulltext2 = DBIx::MyParse->parse("
	SELECT * FROM articles WHERE MATCH (title,body) AGAINST ('database' WITH QUERY EXPANSION)
");

my $binary = DBIx::MyParse->parse("
	SELECT BINARY 'a' = 'A'
");

my $convert = DBIx::MyParse->parse("
	SELECT CONVERT('string' USING latin1)
");

my $cast = DBIx::MyParse->parse("
	SELECT CAST(expr AS SIGNED)
");

my $coercibility = DBIx::MyParse->parse("
	SELECT COERCIBILITY('abc' COLLATE latin1_swedish_ci);
");

#
# 
#

my $round = DBIx::MyParse->parse(" SELECT ROUND(1,2) ");

