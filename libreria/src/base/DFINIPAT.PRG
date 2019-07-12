//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per PATH
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
#include "dfSet.ch"
#include "dfMsg.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfIniPath() // Array Percorsi per i File di Sistema
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aPath := {}
dfScanIni( "path", {|lMod|dfLoadPath(aPath,lMod)} )
RETURN aPath

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfLoadPath( aPath, lMod )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cStr, cLeft, nPos

DEFAULT lMod TO .F.

IF dfSet( AI_INIMESSAGE )
   dfWaitOn( dfStdMsg(MSG_DFINIPATH01) ) // ON Message
ENDIF

DO WHILE !dfFEof()
   IF dfSet( AI_INIMESSAGE )
      dfWaitStep()           // Step message
   ENDIF
   cStr := AllTrim(dfFRead())
   DO CASE
      CASE !lMod .AND. Left(cStr,1) == "["                  // altra sezione
           EXIT

      OTHERWISE
           cLeft := UPPER(dfLeft(cStr))
           nPos  := 0
           IF lMod
              nPos := ASCAN( aPath, {|aSub|aSub[1]==cLeft} )
           END
           IF nPos == 0
              AADD( aPath, NIL ); nPos := LEN(aPath)
           ENDIF
           aPath[nPos] := { cLeft, dfRight(cStr) }
   ENDCASE
   dfFSkip()
ENDDO

IF dfSet( AI_INIMESSAGE )
   dfWaitOff()               // OFF message
ENDIF

RETURN
