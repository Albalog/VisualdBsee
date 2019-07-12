#include "common.ch"
#include "Xbp.ch"
#include "Gra.ch"
#include "font.ch"

CLASS XbpMultiPagePreview FROM XbpPreview
   PROTECTED:
      VAR nCurrPage, oThread
   EXPORTED:
      VAR lShowMargin, lShowRuler, lRenderInThread
      VAR breakRender
      VAR nPageHeight, aMatrix
      METHOD Init, destroy, draw, ShowPage, newPage, drawPage, AdjustCurrPage
      METHOD printDoc, printPage, renderPage
      INLINE METHOD NumPages(); RETURN LEN(::segments)
ENDCLASS

METHOD XbpMultiPagePreview:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::XbpPreview:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::nCurrPage := 0
   ::lShowMargin := .T.
   ::lShowRuler := .F.
   ::lRenderInThread := .F.
   ::oThread := NIL
   ::segments := NIL
   ::breakRender := .F.
   ::nPageHeight := 0
   ::aMatrix     := NIL
RETURN self

METHOD XbpMultiPagePreview:destroy()
   LOCAL oPS := ::presSpace()
   sleep(20)
   IF ::oThread != NIL .AND. ::oThread:active
      // interrompo il render delle pagine
      ::breakRender := .T.
      ::oThread:synchronize(0)
      ::oThread := NIL
   ENDIF
   sleep(20)
   AEval( ::segments, {|aPage| GraSegDestroy(oPS, aPage[1]), ;
                               AEval(aPage[2], ;
                               {|aImg| IIF(aImg[2]:status()==XBP_STAT_CREATE, ;
                                           aImg[2]:destroy(), NIL) }) } )

   ::segments := NIL
   ::XbpPreview:destroy()
RETURN self


METHOD XbpMultiPagePreview:ShowPage( nNum )
   LOCAL lOk := .F.
   IF nNum >= 1 .AND. nNum <= ::NumPages()
      lOk := .T.
      ::nCurrPage := nNum
      ::drawPage()
   ENDIF
RETURN lOk

METHOD XbpMultiPagePreview:draw
   IF ::segments == NIL .AND. Valtype( ::drawBlock ) == "B"
      ::segments := {}

      // L'array ::segments deve essere aggiornato dalla funzione in
      // ::drawBlock, lo pu• fare visto che ::segments Š EXPORTED
      IF ::lRenderInThread
         IF ::oThread == NIL
            ::oThread := Thread():new()

            // Salvo ENVID dato che Š privata e quindi thread local
            // altrimenti non trovo EnvID nella dfWinPrnFont()
            ::oThread:cargo := { {"ENVID", M->EnvId} }
            ::oThread:start(::drawBlock, ::oPresSpace)
         ENDIF
      ELSE
         Eval( ::drawBlock, ::oPresSpace )
      ENDIF

      ::AdjustCurrPage()
   ENDIF
   ::drawPage()
RETURN self

METHOD XbpMultiPagePreview:AdjustCurrPage()
   IF EMPTY(::segments)
      ::nCurrPage := 0
   ELSE
      IF ::nCurrPage <= 0
         ::nCurrPage := 1
      ELSE
         ::nCurrPage := IIF(::nCurrPage <= LEN(::segments), ::nCurrPage, 1)
      ENDIF
   ENDIF
RETURN self

METHOD XbpMultiPagePreview:newPage()
   // da fare...
RETURN self

// xIni puo' essere o la pagina iniziale o un array di pagine da stampare

METHOD XbpMultiPagePreview:printDoc(xIni, nFin, cJobName)
   LOCAL nPage := 0

   ::startDoc(cJobName)

   IF VALTYPE(xIni) == "A"
      AEVAL(xIni, {|n| ::drawPage(n), ;
                       ::printer:newPage() })
   ELSE
      DEFAULT xIni TO 1
      DEFAULT nFin TO ::NumPages()

      FOR nPage := xIni TO nFin
         ::printPage(nPage)
         ::printer:newPage()
      NEXT
   ENDIF

   ::endDoc()
RETURN

METHOD XbpMultiPagePreview:drawPage(nPage)
   LOCAL lOk := .F.
   LOCAL aAttr, aLine
   LOCAL oPS, aViewPort, aWinSize
   LOCAL nInd, nLine
   LOCal aString, oFont
   LOCAL oFontRuler

   DEFAULT nPage TO ::nCurrPage

   // Prendo il viewport REALE
   aViewPort := ::oPresSpace:setViewPort()

   // Prendo la grandezza della finestra
   aWinSize := ::oView:drawingArea:currentSize()

   IF aViewPort[3] < aWinSize[1] .OR. ;
      aViewPort[4] < aWinSize[2]

      oPS := ::oView:drawingArea:lockPS()

      aAttr := Array( GRA_AA_COUNT )
      aAttr [ GRA_AA_COLOR ] := GRA_CLR_BACKGROUND
      oPS:setAttrArea( aAttr )

      IF aViewPort[3] < aWinSize[1]
         GraBox(oPS, {aViewPort[3]+1, aViewPort[2]}, {aWinSize[1], aViewPort[4]}, GRA_FILL)
      ENDIF

      IF aViewPort[4] < aWinSize[2]
         GraBox(oPS, {aViewPort[1], aViewPort[4]+1}, {aViewPort[3], aWinSize[2]}, GRA_FILL)
      ENDIF
      ::oView:drawingArea:unlockPS(oPS)

   ENDIF

   // Drawing is erased by a box filled with white color
   GraBox( ::oPresSpace, {0,0}, ::aPaperSize, GRA_FILL )

   // Box per i margini
   IF (::lShowMargin .OR. ::lShowRuler) .AND. ;
      (::aPrinterSize[3] != 0 .OR. ::aPrinterSize[4] != 0 .OR. ;
       ::aPrinterSize[5] != 0 .OR. ::aPrinterSize[6] != 0)

      aLine := ::oPresSpace:setAttrLine()

      IF ::lShowMargin
         aAttr := Array( GRA_AL_COUNT )
         aAttr [ GRA_AL_TYPE ] := GRA_LINETYPE_DOT
         ::oPresSpace:setAttrLine( aAttr )

         GraLine( ::oPresSpace, {::aPrinterSize[3], ::aPrinterSize[4]}, ;
                  {::aPrinterSize[3], ::aPrinterSize[6]} )

         GraLine( ::oPresSpace, NIL, {::aPrinterSize[5], ::aPrinterSize[6]} )
         GraLine( ::oPresSpace, NIL, {::aPrinterSize[5], ::aPrinterSize[4]} )
         GraLine( ::oPresSpace, NIL, {::aPrinterSize[3], ::aPrinterSize[4]} )
      ENDIF

      IF ::lShowRuler
         // Salvo impostazioni del font
         aString := ::oPresSpace:setAttrString()
         oFont := ::oPresSpace:setFont()

         // Nuove impostazioni font
         aAttr := Array( GRA_AS_COUNT )
         aAttr [ GRA_AS_COLOR] := GRA_CLR_BLUE
         aAttr [ GRA_AS_HORIZALIGN ] := GRA_HALIGN_RIGHT
         aAttr [ GRA_AS_VERTALIGN  ] := GRA_VALIGN_BOTTOM
         ::oPresSpace:setAttrString( aAttr )

         oFontRuler := XbpFont():new(::oPresSpace):create("6.Arial")
         ::oPresSpace:setFont( oFontRuler )

         // Nuove impostazioni linea
         aAttr := Array( GRA_AL_COUNT )
         aAttr [ GRA_AL_COLOR] := GRA_CLR_BLUE
         aAttr [ GRA_AL_TYPE ] := GRA_LINETYPE_SHORTDASH
         ::oPresSpace:setAttrLine( aAttr )

         // Ruler orizzontale
         nLine := 25
         FOR nInd := 50 TO ::aPapersize[1] STEP 50
            nLine := IIF(nLine == 25, 15, 25)
            GraLine( ::oPresSpace, {nInd, ::aPaperSize[2]}, ;
                     {nInd, ::aPaperSize[2]-nLine} )

            IF nLine == 25
               GraStringAt(::oPresSpace, {nInd,::aPaperSize[2] - nLine}, STR(nInd/100,2))
            ENDIF
         NEXT

         // Ruler verticale
         nLine := 25
         FOR nInd := 50 TO ::aPapersize[2] STEP 50
            nLine := IIF(nLine == 25, 15, 25)
            GraLine( ::oPresSpace, {0, ::aPaperSize[2] - nInd}, {nLine, ::aPaperSize[2] - nInd} )
            IF nLine == 25
               GraStringAt(::oPresSpace, {nLine, ::aPaperSize[2] - nInd}, STR(nInd/100,2))
            ENDIF
         NEXT

         // Reimposto allineamenti che altrimenti non vengono messi
         // dalla setAttrString successiva..
         aAttr := Array( GRA_AS_COUNT )
         aAttr [ GRA_AS_HORIZALIGN ] := GRA_HALIGN_LEFT
         aAttr [ GRA_AS_VERTALIGN  ] := GRA_VALIGN_BASE
         ::oPresSpace:setAttrString( aAttr )

         // Reimposto vecchio font
         IF ! EMPTY(oFont)
            ::oPresSpace:setFont(oFont)
         ENDIF
         ::oPresSpace:setAttrString(aString)

         oFontRuler:destroy()

      ENDIF


      // GraBox( ::oPresSpace, {::aPrinterSize[3], ::aPrinterSize[4]}, ;
      //       {::aPrinterSize[5], ::aPrinterSize[6]} )

      ::oPresSpace:setAttrLine(aLine)
   ENDIF

   IF nPage >= 1 .AND. nPage <= LEN(::segments)
      ::renderPage(nPage)
      lOk := .T.
   ENDIF

RETURN lOk

METHOD XbpMultiPagePreview:printPage(nPage)
   LOCAL lOk := .F.
   LOCAL aMatrix := GraInitMatrix()
   DEFAULT nPage TO ::nCurrPage

   // Drawing is erased by a box filled with white color
   // GraBox( ::oPresSpace, {0,0}, ::aPaperSize, GRA_FILL )

   IF ::aMatrix != NIL
      // Stampo i segmenti riportati a margine 0
      GraTranslate(::oPresSpace, aMatrix, -::aPrinterSize[3], -::aPrinterSize[4])
   ENDIF

   IF nPage >= 1 .AND. nPage <= LEN(::segments)
      ::renderPage(nPage)
      // AEval( ::segments[nPage], {|nID| GraSegDraw( ::presSpace(), nID ) } )
      lOk := .T.
   ENDIF

RETURN lOk

METHOD XbpMultiPagePreview:renderPage(nPage)
   LOCAL oPs := ::presSpace()

   IF nPage == 1
      // Prima pagina con coord Y ok
      AEval( ::segments[nPage][2], {|aImg, x| aImg[2]:draw(oPS, aImg[3]) } )
      GraSegDraw( oPs,  ::segments[nPage][1])
   ELSE
      // Sposto le immagini alla coord. Y corretta
      AEval( ::segments[nPage][2], {|aImg, x| x:= ACLONE(aImg[3]), ;
                                              x[2]+= ::nPageHeight, ;
                                              x[4]+= ::nPageHeight, ;
                                              aImg[2]:draw(oPS, x) } )
      // Sposto le stringhe alla coord. Y corretta
      GraSegDraw( oPs,  ::segments[nPage][1], ::aMatrix )
   ENDIF

RETURN self

