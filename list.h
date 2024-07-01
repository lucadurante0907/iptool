/* list.h */

#ifndef __LIST_H
#define __LIST_H

typedef char *BASE;
typedef struct list_elem_t *list;

list crea_nuova_lista( void );
BASE cerca_in_lista_ordinata( list testa, BASE info );
int elimina_da_lista_ordinata( list *P_testa, BASE info );
BASE inserisci_in_lista_ordinata( list *P_testa, BASE info );
void elimina_lista( list testa );
int conta_lista( list testa );
void stampa_lista( list testa );
void stampa_elem( list t );

#endif
