/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/
#include "common.ch"
#include "dfSet.ch"
#include "dfMsgMod.ch"
MEMVAR Act, Sa, A
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dbAskW( cMsg, cRisp, cAct ) //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cRet

DEFAULT cRisp TO ""
DEFAULT cMsg  TO "Inserire Messaggio richiesta dati..."
DEFAULT cAct  TO ""

dbMsgOn( cMsg )

DO WHILE .T.

   dbInk()

   DO CASE
      CASE sa $ cRisp
           cRet = sa

      CASE Act = [ret] .OR. Act $ cAct .OR. cAct = "all"
           cRet = LEFT(cRisp,1)

      CASE Act = [esc]
           cRet = RIGHT(cRisp,1)

      OTHERWISE
           LOOP
   ENDCASE

   EXIT

ENDDO

dbMsgOff()

RETURN cRet
