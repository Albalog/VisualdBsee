#include "dfReport.ch"
#include "common.ch"

//FUNCTION _dfXPrnOut(aBuf )
//   LOCAL lRet := .F.
//   LOCAL oDisp := aBuf[REP_XBASEPRINTDISP]
//   IF ! EMPTY(oDisp)
//      lRet := oDisp:execute() // aBuf[REP_FNAME], aBuf[REP_NAME])
//   ENDIF
//RETURN lRet

//Ger 4287 Luca 22/10/2004
// Inserito Per la chiusura delle dei file aperti quando non c'Š nulla da stampare
FUNCTION _dfXPrnOut(aBuf,lExecute)
   LOCAL lRet  := .F.
   LOCAL oDisp := aBuf[REP_XBASEPRINTDISP]

   DEFAULT lExecute TO .T.

   IF ! EMPTY(oDisp)
      IF lExecute
         lRet := oDisp:execute() // aBuf[REP_FNAME], aBuf[REP_NAME])
      ELSE
         lRet := _dfXPrnClose(aBuf)// oDisp:Close() 
      ENDIF
   ENDIF
RETURN lRet


FUNCTION  _dfXPrnClose(aBuf)
   LOCAL lRet  := .F.
   LOCAL oDisp := aBuf[REP_XBASEPRINTDISP]

   IF ! EMPTY(oDisp)
      lRet := oDisp:Close() 
   ENDIF
RETURN lRet
