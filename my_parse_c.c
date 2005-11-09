/*
   DBIx::MyParse - a glue between Perl and MySQL's SQL parser
   Copyright (C) 2005 Philip Stoev

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "my_parse.h"

#include "assert.h"

static void * thd;

void my_parse_die() {
	Perl_die("MySQL fatal error");
}

void * my_parse_get_thd() {
	if (thd == NULL) {
		thd = my_parse_init();
	}
	return thd;
}

void * my_parse_create_array () {

	return newAV();

}

void * my_parse_set_array (
	void * array_ref,
	int index,
	void * item_ref,
	int item_type,
	char * class_name
) {

	AV * array = (AV *) array_ref;

	assert(array);

	assert(SvTYPE(array) == SVt_PVAV);

	assert(item_ref);

	SV * item = NULL;
	unsigned long * item_long;

	switch(item_type) {
		case MYPARSE_ARRAY_LONG:
			item_long = (unsigned long *) item_ref;
			item = newSViv((IV) *item_long);
			break;
		case MYPARSE_ARRAY_STRING:
			item = newSVpv((char *) item_ref, strlen((char *) item_ref));
			break;
		case MYPARSE_ARRAY_REF:
			assert( SvTYPE((SV *) item_ref) == SVt_PVAV );

			item = newRV_noinc((SV*) item_ref);

			if (class_name) {
				sv_bless(item, gv_stashpv(class_name, TRUE));
			}
			break;
		default:
			assert(item_type);
	}

	assert(item);

	if (index == MYPARSE_ARRAY_APPEND) {
		av_push(array, item);
	} else {
		assert(index < 32);
		av_store(array, index, item);
	}

	return item;
}
