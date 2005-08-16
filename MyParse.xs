#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"
#include "my_parse.h"

#include "assert.h"

MODULE = DBIx::MyParse		PACKAGE = DBIx::MyParse

SV *
parse(object, sv_query)
	SV * object
	SV * sv_query
CODE:

	assert(object);
	assert(sv_query);

	char * query = SvPV_nolen(sv_query);

	AV * array = newAV();

	my_parse_inner( (void *) array, query ); 

	SV * array_ref = newRV_noinc((SV*) array);

	assert(array_ref);

	sv_bless(array_ref, gv_stashpv("DBIx::MyParse::Query", TRUE));
	
	RETVAL = array_ref;
OUTPUT:
	RETVAL	
