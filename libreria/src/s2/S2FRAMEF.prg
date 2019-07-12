// Function/Procedure Prototype Table  -  Last Update: 07/10/98 @ 12.25.36
// 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
// Return Value         Function/Arguments
// 컴컴컴컴컴컴컴컴컴�  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
// self                 METHOD S2FrameFast:Destroy()
// Void                 METHOD S2FrameFast:Line(cLine)
// NIL                  METHOD S2FrameFast:clear()
// Void                 METHOD S2FrameFast:display(cMsg)
// self                 METHOD S2FrameFast:init(nTop, nLeft, nBottom, nRight, cTitle)
// self                 METHOD S2FrameFast:tbConfig()
// Void                 METHOD S2FrameFast:update(cMsg)

#include "Common.ch"
#include "dfXBase.ch"
#include "dfStd.ch"
#include "Xbp.ch"
#include "Gra.ch"
#include "dfSet.ch"
#include "dfWin.ch"

CLASS S2FrameFast FROM S2Dialog
   PROTECTED:
      VAR oTxt, oPS, nHeight, nWidth, nTextHeight, nMaxLines, aMsg
      METHOD _update

   EXPORTED:
      METHOD Init, tbConfig, Display, Update, Clear, Destroy, Line
      METHOD displayBox, show, _paint
      INLINE METHOD getArr(); RETURN ACLONE( ::aMsg )
ENDCLASS

METHOD S2FrameFast:init(nTop, nLeft, nBottom, nRight, cTitle,nCoordMode )
   LOCAL aPP
   DEFAULT nCoordMode   TO S2CoordModeDefault()
   ::S2Dialog:init(nTop, nLeft, nBottom, nRight,;
                   NIL    , NIL   , NIL , NIL  , NIL, NIL     ,nCoordMode) 
   ::nCoordMode := nCoordMode

   ::taskList := .T.
   ::sysMenu  := .F.
   // ::maxButton := .F.
   // ::minButton := .F.
   // ::taskList  := .F.
   //aPP := { {XBP_PP_BGCLR, GraMakeRGBColor({12,230,123})} }
   aPP := { {XBP_PP_BGCLR, GRA_CLR_WHITE} }

   ::oTxt := XbpStatic():new(::drawingArea, NIL, NIL, NIL, aPP )
   ::oTxt:options := XBPSTATIC_TEXT_WORDBREAK
   //::oTxt:paint := {|a| ::_paint(a) }

   #ifndef _NOFONT_
   ::oTxt:setFontCompoundName(APPLICATION_FONT)
   #endif

   IF ! EMPTY(cTitle)
      ::title := cTitle
   ENDIF

   ::aMsg := {}
   ::nMaxLines := 0
RETURN self

METHOD S2FrameFast:tbConfig()
   LOCAL aSize
   LOCAL aAttr := ARRAY(GRA_AA_COUNT)
   // LOCAL oColor := S2Color():new()

   ::S2Dialog:tbConfig()

   ::oTxt:create(NIL,NIL,NIL,::drawingArea:currentSize())

   // Trovo l'altezza di una linea
   ::oPS := ::oTxt:lockPS()
   aSize := GraQueryTextBox(::oPs, "^g")
   ::nTextHeight := MAX(aSize[3][2], aSize[4][2]) - MIN(aSize[1][2], aSize[2][2])
   ::oTxt:unlockPS(::oPS)

   aSize := ::oTxt:currentSize()
   ::nWidth  := aSize[1]
   ::nHeight := aSize[2] - ::nTextHeight
   ::nMaxLines := INT(aSize[2] / ::nTextHeight)
RETURN self

METHOD S2FrameFast:show()
   LOCAL lRet := ::S2Dialog:show()
   ::clear()
RETURN lRet

METHOD S2FrameFast:Destroy()
   ::oTxt:destroy()
   ::S2Dialog:destroy()
RETURN self

METHOD S2FrameFast:clear()
   ::aMsg := {}
   ::_paint()
RETURN NIL

METHOD S2FrameFast:Line(cLine)
   ::display( REPLICATE(cLine, ::nRight-::nLeft-4) )
RETURN

METHOD S2FrameFast:display(cMsg)
   LOCAL nInd
   IF EMPTY(::aMsg) //LEN(::aMsg) < ::nMaxLines
      ASIZE(::aMsg,::nMaxLines)
      AFILL(::aMsg, {"",.F.})
   ELSE
      FOR nInd := 1 TO LEN(::aMsg)-1
         ::aMsg[nInd]:=::aMsg[nInd+1]
      NEXT
   ENDIF

   ::_update(cMsg, NIL, .F. )
RETURN

METHOD S2FrameFast:displayBox(cMsg)
   ::display(cMsg)
RETURN self

METHOD S2FrameFast:update(cMsg, lBox)
RETURN ::_update(cMsg, lBox, .T. )

METHOD S2FrameFast:_update(cMsg, lBox,lLock)

   cMsg := IIF(LEFT(cMsg,1)=="^", SUBSTR(cMsg,2), cMsg)

   IF EMPTY(::aMsg) //LEN(::aMsg) < ::nMaxLines
      ASIZE(::aMsg,::nMaxLines)
      AFILL(::aMsg, {"",.F.})
   ENDIF

   ::aMsg[LEN(::aMsg)] := {cMsg, lBox}
   //::invalidateRect()

#ifdef _XBASE15_
   IF lLock  // effettuo il refresh solo dell'ultima riga
      ::oTxt:lockUpdate(.T.)
   ENDIF
#endif

   ::_paint()

#ifdef _XBASE15_
   IF lLock
      ::oTxt:lockUpdate(.F.)
      ::oTxt:invalidateRect({0,0,::oTxt:currentSize()[1],::nTextHeight*2})
   ENDIF
#endif

RETURN self

METHOD S2FrameFast:_paint(aRect)
   LOCAL aPos := {0,0}
   LOCAL nInd := 0
   LOCAL cCaption := ""
   FOR nInd := 1 TO LEN(::aMsg)
      cCaption += ::aMsg[nInd][1] + IIF(nInd < LEN(::aMsg), CRLF, "")
   NEXT

   ::oTxt:setCaption(cCaption)
RETURN self

