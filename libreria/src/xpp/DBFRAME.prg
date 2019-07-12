#include "dfSet.ch"

STATIC oFrameStack

// La #define _WAA_ serve per dire se compilare per
// il Web Application Adaptor di Alaska (serve per fare applicazioni web)
// Normalmente _WAA_ non Š definita e quindi viene incluso tutto il codice.

PROCEDURE dbFrameInit()
#ifndef _WAA_
   oFrameStack := S2Stack():new()
#endif
RETURN

FUNCTION dbFrameArr()
   LOCAL aRet := {}

#ifndef _WAA_
   IF ! dfInitScreenOpen()
      aRet := oFrameStack:top():getArr()
   ENDIF
#endif

RETURN aRet

FUNCTION dbFrameCol(); S2FU(); RETURN NIL

FUNCTION dbFrameBox( cMsg )
#ifndef _WAA_
   IF ! dfInitScreenOpen()
      oFrameStack:top():displayBox(cMsg)
   ENDIF
#endif
RETURN NIL

FUNCTION dbFrameLine( cLine )
#ifndef _WAA_
   IF ! dfInitScreenOpen()
      oFrameStack:top():Line(cLine)
   ENDIF
#endif
RETURN NIL

FUNCTION dbFramePro( nPos, nTot ); S2FU(); RETURN NIL

FUNCTION dbFrameOn(nTop, nLeft, nBottom, nRight, cTitle)
#ifndef _WAA_
   LOCAL oFrame

   IF ! dfInitScreenOpen()
      IF dfSet("XbaseFrameFast")=="YES"
         // Questo Š un po pi— brutto ma Š veloce                                         
         oFrame := S2FrameFast():new(nTop, nLeft, nBottom, nRight, cTitle)
      ELSE
         // In Xbase 1.5 questo tipo di frame Š lento!
         oFrame := S2Frame():new(nTop, nLeft, nBottom, nRight, cTitle)
         oFrame:Scroll := dfSet(AI_XBASEFRAMESCROLL)
      ENDIF

      oFrame:Create()
      oFrame:tbConfig()
      oFrame:show()
      oFrameStack:push(oFrame)
   ENDIF
#endif
RETURN NIL

FUNCTION dbFrameDis(cMsg)
#ifndef _WAA_
   IF dfInitScreenOpen()
      dfInitScreenUpd(cMsg)
   ELSE
      oFrameStack:top():display(cMsg)
   ENDIF
#endif
RETURN NIL

FUNCTION dbFrameUpd(cMsg)
#ifndef _WAA_
   IF dfInitScreenOpen()
      dfInitScreenUpd(cMsg)
   ELSE
      oFrameStack:top():update(cMsg)
   ENDIF
#endif
RETURN NIL

FUNCTION dbFrameTit(cTitle)
#ifndef _WAA_
   IF ! dfInitScreenOpen()
      oFrameStack:top():SetTitle(cTitle)
   ENDIF
#endif
RETURN NIL

FUNCTION dbFrameOff()
#ifndef _WAA_
   LOCAL oFrame

   IF ! dfInitScreenOpen()
      oFrame := oFrameStack:pop()
      IF ! EMPTY(oFrame)
         oFrame:tbEnd()
         oFrame:destroy()
      ENDIF
   ENDIF
#endif
RETURN NIL

FUNCTION dbFrameClear()
#ifndef _WAA_
   IF dfInitScreenOpen()
      dfInitScreenUpd("")
   ELSE
      oFrameStack:top():clear()
   ENDIF
#endif
RETURN NIL

