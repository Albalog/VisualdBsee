//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per PRN
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "common.ch"
#include "dfSet.ch"
#include "dfMsg.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfIniPor() // Array porte di Stampa
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aPrn := {}
dfScanIni( "port", {|lMod|dfLoadPort(aPrn,lMod)} )
RETURN aPrn

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfLoadPort( aPrn, lMod )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cStr, cLeft, aRight

DEFAULT lMod TO .F.

IF dfSet( AI_INIMESSAGE )
   dfWaitOn( dfStdMsg(MSG_DFINIPOR01) ) // ON Message
ENDIF

DO WHILE !dfFEof()
   IF dfSet( AI_INIMESSAGE )
      dfWaitStep()           // Step message
   ENDIF
   cStr := ALLTRIM(dfFRead())
   DO CASE
      CASE !lMod .AND. Left(cStr,1) == "["                  // altra sezione
           EXIT

      OTHERWISE
           cLeft  := UPPER(dfLeft(cStr))
           aRight := dfRight( cStr, RT_ARRAY )

           ASIZE( aRight, LEN(aRight)+1 )
           AINS( aRight, 1 )
           aRight[1] := cLeft

           AADD( aPrn, aRight )
   ENDCASE
   dfFSkip()
ENDDO

IF dfSet( AI_INIMESSAGE )
   dfWaitOff()               // OFF message
ENDIF

RETURN
