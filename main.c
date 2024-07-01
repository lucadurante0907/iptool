
#include <stdio.h>
#include <stdlib.h>
#include "memstat.h"
#include "hash.h"
#include "parse_tree.h"
/* #include <regex.h> */

hash h;



int main(int argc, char **argv) {
 
  extern FILE *yyin;
  extern int yyparse(void);

 /*   Model M; */
 

  if (argc!=2){
    fprintf(stderr, "USAGE: %s <filename>\n", argv[0]);
    return -1;
  }

  yyin = fopen(argv[1], "r");

  if( !yyin ){
    fprintf( stderr, "ERROR: Cannot open input file %s.\n", argv[1] );
    exit( 1 );
  }

  if(( h = crea_nuovo_hash(997)) == NULL ) {
    fprintf( stderr, "ERROR: Hash based symbol table creation failed.\n" );
    exit( 1 );
  }

  /*parsing input*/
  yyparse();

  fclose( yyin );
  
  distruggi_hash( h );

#ifdef MEMSTAT
  fondi();
#endif /* MEMSTAT */

  return EXIT_SUCCESS;
}
