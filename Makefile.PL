use 5.008006;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my $mysql_path;

while (1) {
	print "Please provide the path to your MySQL source tree: ";
	$mysql_path = <STDIN>;
	$mysql_path =~ s{[\r\n]}{};

	if ($mysql_path eq '') {
		$mysql_path = '/usr/src/mysql-4.1.13';
	}

	$mysql_path = $mysql_path.'/';
	my $check_file = $mysql_path."sql/sql_yacc.cc";
	if (-e $check_file) {
		last;
	} else {
		print "File $check_file does not exist: $!. Please try again.\n";
	};
}

WriteMakefile(
    NAME              => 'DBIx::MyParse',
    VERSION_FROM      => 'lib/DBIx/MyParse.pm', # finds $VERSION
 	ABSTRACT_FROM  => 'lib/DBIx/MyParse.pm',
       AUTHOR         => 'Philip Stoev <philip@stoev.org>',
    LIBS              => qq{-L/usr/lib -L/usr/local/lib/mysql -L/usr/lib/mysql -lmysqld -lpthread -lnsl -lc -lrt -lz},
    'INC'               => qq{-I. -I$mysql_path -I$mysql_path/sql -I$mysql_path/include},
    CCFLAGS 	      => '-Wall -g -O3',
    OBJECT	      => 'my_enum.o my_define.o my_parse_c.o my_parse_cc.o MyParse.o',
    LD		      => 'g++',
    CC		      => 'g++',
    depend => {
	'my_parse_cc.cc' => 'my_define.h',
	'my_parse_cc.cc' => 'my_enum.h',
	'my_enum.o' => 'my_enum.c',
	'my_enum.o' => 'my_enum.h',
	'my_define.o' => 'my_define.h',
	'my_define.o' => 'my_define.c',
	'my_enum.h' => "parse_enum.pl
	perl parse_enum.pl $mysql_path
",
	'my_enum_priv.h' => "parse_enum.pl
	perl parse_enum.pl $mysql_path
",
	'my_define.h' => "parse_define.pl
	perl parse_define.pl $mysql_path
",
	'my_define.c' => "parse_define.pl
	perl parse_define.pl $mysql_path
",
	'my_enum.c' => "parse_define.pl
	perl parse_enum.pl $mysql_path
"}
);

