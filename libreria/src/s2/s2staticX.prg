// -----------------------------
// Template per nuovo Xbase Part
// -----------------------------
#include "Common.ch"
#include "Gra.ch"
#include "Xbp.ch"
#include "AppEvent.ch"

#include "dfCtrl.ch"
#include "dfXbase.ch"

// simone 1/6/05
// mantis 0000760: abilitare nuovi stili per i controls
//
// Static con possibilit… di disegno groupbox
// GROUPBOXFANCY1
// GROUPBOXFANCY2 Š identico al FANCY1 ma usa diversi STATIC interni
//                 in modo che il display sia pi— "stabile"
// GROUPBOXFANCY3 Š identico al FANCY1 ma usa una sola bitmap 
//                 in modo che il display sia pi— "stabile"



// simone 6/12/07 
// mantis 0001687: implementare visualizzazione HTML
//
// inizio di implementazione testo HTML 
// quando il caption Š tipo "[htmltext:ciao <b>grassetto</b>]"
// solo con Xbase 1.90
// per ora disattivato perche non completo 
// vedi anche funzione AlertBox() e S2HTMLTextParse()
//
// #define USE_HTMLTEXT

// Nome della classe
#define _THISXBP_NAME  S2StaticX

// Eredita da
#define _THISXBP_SUPER XbpStatic

#ifdef _TEST_
   PROCEDURE Main()
      LOCAL oXbp 

      oXbp := _THISXBP_NAME():New(NIL, NIL, {20, 50}, {80, 160})
      oXbp:caption := "test"
      oXbp:Create()
      Inkey(0)

   RETURN 
#endif

#define HEADER_COLORBG      GraMakeRGBColor({193,210,238}) //XBPSYSCLR_INACTIVETITLE
#define DEFAULT_COLORBG     XBPSYSCLR_INFOBACKGROUND
#define HEADER_HEIGHT       0 //20
#define HEADER_HEIGHTAUTO   -1
#define OFFSET              4

CLASS _THISXBP_NAME FROM _THISXBP_SUPER
   PROTECTED: 
      VAR    _type
      VAR    oHFont
      VAR    cHFontCompoundName

#ifdef USE_HTMLTEXT
      // usati in stile HTML
      VAR    oHtml
      METHOD getHtmlSize
#endif

      // Usati in FANCY2
      VAR    oHeadBG            
      VAR    oHeadText
      VAR    _oBmpBG

      METHOD createFancy2
      METHOD destroyFancy2
      METHOD paintBackBMP
      METHOD destroyBMP

      METHOD resizeControls

  EXPORTED:
//      VAR    image
      VAR    caption
      VAR    headerHeight
      VAR    headerAlign
      VAR    headerColorBG
      VAR    headerColorFG
      VAR    borderColor

      METHOD Init
      METHOD Create
      METHOD Configure
      METHOD Destroy

      METHOD disable

      ACCESS ASSIGN METHOD headerColorBG

      // Usato in FANCY1 e FANCY3
      METHOD paintGroupBox

      METHOD setSize           // aggiunta gestione minSize e maxSize
      METHOD SetPosAndSize
      METHOD setCaption
      METHOD paint

      METHOD getType
      METHOD setHFont
      METHOD setHFontCompoundName
      METHOD GetColorBG
      ///////////////////////////
      METHOD SetColorBG
      ///////////////////////////
ENDCLASS

METHOD _THISXBP_NAME:GetColorBG()
   LOCAL cBG := ::setColorBG() 
   IF cBG == NIL
      cBG  := DEFAULT_COLORBG
   ENDIF
RETURN cBG

////////////////////////////////
//Luca 3/1/2007
//Workaround: Su form con Activx la funzione SETColorBG(-34) va in crash. Il motivo non Š noto.
///////////////////////////
METHOD _THISXBP_NAME:SetColorBG(cBG)
   IF cBG == NIL
      cBG := ::_THISXBP_SUPER:SetColorBG()
   ELSE
      cBG := ::_THISXBP_SUPER:SetColorBG(cBG)
   ENDIF
RETURN cBG
///////////////////////////

METHOD _THISXBP_NAME:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::_THISXBP_SUPER:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::_type := NIL
   ::headerHeight  := HEADER_HEIGHTAUTO
   ::headerColorBG := HEADER_COLORBG
   ::headerAlign   := GRA_HALIGN_RIGHT
   ::borderColor   := NIL
RETURN self

METHOD _THISXBP_NAME:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   IF ::type == XBPSTATIC_TYPE_GROUPBOXFANCY1
      ::_type := ::type
      ::type := XBPSTATIC_TYPE_TEXT //FGNDFRAME 
      ::clipChildren := .T.
   ELSEIF ::type == XBPSTATIC_TYPE_GROUPBOXFANCY2
      ::_type := ::type
      ::type := XBPSTATIC_TYPE_BITMAP
      ::clipChildren := .T.
   ELSEIF ::type == XBPSTATIC_TYPE_GROUPBOXFANCY3
      ::_type := ::type
      ::type := XBPSTATIC_TYPE_BITMAP
      ::clipChildren := .T.
   ENDIF

#ifdef USE_HTMLTEXT
   IF ::autoSize  
      IF ::getHTMLSize(::caption) != NIL
         aSize := ::getHTMLSize(::caption)
         ::autoSize:=.F.
      ELSE
         ::_THISXBP_SUPER:caption := ::caption
      ENDIF
   ENDIF
#endif

   IF ::Status() == XBP_STAT_CREATE
      ::_THISXBP_SUPER:Destroy()
   ENDIF 
   ::_THISXBP_SUPER:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   IF ::getType() == XBPSTATIC_TYPE_GROUPBOXFANCY2
      ::paintBackBMP()
      ::createFancy2()
   ELSEIF ::getType() == XBPSTATIC_TYPE_GROUPBOXFANCY3
      ::paintBackBMP()
   ENDIF
#ifdef USE_HTMLTEXT
   ::_THISXBP_NAME:setCaption(::caption)
#endif
RETURN self

METHOD _THISXBP_NAME:Configure( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::destroyFancy2()
   ::destroyBMP()

   IF ::type == XBPSTATIC_TYPE_GROUPBOXFANCY1
      ::_type := ::type
      ::type := XBPSTATIC_TYPE_TEXT //FGNDFRAME 
      ::clipChildren := .T.
   ELSEIF ::type == XBPSTATIC_TYPE_GROUPBOXFANCY2
      ::_type := ::type
      ::type := XBPSTATIC_TYPE_BITMAP
      ::clipChildren := .T.
   ELSEIF ::type == XBPSTATIC_TYPE_GROUPBOXFANCY3
      ::_type := ::type
      ::type := XBPSTATIC_TYPE_BITMAP
      ::clipChildren := .T.
   ELSE
      ::_type := NIL
#ifdef USE_HTMLTEXT
#else
      ::_THISXBP_SUPER:caption := ::caption 
#endif
   ENDIF

   ::_THISXBP_SUPER:Configure( oParent, oOwner, aPos, aSize, aPP, lVisible )

   IF ::getType() == XBPSTATIC_TYPE_GROUPBOXFANCY2
      ::paintBackBMP()
      ::createFancy2()
   ELSEIF ::getType() == XBPSTATIC_TYPE_GROUPBOXFANCY3
      ::paintBackBMP()
   ENDIF
#ifdef USE_HTMLTEXT   
   ::_THISXBP_NAME:setCaption(::caption)
#endif   
RETURN self

METHOD _THISXBP_NAME:destroyFancy2()
   IF ::oHeadBG != NIL 
      IF ::oHeadBG:status() == XBP_STAT_CREATE
         ::oHeadBG:destroy()
      ENDIF
      ::oHeadBG := NIL
   ENDIF

   IF ::oHeadText != NIL 
      IF ::oHeadText:status() == XBP_STAT_CREATE
         ::oHeadText:destroy()
      ENDIF
      ::oHeadText := NIL
   ENDIF
RETURN self

METHOD _THISXBP_NAME:createFancy2()
   LOCAL aPos
   LOCAL aSize
   LOCAL nBorderColor 
   LOCAL nHeaderHeight

   ::oHeadBG := XbpStatic():new(self, NIL, NIL, NIL, NIL, .F.)
   //::oHeadBG:type := XBPSTATIC_TYPE_BGNDRECT
   ::oHeadBG:create()
   ::setHFont( ::setHFont() )
   ::setHFontCompoundName( ::setHFontCompoundName() )

   nBorderColor := ::borderColor
   DEFAULT nBorderColor TO ::setColorFG()
   IF nBorderColor != NIL
      ::oHeadBG:setColorBG(nBorderColor)
   ENDIF

   aSize := ::currentsize()
   //aSize[1] -= 2

   nHeaderHeight := ::headerHeight
   IF nHeaderHeight == HEADER_HEIGHTAUTO
      IF EMPTY(::caption)
         nHeaderHeight := HEADER_HEIGHT
      ELSE
         nHeaderHeight := S2StringDim(::oHeadBG, ::caption)[2]
      ENDIF
   ENDIF

   aPos := {0, aSize[2]-nHeaderHeight}
   aSize[2] := nHeaderHeight

   ::oHeadBG:setPosAndSize(aPos, aSize)

   aSize[1] -= 2
   aSize[2] -= 2
   ::oHeadText := XbpStatic():new(::oHeadBG, NIL, {1, 1}, aSize)
   ::oHeadText:options := XBPSTATIC_TEXT_VCENTER 
   DO CASE
      CASE ::headerAlign == GRA_HALIGN_LEFT
         ::oHeadText:options += XBPSTATIC_TEXT_LEFT 

      CASE ::headerAlign == GRA_HALIGN_RIGHT
         ::oHeadText:options += XBPSTATIC_TEXT_RIGHT

      OTHERWISE  //centrato
         ::oHeadText:options += XBPSTATIC_TEXT_CENTER
   ENDCASE
   ::oHeadText:caption := ::caption 
   ::oHeadText:create()
   ::oHeadText:setColorBG(::headerColorBG)

   ::oHeadBG:show()
RETURN self

METHOD _THISXBP_NAME:DestroyBMP()
   IF ::_oBmpBG != NIL
      IF ::_oBmpBG:status() == XBP_STAT_CREATE
         ::_oBmpBG:destroy()
      ENDIF
      ::_oBmpBG := NIL
   ENDIF
RETURN self


METHOD _THISXBP_NAME:Destroy()
#ifdef USE_HTMLTEXT
   IF ! EMPTY(::oHtml)
      ::oHtml:destroy()
      ::oHtml := NIL
   ENDIF
#endif
   ::destroyBMP()
   
   IF ::oHeadBG != NIL
      ::oHeadBG := NIL
   ENDIF
   IF ::oHeadText != NIL
      ::oHeadText := NIL
   ENDIF

   ::_THISXBP_SUPER:Destroy()
RETURN self

METHOD _THISXBP_NAME:setCaption(c)
   LOCAL nType := ::getType()
   LOCAL lHtml :=.F., lURL
   LOCAL aSize, aSBSize

   ::caption := c
   IF nType == XBPSTATIC_TYPE_GROUPBOXFANCY1 .OR. ;
      nType == XBPSTATIC_TYPE_GROUPBOXFANCY2 .OR. ;
      nType == XBPSTATIC_TYPE_GROUPBOXFANCY3 

      IF nType == XBPSTATIC_TYPE_GROUPBOXFANCY1
         ::invalidateRect()
      ELSEIF nType == XBPSTATIC_TYPE_GROUPBOXFANCY2
         IF ::oHeadText != NIL
            ::oHeadText:setCaption(c)
         ENDIF
      ELSEIF nType == XBPSTATIC_TYPE_GROUPBOXFANCY3 
         ::paintBackBMP()
      ENDIF

//      ::_THISXBP_SUPER:setCaption("")

   ELSE
      IF ::type==XBPSTATIC_TYPE_TEXT
         lHtml := S2HTMLTextParse(@c, @aSize, @lURL)
      ENDIF

#ifdef USE_HTMLTEXT
      IF lHtml
         DEFAULT aSize TO ::currentSize()
         // evito bordino
         aSize[1] += 8
         aSize[2] += 8
         IF EMPTY(::oHtml)
            ::oHtml :=  XbpHTMLViewer():new( self ) 
            IF ::status()==XBP_STAT_CREATE
               ::oHTML:create( NIL,NIL, {-4, -4}, aSize) 
            ENDIF
         ENDIF
         //#define SM_CXVSCROLL = 2 'X Size of arrow in vertical scroll bar.
         //#define SM_CYHSCROLL = 3 'Y Size of arrow in horizontal scroll bar
         aSBSize := {S2GetSystemMetrics(2), S2GetSystemMetrics(3)}
         IF aSize[1] < 2*aSBSize[1]
            aSize[1] += aSBSize[1]
            lHTML := .F.
         ENDIF
         IF aSize[2] < 2*aSBSize[2]
            aSize[2] += aSBSize[2]
            lHTML := .F.
         ENDIF

         IF !lHTML
            ::oHtml:setSize(aSize)
         ENDIF
         IF lURL
            // 
            // Navigate to folder URI
            //  
            // 
            ::oHTML:navigate(c) 
         ELSE
            ::oHtml:setHTML(c)
         ENDIF
      ELSE
         IF ! EMPTY(::oHtml)
            ::oHtml:destroy()
            ::oHtml := NIL
         ENDIF
      ::_THISXBP_SUPER:setCaption(c)
   ENDIF
#else
      ::_THISXBP_SUPER:setCaption(c)
#endif      
   ENDIF
RETURN .T.

#ifdef USE_HTMLTEXT
METHOD _THISXBP_NAME:getHtmlSize(c)
   LOCAL aSize := {0, 0}
   S2HTMLTextParse(c, @aSize)
RETURN aSize
#endif

// workaround:
// i tipi bitmap in disabled non visualizzano la bitmap
METHOD _THISXBP_NAME:disable()
   LOCAL lRet := .T.
   IF EMPTY( ::_oBmpBG)
      lRet := ::_THISXBP_SUPER:disable()
   ELSE
      // esegue il disable usando le API di windows
      // che non modificano la bitmap
      #define WS_DISABLED         0x08000000
      dfXBPSetStyle(self, WS_DISABLED, .T.)
   ENDIF
RETURN lRet


METHOD _THISXBP_NAME:headerColorBG(n)
   LOCAL nRet := ::headerColorBG
   LOCAL nType
   IF n != NIL

      ::headerColorBG := n
      nType := ::getType()
      IF nType == XBPSTATIC_TYPE_GROUPBOXFANCY1
         ::invalidateRect()
      ELSEIF nType == XBPSTATIC_TYPE_GROUPBOXFANCY1
         IF ::oHeadText != NIL
            ::oHeadText:setColorBG(n)
         ENDIF
      ELSE
         ::paintBackBMP()
      ENDIF
   ENDIF
RETURN nRet

METHOD _THISXBP_NAME:Paint()
   LOCAL oPS
   IF ::getType() == XBPSTATIC_TYPE_GROUPBOXFANCY1
      oPS := ::lockPS()
      ::paintGroupBox( ::getType(), oPS )
      ::unlockPS(oPS)
      oPS := NIL
   ENDIF
RETURN .T.

METHOD _THISXBP_NAME:PaintGroupBox(nType, oPS)
   LOCAL aSize := ::currentSize()
   LOCAL aPos  := {0, 0}
   LOCAL aAttr
   LOCAL oFont
   LOCAL nHeaderHeight
   LOCAL aDim, nWidth, nHeight
   LOCAL nBorderColor 
   LOCAL nColorBG

   IF nType == XBPSTATIC_TYPE_GROUPBOXFANCY1 .OR. nType == XBPSTATIC_TYPE_GROUPBOXFANCY3

      IF nType == XBPSTATIC_TYPE_GROUPBOXFANCY3 
         nColorBG := ::setColorBG()
         DEFAULT nColorBG TO DEFAULT_COLORBG
      ENDIF

      nBorderColor := ::borderColor
      DEFAULT nBorderColor TO ::setColorFG()

      // disegna un bordo
      dfPSPaintBorder(oPS, aPos, aSize, PS_BORDER, NIL, nBorderColor, nColorBG, NIL )

      nHeaderHeight := ::headerHeight
      IF nHeaderHeight == HEADER_HEIGHTAUTO .OR. nHeaderHeight > 0
         // imposta font header
         IF ! EMPTY(::caption)
            IF ! EMPTY(::setHFont())
               GraSetFont(oPS, ::setHFont())

            ELSEIF ! EMPTY(::setHFontCompoundName())
               oFont := XbpFont():new(oPS):create(::setHFontCompoundName())
               GraSetFont(oPS, oFont)
            ENDIF
         ENDIF

         // calcolo altezza header
         IF nHeaderHeight == HEADER_HEIGHTAUTO
            IF EMPTY(::caption)
               nHeaderHeight := HEADER_HEIGHT
            ELSE
               aDim := GraQueryTextBox(oPS, ::caption)

               nWidth  := MAX(aDim[3][1], aDim[4][1]) - MIN(aDim[1][1], aDim[2][1])
               nHeight := MAX(aDim[3][2], aDim[4][2]) - MIN(aDim[1][2], aDim[2][2])

               nHeaderHeight := nHeight + OFFSET
            ENDIF
         ENDIF

         // disegna header
         aPos[2]  := aSize[2] - nHeaderHeight
         aSize[2] := nHeaderHeight
         dfPSPaintBorder(oPS, aPos, aSize, PS_BORDER, NIL, NIL, ::headerColorBG, NIL )

         // scrive testo header
         IF ! EMPTY(::caption)
            DO CASE
               CASE ::headerAlign == GRA_HALIGN_LEFT
                  aPos[1] := OFFSET

               CASE ::headerAlign == GRA_HALIGN_RIGHT
                  aPos[1] := aSize[1]-OFFSET

               OTHERWISE  //centrato
                  ::headerAlign := GRA_HALIGN_CENTER
                  aPos[1] := ROUND(aSize[1]/2, 0)
            ENDCASE
            aPos[2]+=OFFSET

            aAttr := ARRAY( GRA_AS_COUNT )

            //aAttr [ GRA_AS_BOX        ] := { 8, 16 } 
            aAttr [ GRA_AS_HORIZALIGN ] := ::headerAlign
            //aAttr [ GRA_AS_COLOR      ] := GRA_CLR_GREEN 
            GraSetAttrString( oPS, aAttr ) 

            // Simone 9/1/08 il carattere "~" viene visualizzato, lo tolgo!
            GraStringAt( oPS, aPos, STRTRAN(::Caption, STD_HOTKEYCHAR, "")) 
         ENDIF

         IF oFont != NIL
            oFont:destroy()
            oFont := NIL
         ENDIF

         // scrive immagine
//         IF ! EMPTY(::image) 
//
//            ::image:draw(oPS, aPos)
//         ENDIF
      ENDIF
   ENDIF
RETURN .T.

// usato in stile GROUPBOX_FANCY2
METHOD _THISXBP_NAME:paintBackBMP(nPaintStyle, nLineWidth, xFG, xBG, aRound)
   LOCAL oPS 
   LOCAL aSz 
   LOCAL aAttr
   LOCAL _oBmpBG

   DEFAULT nPaintStyle TO PS_BORDER
   DEFAULT xFG         TO ::borderColor
   DEFAULT xFG         TO ::setColorFG()
   DEFAULT xBG         TO ::setColorBG()
   DEFAULT xBG         TO DEFAULT_COLORBG

   ::destroyBMP()

   IF nPaintStyle == PS_STD
      RETURN self
   ENDIF

   IF ! ::status()==XBP_STAT_CREATE
      RETURN self
   ENDIF

   IF ::getType() == XBPSTATIC_TYPE_GROUPBOXFANCY2
      _oBmpBG := dfBMPPaintBack(::currentSize(), nPaintStyle, nLineWidth, xFG, xBG, aRound)
   ELSE
      _oBmpBG := dfBMPPaint(::currentSize(), {|oPS| ::paintGroupBox(XBPSTATIC_TYPE_GROUPBOXFANCY3, oPS )})
   ENDIF

   ::_THISXBP_SUPER:setCaption(_oBmpBG)
   ::_oBmpBG := _oBmpBG
RETURN self

METHOD _THISXBP_NAME:setSize(aSize, lUpdate)
   LOCAL nX:=0
   LOCAL nY:=0
   LOCAL nMaxX:=NIL
   LOCAL nMaxY:=NIL
   LOCAL lRet
   LOCAL aOld := ::currentSize()

   DEFAULT lUpdate TO .T.

   lRet := ::_THISXBP_SUPER:SetSize(aSize, .F.)
   ::resizeControls(aOld, aSize, .F.)
   IF lUpdate
      ::invalidateRect()
   ENDIF
RETURN lRet

METHOD _THISXBP_NAME:setPosAndSize(aPos, aSize, lUpdate)
   LOCAL lRet1,lRet2
   DEFAULT lUpdate TO .T.

   lRet1 := ::SetPos(aPos, .F.)
   lRet2 := ::SetSize(aSize, .F.)

   IF lUpdate
      ::invalidateRect()
   ENDIF

RETURN lRet1 .AND. lRet2

METHOD _THISXBP_NAME:resizeControls(aOld, aNew, lLock)
   LOCAL aSBSize

   ::destroyBMP()
   ::destroyFancy2()

   IF ::getType() == XBPSTATIC_TYPE_GROUPBOXFANCY2
      ::paintBackBMP()
      ::createFancy2()
   ELSEIF ::getType() == XBPSTATIC_TYPE_GROUPBOXFANCY3
      ::paintBackBMP()

#ifdef USE_HTMLTEXT
   ELSEIF ! EMPTY(::oHtml)
      aSBSize := {S2GetSystemMetrics(2), S2GetSystemMetrics(3)}
      IF aNew[1] < 2*aSBSize[1]
         aNew[1] += aSBSize[1]
      ENDIF
      IF aNew[2] < 2*aSBSize[2]
         aNew[2] += aSBSize[2]
      ENDIF
      ::oHtml:setSize(aNew, lLock)
#endif      
   ENDIF
RETURN self

METHOD _THISXBP_NAME:getType()
RETURN IIF(::_type == NIL, ::type, ::_type)

METHOD _THISXBP_NAME:setHFont(o)
   LOCAL xRet := ::oHFont
   IF VALTYPE(o) == "O" .AND. o:IsDerivedFrom("XbpFont")
      ::oHFont := o

      IF ::getType() == XBPSTATIC_TYPE_GROUPBOXFANCY3 
         ::paintBackBMP()
      ENDIF
      IF ::oHeadBG != NIL
         ::oHeadBG:setFont(o)
      ENDIF
   ENDIF
RETURN xRet

METHOD _THISXBP_NAME:setHFontCompoundName(c)
   LOCAL xRet := ::cHFontCompoundName
   IF VALTYPE(c) $ "CM"
      ::cHFontCompoundName := c

      IF ::getType() == XBPSTATIC_TYPE_GROUPBOXFANCY3 
         ::paintBackBMP()
      ENDIF
      IF ::oHeadBG != NIL
         ::oHeadBG:setFontCompoundName(c)
      ENDIF
   ENDIF
RETURN xRet

#undef _THISXBP_NAME
#undef _THISXBP_SUPER

// Workaround per :setParent() impostato prima di Create
//
// problem in Xbase 1.82.294
//
// using :setParent() before an object is created, the object is added to the childlist() of the parent. 
// When the object is created, the object is added another time to the childlist() of the parent. 
// When the parent is destroyed, there is a runtime error because the same object is destroyed 2 times.

/*
STATIC CLASS _FixXbpStatic FROM XbpStatic
PROTECTED:
   VAR _setParent

EXPORTED:
   METHOD setParent
   METHOD create
ENDCLASS

METHOD _FixXbpStatic:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   
   DEFAULT oParent TO ::setParent()

   ::XbpStatic:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::_setParent := NIL
RETURN self

METHOD _FixXbpStatic:setParent(x)
   LOCAL oRet 
   IF ::_setParent == NIL
      oRet := ::XbpStatic:setParent()
   ELSE
      oRet := ::_setParent
   ENDIF

   IF ! EMPTY(x)
      IF ::Status() == XBP_STAT_CREATE
         ::XbpStatic:setParent(x)
         ::_setParent := NIL
      ELSE
         ::_setParent := x
      ENDIF
   ENDIF
RETURN oRet
*/