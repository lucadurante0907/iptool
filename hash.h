/* hash.h */

#ifndef __HASH_H
#define __HASH_H

#include "list.h"

typedef struct hash_t *hash;

hash crea_nuovo_hash( unsigned int );
BASE chained_hash_insert( hash, BASE );
BASE chained_hash_search( hash, BASE ); /* KEY */
int chained_hash_delete( hash, BASE ); /* KEY */
void distruggi_hash( hash );
void stampa_hash( hash );
void conta_hash( hash );

#endif

