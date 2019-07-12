#include "dfXBase.ch"
#include "Xbp.ch"
#include "Gra.ch"
#include "Common.ch"

#define CHAR_STEP     "|/-\|/-\"
#define CHAR_STEP_LEN 8

// CLASS S2Wait FROM S2Msg, Thread
//    EXPORTED:
//    VAR cMsg, nIdx, nNextSec
//
//    METHOD Init, DoStep, On, Off, execute
// ENDCLASS
//
// METHOD S2Wait:Init()
//    ::S2Msg:init()
//    ::oTxt:TextArea:setFontCompoundName(APPLICATION_FONT)
//    ::nIdx := 1
//    ::nNextSec := -1
//    ::cMsg := ""
// RETURN self
//
// METHOD S2Wait:On( cMsg )
//    ::S2Msg:On(cMsg)
//    ::cMsg := cMsg
//    ::Start()
// RETURN self
//
//
// METHOD S2Wait:Off()
//    ::Stop()
//    ::S2Msg:Off()
// RETURN NIL
//
// METHOD S2Wait:DoStep()
// RETURN NIL
//
// METHOD S2Wait:execute()
//    LOCAL cCh
//
//    // IF SECONDS() > ::nNextSec
//       cCh := SUBSTR(CHAR_STEP, ::nIdx, 1)
//
//       ::nIdx++
//       IF ::nIdx > CHAR_STEP_LEN
//          ::nIdx := 1
//       ENDIF
//
//       ::update(cCh + " " + ::cMsg +" "+ cCh)
//
//       Sleep(30)
//
//       // ::nNextSec := SECONDS() + .5
//
//    // ENDIF
// RETURN self

CLASS S2Wait FROM S2Msg
   EXPORTED:
   VAR cMsg, nIdx, nNextSec

   METHOD Init, DoStep, On
ENDCLASS

METHOD S2Wait:Init()
   ::S2Msg:init()
   //::drawingArea:setColorBG(GRA_CLR_RED)
   //::oTxt:TextArea:setFontCompoundName(APPLICATION_FONT)
   //::oTxt:TextArea:setColorBG(GRA_CLR_RED)
   ::nIdx := 1
   ::nNextSec := -1
   ::cMsg := ""
RETURN self

METHOD S2Wait:On( cMsg )
   DEFAULT cMsg TO ""
   ::S2Msg:On(cMsg)
   // ::setPointer(NIL, XBPSTATIC_SYSICON_WAIT, XBPWINDOW_POINTERTYPE_SYSPOINTER)
   ::cMsg := cMsg
RETURN self


METHOD S2Wait:DoStep()
   LOCAL cCh

   IF SECONDS() > ::nNextSec
      cCh := SUBSTR(CHAR_STEP, ::nIdx, 1)

      ::nIdx++
      IF ::nIdx > CHAR_STEP_LEN
         ::nIdx := 1
      ENDIF

      ::update(cCh + " " + ::cMsg +" "+ cCh)

      ::nNextSec := SECONDS() + .5

   ENDIF
RETURN NIL

