// Function/Procedure Prototype Table  -  Last Update: 07/10/98 @ 12.25.36
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Return Value         Function/Arguments
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// self                 METHOD S2Frame:Destroy()
// Void                 METHOD S2Frame:Line(cLine)
// NIL                  METHOD S2Frame:clear()
// Void                 METHOD S2Frame:display(cMsg)
// self                 METHOD S2Frame:init(nTop, nLeft, nBottom, nRight, cTitle)
// self                 METHOD S2Frame:tbConfig()
// Void                 METHOD S2Frame:update(cMsg)

#include "Common.ch"
#include "dfXBase.ch"
#include "dfStd.ch"
#include "Xbp.ch"
#include "Gra.ch"
#include "dfSet.ch"
#include "dfWin.ch"

CLASS S2Frame FROM S2Dialog
   PROTECTED:
   VAR oTxt, oPS, nHeight, nWidth, nTextHeight, nMaxLines, aMsg
   METHOD VertScroll, _update

   EXPORTED:
   VAR Scroll, nCoordMode
   METHOD Init, tbConfig, Display, Update, Clear, Destroy, Line
   METHOD displayBox, lockPS, unlockPS, show, _paint
   INLINE METHOD getArr(); RETURN ACLONE( ::aMsg )
ENDCLASS

METHOD S2Frame:init(nTop, nLeft, nBottom, nRight, cTitle, nCoordMode)
   DEFAULT nCoordMode   TO S2CoordModeDefault()
   ::nCoordMode := nCoordMode
   ::S2Dialog:init(nTop, nLeft, nBottom, nRight,;
                   NIL    , NIL   , NIL , NIL  , NIL, NIL     ,nCoordMode) 

   ::taskList := .T.
   ::sysMenu  := .F.
   // ::maxButton := .F.
   // ::minButton := .F.
   // ::taskList  := .F.

   S2ObjSetColors(::drawingArea, .T., dfColor("FrameColor")[AC_FRA_WALL])

   ::oTxt := S2Txt():new(::drawingArea)
   ::oTxt:TextArea:paint := {|a| ::_paint(a) }

   #ifndef _NOFONT_
   ::oTxt:TextArea:setFontCompoundName(APPLICATION_FONT)
   #endif

   ::Scroll := .T.

   IF ! EMPTY(cTitle)
      ::title := cTitle
   ENDIF

   ::aMsg := {}
   ::nMaxLines := 0
RETURN self

METHOD S2Frame:tbConfig()
   LOCAL aSize
   LOCAL aAttr := ARRAY(GRA_AA_COUNT)

   ::S2Dialog:tbConfig()
   ::oTxt:create(NIL,NIL,NIL,::drawingArea:currentSize())

   // Trovo l'altezza di una linea
   ::oPS := ::oTxt:TextArea:lockPS()
   aSize := GraQueryTextBox(::oPs, "^g")
   ::nTextHeight := MAX(aSize[3][2], aSize[4][2]) - MIN(aSize[1][2], aSize[2][2])
   ::oTxt:TextArea:unlockPS(::oPS)
   //::nTextHeight := ROW_SIZE

   aSize := ::oTxt:TextArea:currentSize()
   ::nWidth  := aSize[1]
   ::nHeight := aSize[2] - ::nTextHeight
   ::nMaxLines := INT(aSize[2] / ::nTextHeight) + 1
   ::lockPS()

   // ::oPS := ::oTxt:TextArea:lockPS()
   //
   // oColor:setPS(::oPS, "FrameColor", AC_FRA_WALL)
   //
   // // Imposto il colore
   // ::clear()
   //
   // // GraSetFont(XbpFont:New():Create(APPLICATION_FONT))

RETURN self

METHOD S2Frame:show()
   LOCAL lRet := ::S2Dialog:show()
   ::clear()
RETURN lRet


METHOD S2Frame:lockPS()
   LOCAL oPS := ::oTxt:TextArea:lockPS()
   LOCAL aAttr
   LOCAL nFG, nBG

   //LOCAL oColor := S2Color():new()

   //oColor:setPS(oPS, "FrameColor", AC_FRA_WALL)
   nFG := S2DbseeColorToRGB(dfColor("FrameColor")[AC_FRA_WALL], .F.)
   nBG := S2DbseeColorToRGB(dfColor("FrameColor")[AC_FRA_WALL], .T.)

   DEFAULT nFG TO GRA_CLR_WHITE
   DEFAULT nBG TO GRA_CLR_BLUE

   // Per il GRABOX il foreground e il background sono uguali!
   aAttr := ARRAY(GRA_AA_COUNT)
   aAttr[GRA_AA_COLOR]     := nBG
   aAttr[GRA_AA_BACKCOLOR] := nBG
   aAttr[GRA_AA_BGMIXMODE] := GRA_BGMIX_OVERPAINT
   oPS:SetAttrArea(aAttr)

   aAttr := ARRAY(GRA_AS_COUNT)
   aAttr[GRA_AS_COLOR]     := nFG
   aAttr[GRA_AS_BACKCOLOR] := nBG
   oPS:SetAttrString(aAttr)
   ::oPS := oPS

RETURN oPS

METHOD S2Frame:unlockPS(oPS)
   DEFAULT oPS TO ::oPS
RETURN ::oTxt:TextArea:unlockPS(oPS)


METHOD S2Frame:Destroy()

   ::unlockPS()

   // ::oTxt:TextArea:unlockPS(::oPS)

   ::oTxt:destroy()
   ::S2Dialog:destroy()

RETURN self

METHOD S2Frame:clear()
   ::aMsg := {}
   GraBox(::oPS, {0,0}, {::nWidth, ::nHeight+::nTextHeight}, GRA_FILL)
RETURN NIL

METHOD S2Frame:Line(cLine)
   ::display( REPLICATE(cLine, ::nRight-::nLeft-4) )
RETURN


METHOD S2Frame:display(cMsg)
   ::VertScroll()
   ::update(cMsg)
RETURN

METHOD S2Frame:_paint(aRect)
   LOCAL aPos := {0,0}
   LOCAL nInd := 0

   GraBox(::oPS, {aRect[1], aRect[2]}, {aRect[3], aRect[4]}, GRA_FILL)

   FOR nInd := LEN(::aMsg) TO 1 STEP -1
      aPos[2] += ::nTextHeight
      IF ! EMPTY(::aMsg[nInd])
         ::_Update(::aMsg[nInd][1], ::aMsg[nInd][2], ACLONE(aPos) )
      ENDIF
      //GraStringAt(::oPS, aPos, aMsg[nInd])
   NEXT

RETURN self

METHOD S2Frame:VertScroll()
   LOCAL nInd := 0

   IF LEN(::aMsg) < ::nMaxLines
      AADD(::aMsg, NIL)
   ELSE
      ADEL(::aMsg, 1)
   ENDIF

   IF ::Scroll
      FOR nInd := 0 TO ::nTextHeight-1
         GraBitBlt(::oPS, ::oPS, {0, nInd+1, ::nWidth, ::nHeight }, {0, nInd})
         GraBox(::oPS, {0,nInd}, {::nWidth, nInd+1}, GRA_FILL)
      NEXT
   ELSE
      GraBitBlt(::oPS, ::oPS, {0, ::nTextHeight, ::nWidth, ::nHeight }, {0, 0})
      GraBox(::oPS, {0,0}, {::nWidth, ::nTextHeight}, GRA_FILL)
   ENDIF
RETURN self

METHOD S2Frame:displayBox(cMsg)
   ::VertScroll()
   ::VertScroll()
   ::VertScroll()
   ::update(cMsg, .T. )
RETURN self

METHOD S2Frame:update(cMsg, lBox)
   LOCAL aSize := ::oTxt:TextArea:currentSize()
   ::aMsg[LEN(::aMsg)] := {cMsg, lBox}
   //::invalidateRect()
   ::_paint({0,0,aSize[1], ::nTextHeight})
RETURN self


METHOD S2Frame:_update(cMsg, lBox, aPos)
   // LOCAL aPos := {0,4}   // 4 pixel in + in verticale
   LOCAL lCenter := .F.
   LOCAL aAttr
   LOCAL aDim
   LOCAL nMaxW, nMaxH, aLB, aRT

   DEFAULT cMsg TO ""
   DEFAULT lBox TO .F.

   //GraBox(::oPS, {0,0}, {::nWidth, ::nTextHeight}, GRA_FILL)
   GraBox(::oPS, aPos, {aPos[1]+::nWidth, aPos[2]+::nTextHeight}, GRA_FILL)

   aPos[2]+=4

   IF LEFT(cMsg,1) == "^"  // Centro orizzontalmente
      cMsg := SUBSTR(cMsg, 2)
      lCenter := .T.
   ENDIF

   IF lBox
      lCenter := .T.

      // Dimensioni del testo
      aDim := GraQueryTextBox(::oPs, cMsg)
      nMaxW := MAX(aDim[3][1], aDim[4][1]) - MIN(aDim[1][1], aDim[2][1])
      // nMaxH := MAX(aDim[3][2], aDim[4][2]) - MIN(aDim[1][2], aDim[2][2])

      nMaxH := ::nTextHeight

      aLB    := ARRAY(2)
      aLB[1] := aPos[1] + ::nWidth/2 - (nMaxW / 2 + 10)
      aLB[2] := aPos[2] + ::nTextHeight / 2

      aRT    := ARRAY(2)
      aRT[1] := aPos[1] + ::nWidth/2 + (nMaxW / 2 + 10)
      aRT[2] := aPos[2] + 2 * ::nTextHeight

      GraBox(::oPs, aLB, aRT, NIL, 20, 20)

      // Il testo va una linea pi— su
      aPos[2] += nMaxH

   ENDIF

   IF lCenter              // Centro orizzontalmente
      aPos[1] := ::nWidth/2

      aAttr := ARRAY(GRA_AS_COUNT)
      aAttr[GRA_AS_HORIZALIGN] := GRA_HALIGN_CENTER
      ::oPs:setAttrString(aAttr)
      lCenter := .T.
   ENDIF

   GraStringAt(::oPS, aPos, cMsg)

   IF lCenter
      aAttr[GRA_AS_HORIZALIGN] := GRA_HALIGN_LEFT
      ::oPs:setAttrString(aAttr)
   ENDIF

RETURN self

