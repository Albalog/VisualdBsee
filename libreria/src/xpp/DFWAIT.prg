#include "dfStd.ch"
#include "dfSet.ch"
#include "dfMsg1.ch"
#include "Common.ch"

STATIC oWaitStack

STATIC nWaitStyle //"0"=default, "1"=nuovo, "2"=nuovo con thread

PROCEDURE dfWaitInit()
#ifndef _WAA_
   oWaitStack := S2Stack():new()
#endif
RETURN

FUNCTION dfWaitOn(cMsg)
#ifndef _WAA_
   LOCAL oWait

   IF dfInitScreenOpen()
      dfInitScreenUpd(cMsg)
   ELSE

      IF nWaitStyle == NIL

         /////////////////////////////////////////////////////
         //Mantis 2112
         //Da runtime errore su Win98
         IF dfWinIs98()
            dfSet(AI_XBASEWAITSTYLE, AI_WAITSTYLE_STD)
         ENDIF 

         nWaitStyle := dfSet(AI_XBASEWAITSTYLE)
         DEFAULT nWaitStyle TO AI_WAITSTYLE_STD

         IF nWaitStyle != AI_WAITSTYLE_STD
            VDBWaitInit()
         ENDIF
      ENDIF

      IF nWaitStyle == AI_MSGSTYLE_FANCY .OR. nWaitStyle == AI_MSGSTYLE_FANCY_AUTO
         VDBWaitOn(cMsg, dfStdMsg1(MSG1_DFWAIT01), NIL, nWaitStyle == AI_MSGSTYLE_FANCY_AUTO)
      ELSE
         //oWait := S2Wait():new():On(cMsg)
         oWait := S2Wait():new()
         Sleep(10)
         oWait:On(cMsg)
         Sleep(10)
         oWaitStack:push(oWait)
      ENDIF
   ENDIF
#endif
RETURN NIL

FUNCTION dfWaitStep()
   LOCAL xRet
#ifndef _WAA_
   IF dfInitScreenOpen()
      xRet := dfInitScreenStep()
      RETURN xRet
   ELSEIF nWaitStyle == AI_MSGSTYLE_STD
      IF EMPTY(oWaitStack)
         RETURN xRet 
      ENDIF 
      IF EMPTY(oWaitStack:top()) .OR.;
         oWaitStack:IsEmpty()    .OR.;
         !oWaitStack:IsOk()
         RETURN xRet 
      ENDIF 
      xRet := oWaitStack:top():DoStep()
      RETURN xRet 
   ELSE
      xRet := VDBWaitStep()
      RETURN xRet 
   ENDIF
#endif
RETURN xRet

FUNCTION dfWaitOff()
#ifndef _WAA_
   LOCAL oWait
   IF dfInitScreenOpen()
   ELSEIF nWaitStyle == AI_MSGSTYLE_STD
      IF EMPTY(oWaitStack)
         RETURN NIL 
      ENDIF 
      oWait := oWaitStack:pop()
      IF ! EMPTY(oWait)
         oWait:Off()
      ENDIF
   ELSE
      RETURN VDBWaitOff()
   ENDIF
#endif
RETURN NIL
