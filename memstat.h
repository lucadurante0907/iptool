/* memstat.h */

#ifndef __MEMSTAT_H
#define __MEMSTAT_H

#include <stdlib.h>

#if defined MEMSTAT

extern void *msCalloc( size_t nobj, size_t size, char *fname, int lnum );
extern void msFree( void *p, char *fname, int lnum );
extern void *msRealloc( void *ptr, size_t size, char *fname, int lnum );
extern void fondi( void );

#elif defined MEMERROR

#include <stdio.h>

extern void *__p;
#define msCalloc(A,B,F,L) (((__p=calloc((A),(B)))==NULL && (B)>0)?(void *)(perror("msCalloc"),exit(-1),NULL):__p)
#define msFree(P,F,L) free(P)
#define msRealloc(P,B,F,L) (((__p=realloc((P),(B)))==NULL && (B)>0)?(void *)(perror("msRealloc"),exit(-1),NULL):__p)

#else

#define msCalloc(A,B,F,L) calloc((A),(B))
#define msFree(P,F,L) free(P)
#define msRealloc(P,B,F,L) realloc((P),(B))

#endif /* MEMSTAT MEMERROR */

#endif /* __MEMSTAT_H */
