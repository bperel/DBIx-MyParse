package DBIx::MyParse;

use strict;
use warnings;

our $VERSION = '0.10';

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
	my $query = $parser->parse("SELECT 1");
	print $query->getCommand();

=head1 DESCRIPTION

This module provides access to MySQL's SQL parser, which is a full-featured
lexx/yacc-based SQL parser, complete with subqueries and various MySQL extensions.

Please check the documentation for DBIx::MyParse::Query to see how you can access
the parse tree produced by parse().

=head1 FEATURES

The following esoteric SQL constructs are supported:

	* Multiple row INSERT
	* INSERT ... SELECT
	* INSERT ... ON DUPLICATE KEY UPDATE
	* Multiple-table DELETE
	* JOINS of any complexity
	* INSERT INTO table SET column = value

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

=head1 PROS AND CONS

=head2 Pros

This is a full-featured SQL parser, not a set of regular expressions that parsing just
the most common queries, which is mostly the case with the other CPAN modules available as of August 2005.
The author believes that even at this early stage in the lifetime of this module, it is far more capable
than all other SQL parsers available on CPAN combined, which is by virtue of the fact that it
uses the MySQL parsing engine to do the dirty work.

This module will accept any input that is a valid MySQL command and will reject any input
that is not a valid MySQL command. Accepting an imput is one thing, producing a complete and
meaningful parse tree is a different thing, however the module currently produces parse trees
of considerable complexity for many common SQL constructs.

MySQL is unlikely to crash on SQL expressions of any complexity, and so is this parser API. In
particular, weird functions, complex nested expressions and operator precedence are all handled
correctly by definition.

Errors are returned as both error numbers, error codes in English and language-specific long
MySQL error messages, rather than as die() or carp().

=head2 Cons

This module is hooked directly to MySQL's internals. Non-MySQL SQL features are not supported
and can not be supported without changing the MySQL source code. Extending MySQL to support new
functionality is far more complicated and rewarding than simply adding a few regexps to your
home-grown SQL parser.

MySQL is GPL, so this module is GPL, please see the COPYRIGHT section below for more information.

=head1 SEE ALSO

Please see the following sources for further information:

MySQL Internals Manual: http://dev.mysql.com/doc/internals/en/index.html

Doxygen documentation for MySQL 4.1 source: http://www.distlab.dk/mysql-4.1/html/

Doxygen documentation for MySQL 5 source: http:://leithal.cool-tools.co.uk/sourcedoc/mysql509/html/index.html

DBIx::MyParse has a page at SourceForge: http://sourceforge.net/projects/myparse/

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
