#include "xbp.ch"
#include "common.ch"

FUNCTION M_Cless(oForm)
RETURN _setPointer(oForm, NIL, XBPSTATIC_SYSICON_WAIT, ;
                   XBPWINDOW_POINTERTYPE_SYSPOINTER)

FUNCTION M_Normal(oForm)
RETURN _setPointer(oForm, NIL, XBPSTATIC_SYSICON_ARROW, ;
                   XBPWINDOW_POINTERTYPE_SYSPOINTER)

STATIC FUNCTION _setPointer(oForm, cDll, nRes, nType)
   DEFAULT oForm TO S2FormCurr()

   IF ! EMPTY(oForm) .AND. ;
      VALTYPE(oForm) == "O" .AND. ;
      oForm:isDerivedFrom("XbpWindow")

      oForm:setPointer(cDll, nRes, nType )
   ENDIF
RETURN NIL


// STATIC FUNCTION fPointer(oForm, nType)
//    LOCAL nType, i, aList
//
//    oForm:drawingArea:setPointer(,nType,XBPWINDOW_POINTERTYPE_POINTER)
//    aList := oForm:drawingArea:childList()
//
//    FOR i = 1 TO Len(aList)
//       aList[i]:setPointer(,nType,XBPWINDOW_POINTERTYPE_SYSPOINTER)
//    NEXT
// RETURN .t.

