/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/
#include "dfreport.ch"
#include "dfstd.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfPrnConfig( aBuf )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

aBuf[REP_QRY_BLOCK] := NIL

IF aBuf[REP_QRY_EXP]==".T." .OR. EMPTY(aBuf[REP_QRY_EXP])
   aBuf[REP_QRY_EXP]:=NIL
ENDIF

IF aBuf[REP_QRY_EXP]!=NIL
   aBuf[REP_QRY_BLOCK] := DFCOMPILE( aBuf[REP_QRY_EXP] )
ENDIF

RETURN
