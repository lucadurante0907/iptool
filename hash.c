/* hash.c */

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "memstat.h"
#include "hash.h"

typedef struct hash_t {
  list *T;
  unsigned int m;
} hash_t;

hash crea_nuovo_hash( unsigned int m ) {
  hash h;
  if(( h = msCalloc( 1, sizeof( hash_t ), __FILE__, __LINE__ )) != NULL ) {
    h->m = m;
    if(( h->T = msCalloc( m, sizeof( list ), __FILE__, __LINE__)) != NULL )
      while( m > 0 )
        h->T[--m] = NULL;    
    else {
      msFree( h, __FILE__, __LINE__ );
      h = NULL;
    }
  }
  return h;
}

void distruggi_hash( hash h ) {
  int i;
  for( i = 0; i < h->m; i++ )
    elimina_lista( h->T[i] );
  msFree( h->T, __FILE__, __LINE__ );
  msFree( h, __FILE__, __LINE__ );
  return;
}

unsigned int hash_size( hash h ) {
  return h->m;
}

int hash_f( BASE info, unsigned int m ) {
  char *p;
  unsigned int h = 0, g;
  for( p = info; *p != '\0'; p++ ) {
    h = ( h << 4 ) + (*p);
    if(( g = h & 0xf0000000 )) {
      h = h ^ ( g >> 24 );
      h = h ^ g;
    }
  }
  return h % m;
}

/* NULL: malloc fallita, altrimenti il puntatore alla stringa, sia che ci sia gia' */
/* sia che inserita adesso                                                         */
BASE chained_hash_insert( hash h, BASE info ) {
  BASE ris;
  if(( ris = chained_hash_search( h, info )) == NULL )
    return inserisci_in_lista_ordinata( &(h->T[hash_f(info,h->m)]), info );
  return ris;
}

BASE chained_hash_search( hash h, BASE info ) { /* KEY */
  return cerca_in_lista_ordinata( h->T[hash_f(info,h->m)], info );
}

int chained_hash_delete( hash h, BASE info ) { /* KEY */
  return elimina_da_lista_ordinata( &(h->T[hash_f(info,h->m)]), info );
}

void stampa_hash( hash h ) {
  int i;
  for( i = 0; i < h->m; i++ )
    stampa_lista( h->T[i] );
  return;
}

void conta_hash( hash h ) {
  int i, cs, ct;
  for( ct = 0, i = 0; i < h->m; i++ ) {
    cs = conta_lista( h->T[i] );
    printf( "%4d %4d\n", i, cs );
    ct += cs;
  }
  printf( "TOTALE: %d\n", ct );
  return;
}


