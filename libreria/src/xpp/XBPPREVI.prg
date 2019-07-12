//////////////////////////////////////////////////////////////////////
//
//  PREVIEW.PRG
//
//  Copyright:
//      Alaska Software Inc., (c) 1997. All rights reserved.
//
//  Contents:
//      This program contains the XbpPreview class. It displays printer
//      output WYSIWYG as a preview inside a window. Display can be
//      zoomed and scrolled.
//
//  Remarks:
//      An XbpDialog window is created in the Main procedure. It is used
//      as parent for an XbpPreview object. Pushbuttons for zooming and
//      printing are added. Display of the printer output is done in
//      the DrawDB() function which creates a simple listing of a database.
//
//////////////////////////////////////////////////////////////////////

#include "Appevent.ch"
#include "Common.ch"
#include "Font.ch"
#include "Gra.ch"
#include "Xbp.ch"

// PROCEDURE AppSys()
// // Desktop remains application window
// RETURN
//
// PROCEDURE Main
//    LOCAL nEvent, mp1, mp2
//    LOCAL oDlg, oXbp, drawingArea, oView
//
//    SET DEFAULT TO "..\..\DATA"
//    USE Customer NEW
//
//    oDlg := XbpDialog():new( SetAppWindow(), , {10,10}, {400,410}, , .F.)
//    oDlg:border    := XBPDLG_RAISEDBORDERTHIN_FIXED
//    oDlg:title     := "Preview Dialog"
//    oDlg:maxButton := .F.
//    oDlg:titleBar  := .T.
//    oDlg:create()
//
//    drawingArea := oDlg:drawingArea
//    drawingArea:setColorBG( GRA_CLR_PALEGRAY   )
//    drawingArea:setFontCompoundName( "8.Helv" )
//
//    oView := XbpPreview():new( drawingArea, , {0,0}, {270,380} )
//    oView:create()
//    oView:drawBlock := {|oPS| DrawDB( oPS ) }
//
//    oXbp := XbpPushButton():new( drawingArea, , {283,325}, {100,30} )
//    oXbp:caption := "Zoom ++"
//    oXbp:create()
//    oXbp:activate := {|| oView:zoom( oView:zoomFactor + 0.25 ) }
//
//    oXbp := XbpPushButton():new( drawingArea, , {283,275}, {100,30} )
//    oXbp:caption := "Zoom - -"
//    oXbp:create()
//    oXbp:activate := {|| oView:zoom( oView:zoomFactor - 0.25 ) }
//
//    oXbp := XbpPushButton():new( drawingArea, , {283,223}, {100,30} )
//    oXbp:caption := "Print"
//    oXbp:create()
//    oXbp:activate := {|| oView:startDoc(), oView:draw(), oView:endDoc() }
//
//    oXbp := XbpPushButton():new( drawingArea, , {283,171}, {100,30} )
//    oXbp:caption := "OK"
//    oXbp:create()
//    oXbp:activate := {|| PostAppEvent( xbeP_Close ) }
//
//    oDlg:show()
//    SetAppFocus( oXbp )
//
//    nEvent := 0
//    DO WHILE nEvent <> xbeP_Close
//       nEvent := AppEvent( @mp1, @mp2, @oXbp )
//       oXbp:handleEvent( nEvent, mp1, mp2 )
//    ENDDO
// RETURN
//
//
//
// /*
//  * Draw DBF records in a presentation space
//  */
// FUNCTION DrawDB( oPS )
//    LOCAL i, imax   := FCount()
//    LOCAL aFields   := DbStruct()
//    LOCAL aPageSize := oPS:setPageSize()[1]
//    LOCAL aTextBox, aPosX[imax], nY, xValue, nSegment
//    LOCAL nFontWidth, nFontHeight
//
//    // Get font metrics of current font
//    // -> height and width of largest letter
//    aTextBox    := GraQueryTextBox( oPS, "w" )
//    nFontWidth  := aTextBox[3,1] - aTextBox[2,1]
//    aTextBox    := GraQueryTextBox( oPS, "^g" )
//    nFontHeight := aTextBox[3,2] - aTextBox[2,2]
//
//    aPosX[1]    := nFontWidth/2
//    FOR i:=2 TO imax
//       aPosX[i] := aPosX[i-1] + nFontWidth/2 + ;
//                   Max( Len(aFields[i-1,1]),aFields[i-1,3] ) * nFontWidth
//    NEXT
//
//    GO TOP
//
//    // The entire display is stored in one segment
//    nSegment := GraSegOpen( oPS )
//
//    // Draw field names and column separator lines
//    nY := aPageSize[2] - 2 * nFontHeight
//    FOR i:=1 TO imax
//       GraStringAt( oPS, { aPosX[i], nY }, FieldName(i) )
//       GraLine( oPS, {aPosX[i]-nFontWidth/4, 0}, {aPosX[i]-nFontWidth/4, aPageSize[2]} )
//    NEXT
//
//    // Draw heading separator line
//    nY -= nFontHeight/2
//    GraLine( oPS, {0, nY}, {aPageSize[1], nY} )
//
//    // Fill one page with data from DBF
//    DO WHILE nY > 0
//       nY -= ( nFontHeight + 2 )
//
//       FOR i:=1 TO imax
//          xValue := FieldGet(i)
//          DO CASE
//          CASE aFields[i,2] == "D"
//             xValue := DtoC( xValue )
//          CASE aFields[i,2] == "L"
//             xValue := IIf( xValue, "T", "F" )
//          CASE aFields[i,2] == "M"
//             xValue := Left( xValue, 10 )
//          CASE aFields[i,2] == "N"
//             xValue := Str( xValue )
//          ENDCASE
//
//          GraStringAt( oPS, { aPosX[i], nY }, xValue )
//       NEXT
//
//       SKIP
//       IF Eof()
//          EXIT
//       ENDIF
//    ENDDO
//
//    // Close segment
//    GraSegClose( oPS )
//
//    // Return segment ID in an array
//    // XbpPreview expects an array containing segment IDs
// RETURN { nSegment }


/*
 * The preview class declaration
 */
CLASS XbpPreview FROM XbpStatic
   PROTECTED:
   VAR oSquare                    // XbpStatic to fill the gap between scroll bars
   VAR oPresSpace                 // XbpPresSpace
   VAR oFont                      // XbpFont
   VAR aViewPort                  // View port for zoom
   VAR aPrinterSize
   VAR aPaperSize
   VAR aPageSize                  // Printer page size
   VAR aCharAttr                  // Attributes for strings (GRA_AS_BOX)
   VAR aAreaAttr                  // Attributes for areas   (GRA_AA_COLOR)
   VAR lPrintDestroy

   METHOD calcScrollBox           // Calculate size of scroll box inside scroll bars

   EXPORTED:
   METHOD setOrigin               // Set origin for the view port
   VAR oView                      // XbpDialog used as display area
   VAR hScroll    READONLY        // Horizontal scroll bar
   VAR vScroll    READONLY        // Vertical   scroll bar
                                  ** Configuration
   VAR oDC
   VAR drawBlock                  // Code block calls function that draws
   VAR printer                    // XbpPrinter
   VAR zoomFactor                 // Zoom factor from 1 to n
   VAR segments                   // Array containing segment IDs
                                  ** Life cycle
   METHOD init                    //
   METHOD create                  //
   METHOD destroy                 //
                                  ** Display
   METHOD setSize                 // Define size
   METHOD hScroll                 // Scroll horizontally
   METHOD vScroll                 // Scroll vertically
   METHOD zoom                    // Zoom
   METHOD draw                    // Graphic output
   METHOD presSpace               // Retrieve pesentation space
   METHOD setViewPort             // Define size of view port
                                  ** Printing
   METHOD startDoc                // Open spooler
   METHOD endDoc                  // Close spooler
   INLINE METHOD getPageSize(); RETURN ::aPageSize
   INLINE METHOD getPrinterSize(); RETURN ::aPrinterSize
ENDCLASS



/*
 * Initialize object
 */
METHOD XbpPreview:init( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::XbpStatic:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::xbpStatic:type  := XBPSTATIC_TYPE_RAISEDRECT

   ::oView           := XbpDialog():new( self )

   ::vScroll         := XbpScrollbar():new( self )
   ::vScroll:type    := XBPSCROLL_VERTICAL
   ::vScroll:cargo   := 0

   ::hScroll         := XbpScrollbar():new( self )
   ::hScroll:type    := XBPSCROLL_HORIZONTAL
   ::hScroll:cargo   := 0

   ::oSquare         := XbpStatic():new( self )
   ::oSquare:type    := XBPSTATIC_TYPE_RECESSEDBOX

   ::oPresSpace      := XbpPresSpace():new()
   #ifdef _XBASE15_
      // Simone 11/02/02 
      // tolto perche la qualita diminuisce!
      //::oPresSpace:mode := XBPPS_MODE_HIGH_PRECISION
   #endif

   ::zoomFactor      := 1

   // Use default printer
   ::oDC             := NIL
   ::printer         := S2Printer():new()
   ::lPrintDestroy   := .F.

    // Quit if there are no installed printers.
   IF ::printer:list() == NIL
      MsgBox( "Error - There are no printers installed!", "Preview Sample" )
      QUIT
   ENDIF

RETURN self



/*
 * Request system resources
 */
METHOD XbpPreview:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oFont, i, imax, aFontList, cDevice

   // XbpStatic is parent for all other XBPs
   ::xbpStatic:create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   // Create the printer (se cDevice = NIL crea quella di default)
   DO CASE
      CASE VALTYPE(::oDC) == "O"
         ::printer := ::oDC    // Dovrebbe essere gi… creato

      CASE ! EMPTY(dfWinPrinterObject())
         ::printer := dfWinPrinterObject()  // Dovrebbe essere gi… creato

      OTHERWISE
         ::printer:create()     // Creo il device di stampa
         ::lPrintDestroy := .T.

   ENDCASE

   cDevice := ::printer:devName  // reimposta il nome con il nome della stampante creata

   // XbpDialog is displayed without title bar
   ::oView:minButton := .F.
   ::oView:maxButton := .F.
   ::oView:sysMenu   := .F.
   ::oView:titleBar  := .F.
   ::oView:border    := XBPDLG_THINBORDER
   ::oView:create()

   // Create scroll bars and XbpStatic to fill the gap
   ::oSquare:create()
   ::hScroll:create()
   ::vScroll:create()

   ::hScroll:scroll := {|mp1| ::hScroll( mp1 ) }
   ::vScroll:scroll := {|mp1| ::vScroll( mp1 ) }

   // Calculate page size and deduct margins that can not be printed on
   // Unit is 1/10 mm
   ::aPrinterSize := ::printer:paperSize()
   ::aPaperSize  := { ::aPrinterSize[1], ::aPrinterSize[2] }
   ::aPageSize   := { ::aPrinterSize[5]-::aPrinterSize[3], ;
                      ::aPrinterSize[6]-::aPrinterSize[4] }

   // Size of XBPs is calculated in the :setSize() method
   ::setSize( ::currentSize() )

   // Link presentation space with window device context
   // The PS is created with the metric unit 1/10 mm
   ::oPresSpace:create( ::oView:drawingArea:winDevice(), ::aPaperSize, GRA_PU_LOMETRIC )

   // Erase drawing using a filled white box on repaint
   ::aCharAttr := Array( GRA_AS_COUNT )
   ::aAreaAttr := Array( GRA_AA_COUNT )
   ::aAreaAttr [ GRA_AA_COLOR ] := GRA_CLR_WHITE
   ::oPresSpace:setAttrArea( ::aAreaAttr )

   //IF ::oFont == NIL
      ::oFont := dfWinPrnFont( cDevice )

      // // Use default font -> small fixed font
      // ::oFont := XbpFont():new( ::oPresSpace )
      // ::oFont:familyName := "Courier New"
      // ::oFont:nominalPointSize := 8
      // ::oFont:create()
   // ENDIF

   IF ! EMPTY(::oFont)
      ::oPresSpace:setFont( ::oFont )
   ENDIF

   // Initialize view port
   aSize       := ::oView:drawingArea:currentSize()
   ::aViewPort := { 0, 0, aSize[1], aSize[2] }
   ::oView:drawingArea:paint := {|| ::draw() }
   ::zoom()

RETURN self



/*
 * Release system resources
 */
METHOD XbpPreview:destroy

   IF ::lPrintDestroy
      ::printer:destroy()
   ENDIF
   ::oPresSpace:destroy()

   ::xbpStatic:destroy()
   ::aViewPort := ;
   ::aPageSize := ;
   ::oFont     := NIL
RETURN self



/*
 * Change size of XbpStatic and contained XBPs
 */
METHOD XbpPreview:setSize( aSize )
   ::xbpStatic:setSize( aSize )
   aSize := ::currentSize()

#ifdef _XBASE15_
   ::hScroll:setPosAndSize ( { 0, 0 }, { aSize[1]-16, 16 })
   ::vScroll:setPosAndSize ( { aSize[1]-16, 16 }, { 16, aSize[2]-16 } )
   ::oSquare:show()
   ::oSquare:setPosAndSize( { aSize[1]-16,  0 }, { 16, 16 } )
   ::oView  :setPosAndSize ( { 0 , 16 }, { aSize[1]-16, aSize[2]-16 }  )
#else
   ::hScroll:setPos ( { 0, 0 } )
   ::hScroll:setSize( { aSize[1]-16, 16 } )
   ::vScroll:setPos ( { aSize[1]-16, 16 } )
   ::vScroll:setSize( { 16, aSize[2]-16 } )

   ::oSquare:show()
   ::oSquare:setPos ( { aSize[1]-16,  0 } )
   ::oSquare:setSize( { 16, 16 } )

   ::oView  :setPos ( { 0 , 16 } )
   ::oView  :setSize( { aSize[1]-16, aSize[2]-16 } )
#endif


   ::calcScrollBox()
RETURN self



/*
 * Scroll horizontally
 */
METHOD XbpPreview:hScroll( mp1 )
   LOCAL nScrollPos := mp1[1]
   LOCAL nCommand   := mp1[2]

   IF nCommand == XBPSB_SLIDERTRACK .OR. ;
      nCommand == XBPSB_ENDSCROLL

      RETURN self
   ENDIF
   // scroll a bit further after each scroll message
   // as long as the scroll button is pressed
   // (accelerated scrolling)
   DO CASE
   CASE nCommand == XBPSB_PREVPOS
      ::hScroll:cargo := Min( -1, ::hScroll:cargo - 2 )
      ::hScroll:setData( nScrollPos + ::hScroll:cargo )
   CASE nCommand == XBPSB_NEXTPOS
      ::hScroll:cargo := Max(  1, ::hScroll:cargo + 2 )
      ::hScroll:setData( nScrollPos + ::hScroll:cargo )
   CASE nCommand == XBPSB_PREVPAGE
      ::hScroll:setData( nScrollPos )
   CASE nCommand == XBPSB_NEXTPAGE
      ::hScroll:setData( nScrollPos )
   ENDCASE

   ::setOrigin( ::hScroll:getData(), ::vScroll:getData() )
   ::draw()

RETURN self



/*
 * Scroll vertically
 */
METHOD XbpPreview:vScroll( mp1 )
   LOCAL nScrollPos := mp1[1]
   LOCAL nCommand   := mp1[2]

   IF nCommand == XBPSB_SLIDERTRACK .OR. ;
      nCommand == XBPSB_ENDSCROLL

      RETURN self
   ENDIF
   // scroll a bit further after each scroll message
   // as long as the scroll button is pressed
   // (accelerated scrolling)
   DO CASE
   CASE nCommand == XBPSB_PREVPOS
      ::vScroll:cargo := Min( -1, ::vScroll:cargo - 2 )
      ::vScroll:setData( nScrollPos + ::vScroll:cargo )
   CASE nCommand == XBPSB_NEXTPOS
      ::vScroll:cargo := Max(  1, ::vScroll:cargo + 2 )
      ::vScroll:setData( nScrollPos + ::vScroll:cargo )
   CASE nCommand == XBPSB_PREVPAGE
      ::vScroll:setData( nScrollPos )
   CASE nCommand == XBPSB_NEXTPAGE
      ::vScroll:setData( nScrollPos )
   ENDCASE

   ::setOrigin( ::hScroll:getData(), ::vScroll:getData() )
   ::draw()

RETURN self



/*
 * Set origin of the view port after scrolling
 */
METHOD XbpPreview:setOrigin( nX, nY )
   LOCAL aSize       := ::oView:drawingArea:currentSize()
   LOCAL nViewWidth  := aSize[1]
   LOCAL nViewHeight := aSize[2]
   LOCAL nZoomWidth  := nViewWidth  * ::zoomFactor
   LOCAL nZoomHeight := nViewHeight * ::zoomFactor

   // X origin is always <= 0
   nX := - Abs( nX )

   IF nZoomWidth <= nViewWidth
      nX := 0
   ELSEIF nViewWidth - nX >= nZoomWidth
      nX := nViewWidth - nZoomWidth
   ENDIF

   ::aViewPort[1] := nX
   ::aViewPort[3] := nX + nZoomWidth

   // Y origin is always <= 0
   // Consider the difference between visible and total height
   nY := Abs( nY ) - ( nZoomHeight - nViewHeight )

   IF nY > 0 .OR. nZoomHeight <= nViewHeight
      nY := 0
   ELSEIF nViewHeight - nY >= nZoomHeight
      nY := nViewHeight - nZoomHeight
   ENDIF

   ::aViewPort[2] := nY
   ::aViewPort[4] := nY + nZoomHeight

   ::setViewPort( ::aViewPort )

RETURN self



/*
 * Calculate size of the scroll box and range for both scroll bars
 */
METHOD XbpPreview:calcScrollBox()
   LOCAL aSize       := ::oView:drawingArea:currentSize()
   LOCAL nViewWidth  := aSize[1]
   LOCAL nViewHeight := aSize[2]
   LOCAL nZoomWidth
   LOCAL nZoomHeight
   LOCAL lChg        := .F.

   aSize := ::oPresSpace:setViewPort()
   aSize[1] := aSize[3]-aSize[1]
   aSize[2] := aSize[4]-aSize[2]

   // nZoomWidth  := aSize[1] * ::zoomFactor
   // nZoomHeight := aSize[2] * ::zoomFactor

   nZoomWidth  := aSize[1]
   nZoomHeight := aSize[2]

   // Calculation for horizontal scroll bar
   ::hScroll:setRange( { 0, nZoomWidth - nViewWidth } )
   IF nZoomWidth > nViewWidth
      // IF ! ::hScroll:isVisible()
      //    ::hScroll:show()
      //    ::hScroll:enable()
      //    lChg := .T.
      // ENDIF
      ::hScroll:setScrollBoxSize( (nZoomWidth-nViewWidth) * (nViewWidth/nZoomWidth) )
   ELSE
      ::hScroll:setScrollBoxSize( nViewWidth )
      // IF ::hScroll:isVisible()
      //    ::hScroll:hide()
      //    ::hScroll:disable()
      //    lChg := .T.
      // ENDIF
   ENDIF

   // Calculation for vertical scroll bar
   ::vScroll:setRange( { 0, nZoomHeight - nViewHeight } )
   IF nZoomHeight > nViewHeight
      // IF ! ::vScroll:isVisible()
      //    ::vScroll:show()
      //    ::vScroll:enable()
      //    lChg := .T.
      // ENDIF
      ::vScroll:setScrollBoxSize( (nZoomHeight-nViewHeight) * (nViewHeight/nZoomHeight) )
   ELSE
      ::vScroll:setScrollBoxSize( nViewHeight )
      // IF ::vScroll:isVisible()
      //    ::vScroll:hide()
      //    ::vScroll:disable()
      //    lChg := .T.
      // ENDIF
   ENDIF

   // IF lChg
   //    ::setSize(::currentSize())
   // ENDIF

RETURN self



/*
 * Zoom view port
 */
METHOD XbpPreview:zoom( nZoomFactor, aPos )
   LOCAL aSize  := ::oView:drawingArea:currentSize()
   // LOCAL aWinSize := ACLONE(aSize)
   // LOCAL aRange
   // LOCAL aCenter := {INT(aSize[1]/2), INT(aSize[2]/2)}

   DEFAULT nZoomFactor TO ::zoomFactor

   ::zoomFactor := Max( 1, nZoomFactor )

   // Re-calculate view port
   aSize[1] := Int( aSize[1] * nZoomFactor )
   aSize[2] := Int( aSize[2] * nZoomFactor )

   ::aViewPort  := {0,0,aSize[1],aSize[2]}

   ::setOrigin( ::hScroll:getData(), ::vScroll:getData() )

   ::calcScrollBox()

   // Qui dovrebbe centrare in base alla posizione del mouse
   // IF aPos != NIL
   //
   //    aPos[1] := Int( aPos[1] * nZoomFactor )
   //    aPos[2] := Int( aPos[2] * nZoomFactor )
   //
   //    aPos[1] := aPos[1] - aCenter[1]
   //    aPos[2] := aPos[2] - aCenter[2]
   //
   //    aRange := ::hScroll:setRange()
   //    ::hScroll:setData( aRange[1] + aPos[1] )
   //
   //    IF aPos[2] > 0
   //       aRange := ::vScroll:setRange()
   //       ::vScroll:setData( -(aPos[2] - aRange[2]) )
   //    ENDIF
   //
   //    ::setOrigin( ::hScroll:getData(), ::vScroll:getData() )
   // ENDIF

   ::draw()
RETURN self



/*
 * Get presentation space
 */
METHOD XbpPreview:presSpace
RETURN ::oPresSpace



/*
 * Define view port
 */
METHOD XbpPreview:setViewPort( aViewPort )
   LOCAL aOldViewPort := ::oPresSpace:setViewPort()
   LOCAL aView, nX, nY

   IF Valtype( aViewPort ) == "A"
      ::aViewPort := aViewPort

      aView := ACLONE(aViewPort)
      nX := aView[3]-aView[1]
      nY := aView[4]-aView[2]

      IF ::aPaperSize[1] > ::aPaperSize[2]
// gerr 3908 simone 29-8-03 
// commentata riga sotto per migliorare preview in carta A3
//         aView[4] := ::aPaperSize[2] * nX / ::aPaperSize[1] - aView[2]
      ELSE
         aView[3] := ::aPaperSize[1] * nY / ::aPaperSize[2] + aView[1]
      ENDIF

      ::oPresSpace:setViewPort( aView )
   ENDIF

RETURN aOldViewPort



/*
 * Display the drawing
 */
METHOD XbpPreview:draw

   IF Valtype( ::drawBlock ) == "B"
      // Drawing is erased by a box filled with white color
      GraBox( ::oPresSpace, {0,0}, ::aPaperSize, GRA_FILL )

      GraBox( ::oPresSpace, {::aPrinterSize[3], ::aPrinterSize[4]}, ;
              {::aPrinterSize[5], ::aPrinterSize[6]} )

      IF ::segments == NIL
         // :drawBlock must call a routine that does the drawing
         // The drawing must be stored in graphical segments
         // The numeric segment IDs are returned in an array by :drawBlock
         ::segments := Eval( ::drawBlock, ::oPresSpace )
      ELSE
         AEval( ::segments, {|nID| GraSegDraw( ::presSpace(), nID ) } )
      ENDIF
   ENDIF

RETURN self



/*
 * Start printing
 * - The presentation space gets associated with a printer device context
 */
METHOD XbpPreview:startDoc(cJobName)

   ::oPresSpace:configure( ::printer )

   // From now on output in :oPresSpace is redirected to the spooler
   ::printer:startDoc(cJobName)

   // Font and attributes are lost due to :configure() -> reset both
   ::oPresSpace:setFont( ::oFont )
   ::oPresSpace:setAttrArea( ::aAreaAttr )
   ::oPresSpace:setAttrString( ::aCharAttr )

RETURN self



/*
 * End printing
 * - The presentation space gets associated with the window device context again
 */
METHOD XbpPreview:endDoc

   // Close spooler
   ::printer:endDoc()

   // Re-link PS to window device
   ::oPresSpace:configure( ::oView:drawingArea:winDevice() )

   // Font and attributes are lost due to :configure() -> reset both
   ::oPresSpace:setFont( ::oFont )
   ::oPresSpace:setAttrArea( ::aAreaAttr )
   ::oPresSpace:setAttrString( ::aCharAttr )

   // Set view port for window
   ::zoom()

RETURN self

