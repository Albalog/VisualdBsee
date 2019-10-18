// Impostazioni generiche di libreria
             
#ifndef _LIBAPPS_CH 
   #define _LIBAPPS_CH 


#define S2AI_APPSTYPE                         1    // Tipo di APPS per S2AppsSet/Get
   #define S2AI_APPSTYPE_INI       "i"                  // Testo .INI
   #define S2AI_APPSTYPE_DBF       "d"                  // DBF
   #define S2AI_APPSTYPE_DBFCACHE  "c"                  // DBF con CACHE 

#define S2AI_APPSDBFNAME                      2    // Nome del DBF
#define S2AI_APPSDBFPATH                      3    // Percorso
#define S2AI_APPSDBFRDD                       4    // RDD da utilizzare
#define S2AI_APPSDBFALWAISOPEN                5    // Aperto la prima volta che si utilizza
#define S2AI_APPSDBFUPPER                     6    // Il valore di ritorno viene convertito in maiuscolo

#define S2AI_NUMELEM                          6

/* da abilitare per gerr 4030
#define S2AI_APPSDBFCACHETIMEOUT              7    // Tempo di timeout per DBFCACHE

#define S2AI_NUMELEM                          7
*/


#endif