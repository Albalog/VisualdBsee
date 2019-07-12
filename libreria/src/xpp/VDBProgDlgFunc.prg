#include "Common.ch"
#include "DFSTD.CH"

STATIC oPDStack

PROCEDURE VDBProgDialogInit()
#ifndef _WAA_
IF oPDStack == NIL
   oPDStack := S2Stack():new()
ENDIF
#endif
RETURN

FUNCTION VDBProgDialogGetStack(); RETURN oPDStack
FUNCTION VDBProgDialogGetTop(); RETURN oPDStack:top()

FUNCTION VDBProgDialogOn(cTitle, cMsg, lButton, cBackBMP, oParent, oOwner)
#ifndef _WAA_
   LOCAL oPD
   IF dfInitScreenOpen()
      dfInitScreenUpd(cMsg)
   ELSE
      DEFAULT oOwner TO S2FormCurr() // aggiunta simone 31/8/06
      IF lButton
         oPD := VDBProgDialogManager():new(oParent,oOwner,NIL,NIL,NIL,NIL,cBackBMP)
      ELSE
         oPD := VDBProgDialog():new(oParent,oOwner,NIL,NIL,NIL,NIL,cBackBMP)
      ENDIF
      Sleep(0)
      oPDStack:push(oPD)

      IF !EMPTY(cMsg)
         cMsg := STRTRAN(cMsg,  "//", CRLF)
      ENDIF

      oPD:On(cTitle, cMsg, lButton, cBackBMP)

      //S2FormCurr(oPD)
   ENDIF
#endif
RETURN NIL

FUNCTION VDBProgDialogStep(curr, max, msg)
#ifndef _WAA_
LOCAL xRet := .T.
  IF dfInitScreenOpen()
     xRet := dfInitScreenStep()
  ELSE
     IF EMPTY(oPDStack) .OR. EMPTY(oPDStack:top())
        xRet := .F.
        sleep(0)
//printlog("2xret"+var2char(xret))
     ELSE

        IF !EMPTY(Msg)
           Msg := STRTRAN(Msg,  "//", CRLF)
        ENDIF

        xRet := oPDStack:top():DoStep(curr, max, msg)
//printlog("1xret"+var2char(xret))
     ENDIF
  ENDIF
//RETURN IIF(dfInitScreenOpen(), dfInitScreenStep(), oPDStack:top():DoStep())
RETURN  xRet
#else
RETURN NIL
#endif


FUNCTION VDBProgDialogUpd(cMsg) //, cMsg2)
#ifndef _WAA_
LOCAL xRet := ""
  IF !EMPTY(cMsg)
     cMsg := STRTRAN(cMsg,  "//", CRLF)
  ENDIF

  IF dfInitScreenOpen()
     xRet := dfInitScreenUpd(cMsg)
  ELSE
     IF EMPTY(oPDStack) .OR. EMPTY(oPDStack:top())
        xRet := ""
        sleep(1)
     ELSE
        xRet := oPDStack:top():update(cMsg) //,cMsg2)
     ENDIF
  ENDIF
//RETURN IIF(dfInitScreenOpen(), dfInitScreenUpd(cMsg), oPDStack:top():update(cMsg,cMsg2))
RETURN  xRet
#else
RETURN NIL
#endif

FUNCTION VDBProgDialogOff()
#ifndef _WAA_
   LOCAL oPD //, oOwner

   IF ! dfInitScreenOpen()
      oPD := oPDStack:pop()
      IF ! EMPTY(oPD)
         //oOwner := oPD:setOwner()
         oPD:Off()
         //S2FormCurr(oOwner, .T.)
      ENDIF
   ENDIF
#endif
RETURN NIL
