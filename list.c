/* list.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "memstat.h"
#include "list.h"

typedef struct list_elem_t {
	BASE	info;
	struct list_elem_t *succ;
} list_elem;


list crea_nuova_lista( void ) {
  return NULL;
}


char *strdup( const char * );

BASE cerca_in_lista_ordinata( list testa, BASE info ) { /* KEY key */
  while( testa != NULL && strcmp( testa->info, info ) < 0 )
    testa = testa->succ;
  if( testa != NULL && strcmp( testa->info, info ) == 0 )
    return testa->info;
  else return NULL;    
}


BASE inserisci_in_lista_ordinata( list *P_testa, BASE info ) {
  list tmp, s = *P_testa, t;
  if(( tmp = msCalloc( 1, sizeof( list_elem ), __FILE__, __LINE__ )) == NULL ) return NULL;
  if(( tmp->info = strdup( info )) == NULL ) return NULL;
  if( s == NULL || strcmp( s->info, info ) > 0 ) {
    tmp->succ = s;
    *P_testa = tmp;
  }
  else {
    for( t = s->succ; t != NULL && strcmp( t->info, info ) < 0; s = t, t = t->succ );
    tmp->succ = t;
    s->succ = tmp;
  }
  return tmp->info;
}


void elimina_lista( list testa ) {
  list tmp;
  while( testa != NULL ) {
    tmp = testa;
    testa = testa->succ;
    msFree( tmp->info, __FILE__, __LINE__ );
    msFree( tmp, __FILE__, __LINE__ );
  }
  return;
}


int conta_lista( list testa ) {
  list tmp;
  int conta;
  for( conta = 0, tmp = testa; tmp != NULL; tmp = tmp->succ, conta++ );
  return conta;
}


void stampa_lista( list testa ) {
  list tmp;
  for( tmp = testa; tmp != NULL; tmp = tmp->succ )
    stampa_elem( tmp );
  printf( "\n" );
  return;
}


void stampa_elem( list t ) {
  printf( "%s\n", t->info );
  return;
}


int elimina_da_lista_ordinata( list *P_testa, BASE info ) {
  list tmp = NULL, s = *P_testa, t;
  if( s != NULL ) {
    if( strcmp( s->info, info ) == 0 ) {
      tmp = s;
      *P_testa = s->succ;
    }
    else {
      for( t = s->succ;
           t != NULL && strcmp( t->info, info ) < 0; s = t, t = t->succ );
      if( t != NULL && strcmp( t->info, info ) == 0 ) {
        tmp = t;
        s->succ = t->succ;
      }
    }
  }
  if( tmp == NULL ) return 0;
  msFree( tmp->info, __FILE__, __LINE__ );
  msFree( tmp, __FILE__, __LINE__ );
  return 1;
	
}


char *strdup( const char *s ) {
  char *t;
  t = msCalloc( strlen( s ) + 1, sizeof( char ), __FILE__, __LINE__ );
  if( t != NULL )
    strcpy( t, s );
  return t;
}

