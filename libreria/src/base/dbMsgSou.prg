/******************************************************************************
Project     : dBsee 4.5
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "Common.ch"
#include "dfMsg.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dbMsgSound( cMsg, nTime, lSound )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nNum := 0
LOCAL oFocus := SetAppFocus()

   DEFAULT nTime  TO  0
   DEFAULT lSound TO .T.

   IF lSound
      TONE(5000, 1)
   ENDIF

   dbMsgOn(cMsg)

   IF nTime==0
      dbMsgUpd(cMsg +"// //"+dfStdMsg(MSG_DFALERT01))
      //dfUsrMsg( cMsg +"// //"+dfStdMsg(MSG_DFALERT01) )
   ENDIF

   IF nTime==0
      dbInk()
   ELSE
      dfInkey(nTime) //FW
   ENDIF

   IF lSound
      TONE(3000, 1)
   ENDIF

   dbMsgOff()
   //Luca 26/03/2008
   //Inserito per che su Vista da Problemi. Lascia un alone del box gi… chiuso in alcuni casi.
   IF oFocus != NIL
      SetAppFocus(oFocus)
   ENDIF
RETURN .T.
