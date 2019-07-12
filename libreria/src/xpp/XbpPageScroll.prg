#include "Common.ch"
#include "Xbp.ch"
#include "Gra.ch"
#include "Appevent.ch"
#include "font.ch"

// -----------------------------------------------------------------------
#define BTN_OFFSET      1  // distanza dallo static interno
#define ICON_HEIGHT    22  // altezza icona per UP/down
#define ICON_WIDTH     22  // larghezza icona per UP/down
#define SCROLLBAR_WIDTH  16  // larghezza scrollbar

// Nome della classe
#define _THISXBP_NAME  XbpPageScroll

// Eredita da
#define _THISXBP_SUPER XbpStatic

#define _THISXBP_BUTTON XbpPushButton 

#ifdef _TEST_
PROCEDURE Main()
   LOCAL oXbp 
   LOCAL oDlg
   LOCAL o
   LOCAL n
   LOCAL aPos

   oDlg := XbpDialog():new(AppDesktop(), NIL, {10, 100}, {300, 300})
   oDlg:sysmenu := .T.
   oDlg:taskList:= .T.
   oDlg:title := "test"
   oDlg:drawingArea:resize := {|o, n| oXbp:setPos({0, 0}), oXbp:setSize(n)}
   oDlg:create()


   oXbp := _THISXBP_NAME():New(oDlg:drawingarea, NIL, {20, 50}, {150, 160})
//   oXbp:caption := "test"
//   oXbp:setColorBG(GRA_CLR_WHITE)
   oXbp:Create()

   n := oXbp:SetDrawingAreaHeight(660)

   aPos := {0, n}
   for n := 1 TO 22
       aPos[2] -= 30
       o:= XbpPushButton():new(oXbp:drawingArea, NIL, aPos, {100, 25})
       o:caption := "test "+alltrim(str(n))
       o:activate := {||MsgBox("ciao "+alltrim(str(n)))}
       o:create()
   next

   //oxbp:setpos({0, 0})
   //oxbp:setsize({80,200})

   Inkey(0)
                        
RETURN 
#endif

CLASS _THISXBP_NAME FROM _THISXBP_SUPER

PROTECTED:
   VAR oVScroll

EXPORTED:
   VAR drawingarea
   VAR aIconSize
   VAR oUp
   VAR oDown
   VAR lOverlappedButtons       // icone UP/DOWN sopra il drawingarea?
   VAR style

   METHOD Init
   METHOD Create
   METHOD SetSize

   METHOD SetDrawingAreaHeight  // Imposta l'altezza dello static interno
   METHOD updPos
   METHOD pgup
   METHOD pgdown


ENDCLASS

METHOD _THISXBP_NAME:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )

//   DEFAULT aPP TO  { {XBP_PP_BGCLR       , GRA_CLR_DARKBLUE}, ;
//                     {XBP_PP_FGCLR       , GRA_CLR_WHITE   }  }

   ::_THISXBP_SUPER:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::oVScroll:=ps_scrollbar():new()
   ::drawingarea  := XbpStatic():new()
   ::aIconSize    := {ICON_HEIGHT, ICON_WIDTH}
   ::lOverlappedButtons := .F.
   ::style        := 0 // 0=con pulsanti 1=scrollbar
RETURN self

METHOD _THISXBP_NAME:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oXbp
   ::_THISXBP_SUPER:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   aSize := ::currentSize()
   aPos := AClONE(aSize)

   IF ::style == 0
      aPos[1] := aSize[1] - BTN_OFFSET - ::aIconSize[2]
      aPos[2] -= BTN_OFFSET
      aPos[2] -= ::aIconSize[1]

      IF EMPTY(::oUp)
         oXbp := _THISXBP_BUTTON():new()
         oXbp:caption := "up"
      //   oXbp:caption := FORMMENU_UP
      //   oXbp:type    := XBPSTATIC_TYPE_BITMAP

         oXbp:clipSiblings := .T.
         ::oUp := oXbp
      ENDIF

      ::oUp:activate := {|| ::pgUp() }
      ::oUp:create(self,NIL, aPos, ::aIconSize, NIL, .F. )

      IF EMPTY(::oDown)
         oXbp := _THISXBP_BUTTON():new()
         oXbp:caption := "dn"
         //oXbp:caption := FORMMENU_DOWN
         //oXbp:type    := XBPSTATIC_TYPE_BITMAP
         oXbp:clipSiblings := .T.
         ::oDown := oXbp
      ENDIF

      aPos[2] := BTN_OFFSET
      ::oDown:activate := {|| ::pgdown() }
      ::oDown:create(self,NIL, aPos, ::aIconSize, NIL, .F. )
   ELSE
      aPos[1] := aSize[1] - BTN_OFFSET - SCROLLBAR_WIDTH
      aPos[2] := 0
      aSize[1] := SCROLLBAR_WIDTH
      ::oVScroll := XbpScrollBar():new()
      ::oVScroll:type := XBPSCROLL_VERTICAL
      ::oVScroll:create(self, NIL, aPos, aSize)
      ::oVScroll:scroll := {|| ::updPos()}
   ENDIF
   ::drawingArea:clipSiblings := .T.
   ::drawingarea:create(self,NIL,{0,0})

   ::oVScroll:setRange({0,0})
   ::oVScroll:setData( 0 )
   ::SetDrawingAreaHeight(::currentSize()[2])

   IF ::style == 0
      ::drawingArea:toBack()
      ::oUp:toFront()
      dfSetXbpOnTop(::oUP)
      ::oDown:toFront()
      dfSetXbpOnTop(::oDown)
   ENDIF
RETURN self

METHOD _THISXBP_NAME:updPos()
   LOCAL aPos  := ::drawingarea:currentPos()
   LOCAL nI

   nI    := ::oVScroll:getData()
   aPos[2] := nI - ::oVScroll:setRange()[2]

   ::drawingarea:setPos(aPos)
   IF ::Style == 0
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
   ENDIF
RETURN self

METHOD _THISXBP_NAME:pgdown()
   IF ::oDown:isVisible()
      ::oVScroll:Vscroll(XBPSB_NEXTPAGE)
      ::updPos()
   ENDIF
RETURN self

METHOD _THISXBP_NAME:pgup()
   IF ::oUp:isVisible()
      ::oVScroll:Vscroll(XBPSB_PREVPAGE)
      ::updPos()
   ENDIF
RETURN self

METHOD _THISXBP_NAME:SetSize(aNew, lShow)
   LOCAL aPos

   DEFAULT lShow TO .T.

   ::lockUpdate(.T.)

   ::_THISXBP_SUPER:SetSize(aNew)
   IF ::Style == 0
      aPos := aNew

      aPos[1] := aNew[1] - BTN_OFFSET - ::aIconSize[2]
      aPos[2] -= BTN_OFFSET
      aPos[2] -= ::aIconSize[1]
      ::oUp:setPos(aPos)

      aPos[2] := BTN_OFFSET
      ::oDown:setPos(aPos)
   ELSE
      aPos := {0, 0}
      aPos[1] := aNew[1] - BTN_OFFSET - SCROLLBAR_WIDTH
      aNew[1] := SCROLLBAR_WIDTH
      ::oVScroll:setPosAndSize(aPos, aNew, .F.)
   ENDIF
   // Refresh
   ::SetDrawingAreaHeight(::SetDrawingAreaHeight() )
   ::lockUpdate(.F.)

   IF lShow 
      ::invalidateRect()
   ENDIF

RETURN .T.

METHOD _THISXBP_NAME:SetDrawingAreaHeight(nNew)
   LOCAL nY
   LOCAL nPrev
   LOCAL aNew 

   IF nNew != NIL
//      aNew := { ::currentSize()[1] - BTN_OFFSET - ::aIconSize[1], ;
//                nNew }
      aNew := { ::currentSize()[1] - BTN_OFFSET , ;
                nNew }
      IF ::Style == 0
         IF ! ::lOverlappedButtons
            aNew[1] -= ::aIconSize[1]
         ENDIF
      ELSE
         aNew[1] -= SCROLLBAR_WIDTH
      ENDIF
      ::drawingArea:setSize(aNew)

      nY := ::currentSize()[2] - nNew

      nPrev := ::oVScroll:getData()

      IF nY < 0
         nY := -nY
         ::oVScroll:setRange({0,nY})
         ::oVScroll:setData(MIN(nPrev, nY))
         IF ::style == 0
            ::oVScroll:page := MAX(1,MIN(nY, ::currentSize()[2]))
         ELSE
            ::oVScroll:show()
            ::oVScroll:setScrollBoxSize( MAX(1,MIN(nY, ::currentSize()[2])) )
         ENDIF
         ::updPos()
      ELSE
         IF ::style == 0
            ::oUp:hide()
            ::oDown:hide()
         ELSE
            ::oVScroll:hide()
         ENDIF
         ::oVScroll:setRange({0,0})
         ::oVScroll:setData( 0 )
         ::drawingarea:setPos({0, nY})
      ENDIF
   ENDIF
RETURN ::drawingArea:currentSize()[2]



#undef _THISXBP_NAME
#undef _THISXBP_SUPER

STATIC CLASS ps_scrollBar
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



