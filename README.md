## DBIx::MyParse version 0.88

This module provides access to the MySQL SQL parser.

### INSTALLATION

A binary RPM built using cpan2rpm on a Fedora Core 6 is available for MySQL 5.0.45 and less from http://www.sf.net/projects/myparse. To compile
the module from scratch please do the following:

* Prepare your MySQL source

 * Download the MySQL source. The MySQL versions from 5.0.45 to 5.0.96 are currently supported. Here are some examples regarding where to fetch the source : [Version 5.0.45](https://dev.mysql.com/get/Downloads/MySQL-5.0/mysql-5.0.45.tar.gz) ; [Version 5.0.96](https://dev.mysql.com/get/Downloads/MySQL-5.0/mysql-5.0.96.tar.gz).
	
 * Un-TGZ it.

 * Clone this repo :
   	* Use the "master" branch of this repo for versions 5.0.77 to 5.0.89 included
   	* Use the "for-mysql-5.0.45_to_5.0.67" branch of this repo for versions 5.0.45 to 5.0.67 included.

 * Apply the patch, using the MySQL version number as patch file name, e.g. for MySQL 5.0.45 :

```
cd /usr/src/your-mysql-source
cat /usr/src/your-myparse-source/patches/mysql-5.0.45.patch | patch -p1
```

 * Configure the MySQL source

```
cd /usr/src/your-mysql-source
./configure --with-embedded-server
make
```

You do NOT need to do "make install". This way, any other MySQL installations that you have will
not be overwritten. You only need to have a populated /usr/local/share/mysql/ directory (containing errmsg.txt).

If you do not have it, do:

```
cd /usr/src/your-mysql-source
cd sql/share
make install
```

* Install DBIx::MyParse

```
perl Makefile.PL /usr/src/your-mysql-source
make install
mkdir /tmp/myparse
mkdir /tmp/myparse/test
make test
```

You will need to create /tmp/myparse and /tmp/myparse/test to run the test suite.

POTENTIAL ISSUES

If you get:

Can't load '/proj/myparse/blib/arch/auto/DBIx/MyParse/MyParse.so'
for module DBIx::MyParse: libz.so.0: cannot open shared object file:
No such file or directory at /usr/lib/perl5/5.8.6/i386-linux-thread-multi/DynaLoader.pm line 230.

, please try:

```
ln -s /usr/local/lib/mysql/libz.so.0.0.0 /usr/lib/libz.so.0
```

if there is no /usr/local/lib/mysql/libz.so.0.0.0, to a "make install" in the zlib directory
of the mysql source.

If you get:

051007 12:11:20 [ERROR] Can't find messagefile '/usr/local/share/mysql/english/errmsg.sys'

please try:

```
cd your-mysql-source/sql/share
make install
```

or do a complete MySQL install to get the same result

If you get:

Unable to initialize libmysqld. at /usr/local/lib/perl5/site_perl/5.8.8/i686-linux/DBIx/MyParse.pm line 83

Please make sure you have the /usr/local/share/mysql/ directory populated, see step A.3. above.

COPYRIGHT AND LICENCE

Copyright (C) 2007 by Philip Stoev <philip@stoev.org>

This library is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public Licence. Please check the 
files GPL and LICENCE for further iformation.
