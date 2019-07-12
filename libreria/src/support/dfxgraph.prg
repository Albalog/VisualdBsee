/*
 * Include files:
 */
#include "Gra.ch"
#include "AppEvent.ch"
#include "xbp.ch"
#include "dfStd.ch"
#include "dfXbase.ch"

#define CARGO_PS    1   // Presentation space
#define CARGO_SIZE  2   // dimensioni iniziali del Pres. space
#define CARGO_ADRAW 3   // elenco oggetti da disegnare (drawLine, drawBox, ecc)
#define CARGO_VIEW  4   // dimensioni della vista

STATIC aScreen := {}

// Pulisce la pagina grafica
PROCEDURE dfVgaCls()
   dfGrfClear()
RETURN 

// Pulisce la pagina grafica
PROCEDURE dfVgaCls2()
   dfGrfClear()
RETURN 

// Pulisce la pagina grafica
PROCEDURE dfVgaCls3()
   dfGrfClear()
RETURN 

// Imposta modalit… grafica
PROCEDURE dfSetVga()
   dfModGrf(VGA_640x480x16)
RETURN 

// Imposta modalit… grafica
PROCEDURE dfSetVga256()
   dfModGrf(VGA_320x200x256)
RETURN 

// Imposta modalit… grafica
PROCEDURE dfSetEga()
   dfModGrf(VGA_640x350x16)
RETURN 

// Imposta modalit… Testo
PROCEDURE dfTxtMode()
   dfModGrf(VGA_80x25x16)
RETURN 

// Imposta una modalit… graf. o testo aprendo o chiudendo
// una finestra
PROCEDURE dfModGrf(n)
   LOCAL aModes := { {VGA_640x350x16 , 640, 350,  16}, ;
                     {VGA_640x480x16 , 640, 480,  16}, ;
                     {VGA_320x200x256, 320, 200, 256} }
   LOCAL nPos   := ASCAN(aModes, {|x|x[1]==n})

   IF nPos == 0
      _off()
   ELSE
      _on(aModes[nPos])
   ENDIF
RETURN 

// apre una finestra
STATIC PROCEDURE _on(aMode)
   LOCAL oDlg, aSize, aSzView

   IF EMPTY(aScreen)
      aSzView := {aMode[2], aMode[3]}
      IF !dfSet("XbaseGraphicWindowSize") == "MAX"
         aSize := aSzView
      ENDIF

      oDlg:=_GrfDlgOpen(NIL, aSize, aSzView)
      AADD(aScreen, oDlg)
      oDlg:show()
   ENDIF
RETURN 

// chiude una finestra
STATIC PROCEDURE _off()
   IF !EMPTY(aScreen)
      dfGrfDlgClose(ATAIL(aScreen))
      ASIZE(aScreen, LEN(aScreen)-1)
   ENDIF
RETURN 

// torna il oDlg
FUNCTION dfGrfDlg(oDlg)
   LOCAL oRet

   IF ! EMPTY(aScreen)
      oRet:=ATAIL(aScreen)
   ENDIF

   IF VALTYPE(oDlg) =="O"
      AADD(aScreen, oDlg)
   ENDIF

RETURN oRet

// torna il pres. space
FUNCTION dfGrfDlgGetPS(oDlg)

   IF oDlg == NIL .AND. ! EMPTY(aScreen)
      oDlg:=ATAIL(aScreen)
   ENDIF

RETURN IIF( EMPTY(oDlg), NIL, oDlg:cargo[CARGO_PS])

// Imposta il codeblock di paint
FUNCTION dfGrfDlgSetPaint(oDlg, bPaint)
   LOCAL lRet := .F.
   IF oDlg == NIL .AND. ! EMPTY(aScreen)
      oDlg:=ATAIL(aScreen)
   ENDIF

   IF VALTYPE(oDlg)=="O" .AND. VALTYPE(bPaint) == "B"
      oDlg:drawingArea:paint := bPaint
      lRet := .T.
   ENDIF

RETURN lRet

// Apre un oDlg
FUNCTION dfGrfDlgOpen(cHeader, aSize)
RETURN _GrfDlgOpen(cHeader, aSize)

STATIC FUNCTION _GrfDlgOpen(cHeader, aSize, aSzView)
   LOCAL oDlg, oPS
   LOCAL aPos 
   LOCAL oDraw
   LOCAL lCenter := .F.

   IF aSize == NIL
      aPos  := {0, S2WinStartMenuSize()[2]}
      aSize := S2AppDesktopSize()
   ELSE
      lCenter := .T.
      aPos := {0, 0}
   ENDIF

   oDlg := S2Dialog():new(0,0,1,1)

   oDlg:border    := XBPDLG_SIZEBORDER
   oDlg:title     := cHeader
   oDlg:maxButton := .T.
   oDlg:titleBar  := .T.
   oDlg:keyboard := {|n| IIF(n==xbeK_ESC, PostAppEvent(xbeP_Close, NIL, NIL, oDlg), NIL) }
   oDlg:Create(NIL, NIL, aPos, aSize)
   oDlg:tbConfig()

   IF lCenter
      aSize := oDlg:calcFrameRect({0, 0, aSize[1], aSize[2]})
      oDlg:setSize({aSize[3], aSize[4]})
      S2WinCenter(oDlg, AppDesktop())
   ENDIF

   oDlg:drawingArea:paint:={|| AEVAL(oDlg:cargo[CARGO_ADRAW], {|x| x:paint(oDlg:cargo[CARGO_PS]) }) }

   oPs := oDlg:drawingArea:lockPS()

   oDlg:cargo := { oPS, oDlg:drawingArea:currentSize(), {}, aSzView}

   // Imposta il resize automatico del disegno 
   // in base alle dimensioni della vista
   IF ! EMPTY(aSzView)
      oDlg:drawingArea:resize := {|aO, aNew| _SetViewPort(oDlg, aNew), oDlg:invalidateRect()}
      _SetViewPort(oDlg)
   ENDIF
RETURN oDlg

// Imposta il viewport in modo che il disegno si
// dimensioni automaticamente per riempire la finestra
STATIC PROCEDURE _SetViewPort(oDlg, aNew)
   LOCAL aSize, nY, nY2
   LOCAL aMode := oDlg:cargo[CARGO_VIEW]
   IF aNew == NIL
      aSize:=oDlg:cargo[CARGO_PS]:setPageSize()[1]
   ELSE
      oDlg:cargo[CARGO_PS]:setPageSize(aNew)
      aSize := aNew
   ENDIF
   nY:=aSize[2]

   aSize[1] *= aSize[1]/aMode[1]
   aSize[2] *= aSize[2]/aMode[2]

   // devo riaggiornare la Y degli oggetti
   nY2 := nY-oDlg:cargo[CARGO_SIZE][2]
   AEVAL(oDlg:cargo[CARGO_ADRAW], {|o| o:setOffset({0, nY2}) })
  
   oDlg:cargo[CARGO_PS]:setViewPort({0, nY-aSize[2], aSize[1], nY})
RETURN


// Chiude un oDlg
FUNCTION dfGrfDlgClose(oDlg)
   oDlg:unlockPS( oDlg:cargo[CARGO_PS] )

   oDlg:tbEnd()

   oDlg:destroy()
   oDlg:=NIL
RETURN oDlg

// Gestisce l'event loop
PROCEDURE dfGrfEvLoop(n, oDlg)
   LOCAL oXbp, mp1, mp2, nEvent:=xbeP_None
   LOCAL nEnd
   LOCAL bEval

   IF n != NIL
      nEnd := SECONDS() + n
   ENDIF

   IF VALTYPE(oDlg)=="O" .AND. ! oDlg:isVisible()
      oDlg:show()
   ENDIF

   DO WHILE nEvent != xbeP_Close 
      nEvent := dfAppEvent( @mp1, @mp2, @oXbp )

      IF oXbp != NIL
         oXbp:handleEvent( nEvent, mp1, mp2 )
      ENDIF

      IF n == NIL
         EXIT
      ENDIF

      IF n <> 0 .AND. SECONDS() > nEnd
         EXIT
      ENDIF
   ENDDO
RETURN

// Pulisce la pagina grafica
PROCEDURE dfGrfClear()
   LOCAL oDlg

   IF EMPTY(aScreen); RETURN; ENDIF

   oDlg:=ATAIL(aScreen)

   ASIZE(oDlg:cargo[CARGO_ADRAW], 0)

   oDlg:InvalidateRect()
RETURN

// Disegna un punto
PROCEDURE dfPlot(x1, y1, col)
   dfDraw(x1, y1, x1, y1, col)
RETURN 

// Disegna una linea
PROCEDURE dfDraw(x1, y1, x2, y2, col)
   LOCAL nMaxY, oDlg
   LOCAL oDraw
   LOCAL aAttr

   IF EMPTY(aScreen); RETURN; ENDIF

   oDlg:=ATAIL(aScreen)

   IF VALTYPE(col) == "N"
      aAttr := Array( GRA_AL_COUNT )
      aAttr[GRA_AL_COLOR] := _Clr2Vga(col)
   ENDIF

   // Trasla le coord. su asse Y
   nMaxY := oDlg:cargo[CARGO_SIZE][2]
   Y1 := nMaxY-Y1
   Y2 := nMaxY-Y2

   // Apre il segmento e disegna la linea
   oDraw := drawLine():new({x1, y1}, {x2, y2})
   oDraw:setAttr(aAttr)
   oDraw:paint(oDlg:cargo[CARGO_PS])
   AADD(oDlg:cargo[CARGO_ADRAW], oDraw)

RETURN

// Disegna un box
PROCEDURE dfGrfBox(x1, y1, x2, y2, col1, col2)
   LOCAL nMaxY, oDlg
   LOCAL oDraw
   LOCAL aAttr

   IF EMPTY(aScreen); RETURN; ENDIF

   oDlg:=ATAIL(aScreen)

   IF VALTYPE(col1) == "N" .OR. VALTYPE(col2) =="N"
      aAttr := Array( GRA_AA_COUNT )
      aAttr[GRA_AA_COLOR] := _Clr2Vga(col2)
      aAttr[GRA_AA_BACKCOLOR] := _Clr2Vga(col1)
   ENDIF

   // Trasla le coord. su asse Y
   nMaxY := oDlg:cargo[CARGO_SIZE][2]
   Y1 := nMaxY-Y1
   Y2 := nMaxY-Y2

   oDraw := drawBox():new({x1, y1}, {x2, y2}, GRA_OUTLINEFILL)
   oDraw:setAttr(aAttr)
   oDraw:paint(oDlg:cargo[CARGO_PS])
   AADD(oDlg:cargo[CARGO_ADRAW], oDraw)

RETURN

// Disegna un cerchio
PROCEDURE dfGrfCircle(x1, y1, nraggio, col)
   LOCAL nMaxY, oDlg
   LOCAL oDraw
   LOCAL aAttr

   IF EMPTY(aScreen); RETURN; ENDIF

   oDlg:=ATAIL(aScreen)

   IF VALTYPE(col) == "N" 
      aAttr := Array( GRA_AA_COUNT )
      aAttr[GRA_AA_COLOR] := _Clr2Vga(col)
   ENDIF

   // Trasla le coord. su asse Y
   nMaxY := oDlg:cargo[CARGO_SIZE][2]
   Y1 := nMaxY-Y1

   oDraw := drawCircle():new({x1, y1}, nRaggio)
   oDraw:setAttr(aAttr)
   oDraw:paint(oDlg:cargo[CARGO_PS])
   AADD(oDlg:cargo[CARGO_ADRAW], oDraw)

RETURN

// Disegna una stringa
PROCEDURE dfGrfSay(y1, x1, str, col)
   LOCAL nMaxY, oDlg
   LOCAL oDraw
   LOCAL aAttr

   IF EMPTY(aScreen); RETURN; ENDIF

   oDlg:=ATAIL(aScreen)

   IF VALTYPE(col) == "N"
      aAttr := Array( GRA_AS_COUNT )
      aAttr[GRA_AS_COLOR] := _Clr2Vga(col)
   ENDIF

   y1*=16
   x1*=8

   y1+=12  // aggiusto coord. Y

   // Trasla le coord. su asse Y
   nMaxY := oDlg:cargo[CARGO_SIZE][2]
   Y1 := nMaxY-Y1

   oDraw := drawString():new({x1, y1}, str)
   oDraw:setAttr(aAttr)
   oDraw:paint(oDlg:cargo[CARGO_PS])
   AADD(oDlg:cargo[CARGO_ADRAW], oDraw)

RETURN

// Conversione colore numerico DOS (0-15) in colore Xbase
STATIC FUNCTION _Clr2Vga(n)
  IF n==NIL
     RETURN NIL
  ENDIF
  n:=n%16
RETURN { GRA_CLR_BLACK        , ;
         GRA_CLR_DARKBLUE     , ;
         GRA_CLR_DARKGREEN    , ;
         GRA_CLR_DARKCYAN     , ;
         GRA_CLR_DARKRED      , ;
         GRA_CLR_DARKPINK     , ;
         GRA_CLR_BROWN        , ;
         GRA_CLR_PALEGRAY     , ;
         GRA_CLR_DARKGRAY     , ;
         GRA_CLR_BLUE         , ;
         GRA_CLR_GREEN        , ;
         GRA_CLR_CYAN         , ;
         GRA_CLR_RED          , ;
         GRA_CLR_PINK         , ;
         GRA_CLR_YELLOW       , ;
         GRA_CLR_WHITE        }[n+1]


// Classi per disegnare linea, box, cerchio e stringa
// in modo da memorizzare oltre alla posizione anche gli 
// attributi (colori)

STATIC CLASS drawObj

PROTECTED:
   VAR aAttr
   VAR aPos1
   VAR aOffset

EXPORTED: 

   INLINE METHOD init(aPos1)
      ::aPos1  :=aPos1
      ::aOffset:={0, 0}
      ::aAttr  :=NIL
   RETURN self

   INLINE METHOD setOffset(aOff)
      ::aOffset:=aOff
   RETURN ::aOffset

   INLINE METHOD setAttr(aAttr)
      ::aAttr:=aAttr
   RETURN ::aOffset

   INLINE METHOD paint(oPS)
   RETURN self

ENDCLASS


STATIC CLASS drawLine  FROM drawObj
EXPORTED 
   VAR aPos2

   INLINE METHOD init(aPos1, aPos2)
      ::drawObj:init(aPos1)
      ::aPos2:=aPos2
   RETURN self

   INLINE METHOD paint(oPS)
      IF ::aAttr != NIL
         GraSetAttrLine(oPS, ::aAttr)
      ENDIF
      GraLine(oPS, ;
              {::aPos1[1]+::aOffset[1], ::aPos1[2]+::aOffset[2]}, ;
              {::aPos2[1]+::aOffset[1], ::aPos2[2]+::aOffset[2]})
   RETURN self
ENDCLASS

STATIC CLASS drawBox  FROM drawObj
EXPORTED 
   VAR aPos2
   VAR nFill

   INLINE METHOD init(aPos1, aPos2, nFill)
      ::drawObj:init(aPos1)
      ::aPos2:=aPos2
      ::nFill:= nFill
   RETURN self


   INLINE METHOD paint(oPS)
      IF ::aAttr != NIL
         GraSetAttrArea(oPS, ::aAttr)
      ENDIF
      GraBox(oPS, ;
             {::aPos1[1]+::aOffset[1], ::aPos1[2]+::aOffset[2]}, ;
             {::aPos2[1]+::aOffset[1], ::aPos2[2]+::aOffset[2]}, ;
             ::nFill)
   RETURN self
ENDCLASS

STATIC CLASS drawCircle FROM drawObj
EXPORTED 
   VAR nRad

   INLINE METHOD init(aPos1, nRad)
      ::drawObj:init(aPos1)
      ::nRad :=nRad 
   RETURN self

   INLINE METHOD paint(oPS)
      IF ::aAttr != NIL
         GraSetAttrArea(oPS, ::aAttr)
      ENDIF
      GraArc(oPS, {::aPos1[1]+::aOffset[1], ::aPos1[2]+::aOffset[2]}, ::nRad)
   RETURN self
ENDCLASS

STATIC CLASS drawString FROM drawObj
EXPORTED 
   VAR cStr

   INLINE METHOD init(aPos1, cStr)
      ::drawObj:init(aPos1)
      ::cStr :=cStr 
   RETURN self

   INLINE METHOD paint(oPS)
      IF ::aAttr != NIL
         GraSetAttrString(oPS, ::aAttr)
      ENDIF
      GraStringAt(oPS, {::aPos1[1]+::aOffset[1], ::aPos1[2]+::aOffset[2]}, ;
                  ::cStr)
   RETURN self
ENDCLASS
