/* memstat.c */

#if defined MEMSTAT

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <sys/time.h>
#include <inttypes.h>

#define HASH_SIZE 256
#define HASH_ELEM_SIZE 128
#define ATOMIC_TRANSFER 7

#ifdef MEMFILE
#define MEMSTATFILE "memstat.dat"
#endif /* MEMFILE */

typedef struct {
        void               *addr;
        size_t              nobj;
        size_t              size;
        } ms;

static struct {
       unsigned long int n;
       ms               *p;
       } hash[HASH_SIZE];


static unsigned char     first_time = 1;
static unsigned long int memstat_use = 0;

#ifdef MEMFILE
static unsigned long int mem_max = 0;
static unsigned long int mem_act = 0;
static FILE *fp;
#endif /* MEMFILE */


static double read_act_time( void);


static void init_memstat( void ) {
  unsigned int i;

  read_act_time();

  memstat_use += HASH_SIZE * sizeof( hash[0] );

  for( i = 0; i < HASH_SIZE; i++ ) {
    if(( hash[i].p = ( ms * )calloc( HASH_ELEM_SIZE, sizeof( ms ))) == NULL ) {
      fprintf( stderr, "MEMSTAT ERROR 1: exiting program.\n" ); exit(-1);
    }
    hash[i].n = HASH_ELEM_SIZE;
    memstat_use += HASH_ELEM_SIZE * sizeof( ms );
  }
#ifdef MEMFILE
  if(( fp = fopen ( MEMSTATFILE, "w" )) == NULL ) {
     fprintf( stderr, "MEMSTAT ERROR 2: exiting program.\n" ); exit(-1);
  }
#endif /* MEMFILE */
  return;
}


static void resize_hash( unsigned int i ) {

  if(( hash[i].p = ( ms * )realloc( hash[i].p, sizeof( ms ) * hash[i].n * 2 )) == NULL ) {
    fprintf( stderr, "MEMSTAT ERROR 3: exiting program.\n" ); exit(-1);
  }

  memstat_use += hash[i].n * sizeof( ms ); /* raddoppiando il vettore, lo incremento di una */
                                           /* quantita` pari al valore attuale              */
  hash[i].n *= 2;
  return;
}


void *msCalloc( size_t nobj, size_t size, char *fname, int lnum ) {
  void *p = NULL;
  unsigned int k, i;

  if( size == 0 || nobj == 0 ) return NULL;

  if( first_time ) { init_memstat(); first_time = 0; }
  if(( p = calloc( nobj, size )) == NULL ) {
    fprintf( stderr, "ERROR in \"msCalloc\": not enough memory at line %d in file \"%s\"\n", lnum, fname );
    exit(-1);
  }

  k = ( unsigned int )(( ( unsigned long int)p >> ATOMIC_TRANSFER ) & ( HASH_SIZE - 1 ));

  for( i = 0; i < hash[k].n && hash[k].p[i].addr != 0; i++ );

  if( i == hash[k].n ) resize_hash( k );

  hash[k].p[i].addr = p;
  hash[k].p[i].nobj = nobj;
  hash[k].p[i].size = size;
#ifdef MEMFILE
  mem_max = (((mem_act += nobj * size ) > mem_max ) ? mem_act : mem_max );
  fprintf( fp, "%f,%4u,C  0x%" PRIxPTR ",%6lu;%6lu [%s@%d]\n", read_act_time(), k, (uintptr_t)p, mem_act, memstat_use, fname, lnum );
#endif /* MEMFILE */
  
  return p;
}


void msFree( void *p, char *fname, int lnum ) {
  unsigned int k, i;

#ifdef MEMFILE
  uintptr_t u_ptr;
#endif /* MEMFILE */

  if( p == NULL ) return;

  if( first_time ) {
    fprintf( stderr, "ERROR in \"msFree\": unallocated object \"0x%" PRIxPTR "\" at line %d in file \"%s\"\n", (uintptr_t)p, lnum, fname );
    exit( -1 );
  }

  k = ( unsigned int )(( ( unsigned long int)p >> ATOMIC_TRANSFER ) & ( HASH_SIZE - 1 ));

  for( i = 0; i < hash[k].n && hash[k].p[i].addr != p; i++ );

  if( i == hash[k].n ) {
    fprintf( stderr, "ERROR in \"msFree\": unallocated object \"0x%" PRIxPTR "\" at line %d in file \"%s\"\n", (uintptr_t)p, lnum, fname );
    exit( -1 );
  }

#ifdef MEMFILE
  u_ptr = (uintptr_t)p;
#endif /* MEMFILE */

  free( p );

#ifdef MEMFILE
  mem_act -= hash[k].p[i].nobj * hash[k].p[i].size;
  fprintf( fp, "%f,%4u,F  0x%" PRIxPTR ",%6lu;%6lu [%s@%d]\n", read_act_time(), k, u_ptr, mem_act, memstat_use, fname, lnum );
#endif /* MEMFILE */

  hash[k].p[i].addr = 0;
  hash[k].p[i].nobj = hash[k].p[i].size = 0;

  return;
}


void *msRealloc( void *ptr, size_t size, char *fname, int lnum ) {
  void *p = NULL;
  unsigned int ko = 0, io = 0, kn, in;

#ifdef MEMFILE
  uintptr_t u_ptr;
#endif /* MEMFILE */

  if( size == 0 ) {
    msFree( ptr, fname, lnum );
    return NULL;
  }

  if( ptr == NULL && first_time ) { init_memstat(); first_time = 0; }
  else if( first_time )  {
    fprintf( stderr, "ERROR in \"msRealloc\": unallocated object \"0x%" PRIxPTR "\" at line %d in file \"%s\"\n", (uintptr_t)ptr, lnum, fname );
    exit( -1 );
  }

  if( ptr != NULL ) {
    ko = ( unsigned int )(( ( unsigned long int)ptr >> ATOMIC_TRANSFER ) & ( HASH_SIZE - 1 ));

    for( io = 0; io < hash[ko].n && hash[ko].p[io].addr != ptr; io++ );

    if( io == hash[ko].n ) {
      fprintf( stderr, "ERROR in \"msRealloc\": unallocated object \"0x%" PRIxPTR "\" at line %d in file \"%s\"\n", (uintptr_t)ptr, lnum, fname );
      exit( -1 );
    }
  }

#ifdef MEMFILE
  u_ptr = (uintptr_t)ptr;
#endif /* MEMFILE */

  if(( p = realloc( ptr, size )) == NULL ) {
    fprintf( stderr, "ERROR in \"msRealloc\": not enough memory at line %d in file \"%s\"\n", lnum, fname );
    exit( -1 );
  }

  if( p == ptr ) { kn = ko; in = io; }
  else {
    kn = ( unsigned int )(( ( unsigned long int)p >> ATOMIC_TRANSFER ) & ( HASH_SIZE - 1 ));

    for( in = 0; in < hash[kn].n && hash[kn].p[in].addr != 0; in++ );

    if( in == hash[kn].n ) resize_hash( kn );
  }

  if( ptr != NULL ) {
    if( hash[ko].p[io].nobj * hash[ko].p[io].size < size ) {
      memset( (char *)p + hash[ko].p[io].nobj * hash[ko].p[io].size, 0, size - hash[ko].p[io].nobj * hash[ko].p[io].size );
    }
#ifdef MEMFILE
    mem_act -= hash[ko].p[io].nobj * hash[ko].p[io].size;
    fprintf( fp, "%f,%4u,R- 0x%" PRIxPTR ",%6lu;%6lu [%s@%d]\n", read_act_time(), ko, u_ptr, mem_act, memstat_use, fname, lnum );
#endif /* MEMFILE */
    hash[ko].p[io].addr = 0;
    hash[ko].p[io].nobj = hash[ko].p[io].size = 0;
  }
  else {
    memset( p, 0, size );
  }
  hash[kn].p[in].addr = p;
  hash[kn].p[in].nobj = 1;
  hash[kn].p[in].size = size;
#ifdef MEMFILE
  mem_max = (((mem_act += 1 * size ) > mem_max ) ? mem_act : mem_max );
  fprintf( fp, "%f,%4u,R+ 0x%" PRIxPTR ",%6lu;%6lu [%s@%d]\n", read_act_time(), kn, (uintptr_t)p, mem_act, memstat_use, fname, lnum );
#endif /* MEMFILE */
  
  return p;
}


void fondi( void ) {
  unsigned int i, j;
  
  for( i = 0; i < HASH_SIZE; i++ )
    for( j = 0; j < hash[i].n; j++ )
      if( hash[i].p[j].addr != 0 ) 
        fprintf( stderr, "\0070x%" PRIxPTR "   size:%3lu   nobj:%3lu\n", (uintptr_t)(hash[i].p[j].addr), hash[i].p[j].size, hash[i].p[j].nobj );
  return;
}


static double read_act_time( void) {
  struct timeval tmv;
  struct timeval  *tp;
#define __cplusplus
#ifndef __cplusplus
  struct timezone tmz;
  struct timezone  *tzp;
#else /* __cplusplus */
  struct timezone {
         int    tz_minuteswest; /* minutes west of Greenwich */
         int    tz_dsttime;     /* type of dst correction */
         } tmz, *tzp;
#endif /* __cplusplus */
#undef __cplusplus
  static double inittime;
  static int flag = 0;
  double tmp;
  tp = &tmv;
  tzp = &tmz;
  if( flag == 1) {
       gettimeofday(tp,tzp);
       tmp=( (double)(tp->tv_sec) + (double)(tp->tv_usec)/(double)(1000000) - inittime);
  }
  else {
       flag = 1;
       gettimeofday(tp,tzp);
       inittime=( (double)(tp->tv_sec) + (double)(tp->tv_usec)/(double)(1000000) - 0.0);
       tmp=0;
  }
  return tmp;
}

#elif defined MEMERROR

void *__p;

#else

typedef int make_iso_compilers_happy;

#endif /* MEMSTAT MEMERROR */
