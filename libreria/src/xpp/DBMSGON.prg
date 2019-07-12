#include "dfMsg1.ch"
#include "dfSet.ch"
#include "common.ch"
#include "DFSTD.CH"


STATIC oMsgStack
STATIC nMsgStyle

PROCEDURE dbMsgInit()
#ifndef _WAA_
   oMsgStack := S2Stack():new()
#endif
RETURN

FUNCTION dbMsgOn(cMsg, nDelay)
   LOCAL oMsg
#ifndef _WAA_

   IF dfInitScreenOpen()
      dfInitScreenUpd(cMsg)
   ELSE
      /////////////////////////////////////////////////////
      //Mantis 2112
      //Da runtime errore su Win98
      IF dfWinIs98()
         dfSet(AI_XBASEMSGSTYLE,AI_MSGSTYLE_STD) 
      ENDIF 

      IF nMsgStyle == NIL
         nMsgStyle := dfSet(AI_XBASEMSGSTYLE)
         IF nMsgStyle != AI_MSGSTYLE_STD
            VDBWaitInit()
         ENDIF
      ENDIF

      IF nMsgStyle == AI_MSGSTYLE_FANCY .OR. nMsgStyle == AI_MSGSTYLE_FANCY_AUTO
         /////////////////////////////////////
         //Mantis 1206
         IF !EMPTY(cMSG)
            cMSG := STRTRAN(cMsg,"//",CRLF)
         ENDIF
         /////////////////////////////////////
         VDBWaitOn(cMsg, dfStdMsg1(MSG1_DFWAIT01), NIL, nMsgStyle == AI_MSGSTYLE_FANCY_AUTO)
      ELSE
        ///////////////////////////////////////////////////
        //Gerr 3946 e 4508
        //oMsg := S2Msg():new():On(cMsg, nDelay)
         oMsg := S2Msg():new()
         // Errore
         Sleep(5)
         oMsg:On(cMsg, nDelay)
         Sleep(5)
         oMsgStack:push(oMsg)
      ENDIF
   ENDIF
#endif
RETURN NIL

FUNCTION dbMsgUpd(cMsg)
#ifndef _WAA_
   IF dfInitScreenOpen()
      dfInitScreenUpd(cMsg)
   ELSE
      IF nMsgStyle == AI_MSGSTYLE_FANCY .OR. nMsgStyle == AI_MSGSTYLE_FANCY_AUTO
         /////////////////////////////////////
         //Mantis 1206
         IF !EMPTY(cMSG)
            cMSG := STRTRAN(cMsg,"//",CRLF)
         ENDIF
         /////////////////////////////////////
         VDBWaitUpd(cMsg)
      ELSE
         oMsgStack:top():update(cMsg)
      ENDIF
   ENDIF
#endif
RETURN NIL

FUNCTION dbMsgOff()
#ifndef _WAA_
   LOCAL oMsg

   IF dfInitScreenOpen()
   ELSEIF nMsgStyle == AI_MSGSTYLE_STD
      oMsg := oMsgStack:pop()
      IF ! EMPTY(oMsg)
         oMsg:Off()
      ENDIF
   ELSE
      RETURN VDBWaitOff()
   ENDIF
#endif
RETURN NIL
