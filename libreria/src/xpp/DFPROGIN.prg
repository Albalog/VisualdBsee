#include "dfStd.ch"
#include "dfSet.ch"
#include "Common.ch"
#include "dfMsg1.ch"


STATIC oPIStack

PROCEDURE dfPIInit()
#ifndef _WAA_
   oPIStack := S2Stack():new()
#endif
RETURN

FUNCTION dfPIOn(cTitle, cString, lButton, xStyle)
#ifndef _WAA_
   LOCAL oPI
   LOCAL lThread := NIL
   LOCAL cBackBmp
   LOCAL oOwner
   LOCAL oParent

   DEFAULT xStyle  TO dfSet(AI_XBASEPROGRESSSTYLE)
   DEFAULT xStyle  TO AI_PROGRESSSTYLE_STD
   DEFAULT lButton TO .T.

   DEFAULT oOwner TO S2FormCurr() // aggiunta simone 31/8/06

   IF VALTYPE(xStyle)=="L"
      xStyle := IIF(xStyle, AI_PROGRESSSTYLE_STD_THREAD, AI_PROGRESSSTYLE_STD)
   ENDIF

   IF xStyle == AI_PROGRESSSTYLE_FANCY .AND. lButton
      // SD 19/7/07
      // workaround se c'Š un activex si pu• bloccare il thread 
      // VDBProgDialogManager():execute()!
      // vedi ExtraService - GEseVis.prg
      IF dfSet("XbaseProgInThreadEnabled") == "NO"
         lButton := .F.
      ENDIF
   ENDIF

   IF !EMPTY(cString)
      cString := STRTRAN(cString,  "//", CRLF)
   ENDIF
   

   DO CASE
      CASE xStyle == AI_PROGRESSSTYLE_STD_THREAD
         oPI := S2ProgressIndicator():new(.T.)
         oPI:On(cTitle, cString, lButton)


      CASE xStyle == AI_PROGRESSSTYLE_FANCY .AND. lButton
         oPI := VDBProgDialogManager():new(oParent,oOwner,NIL,NIL,NIL,NIL,cBackBMP)

         IF ! EMPTY(cTitle) 
            cString := cTitle+IIF(EMPTY(cString), "", CRLF+cString)
         ENDIF

         oPI:On(dfStdMsg1(MSG1_S2PI04), cString, lButton)

      CASE xStyle == AI_PROGRESSSTYLE_FANCY .AND. ! lButton
         oPI := VDBProgDialog():new(oParent,oOwner,NIL,NIL,NIL,NIL,cBackBMP)

         IF ! EMPTY(cTitle) 
            cString := cTitle+IIF(EMPTY(cString), "", CRLF+cString)
   ENDIF
         oPI:On(dfStdMsg1(MSG1_S2PI04), cString, lButton)
         /////////////////////
         oPI:SHOW()
         /////////////////////
   
      OTHERWISE // default= standard: xStyle == AI_PROGRESSSTYLE_STD
         oPI := S2ProgressIndicator():new(.F.)
   oPI:On(cTitle, cString, lButton)

   ENDCASE

   oPIStack:push(oPI)

   //S2FormCurr(oPI)
#endif
RETURN NIL

FUNCTION dfPIStep(nCur, nTot, cMsg )
#ifndef _WAA_
   IF !EMPTY(cMsg)
      cMsg := STRTRAN(cMsg,  "//", CRLF)
   ENDIF
RETURN oPIStack:top():DoStep(nCur, nTot, cMsg)
#else
RETURN NIL
#endif

FUNCTION dfPIOff()
#ifndef _WAA_
   //LOCAL oOwner
   LOCAL oPI := oPIStack:pop()
   IF ! EMPTY(oPI)
     // oOwner := oPI:setOwner()
      oPI:Off()
     // S2FormCurr(oOwner, .T.)
   ENDIF
#endif
RETURN NIL

FUNCTION dfPIStack()
RETURN oPIStack


FUNCTION dfPIUpdMsg(cMsg)
#ifndef _WAA_
   IF !EMPTY(cMsg)
      cMsg := STRTRAN(cMsg,  "//", CRLF)
   ENDIF
RETURN oPIStack:top():setCaption(cMsg)
#else
RETURN NIL
#endif

//
// // STATIC cStr := ""
//
// FUNCTION dfPIOn(cTitle, cString, lButton)
//    LOCAL cStr := ""
//
//    DEFAULT cTitle  TO ""
//    DEFAULT cString TO ""
//    DEFAULT lButton TO .T.
//
//    cStr := cTitle + "////" + cString
//
//    // dbMsgOn(cStr)
// RETURN NIL
//
// FUNCTION dfPIOff()
//    // dbMsgOff()
// RETURN NIL
//
// FUNCTION dfPIStep(nCur, nTot, cMsg )
//
//    // dbMsgUpd(cStr + "//" + ;
//    //          ALLTRIM( STR( 100*nCur/nTot, 4, 0 )+"%" ) )
//
// RETURN .T.


