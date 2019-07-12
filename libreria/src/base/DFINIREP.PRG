//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per ACT
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "common.ch"
#INCLUDE "dfSet.ch"
#INCLUDE "dfMsg.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfIniRep() // Ritorna l'array delle Action letto dall'ini
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aAct := {}
dfScanIni( "report", {|lMod|dfLoadRep(aAct,lMod)} )
RETURN aAct

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfLoadRep( aAct, lMod )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cStr, nPos, cLeft
LOCAL lIniMsg
DEFAULT lMod TO .F.

lIniMsg := dfSet( AI_INIMESSAGE, .F. ) // disabilito messaggi

IF dfSet( AI_INIMESSAGE )
   dfWaitOn( dfStdMsg(MSG_DFINIREP01) ) // ON Message
ENDIF

WHILE !dfFEof()
   IF dfSet( AI_INIMESSAGE )
      dfWaitStep()           // Step message
   ENDIF
   cStr := ALLTRIM(dfFRead())
   DO CASE
      CASE !lMod .AND. LEFT(cStr,1) == "["  // Another section
           EXIT

      OTHERWISE
           cLeft := UPPER(dfLeft(cStr))
           nPos  := 0
           IF lMod
              nPos := ASCAN( aAct, {|aSub|aSub[1]==cLeft} )
           ENDIF
           IF nPos == 0
              AADD( aAct, NIL ); nPos := LEN( aAct )
           ENDIF
           aAct[nPos] := { cLeft, dfRight(cStr,RT_ARRAY) }
   ENDCASE
   dfFSkip()
ENDDO

IF dfSet( AI_INIMESSAGE )
   dfWaitOff()                  // OFF message
ENDIF

dfSet( AI_INIMESSAGE, lIniMsg )


RETURN
