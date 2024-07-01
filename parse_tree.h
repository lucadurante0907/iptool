/* parse_tree.h */

#ifndef __PARSE_TREE_H
#define __PARSE_TREE_H

#include "hash.h"


#define myStrdup( TEXT, TEXTLEN ) \
          strncpy(( char * )msCalloc( (TEXTLEN) + 1, sizeof( char ), __FILE__, __LINE__ ), \
          (TEXT), (TEXTLEN) + 1 )


#define SET_OF_STRUCT(TYPE) \
typedef struct { \
  TYPE *items; \
  int   n; \
} TYPE ## _SET


/* descrittore di token, restituito da yylex */
typedef struct {
  int   id;   /* codice del token                                        */
  char *text; /* stringa corrispondente al token                         */
  int   leng; /* lunghezza del token                                     */
  int	  lnum; /* # di linea del file sorgente di provenienza del token   */
  int	  cnum; /* posizione all'interno della linea                       */
} tok_descr;


extern int yylex( void );

extern int yyerror( const char * );

#if defined (__STEP_1__)
typedef tok_descr *tok_type;
#elif defined (__STEP_2__)
typedef char      *tok_type;
#endif

typedef char *STRING;

/* SOURCE CODE MEMO STRUCTURES */
#if !defined __LANG_FLEX
/* quando includo il file in spi.flex, questa dichiarazione non ha effetto       */
/* struttura di memorizzazione di tutte le linee del codice sorgente. Deve       */
/* essere visibile dalla yyparse in modo che possa invocare yyerror facendole    */
/* stampare la linea incriminata                                                 */
extern struct {
  int	 n;  /* indice primo carattere libero nella linea corrente (la ln - 1)   */
  int	 m;  /* numero massimo di caratteri della linea corrente                 */
  char **lv; /* puntatore al vettore delle linee memorizzate                     */
  int	 ln; /* numero della linea nel file sorgente                             */
  int	 lm; /* numero massimo di linee memorizzabili                            */
} line;
#endif 

extern hash h;
extern char **MySymTab;
extern unsigned int MySymTabLen;


/* qui altre def di tipo per le regole */

typedef enum {
  /* S_R_MARK_OPTION_T */
  MASK_T, NFMASK_T, CTMASK_T, NF_and_CTMASK_T,
  /* CONNMARK_OPTION_T */
  S_R_MARK_T, MARK_VAL_T,
  /* EXT_TARGET_T */
  CONNMARK_T, DNAT_T, MARK_T, MASQUERADE_T, REDIRECT_T, REJECT_T, SNAT_T,
  /* TARGET_T */
  G_C_CHAIN, J_C_CHAIN, J_B_CHAIN, J_E_TGT,
  /* ICMTYPE_T */
  TYPE_C, TYPE_N,
  /* TCP_MATCH_T */
  SPORT_T, DPORT_T, TCP_FLAGS_T, TCP_OPTION_T, SYN_T,
  /* MATCH_MPDULE_T */
  /* CONNMARK_T, */ CONNTRACK_T, ICMP_T, IPRANGE_T, /* MARK_T, */ MULTIPORT_T, 
  STATE_T, TCP_T, UDP_T,
  /* PARAMETER */
  PROTOCOL_T, S_D_ADDRS_T, EXT_ID_T, F_ONLY_T, TWO_INTS_T,
  /* MATCH */
  PARAMETER_T, MATCH_W_MODULE_T,
  /* RULE */
  ADD_T, DELETE_T, RENAME_T, FLUSH_T, INSERT_T, NEW_T, POLICY_SET_T, REPLACE_T, CLEAR_EMPTY_T, ZERO_COUNTER_T
} U_TYPE;

/* addr e addr_set */
/* ADDR può avere due parti 'a' e 'm', o anche solo una delle due. La prima      */
/* può essere un 'ip' o un 'network mame': viene assegnato il dato esistente     */
/* e l'altro va a NULL. Se l'intera 'a' è assente, entrambi i campi sono NULL    */
/* La seconda parte 'm' può essere un 'ip' o un valore intero >= 0, se c'è       */
/* l'ip, allora 'val' è -1, viceversa, 'val' è >=0 e l'ip' è NULL. Se 'm' è      */
/* assente, allora 'ip' è NULL e 'val' è -1                                      */
typedef struct {
  struct {
    unsigned int *ip;
    STRING        name;
  } a;
  struct {
    unsigned int *ip;
    int           val;
  } m;
} ADDR;

SET_OF_STRUCT(ADDR);

/* addr_interval */
/* il secondo ip o entrambi potrebbero non esserci: NULL nel caso                */
typedef struct {
  unsigned int *ip_first;
  unsigned int *ip_last;
} ADDR_INTERVAL;

/* port_interval e port_interval_set */
/* la seconda porta o entrambe potrebbero non esserci: -1 nel caso               */
typedef struct {
  int port_first;
  int port_last;
} PORT_INTERVAL;

SET_OF_STRUCT(PORT_INTERVAL);

/* to_src_dst_addr */
/* vedi commenti alle due sopra                                                  */
typedef struct {
  ADDR_INTERVAL ai;
  PORT_INTERVAL pi;
} TO_SRC_DST_ADDR;

typedef struct {
  int val;
  int mask;
} MARK_VAL;

/* s_r_mark_option */
typedef struct {
    U_TYPE t;
    union {
        struct {
            STRING mask_string;
            int val;
        } one;
        struct {
            STRING nfmask_string;
            int nfval;
            STRING ctmask_string;
            int ctval;
        } two;
    } u;
} S_R_MARK_OPTION;

/* connmark_option */
typedef struct {
  U_TYPE t;
  union {
    S_R_MARK_OPTION s_r_mark;
    MARK_VAL        mark;
  } u;
} CONNMARK_OPTION;

/* ext_target */
typedef struct {
  U_TYPE t;
  STRING ext_target_string;
  STRING ext_target_option_string;
  union {
    STRING          reject_type_string;
    TO_SRC_DST_ADDR addr;
    PORT_INTERVAL   port;
    MARK_VAL        mark;
    CONNMARK_OPTION connmark;
  } u;
} EXT_TARGET;

/* target */
typedef struct {
  U_TYPE t;
  STRING target_string;
  union {
    STRING     chain_string;
    STRING     builtin_target_string;
    EXT_TARGET ext_target;
  } u;
} TARGET;

/* se il protocollo è tra quelli "normati", allora il campo 'code' è il CODE     */
/* del terminale corrispondente, e il nome è il terminale corrispondente         */
/* se il protocollo è identificato da una stringa "non normata", allora          */
/* il campo 'name' è la stringa, e il campo 'code' vale -1                       */
/* se il protocollo è identificato da un intero, allora il campo 'code' è        */
/* il numero intero, mentre il campo 'name' è NULL                               */
typedef struct {
  STRING name;
  int    code;
} PROTOCOL;

/* STRING_SET */
SET_OF_STRUCT(STRING);

/* icmp_type structs */
typedef struct {
  int type;
  int code;
} TYPECODE;

/* icmtype */
typedef struct {
  U_TYPE t;
  union {
    TYPECODE tc;   /* type / code */
    STRING   tn;   /* typename */
  } u;
} ICMP_TYPE_S;

/* udp_match */
typedef struct {
  STRING        neg;
  STRING        s_d;
  PORT_INTERVAL p;
} UDP_MATCH;

SET_OF_STRUCT(UDP_MATCH);

/* tcp_match */
typedef struct {
  STRING neg;
  STRING tcp_match_string; /* definisce quale campo della union valga */
  U_TYPE  t;
  union {
    PORT_INTERVAL p;
    struct {
      STRING_SET tcp_fl1;
      STRING_SET tcp_fl2;
    } tcp_2fl;
    int           val;
  } u;
} TCP_MATCH;

SET_OF_STRUCT(TCP_MATCH);

/* state_match */
typedef struct {
  STRING     neg;
  STRING     state_match_string;
  STRING_SET sstate_list;
} STATE_MATCH;

SET_OF_STRUCT(STATE_MATCH);

/* multiport_match */
typedef struct {
  STRING            neg;
  STRING            multiport_match_string;
  PORT_INTERVAL_SET port_interval_set;
} MULTIPORT_MATCH;

SET_OF_STRUCT(MULTIPORT_MATCH);

/* mark_match */
typedef struct {
  STRING   neg;
  STRING   mark_match_string;
  MARK_VAL mark_val;
} MARK_MATCH;

SET_OF_STRUCT(MARK_MATCH);

/* iprange_match */
typedef struct {
  STRING        neg;
  STRING        iprange_match_string;
  ADDR_INTERVAL addr_interval;
} IPRANGE_MATCH;

SET_OF_STRUCT(IPRANGE_MATCH);

/* icmp_match */
typedef struct {
  STRING      neg;
  STRING      icmp_match_string;
  ICMP_TYPE_S icmptype;   
} ICMP_MATCH;

SET_OF_STRUCT(ICMP_MATCH);

/* conntrack_match */
typedef struct {
  STRING     neg;
  STRING     conntrack_match_string;
  STRING_SET ctst_list;
} CONNTRACK_MATCH;

SET_OF_STRUCT(CONNTRACK_MATCH);

/* connmark_match */
/* see mark_match */

/* match_module */
typedef struct {
  U_TYPE t;
  STRING         match_module_string;
  struct {
    MARK_MATCH_SET      connmark_matches;
    CONNTRACK_MATCH_SET conntrack_matches;
    ICMP_MATCH_SET      icmp_matches;
    IPRANGE_MATCH_SET   iprange_matches;
    MARK_MATCH_SET      mark_matches;
    MULTIPORT_MATCH_SET multiport_matches;
    STATE_MATCH_SET     state_matches;
    TCP_MATCH_SET       tcp_matches;
    UDP_MATCH_SET       udp_matches;
  } u;
} MATCH_MODULE;

/* match_w_module */
typedef struct {
  STRING match_w_module_string;
  MATCH_MODULE match_module;
} MATCH_W_MODULE;

/* parameter */
typedef struct {
  U_TYPE t;
  STRING neg;
  STRING parameter_string;
  union {
    PROTOCOL protocol;
    ADDR_SET s_d_addrs;
    STRING ext_id;
    union {
      int int_1;
      int int_2;
    } two_ints;
  } u;
} PARAMETER;

/* match */
typedef struct {
  U_TYPE t;
  union {
    PARAMETER parameter;
    MATCH_W_MODULE match_w_module;
  } u;
} MATCH;

SET_OF_STRUCT(MATCH);

/* rule_spec */
typedef struct {
  MATCH_SET  matches;
  TARGET    *P_target;
} RULE_SPEC;

/* zero_counter */
typedef struct {
  STRING zero_counter_string;
  STRING chain_id;
  int    num;
} ZERO_COUNTER_S;

/* clear_empty */
typedef struct {
  STRING clear_empty_string;
  STRING chain_id;
} CLEAR_EMPTY_S;

/* replace */
typedef struct {
  STRING    replace_string;
  STRING    chain_id;
  int       num;
  RULE_SPEC rule_spec;
} REPLACE_S;

/* policy_set */
typedef struct {
  STRING policy_set_string;
  STRING builtin_chain;
  STRING chain_policy;
} POLICY_SET_S;

/* new */
typedef struct {
  STRING new_string;
  STRING chain_id;
} NEW_S;

/* insert */
typedef struct {
  STRING     insert_string;
  STRING     chain_id;
  int        num;
  RULE_SPEC *P_rule_spec;
} INSERT;

/* flush */
typedef struct {
  STRING flush_string;
  STRING chain_id;
} FLUSH_S;

/* rename */
typedef struct {
  STRING rename_string;
  STRING chain_id_1;
  STRING chain_id_2;
} RENAME;

/* delete */
typedef struct {
  STRING     delete_string;
  STRING     chain_id;
  int        num;
  RULE_SPEC *P_rule_spec;
} DELETE;

/* add */
typedef struct {
  STRING     add_string;
  STRING     chain_id;
  RULE_SPEC *P_rule_spec;
} ADD;

/* rule */
typedef struct {
  U_TYPE t;
  union {
    ADD           add;
    DELETE        delete;
    RENAME        rename;
    FLUSH_S       flush;
    INSERT        insert;
    NEW_S         new;
    POLICY_SET_S  policy_set;
    REPLACE_S     replace;
    CLEAR_EMPTY_S clear_empty;
    ZERO_COUNTER_S zero_counter;
  } u;
} RULE;

SET_OF_STRUCT(RULE);

/* counters */
typedef struct {
  STRING  left_square_bracket;
  int     num_1;
  STRING  colon;
  int     num_2;
  STRING  right_square_bracket;
} COUNTERS;

/* chain_def */
typedef struct {
  STRING    colon;
  STRING    chain_id;
  STRING    ext_chain_policy;
  COUNTERS *P_counters;
} CHAIN_DEF;

SET_OF_STRUCT(CHAIN_DEF);

/* table */
typedef struct {
  STRING star;
  STRING table_name;
  CHAIN_DEF_SET chain_defs;
  RULE_SET rules;
  STRING committ_string;
} TABLE;

SET_OF_STRUCT( TABLE );

extern TABLE_SET c;

#endif /* __PARSE_TREE_H */
