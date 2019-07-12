#include "toolbar.ch"

CLASS S2ToolClass FROM ToolBar100
PROTECTED
   VAR aBtns

EXPORTED:
   VAR nToolBarSize

   ACCESS ASSIGN METHOD nToolBarSize 
   METHOD destroy
   METHOD addTool
   METHOD addSeparator
   METHOD getStatic
   METHOD dispItm
ENDCLASS

METHOD S2ToolClass:nToolBarSize(n)
   IF VALTYPE(n) == "N"
      ::High := n
      ::nToolBarSize := n
   ENDIF
RETURN ::High

METHOD S2ToolClass:destroy()
   ::aBtns := NIL
   ::ToolBar100:destroy()
RETURN self

METHOD S2ToolClass:getStatic()
RETURN ::drawingArea

METHOD S2ToolClass:addSeparator()
RETURN ::add(TB_SEPARATOR)

METHOD S2ToolClass:addTool(aIconId, bAction, cToolTip, bActive, cMsgShort, cID)
   LOCAL xCaption
   LOCAL nType 
   LOCAL oBtn
   LOCAL xIconDisabled

   IF VALTYPE(aIconID) == "C"
      nType := TB_TEXT
      xCaption := aIconId
   ELSE
      nType := TB_BUTTON
      xCaption := aIconId[1]
      xIconDisabled:= aIconId[2]
   ENDIF

   oBtn := ::add(nType, xCaption, bAction, cToolTip)

   IF ::aBtns == NIL
      ::aBtns := {}
   ENDIF
   AADD(::aBtns, {oBtn, bActive, xCaption, xIconDisabled})
RETURN self

METHOD S2ToolClass:dispItm()
   LOCAL n
   LOCAL oBtn
   IF EMPTY(::aBtns)
      RETURN self
   ENDIF

   ::lockUpdate( .T. )
   FOR n := 1 TO LEN(::aBtns)
      oBtn := ::aBtns[n][1] 
      IF EMPTY(::aBtns[n][2]) .OR. EVAL(::aBtns[n][2])
//         IF ::aBtns[n][3] != NIL
//            oBtn:display := ::aBtns[n][3] 
//         ENDIF
//         IF oBtn:mode == TB_BUTTON
//            oBtn:bmp( oBtn:display )
//         ENDIF
         oBtn:enable()
      ELSE
//         IF ::aBtns[n][4] != NIL
//            oBtn:display := ::aBtns[n][4] 
//         ENDIF
//         IF oBtn:mode == TB_BUTTON
//            oBtn:bmp( oBtn:display )
//         ENDIF
         oBtn:disable()
      ENDIF
//      oBtn:invalidateRect()
   NEXT
   ::lockUpdate( .F. )
   ::invalidateRect()
RETURN self

