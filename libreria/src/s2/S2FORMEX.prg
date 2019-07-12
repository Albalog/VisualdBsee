#include "dfSet.ch"
#include "dfWin.ch"

CLASS S2FormCompatibility FROM S2BrowserCompatibility
   EXPORTED:
      VAR colCount
      VAR rowPos
      INLINE METHOD init; ::colCount := 0; ::rowPos := 1; RETURN self
ENDCLASS


FUNCTION S2GetStatusLineStyle()
RETURN dfSet(AI_XBASESTATUSLINESTYLE)
/*
   LOCAL nRet   := W_STATUSLINE_STYLE_SYSTEM
   LOCAL cStyle := dfSet("XbaseStatusLineStyle")

   DO CASE
      CASE EMPTY(cStyle)
        nRet := W_STATUSLINE_STYLE_SYSTEM
      CASE cStyle == "1"
        nRet := W_STATUSLINE_STYLE_FLAT
   ENDCASE
RETURN nRet
*/


FUNCTION S2GetToolBarStyle()
RETURN dfSet(AI_XBASETOOLBARSTYLE)

/*
   LOCAL nRet   := W_TOOLBAR_STYLE_SYSTEM
   LOCAL cStyle

//   IF VALTYPE(nStyle) == "N"
//      RETURN nStyle
//   ENDIF

   cStyle := dfSet(AI_XBASETOOLBARSTYLE)

   DO CASE
      CASE EMPTY(cStyle)
        nRet := W_TOOLBAR_STYLE_SYSTEM
      CASE cStyle == "1"
        nRet := W_TOOLBAR_STYLE_RIGHT
      CASE cStyle == "2"
        nRet := 2 //W_TOOLBAR_STYLE_FLAT
   ENDCASE
RETURN nRet
*/

FUNCTION S2GetToolBarClass(n)
   LOCAL oBtn
//   LOCAL n
//   n :=S2GetToolBarStyle(nStyle)
   IF n == AI_TOOLBARSTYLE_STD
      oBtn := ToolBar()
   ELSEIF n == 2 //W_TOOLBAR_STYLE_FLAT
      ToolBarThread() // inizializzo thread toolbar
      oBtn := S2ToolClass()
   ELSE
      oBtn := S2ToolClass2()
   ENDIF
RETURN oBtn
