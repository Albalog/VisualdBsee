//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per ACT
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"
#INCLUDE "dfSet.ch"
#INCLUDE "dfMsg.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfIniAct() // Ritorna l'array delle Action letto dall'ini
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aAct := {}
dfScanIni( "Act", {|lMod|dfLoadAct(aAct,lMod)} )
RETURN aAct

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfLoadAct( aAct, lMod )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos, nAct, cRight, cStr

DEFAULT lMod TO .F.

IF dfSet( AI_INIMESSAGE )
   dfWaitOn( dfStdMsg(MSG_DFINI03) ) // ON Message
ENDIF

WHILE !dfFEof()
   IF dfSet( AI_INIMESSAGE )
      dfWaitStep()                   // Step message
   ENDIF
   cStr := ALLTRIM(dfFRead())
   DO CASE
      CASE !lMod .AND. LEFT(cStr,1) == "["       // Another section
           EXIT

      OTHERWISE
           nPos   := 0
           nAct   := VAL(dfLeft(cStr))
           cRight := dfRight(cStr)

           IF lMod
              nPos := ASCAN( aAct, {|aSub|aSub[1]==nAct} )
           ENDIF
           IF nPos==0
              AADD( aAct, NIL ); nPos := LEN( aAct )
           ENDIF

           aAct[nPos] := { nAct                  ,;
                           dfToken(cRight,",",1) ,;
                           dfToken(cRight,",",2)  }
   ENDCASE
   dfFSkip()
ENDDO

IF dfSet( AI_INIMESSAGE )
   dfWaitOff()                       // OFF message
ENDIF

RETURN
