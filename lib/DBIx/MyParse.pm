package DBIx::MyParse;

use strict;
use warnings;

our $VERSION = '0.40';

require XSLoader;
XSLoader::load('DBIx::MyParse', $VERSION);

# Preloaded methods go here.

sub new {
        my $parser = bless ([], shift);
	return $parser;
}

1;


__END__

=head1 NAME

DBIx::MyParse - Perl API for MySQL's SQL Parser

=head1 SYNOPSIS

	use DBIx::MyParse;
	my $parser = DBIx::MyParse->new();
	my $query = $parser->parse("SELECT field FROM table");
	print $query->getCommand();

=head1 DESCRIPTION

This module provides access to MySQL's SQL parser, which is a full-featured
lexx/yacc-based SQL parser, complete with subqueries and various MySQL extensions.

Please check the documentation for L<DBIx::MyParse::Query|DBIx::MyParse::Query> to see how you can access
the parse tree produced by parse(). The parse tree itself consists of L<DBIx::MyParse::Item|DBIx::MyParse::Item> objects.

=head1 FEATURES

The following esoteric SQL constructs are supported:

	* Multiple row INSERT
	* INSERT ... SELECT
	* INSERT ... ON DUPLICATE KEY UPDATE
	* Multiple-table DELETE
	* JOINS of any complexity
	* INSERT INTO table SET column = value
	* ?-style placeholders

The following SQL constructs are not currently supported:

	* Subqueries (they are on the top of the ToDo list)
	* LOAD DATA INFILE
	* SELECT INTO OUTFILE

The following MySQL oddities are not supported yet:

	* FORCE INDEX
	* NATURAL RIGHT [OUTER] JOIN
	* MySQL variables
	* DATE_ADD/DATE_SUB and the like
	* expr LIKE pat ESCAPE 'escape-char'

=head1 ADVANTAGES AND DISADVANTAGES

=head2 ADVANTAGES

This is a full-featured SQL parser, not a set of regular expressions that parsing just
the most common queries. It makes use of a complete parsing grammar taken from a real-life
database, by virtue of the fact that it uses the MySQL parsing engine to do the dirty work.

This module will accept any input that is a valid MySQL command and will reject any input
that is not a valid MySQL command. Accepting an imput is one thing, producing a complete and
meaningful parse tree is a different thing, however the module currently produces parse trees
of considerable complexity for many common SQL constructs.

MySQL is unlikely to crash on SQL expressions of any complexity, and so is this parser API. In
particular, weird functions, complex nested expressions and operator precedence are all handled
correctly by definition.

Errors are returned as both error numbers, error codes in English and language-specific long
MySQL error messages, rather than as C<die()> or C<carp()>.

The module's objects are completely hash-free, which should be considerably faster than a comparable
hash-based implementation.

=head2 DISADVANTAGES

This module is hooked directly to MySQL's internals. Non-MySQL SQL features are not supported
and can not be supported without changing the MySQL source code. Extending MySQL to support new
functionality is far more complicated and rewarding than simply adding a few regexps to your
home-grown SQL parser.

Some of MySQL's code is not friendly towards being (ab)used in the manner employed by this module. There
are object methods declared Private for no obvious reasons.

MySQL is GPL, so this module is GPL, please see the COPYRIGHT section below for more information.

=head1 SEE ALSO

Please see the following sources for further information:

MySQL Internals Manual: L<http://dev.mysql.com/doc/internals/en/index.html>

Doxygen documentation for MySQL 4.1 source: L<http://www.distlab.dk/mysql-4.1/html/>

Doxygen documentation for MySQL 5 source: L<http:://leithal.cool-tools.co.uk/sourcedoc/mysql509/html/index.html>

C<DBIx::MyParse> has a page at SourceForge: L<http://sourceforge.net/projects/myparse/>

=head1 AUTHOR

Philip Stoev E<lt>philip@stoev.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Philip Stoev

This library is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public Licence

Please note that this module links to libmysqld which is distributed under
GPL as well. If you intend to use this module in a commercial product, you are
strongly advised to contact MySQL directly to obtain a commercial licence for 
the MySQL embedded server.

Please see the file named LICENCE for the full text of the GNU General Public Licence

=cut
