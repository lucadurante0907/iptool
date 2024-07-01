/* lang. y */

%code top {
#line 4 "lang.y"

#ifndef __LANG_Y
#define __LANG_Y

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "memstat.h"
#include "parse_tree.h"


#define EMPTY_SET(S) do { (S).n = 0; (S).items = NULL; } while(0)

#define ADD_1st( S, O, T ) do { \
          (S).n = 1; \
          (S).items = msRealloc( NULL, sizeof( T ) * (S).n, __FILE__, __LINE__ ); \
          (S).items[(S).n - 1] = (O); \
        } while(0)

#define ADD_Nth( S, O, T ) do { \
          (S).n++; \
          (S).items = msRealloc( (S).items, sizeof( T ) * (S).n, __FILE__, __LINE__ ); \
          (S).items[(S).n - 1] = (O); \
        } while(0)

#define DUP_TOKEN( DST_P_TOK, SRC_TOK ) do { \
          (DST_P_TOK) = (tok_descr *)msCalloc( 1, sizeof( tok_descr ), __FILE__, __LINE__ ); \
          *(DST_P_TOK) = (SRC_TOK); \
          (DST_P_TOK)->text = myStrdup( (SRC_TOK).text, strlen( (SRC_TOK).text )); \
        } while(0)

extern int yylex( void );

extern int yyerror( const char * );

extern char *yytext;

extern int yylineno;

char **MySymTab;
unsigned int MySymTabLen;

TABLE_SET c;

/* ================= IMPORTANT NOTE =========================================*/
/*                                                                           */
/* the field text of object <tok> returned by yylex is not a copy of the     */
/* token stored in yylex  ("yytext"), but IS that token, thus, if needed, it */
/* must be duplicated as soon as yylex gives it, since after further one or  */
/* more calls, that object will be overwritten by yylex.                     */
/* For this reason we introduced non terminal "id" to duplicate the name of  */
/* identifiers. In fact, in rule "ict_object", if we have "IDENTIFIER"       */
/* instead of "id", when access is made to "$2.text", that field is no more  */
/* valid since "yytext" has been modified many times.                        */
/*                                                                           */
/* If the above is too hard to handle, in file "spi.flex", each instruction  */
/* "yylval.tok.text = string" must be changed in                             */
/* "yylval.tok.text = myStrdup( string, strlen(string))". This approach is   */
/* "cleaner" than the above, but causes a little more waste of dynamic memory*/

}

%union  {
  tok_descr            tok;
  STRING               string;
  unsigned int        *ip;
  int                  num;
  int                  tok_id;
  ADDR                 addr;
  ADDR_SET             addr_set;
  PROTOCOL             protocol;
  ADDR_INTERVAL        addr_interval;
  PORT_INTERVAL        port_interval;
  TO_SRC_DST_ADDR      to_src_dst_addr;
  MARK_VAL             mark;
  EXT_TARGET           ext_target;
  S_R_MARK_OPTION      s_r_mark_option;
  CONNMARK_OPTION      connmark_option;
  TARGET               target;
  STRING_SET           string_set;
  PORT_INTERVAL_SET    port_interval_set;
  ICMP_TYPE_S          icmp_type;
  UDP_MATCH            udp_match;
  UDP_MATCH_SET        udp_match_set;
  TCP_MATCH            tcp_match;
  TCP_MATCH_SET        tcp_match_set;
  STATE_MATCH          state_match;
  STATE_MATCH_SET      state_match_set;
  MULTIPORT_MATCH      multiport_match;
  MULTIPORT_MATCH_SET  multiport_match_set;
  MARK_MATCH           mark_match;
  MARK_MATCH_SET       mark_match_set;
  IPRANGE_MATCH        iprange_match;
  IPRANGE_MATCH_SET    iprange_match_set;
  ICMP_MATCH           icmp_match;
  ICMP_MATCH_SET       icmp_match_set;
  CONNTRACK_MATCH      conntrack_match;
  CONNTRACK_MATCH_SET  conntrack_match_set;
  MATCH_MODULE         match_module;
  MATCH_W_MODULE       match_w_module;
  PARAMETER            parameter;
  MATCH                match;
  MATCH_SET            match_set;
  RULE_SPEC            rule_spec;
  ZERO_COUNTER_S       zero_counter;
  CLEAR_EMPTY_S        clear_empty;
  REPLACE_S            replace;
  POLICY_SET_S         policy_set;
  NEW_S                new;
  INSERT               insert;
  FLUSH_S              flush;
  RENAME               rename;
  DELETE               delete;
  ADD                  add;
  RULE                 rule;
  RULE_SET             rule_set;
  COUNTERS *           counters;
  CHAIN_DEF            chain_def;
  CHAIN_DEF_SET        chain_def_set;
  TABLE                table;
  TABLE_SET            table_set;
}


        /* terminals */
%token <tok>                   '!'
%token <tok>                   '['
%token <tok>                   ']'
%token <tok>                   ':'
%token <tok>                   '*'
%token <tok>                   '-'
%token <tok>                   INTEGER  
%token <tok>                   IDENTIFIER
%token <tok>                   IP_ADDRESS
%token <tok>                   MAC_ADDRESS
%token <tok>                   HEX
%token <tok>                   EXT_IDENTIFIER
%token <tok>                   TLD_IDENTIFIER
%token <tok>                   NET_IDENTIFIER

        /* table names */
%token <tok>                   filter
%token <tok>                   mangle
%token <tok>                   nat
%token <tok>                   raw
%token <tok>                   security


        /*  table closing keyword */
%token <tok>                   COMMIT


        /* bultin chains */
%token <tok>                   INPUT      
%token <tok>                   FORWARD
%token <tok>                   OUTPUT
%token <tok>                   PREROUTING
%token <tok>                   POSTROUTING


        /* rule commands */
%token <tok>                   APPEND               "-A"
%token <tok>                   DEL                  "-D"
%token <tok>                   REN                  "-E"
%token <tok>                   FLUSH                "-F"
%token <tok>                   INS                  "-I"
%token <tok>                   NEW_CHAIN            "-N"
%token <tok>                   POLICY_SET           "-P"
%token <tok>                   REPLACE              "-R"
%token <tok>                   CLEAR_EMPTY          "-X"
%token <tok>                   ZERO_COUNTER         "-Z"


        /* parameter options */
%token <tok>                   PROTOCOL_OPT         "-p"
%token <tok>                   SOURCE_OPT           "-s"
%token <tok>                   DESTINATION_OPT      "-d"
%token <tok>                   IN_INTERFACE_OPT     "-i"
%token <tok>                   OUT_INTERFACE_OPT    "-o"
%token <tok>                   FRAGMENT_OPT         "-f"
%token <tok>                   SET_COUNT_OPT        "-c"


        /* protocol names - except tcp udp - see below */
%token <tok>                   udplite
%token <tok>                   esp
%token <tok>                   sctp
%token <tok>                   ah
%token <tok>                   mh
%token <tok>                   all


        /* general module options */
%token <tok>                   MODULE               "-m"


        /* module names */
%token <tok>                   conntrack
%token <tok>                   connmark
%token <tok>                   icmp
%token <tok>                   iprange
%token <tok>                   mark
%token <tok>                   multiport
%token <tok>                   state
%token <tok>                   tcp
%token <tok>                   udp


        /* module connmark options */
%token <tok>                   MARK_OPT             "--mark"


        /* module conntrack options */
%token <tok>                   CTSTATE              "--ctstate"
%token <tok>                   CTSTATUS             "--ctstatus"


        /* module conntrack ctstate and module state states*/
%token <tok>                   INVALID
%token <tok>                   NEW
%token <tok>                   ESTABLISHED
%token <tok>                   RELATED
%token <tok>                   UNTRACKED


        /* module conntrack ctstate specific states */
%token <tok>                   DNAT
%token <tok>                   SNAT


        /* module conntrack ctstatus states */
%token <tok>                   NONE
%token <tok>                   EXPECTED
%token <tok>                   SEEN_REPLY
%token <tok>                   ASSURED
%token <tok>                   CONFIRMED


        /* module icmp options */
%token <tok>                   ICMP_TYPE            "--icmp-type"


        /* module iprange oprions */
%token <tok>                   SRC_RANGE            "--src-range"
%token <tok>                   DST_RANGE            "--dst-range"


        /* module mark options except --mark - see above */


        /* module multiport options */
%token <tok>                   SPORTS               "--sports"  
%token <tok>                   DPORTS               "--dports"
%token <tok>                   PORTS                "--ports"


        /* module state options */
%token <tok>                   STATE_OPT            "--state"


        /* module tcp options - also udp options the first four ones*/
%token <tok>                   SPORT                "--sport"   
%token <tok>                   DPORT                "--dport"
%token <tok>                   TCP_FLAGS            "--tcp-flags"
%token <tok>                   SYN_OPT              "--syn"
%token <tok>                   TCP_OPTION           "--tcp-option"


        /* module tcp option tcp-flags values except NONE - see above */
%token <tok>                   SYN
%token <tok>                   ACK
%token <tok>                   FIN
%token <tok>                   RST
%token <tok>                   URG
%token <tok>                   PSH
%token <tok>                   ALL


        /* general target options */
%token <tok>                   ACTION_J             "-j"
%token <tok>                   ACTION_G             "-g"


        /* native target names */
%token <tok>                   ACCEPT
%token <tok>                   DROP
%token <tok>                   RETURN


        /* extended target names - except DNAT and SNAT - see above */
%token <tok>                   CONNMARK
%token <tok>                   MARK
%token <tok>                   MASQUERADE
%token <tok>                   REDIRECT
%token <tok>                   REJECT_SYM           "REJECT"


        /* target CONNMARK options */
%token <tok>                   SET_XMARK            "--set-xmark"
%token <tok>                   SAVE_MARK            "--save-mark"
%token <tok>                   RESTORE_MARK         "--restore-mark"
%token <tok>                   AND_MARK             "--and-mark"
%token <tok>                   OR_MARK              "--or-mark"
%token <tok>                   XOR_MARK             "--xor-mark"
%token <tok>                   SET_MARK             "--set-mark"


        /* target CONNMARK - options --save-mark, --restore-make suboptions */
%token <tok>                   MASK                 "--mask"
%token <tok>                   NFMASK               "--nfmask"
%token <tok>                   CTMASK               "--ctmask"


        /* target DNAT options */
%token <tok>                   TO_DST               "--to-destination"
%token <tok>                   RANDOM               "--random"
%token <tok>                   PERSISTENT           "--persistent"


        /* target MARK options: --set-xmark --set-mark --and-mark --or-mark --xor-mark - see above */


        /* target MASQUERADE options - except --random - see above */
%token <tok>                   TO_PORTS             "--to-ports"
%token <tok>                   RANDOM_FULLY         "--random-fully"


        /* target REJECT options */
%token <tok>                   REJECT_WITH          "--reject-with"


        /* target REJECT types */
%token <tok>                   ICMP_NET_UR          "icmp-net-unreachable"       
%token <tok>                   ICMP_HOST_UR         "icmp-host-unreachable"
%token <tok>                   ICMP_PORT_UR         "icmp-port-unreachable"
%token <tok>                   ICMP_PROTO_UR        "icmp-proto-unreachable"
%token <tok>                   ICMP_NET_PRO         "icmp-net-prohibited"
%token <tok>                   ICMP_HOST_PRO        "icmp-host-prohibited"
%token <tok>                   ICMP_ADM_PRO         "icmp-admin-prohibited"


        /* target SNAT options except --random --random-fully --persistent - see above */
%token <tok>                   TO_SRC               "--to-source"


    /* non terminals i.e. rules */
%type  <ip>                    ip_addr
%type  <string>                id
%type  <string>                ext_id
%type  <string>                net_id
%type  <string>                tld_id
%type  <num>                   int
%type  <num>                   hex
%type  <num>                   int_hex
%type  <string>                reject_type
%type  <string>                sstate
%type  <string>                ctstate
%type  <string>                ctstatus
%type  <string>                table_name
%type  <protocol>              protocol
%type  <string>                builtin_target
%type  <string>                neg
%type  <string>                builtin_chain
%type  <string>                chain_policy
%type  <string>                ext_chain_policy
%type  <string>                tcp_flag

%type  <addr>                  s_d_addr
%type  <addr_set>              s_d_addrs

%type  <addr_interval>         addrs_interval
%type  <port_interval>         ports_interval
%type  <port_interval>         ports_range

%type  <to_src_dst_addr>       to_src_dst_opt
%type  <mark>                  mark_val
%type  <s_r_mark_option>       s_r_mark_option

%type  <ext_target>            ext_target
%type  <ext_target>            connmark_option
%type  <ext_target>            dnat_option
%type  <ext_target>            mark_option
%type  <ext_target>            masquerade_option
%type  <ext_target>            redirect_option
%type  <ext_target>            reject_option
%type  <ext_target>            snat_option
%type  <target>                target
%type  <string>                chain_id
%type  <string_set>            tcp_flags
%type  <port_interval_set>     ports_ranges
%type  <icmp_type>             icmp_type
%type  <string_set>            ctstatus_list
%type  <string_set>            ctstate_list
%type  <string_set>            sstate_list
%type  <udp_match>             udp_match   
%type  <udp_match_set>         udp_matches
%type  <tcp_match>             tcp_match
%type  <tcp_match_set>         tcp_matches
%type  <state_match>           state_match
%type  <state_match_set>       state_matches
%type  <multiport_match>       multiport_match
%type  <multiport_match_set>   multiport_matches
%type  <mark_match>            mark_match
%type  <mark_match_set>        mark_matches
%type  <iprange_match>         iprange_match
%type  <iprange_match_set>     iprange_matches     
%type  <icmp_match>            icmp_match
%type  <icmp_match_set>        icmp_matches
%type  <conntrack_match>       conntrack_match
%type  <conntrack_match_set>   conntrack_matches
%type  <mark_match>            connmark_match
%type  <mark_match_set>        connmark_matches
%type  <match_module>          match_module
%type  <match_w_module>        match_w_module
%type  <parameter>             parameter
%type  <match>                 match
%type  <match_set>             matches
%type  <rule_spec>             rule_spec
%type  <zero_counter>          zero_counter
%type  <clear_empty>           clear_empty
%type  <replace>               replace
%type  <policy_set>            policy_set
%type  <new>                   new
%type  <insert>                insert
%type  <flush>                 flush
%type  <rename>                rename
%type  <delete>                delete
%type  <add>                   add
%type  <rule>                  rule
%type  <counters>              counters
%type  <rule_set>              rules
%type  <chain_def>             chain_def
%type  <chain_def_set>         chain_defs
%type  <table>                 table
%type  <table_set>             tables
%type  <table_set>             configurazione

%left  ','

%start configurazione

%%

configurazione  : {MySymTabLen = YYMAXUTOK+1;
                   MySymTab = msCalloc( MySymTabLen, sizeof(char *), __FILE__, __LINE__ );} 
                  tables {c = $2;}
                ;

tables          : table                                 {ADD_1st( $$, $1, TABLE );}
                | tables table                          {$$ = $1; ADD_Nth( $$, $2, TABLE );}
                ;

table           : '*' table_name chain_defs rules COMMIT {$$.star = $1.text; $$.table_name = $2; $$.chain_defs = $3;
                                                          $$.rules = $4; $$.committ_string = $5.text;}
                ;


chain_defs      : chain_def                             {ADD_1st( $$, $1, RULE );}
                | chain_defs chain_def                  {$$ = $1; ADD_Nth( $$, $2, CHAIN_DEF );}
                | /* forse non ammesso */               {EMPTY_SET($$);}
                ;

rules           : rule                                  {ADD_1st( $$, $1, RULE );}
                | rules rule                            {$$ = $1; ADD_Nth( $$, $2, RULE );}
                | /* forse non ammesso */               {EMPTY_SET($$);}
                ;

chain_def       : ':' chain_id ext_chain_policy counters {$$.colon = $1.text; $$.chain_id = $2; $$.ext_chain_policy = $3; $$.P_counters = $4;}
                ;

chain_id        : builtin_chain                         {$$ = $1;}
                | id                                    {$$ = $1;}
                | tld_id                                {$$ = $1;}
                ;

ext_chain_policy: chain_policy                          {$$ = $1;}
                | '-'                                   {$$ = $1.text;}
                ;

chain_policy    : ACCEPT                                {$$ = $1.text;}
                | DROP                                  {$$ = $1.text;}
                ;

counters        : '[' int ':' int ']'                   {$$ = (COUNTERS *)msCalloc( 1, sizeof(COUNTERS), __FILE__, __LINE__ );
                                                         $$->left_square_bracket = $1.text; $$->num_1 = $2; $$->colon = $3.text;
                                                         $$->num_2 = $4; $$->right_square_bracket = $5.text;}
                |                                       {$$ = NULL;}
                ;

rule            : add                                   {$$.t = ADD_T;          $$.u.add          = $1;}
                | delete                                {$$.t = DELETE_T;       $$.u.delete       = $1;}
                | rename                                {$$.t = RENAME_T;       $$.u.rename       = $1;}
                | flush                                 {$$.t = FLUSH_T;        $$.u.flush        = $1;}
                | insert                                {$$.t = INSERT_T;       $$.u.insert       = $1;}
                | new                                   {$$.t = NEW_T;          $$.u.new          = $1;}
                | policy_set                            {$$.t = POLICY_SET_T;   $$.u.policy_set   = $1;}
                | replace                               {$$.t = REPLACE_T;      $$.u.replace      = $1;}
                | clear_empty                           {$$.t = CLEAR_EMPTY_T;  $$.u.clear_empty  = $1;}
                | zero_counter                          {$$.t = ZERO_COUNTER_T; $$.u.zero_counter = $1;}
                ;

add             : "-A" chain_id rule_spec               {$$.add_string = $1.text; $$.chain_id = $2;
                                                         $$.P_rule_spec = (RULE_SPEC *)msCalloc( 1, sizeof( RULE_SPEC ), __FILE__, __LINE__);
                                                         *($$.P_rule_spec) = $3;}
                ;

delete          : "-D" chain_id /* forse non ammesso */ {$$.delete_string = $1.text; $$.chain_id = $2; $$.num = -1; $$.P_rule_spec = NULL;}
                | "-D" chain_id int                     {$$.delete_string = $1.text; $$.chain_id = $2; $$.num = $3; $$.P_rule_spec = NULL;}
                | "-D" chain_id rule_spec               {$$.delete_string = $1.text; $$.chain_id = $2; $$.num = -1;
                                                         $$.P_rule_spec = (RULE_SPEC *)msCalloc( 1, sizeof( RULE_SPEC ), __FILE__, __LINE__);
                                                         *($$.P_rule_spec) = $3;}
                ;

rename          : "-E" chain_id chain_id                {$$.rename_string = $1.text; $$.chain_id_1 = $2; $$.chain_id_2 = $3;}
                ;

flush           : "-F"                                  {$$.flush_string = $1.text; $$.chain_id = NULL;}
                | "-F" chain_id                         {$$.flush_string = $1.text; $$.chain_id = $2;}
                ;

insert          : "-I" chain_id /* forse non ammesso */ {$$.insert_string = $1.text; $$.chain_id = $2; $$.num = -1; $$.P_rule_spec = NULL;}
                | "-I" chain_id rule_spec               {$$.insert_string = $1.text; $$.chain_id = $2; $$.num = -1;
                                                         $$.P_rule_spec = (RULE_SPEC *)msCalloc( 1, sizeof( RULE_SPEC ), __FILE__, __LINE__);
                                                         *($$.P_rule_spec) = $3 ;}
                | "-I" chain_id int rule_spec           {$$.insert_string = $1.text; $$.chain_id = $2; $$.num = $3;
                                                         $$.P_rule_spec = (RULE_SPEC *)msCalloc( 1, sizeof( RULE_SPEC ), __FILE__, __LINE__);
                                                         *($$.P_rule_spec) = $4;}
                ;

new             : "-N" chain_id                         {$$.new_string = $1.text; $$.chain_id = $2;}
                ;

policy_set      : "-P" builtin_chain chain_policy       {$$.policy_set_string = $1.text; $$.builtin_chain = $2; $$.chain_policy = $3;}
                ;

replace         : "-R" chain_id int rule_spec           {$$.replace_string = $1.text; $$.chain_id = $2; $$.num = $3; $$.rule_spec = $4;}
                ;

clear_empty     : "-X"                                  {$$.clear_empty_string = $1.text; $$.chain_id = NULL;}
                | "-X" chain_id                         {$$.clear_empty_string = $1.text; $$.chain_id = $2;}
                ;

zero_counter    : "-Z"                                  {$$.zero_counter_string = $1.text; $$.chain_id = NULL; $$.num = -1;}
                | "-Z" chain_id                         {$$.zero_counter_string = $1.text; $$.chain_id = $2; $$.num = -1;}
                | "-Z" chain_id int                     {$$.zero_counter_string = $1.text; $$.chain_id = $2; $$.num = $3;}
                ;

rule_spec       : matches                               {$$.matches = $1; $$.P_target = NULL; }
                | matches target                        {$$.matches = $1;
                                                         $$.P_target = (TARGET *)msCalloc( 1, sizeof( TARGET ), __FILE__, __LINE__ );
                                                         *($$.P_target) = $2;}
                ;



matches         : match                                 {ADD_1st( $$, $1, MATCH );}
                | matches match                         {$$ = $1; ADD_Nth( $$, $2, MATCH );}
                | /* forse caso non ammesso */          {EMPTY_SET( $$ );}
                ;

match           : parameter                             {$$.t = PARAMETER_T; $$.u.parameter = $1;}
                | match_w_module                        {$$.t = MATCH_W_MODULE_T; $$.u.match_w_module = $1;}
                ;

/* parameter rules */
parameter       : neg "-p" protocol                     {$$.neg = $1; $$.t = PROTOCOL_T;
                                                         $$.parameter_string = $2.text;
                                                         $$.u.protocol = $3;}
                | neg "-s" s_d_addrs                    {$$.neg = $1; $$.t = S_D_ADDRS_T;
                                                         $$.parameter_string = $2.text;
                                                         $$.u.s_d_addrs = $3;}
                | neg "-d" s_d_addrs                    {$$.neg = $1; $$.t = S_D_ADDRS_T;
                                                         $$.parameter_string = $2.text;
                                                         $$.u.s_d_addrs = $3;}
                | neg "-i" ext_id                       {$$.neg = $1; $$.t = EXT_ID_T;
                                                         $$.parameter_string = $2.text;
                                                         $$.u.ext_id = $3;}
                | neg "-o" ext_id                       {$$.neg = $1; $$.t = EXT_ID_T;
                                                         $$.parameter_string = $2.text;
                                                         $$.u.ext_id = $3;}
                | neg "-f"                              {$$.neg = $1; $$.t = F_ONLY_T;
                                                         $$.parameter_string = $2.text;}
                | "-c" int int                          {$$.neg = NULL; $$.t = TWO_INTS_T;
                                                         $$.u.two_ints.int_1 = $2;
                                                         $$.u.two_ints.int_2 = $2;
                                                         $$.parameter_string = $1.text;}
                ;

s_d_addrs       : s_d_addr                              {ADD_1st( $$, $1, ADDR );}
                | s_d_addrs ',' s_d_addr                {$$ = $1; ADD_Nth( $$, $3, ADDR );}
                ;

            /* vedi commenti alla struct ADDR in parse_tree.h */
s_d_addr        : net_id {$$.a.name = $1; $$.a.ip = NULL; $$.m.ip = NULL; $$.m.val = -1;}
                | ip_addr {$$.a.name = NULL; $$.a.ip = $1; $$.m.ip = NULL; $$.m.val = -1;}
                | ip_addr '/' ip_addr {$$.a.name = NULL; $$.a.ip = $1; $$.m.ip = $3; $$.m.val = -1;}
                | ip_addr '/' int {$$.a.name = NULL; $$.a.ip = $1; $$.m.ip = NULL; $$.m.val = $3;}
                ;

/* match_w_module rules */
match_w_module  : "-m" match_module                     {$$.match_w_module_string = $1.text; $$.match_module = $2;}
                ;

match_module    : connmark connmark_matches             {$$.t = CONNMARK_T; $$.match_module_string = $1.text;
                                                         $$.u.connmark_matches = $2;}
                | conntrack conntrack_matches           {$$.t = CONNTRACK_T; $$.match_module_string = $1.text;
                                                         $$.u.conntrack_matches = $2;}
                | icmp icmp_matches                     {$$.t = ICMP_T; $$.match_module_string = $1.text;
                                                         $$.u.icmp_matches = $2;}
                | iprange iprange_matches               {$$.t = IPRANGE_T; $$.match_module_string = $1.text;
                                                         $$.u.iprange_matches = $2;}
                | mark mark_matches                     {$$.t = MARK_T; $$.match_module_string = $1.text;
                                                         $$.u.mark_matches = $2;}
                | multiport multiport_matches           {$$.t = MULTIPORT_T; $$.match_module_string = $1.text;
                                                         $$.u.multiport_matches = $2;}
                | state state_matches                   {$$.t = STATE_T; $$.match_module_string = $1.text;
                                                         $$.u.state_matches = $2;}
                | tcp tcp_matches                       {$$.t = TCP_T; $$.match_module_string = $1.text;
                                                         $$.u.tcp_matches = $2;}
                | udp udp_matches                       {$$.t = UDP_T; $$.match_module_string = $1.text;
                                                         $$.u.udp_matches = $2;}
                ;
 
connmark_matches: connmark_match                        {ADD_1st( $$, $1, MARK_MATCH );}
                | connmark_matches connmark_match       {$$ = $1; ADD_Nth( $$, $2, MARK_MATCH );}
                ;

connmark_match  : neg "--mark" mark_val                 {$$.neg = $1;
                                                         $$.mark_match_string = $2.text;
                                                         $$.mark_val = $3;}
                ;

conntrack_matches   : conntrack_match                   {ADD_1st( $$, $1, CONNTRACK_MATCH );}
                    | conntrack_matches conntrack_match {$$ = $1; ADD_Nth( $$, $2, CONNTRACK_MATCH );}
                    ;

conntrack_match : neg "--ctstate" ctstate_list          {$$.neg = $1;
                                                         $$.conntrack_match_string = $2.text;
                                                         $$.ctst_list = $3;}
                | neg "--ctstatus" ctstatus_list        {$$.neg = $1;
                                                         $$.conntrack_match_string = $2.text;
                                                         $$.ctst_list = $3;}
                ;

icmp_matches    : icmp_match                            {ADD_1st( $$, $1, ICMP_MATCH );}
                | icmp_matches icmp_match               {$$ = $1; ADD_Nth( $$, $2, ICMP_MATCH );}
                ;
            
icmp_match      : neg "--icmp-type" icmp_type           {$$.neg = $1;
                                                         $$.icmp_match_string = $2.text;
                                                         $$.icmptype = $3;}
                ;

iprange_matches : iprange_match                         {ADD_1st( $$, $1, IPRANGE_MATCH );}
                | iprange_matches iprange_match         {$$ = $1; ADD_Nth( $$, $2, IPRANGE_MATCH );}
                ;

iprange_match   : neg "--src-range" addrs_interval      {$$.neg = $1;
                                                         $$.iprange_match_string = $2.text;
                                                         $$.addr_interval = $3;}
                | neg "--dst-range" addrs_interval      {$$.neg = $1; 
                                                         $$.iprange_match_string = $2.text;
                                                         $$.addr_interval = $3;}
                ;

mark_matches    : mark_match                            {ADD_1st( $$, $1, MARK_MATCH );}
                | mark_matches mark_match               {$$ = $1; ADD_Nth( $$, $2, MARK_MATCH );}
                ;

mark_match      : neg "--mark" mark_val                 {$$.neg = $1;
                                                         $$.mark_match_string = $2.text;
                                                         $$.mark_val = $3;}
                ;

multiport_matches   : multiport_match                   {ADD_1st( $$, $1, MULTIPORT_MATCH );}
                    | multiport_matches multiport_match {$$ = $1; ADD_Nth( $$, $2, MULTIPORT_MATCH );}
                    ;

multiport_match : neg "--sports" ports_ranges           {$$.neg = $1;
                                                         $$.multiport_match_string = $2.text;
                                                         $$.port_interval_set = $3;}
                | neg "--dports" ports_ranges           {$$.neg = $1;
                                                         $$.multiport_match_string = $2.text;
                                                         $$.port_interval_set = $3;}
                | neg "--ports" ports_ranges            {$$.neg = $1;
                                                         $$.multiport_match_string = $2.text;
                                                         $$.port_interval_set = $3;}
                ;

state_matches   : state_match                           {ADD_1st( $$, $1, STATE_MATCH );}
                | state_matches state_match             {$$ = $1; ADD_Nth( $$, $2, STATE_MATCH );}
                ;

state_match     : neg "--state" sstate_list             {$$.neg = $1;
                                                         $$.state_match_string = $2.text;
                                                         $$.sstate_list = $3;}
                ;

tcp_matches     : tcp_match                             {ADD_1st( $$, $1, TCP_MATCH );}
                | tcp_matches tcp_match                 {$$ = $1; ADD_Nth( $$, $2, TCP_MATCH );}
                ;

tcp_match       : neg "--sport" ports_range             {$$.neg = $1;
                                                         $$.tcp_match_string = $2.text;
                                                         $$.t = SPORT_T; $$.u.p = $3;}
                | neg "--dport" ports_range             {$$.neg = $1;
                                                         $$.tcp_match_string = $2.text;
                                                         $$.t = DPORT_T; $$.u.p = $3;}
                | neg "--tcp-flags" tcp_flags tcp_flags {$$.neg = $1;
                                                         $$.tcp_match_string = $2.text;
                                                         $$.t = TCP_FLAGS_T; $$.u.tcp_2fl.tcp_fl1 = $3;
                                                         $$.u.tcp_2fl.tcp_fl2 = $4;}
                | neg "--tcp-option" int                {$$.neg = $1;
                                                         $$.tcp_match_string = $2.text;
                                                         $$.t = SYN_T; $$.u.val = $3;}
                | neg "--syn"                           {$$.neg = $1;
                                                         $$.tcp_match_string = $2.text;}
                ;

udp_matches     : udp_match                             {ADD_1st( $$, $1, UDP_MATCH );}
                | udp_matches udp_match                 {$$ = $1; ADD_Nth( $$, $2, UDP_MATCH );}
                ;

udp_match       : neg "--sport" ports_range             {$$.neg = $1;
                                                         $$.s_d = $2.text; $$.p = $3;}
                | neg "--dport" ports_range             {$$.neg = $1;
                                                         $$.s_d = $2.text; $$.p = $3;}
                ;

mark_val        : hex                                   {$$.val = $1; $$.mask = -1;}
                | hex '/' hex                           {$$.val = $1; $$.mask = $3;}
                ;

ctstate_list    : ctstate                               {ADD_1st( $$, $1, STRING);}
                | ctstate_list ',' ctstate              {$$ = $1; ADD_Nth( $$, $3, STRING);}
                ;

sstate_list     : sstate                                {ADD_1st( $$, $1, STRING);}
                | sstate_list ',' sstate                {$$ = $1; ADD_Nth( $$, $3, STRING);}
                ;

ctstatus_list   : ctstatus                              {ADD_1st( $$, $1, STRING);}
                | ctstatus_list ',' ctstatus            {$$ = $1; ADD_Nth( $$, $3, STRING);}
                ;

icmp_type       : int                                   {$$.t = TYPE_C; $$.u.tc.type = $1; $$.u.tc.code = -1;}
                | int '/' int                           {$$.t = TYPE_C; $$.u.tc.type = $1; $$.u.tc.code = $3;}
                | id                                    {$$.t = TYPE_N; $$.u.tn = $1;}
                ;

ports_ranges    : ports_range                           {ADD_1st( $$, $1, PORT_INTERVAL);}
                | ports_ranges ',' ports_range          {$$ = $1; ADD_Nth( $$, $3, PORT_INTERVAL);}
                ;

ports_range     : int                                   {$$.port_first = $1; $$.port_last = -1;}
                | int ':' int                           {$$.port_first = $1; $$.port_last = $3;}
                ;

tcp_flags       : tcp_flag                              {ADD_1st( $$, $1, STRING);}
                | tcp_flags ',' tcp_flag                {$$ = $1; ADD_Nth( $$, $3, STRING);}
                ;

/* target rules */
target          : "-g" chain_id                         {$$.t = G_C_CHAIN; $$.target_string = $1.text;
                                                         $$.u.chain_string = $2;}
                | "-j" chain_id                         {$$.t = J_C_CHAIN; $$.target_string = $1.text;
                                                         $$.u.chain_string = $2;}
                | "-j" builtin_target                   {$$.t = J_B_CHAIN; $$.target_string = $1.text;
                                                         $$.u.builtin_target_string = $2;}
                | "-j" ext_target                       {$$.t = J_E_TGT; $$.target_string = $1.text;
                                                         $$.u.ext_target = $2;}
                ;

ext_target      : CONNMARK connmark_option              {$$ = $2; $$.ext_target_string = $1.text;}
                | DNAT dnat_option                      {$$ = $2; $$.ext_target_string = $1.text;}
                | MARK mark_option                      {$$ = $2; $$.ext_target_string = $1.text;}
                | MASQUERADE masquerade_option          {$$ = $2; $$.ext_target_string = $1.text;}
                | REDIRECT redirect_option              {$$ = $2; $$.ext_target_string = $1.text;}   
                | "REJECT" reject_option                {$$ = $2; $$.ext_target_string = $1.text;}
                | SNAT snat_option                      {$$ = $2; $$.ext_target_string = $1.text;}
                ;

connmark_option : "--set-xmark" mark_val                {$$.t = CONNMARK_T; $$.ext_target_option_string = $1.text;
                                                         $$.u.connmark.t = MARK_VAL_T;
                                                         $$.u.connmark.u.mark = $2;}
                | "--set-mark" mark_val                 {$$.t = CONNMARK_T; $$.ext_target_option_string = $1.text;
                                                         $$.u.connmark.t = MARK_VAL_T;
                                                         $$.u.connmark.u.mark = $2;}
                | "--and-mark" mark_val                 {$$.t = CONNMARK_T; $$.ext_target_option_string = $1.text;
                                                         $$.u.connmark.t = MARK_VAL_T;
                                                         $$.u.connmark.u.mark = $2;}
                | "--or-mark" mark_val                  {$$.t = CONNMARK_T; $$.ext_target_option_string = $1.text;
                                                         $$.u.connmark.t = MARK_VAL_T;
                                                         $$.u.connmark.u.mark = $2;}
                | "--xor-mark" mark_val                 {$$.t = CONNMARK_T; $$.ext_target_option_string = $1.text;
                                                         $$.u.connmark.t = MARK_VAL_T;
                                                         $$.u.connmark.u.mark = $2;}
                | "--save-mark" s_r_mark_option         {$$.t = CONNMARK_T; $$.ext_target_option_string = $1.text;
                                                         $$.u.connmark.t = S_R_MARK_T;
                                                         $$.u.connmark.u.s_r_mark = $2;}
                | "--restore-mark" s_r_mark_option      {$$.t = CONNMARK_T; $$.ext_target_option_string = $1.text;
                                                         $$.u.connmark.t = S_R_MARK_T;
                                                         $$.u.connmark.u.s_r_mark = $2;}
                ;      

s_r_mark_option : "--mask" int_hex                      {$$.t = MASK_T; $$.u.one.mask_string = $1.text;
                                                         $$.u.one.val = $2;}
                | "--nfmask" int_hex                    {$$.t = NFMASK_T; $$.u.one.mask_string = $1.text;
                                                         $$.u.one.val = $2;}
                | "--ctmask" int_hex                    {$$.t = CTMASK_T; $$.u.one.mask_string = $1.text;
                                                         $$.u.one.val = $2;}
                | "--nfmask" int_hex "--ctmask" int_hex {$$.t = NF_and_CTMASK_T; $$.u.two.nfmask_string = $1.text;
                                                         $$.u.two.nfval = $2; $$.u.two.ctmask_string = $3.text;
                                                          $$.u.two.nfval = $4;}
                | "--ctmask" int_hex "--nfmask" int_hex {$$.t = NF_and_CTMASK_T; $$.u.two.nfmask_string = $3.text;
                                                         $$.u.two.nfval = $4; $$.u.two.ctmask_string = $1.text;
                                                          $$.u.two.nfval = $2;}
                ;

dnat_option     : "--to-destination" to_src_dst_opt     {$$.t = DNAT_T; $$.ext_target_option_string = $1.text;
                                                         $$.u.addr = $2;}
                | "--random"                            {$$.t = DNAT_T; $$.ext_target_option_string = $1.text;}
                | "--persistent"                        {$$.t = DNAT_T; $$.ext_target_option_string = $1.text;}
                ;
            
mark_option     : "--set-xmark" mark_val                {$$.t = MARK_T; $$.ext_target_option_string = $1.text;
                                                         $$.u.mark = $2;}
                | "--set-mark"  mark_val                {$$.t = MARK_T; $$.ext_target_option_string = $1.text;
                                                         $$.u.mark = $2;}
                | "--and-mark"  mark_val                {$$.t = MARK_T; $$.ext_target_option_string = $1.text;
                                                         $$.u.mark = $2;}
                | "--or-mark"   mark_val                {$$.t = MARK_T; $$.ext_target_option_string = $1.text;
                                                         $$.u.mark = $2;}
                | "--xor-mark"  mark_val                {$$.t = MARK_T; $$.ext_target_option_string = $1.text;
                                                         $$.u.mark = $2;}
                ;

masquerade_option: "--to-ports" ports_interval          {$$.t = MASQUERADE_T; $$.ext_target_option_string = $1.text;
                                                         $$.u.port = $2;}
                | "--random"                            {$$.t = MASQUERADE_T; $$.ext_target_option_string = $1.text;}
                | "--random-fully"                      {$$.t = MASQUERADE_T; $$.ext_target_option_string = $1.text;}
                ;
            
redirect_option : "--to-ports" ports_interval           {$$.t = REDIRECT_T; $$.ext_target_option_string = $1.text;
                                                         $$.u.port = $2;}
                | "--random"                            {$$.t = REDIRECT_T; $$.ext_target_option_string = $1.text;}
                ;

reject_option   : "--reject-with" reject_type           {$$.t = REJECT_T; $$.ext_target_option_string = $1.text;
                                                         $$.u.reject_type_string = $2;}
                |                                       {$$.t = REJECT_T; $$.ext_target_option_string = NULL;
                                                         $$.u.reject_type_string = NULL;}
                ;

snat_option     : "--to-source" to_src_dst_opt          {$$.t = SNAT_T; $$.ext_target_option_string = $1.text;
                                                         $$.u.addr = $2;}
                | "--random"                            {$$.t = SNAT_T; $$.ext_target_option_string = $1.text;}
                | "--random-fully"                      {$$.t = SNAT_T; $$.ext_target_option_string = $1.text;}
                | "--persistent"                        {$$.t = SNAT_T; $$.ext_target_option_string = $1.text;}
                ;           

            /* vedi commenti a TO_SRC_DST_ADDR in parse_tree.h    */
to_src_dst_opt  : addrs_interval ':' ports_interval     {$$.ai = $1; $$.pi = $3;}
                ;

            /* vedi commenti a PORT_INTERVAL in parse_tree.h      */
ports_interval  : int                                   {$$.port_first = $1; $$.port_last = -1;}
                | int '-' int                           {$$.port_first = $1; $$.port_last = $3;}
                |                                       {$$.port_first = $$.port_last = -1;}
                ;

            /* vedi commenti a ADDR_INTERVAL in parse_tree.h      */
addrs_interval  : ip_addr                               {$$.ip_first = $1; $$.ip_last = NULL;}
                | ip_addr '-' ip_addr                   {$$.ip_first = $1; $$.ip_last = $3;}
                |                                       {$$.ip_first = $$.ip_last = NULL;}
                ;
                        
neg             : '!'                                   {$$ = $1.text;}
                |                                       {$$ = NULL;}
                ;

builtin_target  : ACCEPT                                {$$ = $1.text;}
                | DROP                                  {$$ = $1.text;}
                | RETURN                                {$$ = $1.text;}
                ;

int_hex         : int               /* default: $$ = $1 */
                | hex
                ;

table_name      : filter                                {$$ = $1.text;}
                | mangle                                {$$ = $1.text;}
                | nat                                   {$$ = $1.text;}
                | raw                                   {$$ = $1.text;}
                | security                              {$$ = $1.text;}
                ;

builtin_chain   : INPUT                                 {$$ = $1.text;}
                | FORWARD                               {$$ = $1.text;}
                | OUTPUT                                {$$ = $1.text;}
                | PREROUTING                            {$$ = $1.text;}
                | POSTROUTING                           {$$ = $1.text;}
                ;

tcp_flag        : SYN                                   {$$ = $1.text;}
                | ACK                                   {$$ = $1.text;}
                | FIN                                   {$$ = $1.text;}
                | RST                                   {$$ = $1.text;}
                | URG                                   {$$ = $1.text;}
                | PSH                                   {$$ = $1.text;}
                | ALL                                   {$$ = $1.text;}
                | NONE                                  {$$ = $1.text;}
                ;

            /* vedi commenti alla struct PROTOCOL in parse_tree.h */
protocol        : tcp                                   {$$.name = $1.text; $$.code = $1.id;}
                | udp                                   {$$.name = $1.text; $$.code = $1.id;}
                | udplite                               {$$.name = $1.text; $$.code = $1.id;}
                | icmp                                  {$$.name = $1.text; $$.code = $1.id;}
                | esp                                   {$$.name = $1.text; $$.code = $1.id;}
                | ah                                    {$$.name = $1.text; $$.code = $1.id;}
                | sctp                                  {$$.name = $1.text; $$.code = $1.id;}
                | mh                                    {$$.name = $1.text; $$.code = $1.id;}
                | all                                   {$$.name = $1.text; $$.code = $1.id;}
                | id                                    {$$.name = $1; $$.code = -1;}
                | int                                   {$$.name = NULL; $$.code = (int)$1;}
                ;

ctstate         : INVALID                               {$$ = $1.text;}
                | NEW                                   {$$ = $1.text;}
                | ESTABLISHED                           {$$ = $1.text;}
                | RELATED                               {$$ = $1.text;}
                | UNTRACKED                             {$$ = $1.text;}
                | DNAT                                  {$$ = $1.text;}
                | SNAT                                  {$$ = $1.text;}
                ;
            
ctstatus        : NONE                                  {$$ = $1.text;}
                | EXPECTED                              {$$ = $1.text;}
                | SEEN_REPLY                            {$$ = $1.text;}
                | ASSURED                               {$$ = $1.text;}
                | CONFIRMED                             {$$ = $1.text;}
                ;

sstate          : INVALID                               {$$ = $1.text;}
                | NEW                                   {$$ = $1.text;}
                | ESTABLISHED                           {$$ = $1.text;}
                | RELATED                               {$$ = $1.text;}
                | UNTRACKED                             {$$ = $1.text;}
                ;

reject_type     : "icmp-net-unreachable"                {$$ = $1.text;}
                | "icmp-host-unreachable"               {$$ = $1.text;}
                | "icmp-port-unreachable"               {$$ = $1.text;}
                | "icmp-proto-unreachable"              {$$ = $1.text;}
                | "icmp-net-prohibited"                 {$$ = $1.text;}
                | "icmp-host-prohibited"                {$$ = $1.text;}
                | "icmp-admin-prohibited"               {$$ = $1.text;}
                ;

ip_addr         : IP_ADDRESS                            {$$ = msCalloc( 4, sizeof(unsigned int), __FILE__, __LINE__);
                                                         sscanf( $1.text, "%u.%u.%u.%u", &($$[0]), &($$[1]), &($$[2]), &($$[3]) );}
                ;

id              : IDENTIFIER                            {$$ = myStrdup( $1.text, $1.leng );}
                ;

tld_id          : TLD_IDENTIFIER                        {$$ = myStrdup( $1.text, $1.leng );}
                ;

ext_id          : IDENTIFIER                            {$$ = myStrdup( $1.text, $1.leng );}
                | EXT_IDENTIFIER                        {$$ = myStrdup( $1.text, $1.leng );}
                ;

net_id          : NET_IDENTIFIER                        {$$ = myStrdup( $1.text, $1.leng );}
                ;

int             : INTEGER                               {sscanf( $1.text, "%u", (unsigned int *)(&$$) );}
                ;

hex             : HEX                                   {sscanf( $1.text, "%x", (unsigned int *)(&$$) );}
                ;
            
%%

/*****      FUNCTIONS   *****/

int yyerror( const char* s ) {
    fprintf( stderr, "%s at line %d:\n", s, line.ln + 1 );
    fprintf( stderr, "%s\n", line.lv[line.ln] );
    exit( 1 );
    return 0;
}

#endif /* __LANG_Y */
