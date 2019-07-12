// Function/Procedure Prototype Table  -  Last Update: 07/10/98 @ 12.24.42
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Return Value         Function/Arguments
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

#include "dfWin.ch"
#include "dfMenu.ch"
#include "dfCtrl.ch"
#include "Common.ch"
#include "Xbp.ch"
#include "Gra.ch"
#include "Appevent.ch"
#include "dfXBase.ch"
#include "dfXRes.ch"
#include "font.ch"


// -----------------------------------------------------------------------
#define TITLE_HEIGHT   35
#define BTN_WIDTH     130
#define BTN_HEIGHT     22
#define BTN_OFFSET      1
#define ICON_HEIGHT    22
#define ICON_WIDTH     22


//Mantis 2165 del 20/09/2011
STATIC cFGColorFocus
STATIC cFGColorNOFocus

//Mantis 2165 del 20/09/2011
FUNCTION S2InformMenuButtonFocusColor(cColor)
  LOCAL cRet := 0
  IF cFGColorFocus == NIL
     cFGColorFocus := GRA_CLR_YELLOW
  ENDIF
  IF cColor != NIL
     cFGColorFocus := cColor
  ENDIF
  cRet := cFGColorFocus
RETURN cRet

//Mantis 2165 del 20/09/2011
FUNCTION S2InformMenuButtonNoFocusColor(cColor)
  LOCAL cRet := 0
  IF cFGColorNoFocus == NIL
     cFGColorNoFocus := GRA_CLR_WHITE
  ENDIF
  IF cColor != NIL
     cFGColorNoFocus := cColor
  ENDIF
  cRet := cFGColorNoFocus
RETURN cRet

CLASS S2FormMenu FROM XbpStatic

PROTECTED:
   VAR oBase
   VAR oUp
   VAR oDown
   VAR oExit
   VAR cCurr
   VAR oTitle
   VAR aItems       // All child
   VAR aButtons     // only buttons
   VAR nY
   VAR nYSize
   VAR nYPos

   INLINE METHOD ChgHotKey(x, y)
   RETURN IIF(y==NIL, S2HotCharCvt(x), STRTRAN(x, dfHot()) )

   METHOD findBtn
   METHOD findBtnHilited

EXPORTED:
   VAR oVScroll
   VAR oForm
   VAR aMenu

   METHOD Init, Create
   METHOD BuildMenu
   METHOD SetMenu
   METHOD updPos
   METHOD keyboard
   METHOD activate
   METHOD down
   METHOD up
   METHOD top
   METHOD bottom
   METHOD pgup
   METHOD pgdown
   INLINE METHOD SetColorTitleBG(cColor); RETURN ::oTitle:setColorBG(cColor)
   INLINE METHOD SetColorTitleFG(cColor); RETURN ::oTitle:setColorFG(cColor)

   //METHOD findKey
ENDCLASS

METHOD S2FormMenu:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )

   DEFAULT aPP TO  { {XBP_PP_BGCLR       , GRA_CLR_DARKBLUE}, ;
                     {XBP_PP_FGCLR       , GRA_CLR_WHITE   }  }

   ::XbpStatic:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::oVScroll :=ScrollBar():new()
   ::oBase    := XbpStatic():new()
   ::oTitle   := XbpStatic():new()
   ::oTitle:setFontCompoundName(FONT_HELV_LARGE+FONT_STYLE_BOLD+FONT_STYLE_ITALIC)
   ::oTitle:setColorFG(GRA_CLR_YELLOW)

   ::aMenu    := {}
   ::aItems   := {}
   ::aButtons := {}
RETURN self

METHOD S2FormMenu:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oXbp
   LOCAL aIconSize := {ICON_HEIGHT, ICON_WIDTH}
   ::XbpStatic:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   aSize := ::currentSize()
   aPos  := {0, aSize[2]}

   IF ! EMPTY(aPos)
      aPos[2]-= TITLE_HEIGHT // Altezza del titolo
   ENDIF

   aSize[2] := TITLE_HEIGHT
   ::rbdown := ::setParent():rbDown
   ::oTitle:create(self, NIL, aPos, aSize)

   // Aggiungo il pulsante per aprire il menu della form
   // DISATTIVATO perchŠ non funziona il menuOpen (o dbAct2Kbd)
   // che in altri casi funziona perfettamente.
   // ---------------------------------------------------------
   // // Cerco il padre derivato da S2Form
   // oXbp := ::setParent()
   // DO WHILE ! EMPTY(oXbp) .AND. ;
   //          ! oXbp:isDerivedFrom("S2Form")
   //    oXbp := oXbp:setParent()
   // ENDDO
   //
   // // Se lo trovo e ha il menu aggiungo il pulsante per aprire il menu
   // IF ! EMPTY(oXbp) .AND. ! EMPTY(oXbp:oMenuBar)
   //    aSize[1] -= ICON_WIDTH - BTN_OFFSET
   //    ::oTitle:setSize(aSize)
   //
   //    aSize := ::currentSize()
   //
   //    aPos[1] := aSize[1]-BTN_OFFSET-ICON_WIDTH
   //    aPos[2] := aSize[2]-BTN_OFFSET-ICON_HEIGHT
   //    ::oForm := oXbp
   //    oXbp := ie4Button():new(self,NIL, aPos, aIconSize, NIL, .T. )
   //    oXbp:caption := FORMMENU_EXIT
   //    oXbp:type    := XBPSTATIC_TYPE_BITMAP
   //    oXbp:activate := {|| dbAct2Kbd("smp") }
   //    //oXbp:activate := {|| ::oForm:menuOpen() }
   //    oXbp:create()
   //    ::oExit := oXbp
   // ENDIF

   aPos[1] := aSize[1] - BTN_OFFSET - ICON_WIDTH
   aPos[2] -= BTN_OFFSET
   aPos[2] -= ICON_HEIGHT

   oXbp := ie4Button():new(self,NIL, aPos, aIconSize, NIL, .F. )
   oXbp:caption := FORMMENU_UP
   oXbp:type    := XBPSTATIC_TYPE_BITMAP
   oXbp:activate := {|| ::pgUp() }
   oXbp:create()
   ::oUp := oXbp

   aPos[2] := BTN_OFFSET
   oXbp := ie4Button():new(self,NIL, aPos, aIconSize, NIL, .F. )
   oXbp:caption := FORMMENU_DOWN
   oXbp:type    := XBPSTATIC_TYPE_BITMAP
   oXbp:activate := {|| ::pgdown() }
   oXbp:create()
   ::oDown := oXbp

   ::oBase:rbDown := ::rbDown
   ::oBase:create(self,NIL,{0,0})

RETURN self

METHOD S2FormMenu:updPos()
   LOCAL aPos  := ::oBase:currentPos()
   LOCAL aSize := ::oBase:currentSize()
   LOCAL nI
   LOCAL nInd

   nI    := ::oVScroll:getData()

   aPos[2] := ::nYPos + nI
   aSize[2] := ::nYSize - nI

#ifdef _XBASE15_
   ::oBase:setPosAndSize(aPos, aSize, .F. )
#else
   ::oBase:setSize(aSize, .F. )
   ::oBase:setPos(aPos, .F. )
#endif

   ::oBase:invalidateRect()

   IF ::oVScroll:isTop()
      ::oUp:hide()
   ELSE
      ::oUp:show()
   ENDIF

   IF ::oVScroll:isBottom()
      ::oDown:hide()
   ELSE
      ::oDown:show()
   ENDIF

RETURN self

METHOD S2FormMenu:setMenu(cNew)
   LOCAL aMenu := dfMenuItm(::aMenu, cNew)
   LOCAL aDim, aPos
   LOCAL nY
   LOCAL cLab

   IF ! EMPTY(aMenu)
      ::hide()
      ::oUp:hide()
      ::oDown:hide()

      //Nuova implementazione etichette dinamiche, mantis 2185, luca 05/09/2012
      cLAB   := aMenu[MNI_LABEL]
      IF VALTYPE(cLAB) == "B"
         cLAB := EVAL(cLAB)
      ENDIF

      //::oTitle:setCaption( ::ChgHotKey(ALLTRIM(aMenu[MNI_LABEL]), .T. ))
      ::oTitle:setCaption( ::ChgHotKey(ALLTRIM(cLab), .T. ))

      //::nY := ::oTitle:currentPos()[2]

      // Grandezza iniziale dell'oBase
      aDim := ::currentSize()
      aDim[1] -= ICON_WIDTH+BTN_OFFSET
      aDim[2] -=  TITLE_HEIGHT
   #ifdef _XBASE15_
      ::oBase:setPosAndSize({0,0}, aDim)
   #else
      ::oBase:setPos({0,0})
      ::oBase:setSize(aDim)
   #endif


      ::nY := aDim[2]

      AEVAL(::aItems, {|o| o:destroy() })
      ASIZE(::aItems, 0)
      ASIZE(::aButtons, 0)
      AEVAL(aMenu[MNI_ARRAY], {|aMnu, nItm| ::buildMenu(aMnu, 0, nItm, 14) })

      nY := ::nY

      IF nY < 0
         ::oVScroll:setRange({0,-nY})
         ::oVScroll:setData(0)
         ::oVScroll:page := MAX(1,MIN(-nY, ::currentSize()[2]-TITLE_HEIGHT))
         aDim[2] += -nY

         aPos := ::oBase:currentPos()
         aPos[2] += nY
      #ifdef _XBASE15_
         ::oBase:setPosAndSize(aPos, aDim)
      #else
         ::oBase:setSize(aDim)
         ::oBase:setPos(aPos)
      #endif

         AEVAL(::aItems, {|o| aDim := o:currentPos(), ;
                              aDim[2]+=-nY        , ;
                              o:setPos(aDim)          } )
      ENDIF

      ::nYPos := ::oBase:currentPos()[2]
      ::nYSize := ::oBase:currentSize()[2]

      ::show()

      IF nY < 0
         ::oDown:show()
      ENDIF

   ENDIF
RETURN self

METHOD S2FormMenu:buildMenu(aMenu, nX, nItm, nLev)
   LOCAL nInd := 0
   LOCAL oBtn
   LOCAL cLab

   //////////////////////////////////////////////////////////////////////////
   //Nuova implementazione etichette dinamiche, mantis 2185, luca 05/09/2012
   cLAB   := aMenu[MNI_LABEL]
   IF VALTYPE(cLAB) == "B"
      cLAB := EVAL(cLAB)
   ENDIF
   //////////////////////////////////////////////////////////////////////////

   DO CASE
      CASE aMenu[MNI_TYPE] == MN_LINE

      CASE aMenu[MNI_SECURITY] == MN_ON .AND. ! EMPTY(aMenu[MNI_ARRAY])
         ::nY -= BTN_HEIGHT + 2*BTN_OFFSET
         oBtn := XbpStatic():new(::oBase, NIL, {nX, ::nY}, {BTN_WIDTH,BTN_HEIGHT})
         oBtn:autoSize := .T.
         //////////////////////////////////////////////////////////////////////////
         //Nuova implementazione etichette dinamiche, mantis 2185, luca 05/09/2012
         //oBtn:caption := ::ChgHotKey(ALLTRIM(aMenu[MNI_LABEL]), .T. )
         oBtn:caption := ::ChgHotKey(ALLTRIM(cLab), .T. )
         //////////////////////////////////////////////////////////////////////////
         oBtn:options := XBPSTATIC_TEXT_BOTTOM
         oBtn:setFontCompoundName(  ALLTRIM(STR(nLev,3,0))+".Arial Bold Italic"  )
         oBtn:create()
         AADD(::aItems, oBtn)
         AEVAL(aMenu[MNI_ARRAY], {|aMnu, nItm| ::buildMenu(aMnu, nX + 20, nItm, nLev-3) })

      CASE aMenu[MNI_SECURITY] == MN_ON .AND. EMPTY(aMenu[MNI_ARRAY])
         ::nY -= BTN_HEIGHT + BTN_OFFSET
         oBtn := S2FormMenuItm():new(::oBase, NIL, {nX, ::nY}, {BTN_WIDTH,BTN_HEIGHT})
         oBtn:cChoice := aMenu[MNI_CHILD]
         //////////////////////////////////////////////////////////////////////////
         //Nuova implementazione etichette dinamiche, mantis 2185, luca 05/09/2012
         //oBtn:caption := ::ChgHotKey(ALLTRIM(aMenu[MNI_LABEL]))
         oBtn:caption := ::ChgHotKey(ALLTRIM(cLab))
         //////////////////////////////////////////////////////////////////////////
         //oBtn:activate := {|uNil1, uNil2, oXbp| PostAppEvent(xbeP_User+EVENT_MENU_SELECTION, uNil1, uNil2, oXbp)  }
         oBtn:activate := {|nItm, uNIL, oXbp | ::oForm:ExecMenuItem(nItm, oXbp) }

         oBtn:toolTipText := aMenu[MNI_HELP]
         oBtn:options := XBPSTATIC_TEXT_TOP
         oBtn:create()
         AADD(::aItems, oBtn)
         AADD(::aButtons, oBtn)
   ENDCASE
RETURN self

METHOD S2FormMenu:activate()
   LOCAL nHilite := ::findBtnHilited()
   IF nHilite != 0
      ::aButtons[nHilite]:deHilite()
      EVAL(::aButtons[nHilite]:activate, NIL, NIL, ::aButtons[nHilite])
   ENDIF
RETURN self

METHOD S2FormMenu:down()
   LOCAL nHilite := ::findBtnHilited()
   LOCAL nPrev
   LOCAL nPos

   IF nHilite == 0
      ::top()

   ELSE

      nPrev := nHilite


      // Cerco il prossimo bottone
      DO WHILE .T.
         nHilite++

         IF nHilite > LEN(::aButtons)
            nHilite := nPrev
            EXIT
         ENDIF

         IF ::aButtons[nHilite]:isEnabled()

            EXIT
         ENDIF
      ENDDO

      IF nHilite != nPrev
         ::aButtons[nPrev]:dehilite()

         // IF ! EMPTY(::oVScroll) .AND. ! EMPTY(::oVScroll:range)
         IF ::oDown:isVisible()
            IF nHilite == LEN(::aButtons)
               ::oVScroll:setData( ::oVScroll:range[2] )
               ::updPos()
            ELSE
               nPos := ::aButtons[nHilite]:currentPos()[2] + ::oBase:currentPos()[2]

               IF nPos < 0
                  ::oVScroll:setData( ::oVScroll:getData() - nPos )
                  ::updPos()
               ENDIF
            ENDIF
         ENDIF

         ::aButtons[nHilite]:hilite()
      ENDIF
   ENDIF
RETURN self

METHOD S2FormMenu:up()
   LOCAL nHilite := ::findBtnHilited()
   LOCAL nPrev
   LOCAL nPos

   IF nHilite == 0
      ::bottom()

   ELSE

      nPrev := nHilite

      // Cerco il bottone precedente
      DO WHILE .T.
         nHilite--

         IF nHilite < 1
            nHilite := nPrev
            EXIT
         ENDIF

         IF ::aButtons[nHilite]:isEnabled()

            EXIT
         ENDIF
      ENDDO

      IF nHilite != nPrev
         ::aButtons[nPrev]:dehilite()

         //IF ! EMPTY(::oVScroll) .AND. ! EMPTY(::oVScroll:range)
         IF ::oUp:isVisible()
            IF nHilite == 1
               ::oVScroll:setData( ::oVScroll:range[1] )
               ::updPos()
            ELSE
               nPos := ::aButtons[nHilite]:currentPos()[2] + BTN_HEIGHT + BTN_OFFSET + ;
                       ::oBase:currentPos()[2]

               IF nPos > ::currentSize()[2] - TITLE_HEIGHT
                  ::oVScroll:setData( ::oVScroll:getData() - nPos + ;
                                      (::currentSize()[2]- TITLE_HEIGHT) )
                  ::updPos()
               ENDIF
            ENDIF
         ENDIF

         ::aButtons[nHilite]:hilite()
      ENDIF
   ENDIF
RETURN self

METHOD S2FormMenu:top()
   LOCAL nPrev := ::findBtnHilited()
   LOCAL nHilite := 0
   LOCAL nPos

   // Cerco il primo bottone
   DO WHILE .T.
      nHilite++

      IF nHilite > LEN(::aButtons)
         nHilite := 0
         EXIT
      ENDIF

      IF ::aButtons[nHilite]:isEnabled()

         EXIT
      ENDIF
   ENDDO

   IF nHilite > 0
      IF nPrev > 0
         ::aButtons[nPrev]:dehilite()
      ENDIF

      //IF ! EMPTY(::oVScroll) .AND. ! EMPTY(::oVScroll:range)
      IF ::oUp:isVisible()
         IF nHilite == 1
            ::oVScroll:setData( ::oVScroll:range[1] )
            ::updPos()
         ELSE
            nPos := ::aButtons[nHilite]:currentPos()[2] + BTN_HEIGHT + BTN_OFFSET + ;
                    ::oBase:currentPos()[2]

            IF nPos > ::currentSize()[2] - TITLE_HEIGHT
               ::oVScroll:setData( ::oVScroll:getData() - nPos + ;
                                    (::currentSize()[2]- TITLE_HEIGHT) )
               ::updPos()
            ENDIF
         ENDIF

      ENDIF

      ::aButtons[nHilite]:hilite()

   ENDIF

RETURN self

METHOD S2FormMenu:bottom()
   LOCAL nPrev := ::findBtnHilited()
   LOCAL nHilite := LEN(::aButtons) +1
   LOCAL nPos

   // Cerco l'ultimo bottone
   DO WHILE .T.
      nHilite--

      IF nHilite < 1
         EXIT
      ENDIF

      IF ::aButtons[nHilite]:isEnabled()

         EXIT
      ENDIF
   ENDDO

   IF nHilite > 0
      IF nPrev > 0
         ::aButtons[nPrev]:dehilite()
      ENDIF

      //IF ! EMPTY(::oVScroll) .AND. ! EMPTY(::oVScroll:range)
      IF ::oDown:isVisible()
         IF nHilite == LEN(::aButtons)
            ::oVScroll:setData( ::oVScroll:range[2] )
            ::updPos()
         ELSE
            nPos := ::aButtons[nHilite]:currentPos()[2] + ::oBase:currentPos()[2]

            IF nPos < 0
               ::oVScroll:setData( ::oVScroll:getData() - nPos )
               ::updPos()
            ENDIF
         ENDIF
      ENDIF

      ::aButtons[nHilite]:hilite()
   ENDIF


RETURN self

METHOD S2FormMenu:pgdown()
   LOCAL nHilite
   LOCAL nPos

   IF ::oDown:isVisible()

      nHilite := ::findBtnHilited()

      IF nHilite != 0
         ::aButtons[nHilite]:dehilite()
      ENDIF

      ::oVScroll:Vscroll(XBPSB_NEXTPAGE)
      ::updPos()

      IF nHilite != 0

         // Cerco il pulsante che e' visibile nella pagina
         DO WHILE .T.
            nPos := ::aButtons[nHilite]:currentPos()[2] + BTN_HEIGHT + BTN_OFFSET + ;
                  ::oBase:currentPos()[2]

            IF nPos <= ::currentSize()[2] - TITLE_HEIGHT .AND. ;
               ::aButtons[nHilite]:isEnabled()

               // OK!
               EXIT
            ENDIF

            nHilite++

            IF nHilite > LEN(::aButtons)
               ::nHilite := 0
               EXIT
            ENDIF

         ENDDO


         IF nHilite != 0
            ::aButtons[nHilite]:hilite()
         ENDIF
      ENDIF

   ELSE
      ::bottom()
   ENDIF

RETURN self

METHOD S2FormMenu:pgup()
   LOCAL nHilite
   LOCAL nPos

   IF ::oUp:isVisible()
      nHilite := ::findBtnHilited()
      IF nHilite != 0
         ::aButtons[nHilite]:dehilite()
      ENDIF

      ::oVScroll:Vscroll(XBPSB_PREVPAGE)
      ::updPos()

      IF nHilite != 0

         // Cerco il pulsante che e' visibile nella pagina
         DO WHILE .T.
            nPos := ::aButtons[nHilite]:currentPos()[2] + ::oBase:currentPos()[2]

            IF nPos > 0 .AND. ;
               ::aButtons[nHilite]:isEnabled()

               // OK!
               EXIT
            ENDIF

            nHilite--

            IF nHilite < 1
               ::nHilite := 0
               EXIT
            ENDIF

         ENDDO


         IF nHilite != 0
            ::aButtons[nHilite]:hilite()
         ENDIF
      ENDIF
   ELSE
      ::top()
   ENDIF
RETURN self

// METHOD S2FormMenu:findKey(nKey)
//    LOCAL bRet
//    LOCAL nPos
//    LOCAL aKeys := { { xbeK_ENTER, {|| ::activate() } }, ;
//                     { xbeK_SPACE, {|| ::activate() } }, ;
//                     { xbeK_DOWN , {|| ::down()     } }, ;
//                     { xbeK_UP   , {|| ::up()       } }, ;
//                     { xbeK_HOME , {|| ::top()      } }, ;
//                     { xbeK_END  , {|| ::bottom()   } }, ;
//                     { xbeK_PGUP , {|| ::pgup()     } }, ;
//                     { xbeK_PGDN , {|| ::pgdown()   } }  }
//
//
//    IF nKey >= 0 .AND. nKey <= ASC("z")
//       bRet := {|n| ::findBtn( UPPER(CHR(n))) }
//    ELSEIF (nPos := ASCAN(aKeys, {|x| x[1]==nKey })) > 0
//       bRet := aKeys[nPos][2]
//    ENDIF
//
// RETURN bRet
//
// METHOD S2FormMenu:keyboard(nKey)
//    LOCAL bExe := ::findKey(nKey)
//    IF bExe == NIL
//       ::XbpStatic:keyboard(nKey)
//    ELSE
//       EVAL(bExe, nKey)
//    ENDIF
// RETURN self

METHOD S2FormMenu:keyboard(nKey)
   LOCAL lHandled := .F.

   DO CASE
      CASE nKey == xbeK_ENTER .OR. nKey == xbeK_SPACE
         ::activate()
         lHandled := .T.

      CASE nKey == xbeK_DOWN
         ::down()
         lHandled := .T.

      CASE nKey == xbeK_UP
         ::up()
         lHandled := .T.

      CASE nKey == xbeK_HOME
         ::top()
         lHandled := .T.

      CASE nKey == xbeK_END
         ::bottom()
         lHandled := .T.

      CASE nKey == xbeK_PGUP
         ::pgup()
         lHandled := .T.

      CASE nKey == xbeK_PGDN
         ::pgdown()
         lHandled := .T.

      CASE nKey >= 0 .AND. nKey <= ASC("z")
         ::findBtn( UPPER(CHR(nKey)))
         lHandled := .T.

   ENDCASE
   IF ! lHandled
      ::XbpStatic:keyboard(nKey)
   ENDIF
RETURN self

METHOD S2FormMenu:findBtn(cKey)
   LOCAL nPrev := ::findBtnHilited()
   LOCAL nHilite
   LOCAL nPos

   nHilite := nPrev

   DO WHILE .T.
      nHilite++

      IF nHilite > LEN(::aButtons)

         IF nPrev == 0
            nHilite := 0
            EXIT
         ENDIF

         // Sono arrivato in fondo ricomicio dall'inizio
         nHilite := 1
      ENDIF

      IF nHilite == nPrev
         // Ho fatto il giro... esco
         EXIT
      ENDIF

      IF STD_HOTKEYCHAR+cKey $ UPPER(::aButtons[nHilite]:caption)
         EXIT
      ENDIF
   ENDDO

   IF ! nHilite == nPrev
      IF nPrev != 0
         ::aButtons[nPrev]:dehilite()
      ENDIF

      // guardo se devo fare lo scroll dell menu
      IF nHilite > nPrev
         // Sono andato verso il basso

         IF ::oDown:isVisible()
            IF nHilite == LEN(::aButtons)
               ::oVScroll:setData( ::oVScroll:range[2] )
               ::updPos()
            ELSE
               nPos := ::aButtons[nHilite]:currentPos()[2] + ::oBase:currentPos()[2]

               IF nPos < 0
                  ::oVScroll:setData( ::oVScroll:getData() - nPos )
                  ::updPos()
               ENDIF
            ENDIF
         ENDIF

      ELSE
         // Sono andato verso l'alto
         IF ::oUp:isVisible()
            IF nHilite == 1
               ::oVScroll:setData( ::oVScroll:range[1] )
               ::updPos()
            ELSE
               nPos := ::aButtons[nHilite]:currentPos()[2] + BTN_HEIGHT + BTN_OFFSET + ;
                       ::oBase:currentPos()[2]

               IF nPos > ::currentSize()[2] - TITLE_HEIGHT
                  ::oVScroll:setData( ::oVScroll:getData() - nPos + ;
                                      (::currentSize()[2]- TITLE_HEIGHT) )
                  ::updPos()
               ENDIF
            ENDIF
         ENDIF

      ENDIF

      ::aButtons[nHilite]:hilite()
   ENDIF

RETURN self

METHOD S2FormMenu:findBtnHilited()
   LOCAL nRet := 0
   LOCAL nInd

   FOR nInd := 1 TO LEN(::aButtons)
      IF ::aButtons[nInd]:isHilited()

         nRet := nInd
         EXIT
      ENDIF
   NEXT
RETURN nRet

CLASS S2FormMenuItm FROM ie4Button
   EXPORTED:
      VAR cChoice

      INLINE METHOD init( oParent, oOwner, aPos, aSize, aPresParm, lVisable )
         ::ie4Button:init( oParent, oOwner, aPos, aSize, aPresParm, lVisable )
         ::autoSize := .T.
         //Mantis 2165 del 20/09/2011
         ::FGColorFocus   := S2InformMenuButtonFocusColor()//GRA_CLR_YELLOW
         ::cChoice := ""
         //Mantis 2165 del 20/09/2011
         ::FGColorNoFocus := S2InformMenuButtonNoFocusColor()//GRA_CLR_WHITE
      RETURN self

ENDCLASS


STATIC CLASS scrollBar
   EXPORTED:
      VAR page
      VAR pos
      VAR range

      INLINE METHOD isTop()
      RETURN ::pos <= ::range[1]

      INLINE METHOD isBottom()
      RETURN ::pos >= ::range[2]

      INLINE METHOD Vscroll(n)
         IF n == XBPSB_NEXTPAGE
            ::pos := MIN(::range[2], ::pos+::page)
         ELSE
            ::pos := MAX(::range[1], ::pos-::page)
         ENDIF
      RETURN self


      INLINE METHOD setData(x)
         ::pos := x
      RETURN self

      INLINE METHOD getData()
      RETURN ::pos

      INLINE METHOD setRange(x)
         IF x!=NIL
            ::range := x
         ENDIF
      RETURN ::range
ENDCLASS



//    LOCAL nInd := 0
//    LOCAL oSubMenu
//    LOCAL cPrompt
//    LOCAL aLabel
//
//    DEFAULT lAllTrim TO .F.
//
//    FOR nInd := 1 TO LEN(aArr)
//
//       aLabel := aArr[nInd]
//
//       IF aLabel[MNI_TYPE] == MN_LINE
//          oMenu:addItem( MENUITEM_SEPARATOR )
//       ELSE
//
//          // Inserisco solo le voci visibili
//          IF aLabel[MNI_SECURITY] == MN_ON .OR. aLabel[MNI_SECURITY] == MN_OFF
//             cPrompt := ::ChgHotKey(aLabel[MNI_LABEL])
//
//             IF ! EMPTY(aLabel[MNI_SACTION])
//                cPrompt += CHR(9)+aLabel[MNI_SACTION]
//             ENDIF
//
//             IF lAllTrim
//                cPrompt := ALLTRIM(cPrompt)
//             ENDIF
//
//             // ha un sottomenu ?
//             IF EMPTY(aLabel[MNI_ARRAY])
//                oMenu:addItem( {cPrompt} )
//
//             ELSE
//
//                oSubMenu := S2Menu():new( oMenu )
//                oSubMenu:create()
//                oSubMenu:title := IIF(lAllTrim, ALLTRIM(cPrompt), cPrompt)
//                oSubMenu:Id := aLabel[MNI_CHILD]
//
//                oSubMenu:itemSelected := {|nItm, uNIL, oXbp | PostAppEvent(xbeP_User+EVENT_MENU_SELECTION, nItm, uNil, oXbp) }
//                oSubMenu:ItemMarked   := {|nItm, uNIL, oXbp | uNil := ::Menufind(oXbp, nItm), ;
//                                                              IIF(uNil==NIL, NIL, dfUsrMsg(uNil[MNI_HELP])) }
//
//                ::MenuCreate( oSubMenu, aLabel[MNI_ARRAY] )
//
//                oMenu:addItem( {oSubMenu} )
//
//             ENDIF
//
//             IF aLabel[MNI_SECURITY] == MN_OFF
//                oMenu:disableItem(oMenu:numItems())
//             ENDIF
//          ENDIF
//
//       ENDIF
//
//    NEXT








