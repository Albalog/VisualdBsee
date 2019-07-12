//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per PATH
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "COMMON.CH"
#include "dfStd.ch"

// simone 26/3/08
// mantis 0001786: supporto dizionario dati ADS
// abilita gestione dizionario dati ADS
//#define _ENABLE_ADS_DD_

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfArrPath( lReload ) // Array Percorsi per i File di Sistema
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC aPath := NIL
LOCAL  n, cID, cConn

DEFAULT lReload TO .F.

IF aPath == NIL .OR. lReload

#ifdef _ENABLE_ADS_DD_
   IF aPath != NIL
      FOR n := 1 TO LEN(aPath)
         IF dfDACConnIsID(aPath[n][1])
            dfDACConnIDUnregister(aPath[n][1])
         ENDIF
      NEXT
   ENDIF
#endif

   aPath := NIL

   // Reopen the INI
   IF lReload                ; dfIniOpen();  ENDIF

   IF dfIsIni()             // Ho l'INI aperto
      aPath := dfIniPath()     // Leggo i path
   ENDIF
   IF EMPTY aPath ASSIGN dfIntPath() // Prendo i valori interni

#ifdef _ENABLE_ADS_DD_
   FOR n := 1 TO LEN(aPath)
      IF dfDACConnIsID(aPath[n][1])
         cConn := dfDACConnStringGet(@aPath[n][2])
         IF ! EMPTY(cConn)
            dfDACConnIDRegister(aPath[n][1], cConn)
         ENDIF
      ENDIF
   NEXT
#endif
   // Close the INI
   IF lReload .AND. dfIsIni(); dfIniClose(); ENDIF
ENDIF
RETURN aPath