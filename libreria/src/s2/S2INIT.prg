#include "Common.ch"
#include "Xbp.ch"
#include "Gra.ch"

CLASS S2InitScreen FROM XbpDialog
   PROTECTED:
      VAR oTxt, nNextSec, oBmp, oTxtPS

   EXPORTED:
      CLASS VAR bTxtObject // codeblock che ritorna oggetto per display testo

      METHOD Init, Create, On, Off, update, doStep, centerPos //, txtPaint
ENDCLASS

METHOD S2InitScreen:init(nBmp, nX, nY)
   ::XbpDialog:init(AppDeskTop(), NIL, NIL, {nX, nY})

   ::taskList := .F.
   ::titleBar := .F.
   ::sysMenu  := .F.
   ::border   := XBPDLG_NO_BORDER

   ::drawingArea:bitmap := nBmp

   ::setColorBG(XBPSYSCLR_TRANSPARENT )
   ::drawingArea:setColorBG(XBPSYSCLR_TRANSPARENT )

   // ::oBmp := XbpStatic():new(::drawingArea)
   // ::oBmp:type := XBPSTATIC_TYPE_BITMAP
   // ::oBmp:caption := nBmp
   IF EMPTY(::bTxtObject)
   ::oTxt := XbpStatic():new(::drawingArea)
   ::oTxt:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_CENTER+XBPSTATIC_TEXT_WORDBREAK
   ELSE
      ::oTxt := EVAL(::bTxtObject, XBP_STAT_INIT, self, nBmp, nX, nY)
   ENDIF

   //::oTxt:paint := {|aRect, uNil, oObj| ::TxtPaint() }

   // ::oTxt:autosize := .T.
   // ::oTxt:TextArea:autosize := .T.

RETURN self

METHOD S2InitScreen:Create(oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL aAttr
   LOCAL nXOffset := 3, nYOffset := 9
   //LOCAL nXOffset := 4, nYOffset := 4

   ::XbpDialog:Create(oParent, oOwner, aPos, aSize, aPP, .F.  )
   ::centerPos()

   aSize := ::drawingArea:currentSize()

   aSize[2] := 25
   aPos := {nXOffset, nYOffset}
   aSize[1]-= nXOffset*2

   IF EMPTY(::bTxtObject)
     // ::oBmp:create(NIL, NIL, NIL, aSize)
     //aSize[2] := 20
     //aSize[2]-= 4*2
     ::oTxt:create(NIL, NIL, aPos, aSize)
     ::oTxt:setColorFG(GRA_CLR_NEUTRAL)
     ::oTxt:setColorBG(XBPSYSCLR_TRANSPARENT)
   ELSE
      EVAL(::bTxtObject, XBP_STAT_CREATE, self, ::oTxt, aPos, aSize)
   ENDIF

   // ::oTxt:setColorBG(XBPSYSCOL)

//   ::oTxt:setColorFG(GRA_CLR_BLACK)
//   ::oTxt:setColorBG(GRA_CLR_WHITE)

   //::oTxt:setColorFG(GRA_CLR_WHITE)
   //::oTxt:setColorBG(GRA_CLR_DARKBLUE)

   // aAttr := ARRAY(GRA_AA_COUNT)
   // aAttr[GRA_AA_MIXMODE] := GRA_FGMIX_LEAVEALONE
   // aAttr[GRA_AA_BGMIXMODE] := GRA_BGMIX_LEAVEALONE
   //
   // ::oTxtPS := ::oTxt:lockPS()
   //
   // ::oTxtPS:setAttrArea(aAttr)
   //
   // aAttr := ARRAY(GRA_AS_COUNT)
   // aAttr[GRA_AS_MIXMODE] := GRA_FGMIX_LEAVEALONE
   // aAttr[GRA_AS_BGMIXMODE] := GRA_BGMIX_LEAVEALONE
   //
   // ::oTxtPS:setAttrString(aAttr)

   ::nNextSec := -1
RETURN self

METHOD S2InitScreen:On()
   ::Create()
   // SetAppFocus(self)
   ::show()
RETURN self

METHOD S2InitScreen:Off()

   // ::oTxt:unLockPS(::oTxtPS)
   // ::oTxtPS := NIL

   ::hide()
   ::destroy()
RETURN self

METHOD S2InitScreen:update(cMsg)
   DEFAULT cMsg TO ""
   cMsg := S2MultiLineCvt(cMsg)

   ::oTxt:SetCaption( cMsg )  // ::oTxt:SetText( cMsg )
RETURN self

METHOD S2InitScreen:DoStep()

   // IF SECONDS() > ::nNextSec
   //
   //    ::update(::cMsg)
   //
   //    ::nNextSec := SECONDS() + .5
   //
   // ENDIF
RETURN self

METHOD S2InitScreen:CenterPos()
   LOCAL aParentSize
   LOCAL aSize


   aParentSize := AppDesktop():currentSize()
   aSize := ::currentSize()

   aSize[1] := (aParentSize[1] - aSize[1]) / 2
   aSize[2] := (aParentSize[2] - aSize[2]) / 2

   ::setPos(aSize)

RETURN self

// METHOD S2InitScreen:TxtPaint()
//    LOCAL oPS := ::oTxt:lockPS()
//
//    GraStringAt(oPS, {0,0}, ::oTxt:caption)
//
//    ::oTxt:unlockPS( oPS )
// RETURN self
