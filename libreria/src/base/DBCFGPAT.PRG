//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Percorsi per i File di Sistema
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"

// simone 26/3/08
// mantis 0001786: supporto dizionario dati ADS
// abilita gestione dizionario dati ADS
#define _ENABLE_ADS_DD_

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dbCfgPath( cFile, cNewPath ) // Percorsi per i File di Sistema
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aPath := dfArrPath()
LOCAL cPath := ""
LOCAL nPath
LOCAL cConn

IF !EMPTY(cFile)
   cFile := UPPER(ALLTRIM(cFile))
   IF (nPath := ASCAN( aPath, {|aSub| aSub[1]==cFile } )) # 0
      cPath := aPath[nPath][2]
      IF cNewPath#NIL
#ifdef _ENABLE_ADS_DD_
         IF dfDACConnIsID(cFile)
            // elimino la connessione precedente
            dfDACConnIDUnregister(cFile)

            cConn := dfDACConnStringGet(@cNewPath)
            IF ! EMPTY(cConn)
               dfDACConnIDRegister(cFile, cConn)
            ENDIF
         ENDIF
#endif
         aPath[nPath][2] := cNewPath
      ENDIF
   ELSE
      IF !EMPTY(cFile) .AND. !EMPTY(cNewPath)

#ifdef _ENABLE_ADS_DD_
         IF dfDACConnIsID(cFile)
           cConn := dfDACConnStringGet(@cNewPath)
           IF ! EMPTY(cConn)
              dfDACConnIDRegister(cFile, cConn)
           ENDIF
         ENDIF
#endif
        AADD(aPath, {cFile, cNewPath})
      ENDIF
   ENDIF
ENDIF

RETURN dfPathChk(cPath)
