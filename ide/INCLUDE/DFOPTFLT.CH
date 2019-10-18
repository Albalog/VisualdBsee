/* +----------------------------------------------------------------------+
   |                                                                      |
   |           2000 - 2006 by Albalog Srl - Florence - Italy              |
   |                                                                      |
   |                          Filter optimizer                            |
   |                                                                      |
   +----------------------------------------------------------------------+ */

#ifndef _DFOPTFLT_CH
   #define _DFOPTFLT_CH

   #translate DFOPTFLTNORM( <x> ) => "-"+<x>+"-"
   #translate DFOPTFLTAT( <x>, <y> ) => AT(DFOPTFLTNORM(<x>), <y>)
   #translate DFOPTFLTASCAN( <y>, <x>) => AT(DFOPTFLTNORM(<x>), <y>)

   #command CREATE FILTER ON <db> TO <x> FOR <exp> [ACCESSVAR <bVar>] OPTIMIZEALIAS <alias,...> => <x> := dfOptFltNew(<(db)>, , <{exp}>, <bVar>);dfOptFltSetAlias(<x>, <alias>)
   #command CREATE FILTER ON <db> TO <x> FOR <exp> [ACCESSVAR <bVar>] USING <list,...> OPTIMIZEALIAS <alias,...> => <x> := dfOptFltNew(<(db)>, , <{exp}>, <bVar>);dfOptFltSetVar(<x>, <"list">); dfOptFltSetVal(<x>, <{list}>);dfOptFltSetAlias(<x>, <alias>)
   #command CREATE FILTER ON <db> TO <x> FOR <exp> [ACCESSVAR <bVar>] => <x> := dfOptFltNew(<(db)>, , <{exp}>, <bVar>)
   #command CREATE FILTER ON <db> TO <x> FOR <exp> [ACCESSVAR <bVar>] USING <list,...> => <x> := dfOptFltNew(<(db)>, , <{exp}>, <bVar>);dfOptFltSetVar(<x>, <"list">); dfOptFltSetVal(<x>, <{list}>)
   #command OPTIMIZE FILTER <x> => dfOptFltOptimize(<x>)

   #define OPTFLT_ALIAS            1   // alias
   #define OPTFLT_STREXP           2   // filtro da ottimizzare come stringa
   #define OPTFLT_CBEXP            3   // filtro da ottimizzare come codeblock
   #define OPTFLT_CBVARACCESS      4   // codeblock accesso var. statiche
   #define OPTFLT_VAR_ARR          5   // array per accesso altre variabili
   #define OPTFLT_STROPTEXP        6   // filtro ottimizzato come stringa
   #define OPTFLT_CBOPTEXP         7   // filtro ottimizzato come codeblock
   #define OPTFLT_ERRNUM           8   // num. errore in ottimizzazione
   #define OPTFLT_ERRMESSAGE       9   // msg. errore in ottimizzazione
   #define OPTFLT_NOTOPTFUNC      10   // array funz. non ottimizzabili
   #define OPTFLT_STRNOTOPTEXP    11   // filtro non ottimizzato come stringa
   #define OPTFLT_CBNOTOPTEXP     12   // filtro non ottimizzato come codeblock
   #define OPTFLT_OPTIMIZEALIAS   13   // elenco alias ottimizzabili
   #define OPTFLT_CARGO           14   // utilizzabile dall'utente

   #define OPTFLT_NUMELEM         14
#endif
