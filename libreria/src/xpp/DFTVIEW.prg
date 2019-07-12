/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "Appevent.ch"
#include "Common.ch"
#include "Font.ch"
#include "Gra.ch"
#include "Xbp.ch"
#include "dfmsg.ch"
#include "dfReport.ch"
#include "dfXBase.ch"
#include "dfXRes.ch"
#include "dfWinRep.ch"
#include "dfMsg1.ch"

#define BTN_WIDTH    20
#define BTN_HEIGHT   20
#define H_OFFSET      4
#define V_OFFSET      4

//#define ZOOM_FACTOR  .5

FUNCTION dfTView(a,b,c,d,cFile, cTitle, oDC, aExtra)
   LOCAL nRet := -1, oDlg
   LOCAL cPrinter

   IF EMPTY(cFile) .OR. ! FILE(cFile)
      RETURN nRet
   ENDIF

   dfPushAct()

   DEFAULT cTitle TO ""
   DEFAULT aExtra TO dfWinPrnExtra()

   // oDlg := BuildWindow( cFile )

   oDlg := S2PreviewDialog():new()
   oDlg:title := dbMMrg(STRTRAN(cTitle,dfHot()))
   oDlg:cFile := cFile
   oDlg:aExtra := aExtra

   oDlg:viewPreview:oDC := oDC

   oDlg:Create()

   IF oDlg:viewPreview:printer:status() == XBP_STAT_CREATE
      oDlg:tbConfig()
      oDlg:show()
      // oDlg:setFrameState(XBPDLG_FRAMESTAT_MAXIMIZED)
      oDlg:tbInk()
      oDlg:tbEnd()
   ELSE
      // Simone 4/2/2005
      // mantis 0000520: Runtime Error in generazione/compilazione
      // nota: il problema non Š stato rilevato
      cPrinter := oDlg:viewPreview:printer:devName
      IF EMPTY(cPrinter)
         cPrinter := "(unkonwn printer)"
      ENDIF
      //dbMsgErr("Stampante non valida//"+oDlg:viewPreview:printer:devName)
      dbMsgErr(dfStdMsg1(MSG1_DFPRNMENU02)+"//"+cPrinter)
   ENDIF

   oDlg:destroy()
   dfPopAct()
   nRet := 0

RETURN nRet


CLASS S2PreviewDialog FROM S2Dialog
   PROTECTED:
      VAR lEventLoop
      VAR nDrawing // Flag per sapere se sono in fase di drawing o no
      VAR lUseMatrix

   EXPORTED:
      VAR aOkZoom, nCurrZoom
      VAR btnZoomIn, btnZoomOut, btnClose, btnPrint, viewPreview, spnPage
      VAR btnRuler, sayNumPages
      VAR cFile
      VAR aExtra
      VAR aImgCache
      VAR aFontCache

      METHOD DrawFile, resize, reposCtrls //, findImage
      METHOD Init, Create, destroy, tbInk //, Show
      METHOD keyboard
      METHOD breakEventLoop
      METHOD zoomIn, zoomOut
      METHOD addPageSegment

      INLINE METHOD ToggleRuler()
          IF ::CanChangeView()
             ::viewPreview:lShowRuler := ! ::viewPreview:lShowRuler
             ::viewPreview:drawPage()
          ENDIF
      RETURN self

      // Modifico la visualizzazione solo se ho finito il drawing oppure
      // ho visualizzato la prima pagina
      INLINE METHOD CanChangeView()
      RETURN  (::nDrawing == 0 .OR. ::viewPreview:numPages() > 1)
ENDCLASS

METHOD S2PreviewDialog:Init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL nScreenSize

   ::S2Dialog:init(0, 0, MAXROW(), MAXCOL(), ;
                   oParent, oOwner, aPos, aSize, aPP, lVisible)

   ::border    := XBPDLG_SIZEBORDER
   ::title     := ""
   ::maxButton := .T.
   ::titleBar  := .T.
   ::cFile     := ""
   ::lEventLoop := .T.
   ::close := {|| ::breakEventLoop() }
   ::nDrawing := 0

   nScreenSize := S2AppDesktopChkSize()
   DO CASE
      CASE nScreenSize == S2APPDESKTOPSIZE_800x600
         ::aOKZoom := {1, 2.3, 3 }

      CASE nScreenSize == S2APPDESKTOPSIZE_1280x1024
         ::aOKZoom := {1.3, 2.1, 3.1}

      OTHERWISE
         ::aOKZoom := {1, 2, 3} // Questi livelli di zoom sono ok
                                // a 640*480,1024*768 e 1152*864
   ENDCASE
   ::nCurrZoom := 2  // Livello di zoom iniziale
   ::aImgCache := {}
   ::aFontCache:= {}
   ::drawingArea:setColorBG( XBPSYSCLR_DIALOGBACKGROUND  )
   #ifndef _NOFONT_
   ::drawingArea:setFontCompoundName( "8.Helv" )
   #endif

   ::viewPreview := XbpMultiPagePreview():new( ::drawingArea, NIL, NIL, NIL, NIL, .T. )
   ::viewPreview:lRenderInThread := dfSet("XbaseFastPreview")!="NO"
   ::viewPreview:drawBlock := {|oPS| ::DrawFile( oPS, ::cFile, ::aExtra, ::viewPreview:lRenderInThread, ;
                                     {|| ::viewPreview:breakRender } ) }

   //::viewPreview:zoomFactor += ZOOM_FACTOR
   ::viewPreview:zoomFactor := ::aOkZoom[::nCurrZoom]

   ::viewPreview:oView:drawingArea:lbClick:= {|aPos, n, o| ::zoomIn(aPos)}
   ::viewPreview:oView:drawingArea:rbClick:= {|aPos, n, o| ::zoomOut()}

   ::viewPreview:oView:drawingArea:setPointer(NIL, PTR_MAGNIFY_PLUS, XBPWINDOW_POINTERTYPE_POINTER)


   ::btnPrint := ie4Button():new( ::drawingArea, NIL, NIL, NIL, NIL, .T. )
   //::btnPrint:caption := "Stampa"
   ::btnPrint:caption := BTN_PRINT
   ::btnPrint:type := XBPSTATIC_TYPE_BITMAP

   // QUESTO PER EVITARE I PROBLEMI SU STAMPA DIRETTA DA ANTEPRIMA,
   // PERO' E' PIU' LENTO
   //::btnPrint:activate := {|| ::viewPreview:printDoc()}
   ::btnPrint:activate := {|| dfFile2WPrn(::cFile, ::Title, ::viewPreview:printer, ::aExtra, 2 )}

   ::btnRuler := ie4Button():new( ::drawingArea, NIL, NIL, NIL, NIL, .T. )
   //::btnRuler:caption := "Ruler"
   ::btnRuler:caption := BTN_RULER
   ::btnRuler:type := XBPSTATIC_TYPE_BITMAP
   ::btnRuler:toolTipText := "Ruler on/off"

   ::btnRuler:activate := {|| ::ToggleRuler() }


   ::btnClose := ie4Button():new( ::drawingArea, NIL, NIL, NIL, NIL, .T. )
   ::btnClose:caption := "OK"
   //::btnClose:caption := BTN_CLOSE
   //::btnClose:type := XBPSTATIC_TYPE_BITMAP
   ::btnClose:activate := {|| ::breakEventLoop() }


   ::spnPage := XbpSpinButton():new( ::drawingArea, NIL, NIL, NIL, NIL, .T. )
   ::spnPage:fastSpin := .T.
   ::spnPage:setInputFocus:={|| setAppFocus(self) }

   ::sayNumPages := XbpStatic():new(::drawingArea, NIL, NIL, NIL, NIL, .T. )
   ::sayNumPages:caption := ""
   ::sayNumPages:options := XBPSTATIC_TEXT_VCENTER

   // su sistemi NT uso transformation matrix,
   // ma su sistemi 9x non funziona vedi GERR 3393
   DO CASE
      CASE dfSet("XbasePreviewMode")=="NEW"
         ::lUseMatrix := .T.

      CASE dfSet("XbasePreviewMode")=="OLD"
         ::lUseMatrix := .F.

      OTHERWISE
         ::lUseMatrix := (dfOsFamily() == "WINNT")
   ENDCASE


RETURN self

METHOD S2PreviewDialog:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   // LOCAL cZoom
   // LOCAL aZoom

   DEFAULT aPos TO {0, S2WinStartMenuSize()[2]}
   DEFAULT aSize TO S2AppDesktopSize()

   ::S2Dialog:Create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   aSize := ::drawingArea:currentSize()

   aPos  := {0,0}
   aSize[2] -= BTN_HEIGHT +  2 * V_OFFSET
   ::viewPreview:create(NIL, NIL, aPos, aSize)

   ::btnPrint:toolTipText := ::viewPreview:printer:devName

   aSize[2] += V_OFFSET  // un po' di spazio in verticale
   aPos := {H_OFFSET, aSize[2]}
   aSize := {BTN_WIDTH,BTN_HEIGHT}
   // ::btnZoomIn:create(NIL, NIL, aPos, aSize)
   //
   // aPos[1] += BTN_WIDTH + H_OFFSET     // un po' di spazio fra i pulsanti
   // ::btnZoomOut:create(NIL, NIL, aPos, aSize)
   //
   // aPos[1] += BTN_WIDTH + H_OFFSET
   ::btnPrint:create(NIL, NIL, aPos, aSize)

   aPos[1] += BTN_WIDTH + H_OFFSET
   ::btnRuler:create(NIL, NIL, aPos, aSize)

   aPos[1] += BTN_WIDTH + H_OFFSET
   ::btnClose:create(NIL, NIL, aPos, aSize)

   aSize[1] := 40
   aPos[1] += BTN_WIDTH + H_OFFSET

   ::spnPage:create(NIL, NIL, aPos, aSize)
   ::spnPage:setNumLimits(1, ::viewPreview:NumPages())
   ::spnPage:up   := {|n1,n2,o| IIF(::CanChangeView(), ::viewPreview:showPage(o:getData()), NIL) }
   ::spnPage:down := {|n1,n2,o| IIF(::CanChangeView(), ::viewPreview:showPage(o:getData()), NIL) }

   aPos[1] += 40 + H_OFFSET
   ::sayNumPages:create(NIL, NIL, aPos, aSize)

   // cZoom := dfSet("XbasePreviewZoom."+::viewPreview:printer:devName)
   // IF ! EMPTY(cZoom)
   //    aZoom := dfStr2Arr(cZoom, ",")
   //    IF ! EMPTY(aZoom)
   //       ::aOkZoom := {}
   //       AEVAL(aZoom, {|a| AADD(::aOkZoom, VAL(a)) })
   //       ::zoomOut()
   //    ENDIF
   // ENDIF

RETURN self

// gerr 3909 simone 29/8/03
METHOD S2PreviewDialog:reposCtrls()
   LOCAL aSize := ::drawingArea:currentSize()
   LOCAL aPos  := {0,0}
   aSize[2] -= BTN_HEIGHT +  2 * V_OFFSET

   ::viewPreview:setSize(aSize, .F.)
   aSize[2] += V_OFFSET  // un po' di spazio in verticale
   aPos := {H_OFFSET, aSize[2]}
   aSize := {BTN_WIDTH,BTN_HEIGHT}
   ::btnPrint:setPosAndSize(aPos, aSize, .F.)

   aPos[1] += BTN_WIDTH + H_OFFSET
   ::btnRuler:setPosAndSize(aPos, aSize, .F.)

   aPos[1] += BTN_WIDTH + H_OFFSET
   ::btnClose:setPosAndSize(aPos, aSize, .F.)

   aSize[1] := 40
   aPos[1] += BTN_WIDTH + H_OFFSET

   ::spnPage:setPosAndSize(aPos, aSize, .F.)

   aPos[1] += 40 + H_OFFSET
   ::sayNumPages:setPosAndSize(aPos, aSize, .F.)

   ::drawingArea:invalidateRect()

RETURN self

METHOD S2PreviewDialog:destroy()
   AEVAL(::aImgCache, {|x| x[2]:destroy()})
   AEVAL(::aFontCache, {|x| IIF(x[2]:status() == XBP_STAT_CREATE, ;
                                x[2]:destroy(), NIL)})
   ::viewPreview:destroy()
   ::S2Dialog:destroy()
RETURN self

METHOD S2PreviewDialog:zoomIn(aPos)
   LOCAL nNew := MIN(::nCurrZoom+1, LEN(::aOkZoom))

   IF ! nNew == ::nCurrZoom .AND. ::CanChangeView()
      ::nCurrZoom := nNew
      ::viewPreview:zoom( ::aOkZoom[::nCurrZoom], aPos )
//      ::viewPreview:drawPage()
   ENDIF
RETURN self

METHOD S2PreviewDialog:zoomOut()
   LOCAL nNew := MAX(::nCurrZoom-1, 1)
   IF ! nNew == ::nCurrZoom .AND. ::CanChangeView()
      ::nCurrZoom := nNew
      ::viewPreview:zoom( ::aOkZoom[::nCurrZoom] )
//      ::viewPreview:drawPage()
   ENDIF
RETURN self


METHOD S2PreviewDialog:keyboard(nKey)
   LOCAL nSBPos, nSBSize, aRange, lSpin
   DO CASE
      CASE nKey == xbeK_ESC
         ::breakEventLoop()

      CASE nKey == xbeK_HOME .AND. ::CanChangeView()
         ::spnPage:setData(1)
         ::viewPreview:showPage(1)

      CASE nKey == xbeK_END  .AND. ::CanChangeView()
         ::spnPage:setData(::viewPreview:NumPages())
         ::viewPreview:showPage(::viewPreview:NumPages())

      CASE nKey == xbeK_CTRL_UP  .AND. ::CanChangeView()
         ::zoomOut()
         //::viewPreview:zoom( ::viewPreview:zoomFactor - ZOOM_FACTOR )

      CASE nKey == xbeK_CTRL_DOWN  .AND. ::CanChangeView()
         ::zoomIn()
         //::viewPreview:zoom( ::viewPreview:zoomFactor + ZOOM_FACTOR )

      CASE nKey == xbeK_LEFT  .AND. ::CanChangeView()
         nSBPos  := ::viewPreview:hScroll:getData()
         nSBSize := ::viewPreview:hScroll:setScrollBoxSize()
         aRange  := ::viewPreview:hScroll:setRange()
         DO CASE
            CASE nSBPos <= aRange[1]

            CASE nSBPos - nSBSize < aRange[1]
               nSBPos := aRange[1]

            OTHERWISE
               nSBPos -= nSBSize

         ENDCASE
         ::viewPreview:hScroll({nSBPos, XBPSB_NEXTPAGE})

      CASE nKey == xbeK_RIGHT  .AND. ::CanChangeView()
         nSBPos  := ::viewPreview:hScroll:getData()
         nSBSize := ::viewPreview:hScroll:setScrollBoxSize()
         aRange  := ::viewPreview:hScroll:setRange()
         DO CASE
            CASE nSBPos >= aRange[2]

            CASE nSBPos + nSBSize > aRange[2]
               nSBPos := aRange[2]

            OTHERWISE
               nSBPos += nSBSize

         ENDCASE
         ::viewPreview:hScroll({nSBPos, XBPSB_NEXTPAGE})

      CASE (nKey == xbeK_PGUP .OR. nKey == xbeK_UP)  .AND. ::CanChangeView()
         nSBPos  := ::viewPreview:vScroll:getData()
         nSBSize := ::viewPreview:vScroll:setScrollBoxSize()
         aRange  := ::viewPreview:vScroll:setRange()
         lSpin   := .F.
         DO CASE
            CASE nSBPos <= aRange[1]
               nSBPos := aRange[2]
               lSpin := .T.

            CASE nSBPos - nSBSize < aRange[1]
               nSBPos := aRange[1]

            OTHERWISE
               nSBPos -= nSBSize

         ENDCASE
         #ifdef _XBASE15_
         IF lSpin
            ::viewPreview:lockUpdate(.T.)
         ENDIF
         #endif

         ::viewPreview:vScroll({nSBPos, XBPSB_NEXTPAGE})
         IF lSpin
            ::spnPage:spinDown(1)
         ENDIF

         #ifdef _XBASE15_
         IF lSpin
            ::viewPreview:lockUpdate(.F.)
            ::viewPreview:invalidateRect()
         ENDIF
         #endif

      CASE (nKey == xbeK_PGDN .OR. nKey == xbeK_DOWN)  .AND. ::CanChangeView()
         nSBPos  := ::viewPreview:vScroll:getData()
         nSBSize := ::viewPreview:vScroll:setScrollBoxSize()
         aRange  := ::viewPreview:vScroll:setRange()
         lSpin   := .F.
         DO CASE
            CASE nSBPos >= aRange[2]
               lSpin := .T.
               nSBPos := aRange[1]

            CASE nSBPos + nSBSize > aRange[2]
               nSBPos := aRange[2]

            OTHERWISE
               nSBPos += nSBSize
         ENDCASE
         #ifdef _XBASE15_
         IF lSpin
            ::viewPreview:lockUpdate(.T.)
         ENDIF
         #endif

         ::viewPreview:vScroll({nSBPos, XBPSB_NEXTPAGE})
         IF lSpin
            ::spnPage:spinUp(1)
         ENDIF

         #ifdef _XBASE15_
         IF lSpin
            ::viewPreview:lockUpdate(.F.)
            ::viewPreview:invalidateRect()
         ENDIF
         #endif

      OTHERWISE
         ::S2Dialog:keyboard(nKey)
   ENDCASE
RETURN self

METHOD S2PreviewDialog:breakEventLoop()
   ::lEventLoop := .F.
RETURN self


METHOD S2PreviewDialog:resize(aOld, aNew)
   ::reposCtrls()
// gerr 3909 simone 29/8/03
/*
   LOCAL aDelta := {aNew[1]-aOld[1], aNew[2]-aOld[2]}
   LOCAL aCoords  := ::viewPreview:currentSize()

   aCoords[1] += aDelta[1]
   aCoords[2] += aDelta[2]

   ::viewPreview:setSize( aCoords )
   // aCoords := ::btnZoomIn:currentPos()
   // aCoords[2]+= aDelta[2]
   // ::btnZoomIn:setPos(aCoords)
   //
   // aCoords := ::btnZoomOut:currentPos()
   // aCoords[2]+= aDelta[2]
   // ::btnZoomOut:setPos(aCoords)

   aCoords := ::btnPrint:currentPos()
   aCoords[2]+= aDelta[2]
   ::btnPrint:setPos(aCoords)

   aCoords := ::btnRuler:currentPos()
   aCoords[2]+= aDelta[2]
   ::btnRuler:setPos(aCoords)

   aCoords := ::btnClose:currentPos()
   aCoords[2]+= aDelta[2]
   ::btnClose:setPos(aCoords)

   aCoords := ::spnPage:currentPos()
   aCoords[2]+= aDelta[2]
   ::spnPage:setPos(aCoords)

   aCoords := ::sayNumPages:currentPos()
   aCoords[2]+= aDelta[2]
   ::sayNumPages:setPos(aCoords)
   ::invalidateRect( {0, 0, aNew[1], aNew[2]} )
*/


RETURN self

METHOD S2PreviewDialog:tbInk()
   LOCAL nEvent, mp1, mp2, oXbp
   LOCAL nEvent2, mp12, mp22, oXbp2
   LOCAL bEval

   DO WHILE ::lEventLoop
      nEvent := dfAppEvent( @mp1, @mp2, @oXbp, NIL, self )

      #ifdef _S2DEBUG_
         S2DebugOut(oXbp, nEvent, mp1, mp2)
      #endif

      IF nEvent == xbeP_Keyboard
         // Simone 23/04/2004 GERR 3833
         // Toglie dalla coda dei messaggi i messaggi keyboard doppi
         dfIgnoreKbdEvent(mp1, mp2, oXbp)
       /*
         // Toglie dalla coda dei messaggi i messaggi doppi
         DO WHILE .T.
            nEvent2 := dfNextAppEvent(@mp12, @mp22, @oXbp2)

            IF nEvent2 == nEvent .AND. mp12 == mp1 .AND. mp22 == mp2 .AND. ;
               oXbp2 != oXbp

               AppEvent(@mp12, @mp22, @oXbp2)
            ELSE

               EXIT
            ENDIF

         ENDDO
        */
      ENDIF


      oXbp:handleEvent( nEvent, mp1, mp2 )
   ENDDO

RETURN self

METHOD S2PreviewDialog:DrawFile( oPS, cFile, aExtra, lThread, bBreak )
   LOCAL aPageSize := ::viewPreview:getPageSize()
   LOCAL aTextBox, nY, nSegment
   LOCAL nFontWidth, nFontHeight, nCount := 0
   LOCAL cString, aFrame, nHandle, nFileLen, cCol
   LOCAL aCurrAttr := dfWinPrnReset()
   LOCAL cDevice := ::viewPreview:printer:devName
   LOCAL nLine := 0
   LOCAL nSize := 0, nMargX, nMargY
   LOCAL nPag  := 0
   LOCAL aImg  := {}
   LOCAL nPageHeight := aPageSize[2]
   LOCAL bFont
   LOCAL aPaperSize := ::viewPreview:getPrinterSize()
   LOCAL cInitString
   LOCAL nOldMode
   LOCAL nCurrPage := 0
   LOCAL bImg := {|oPS, oBmp, aImgPos, cImgName| AADD(aImg, {cImgName, oBmp, aImgPos}) }
   LOCAL aMatrix
   LOCAL oFile
   LOCAL aAttr
   LOCAL aAttr1
   LOCAL nBGColor
   LOCAL aBoxPos
   LOCAL lEvidenzia

   ::nDrawing++

   nY := nPageHeight
   nMargX := aPaperSize[3]
   nMargY := aPaperSize[4]

   // Get font metrics of current font
   // -> height and width of largest letter
   aTextBox    := GraQueryTextBox( oPS, "w" )
   nFontWidth  := aTextBox[3,1] - aTextBox[2,1]
   aTextBox    := GraQueryTextBox( oPS, "^g" )
   nFontHeight := aTextBox[3,2] - aTextBox[2,2]

   //DEFAULT bBreak TO {|| .F. }
   IF bBreak != NIL .AND. VALTYPE(bBreak)!="B"
      bBreak := NIL
   ENDIF

   IF ! EMPTY(aExtra)

      IF aExtra[DFWINREP_EX_MARGTOP] != NIL
         //nMargY := aExtra[DFWINREP_EX_MARGTOP]
         nMargY += -aExtra[DFWINREP_EX_MARGTOP] - ;
                     (aPaperSize[2] - aPaperSize[6])

      ENDIF

      IF aExtra[DFWINREP_EX_MARGLEFT] != NIL
         nMargX := aExtra[DFWINREP_EX_MARGLEFT]
      ENDIF

      IF aExtra[DFWINREP_EX_INTERLINE] != NIL
         nFontHeight := aExtra[DFWINREP_EX_INTERLINE]
      ENDIF

      IF aExtra[DFWINREP_EX_PAGEHEIGHT] != NIL
         nPageHeight := aExtra[DFWINREP_EX_PAGEHEIGHT]
      ENDIF

      IF aExtra[DFWINREP_EX_FONTS] != NIL
         bFont := aExtra[DFWINREP_EX_FONTS]
      ENDIF
   ENDIF

   IF ! EMPTY(dfSet("XbasePrintEasyReadColor"))
      nBGColor := S2DbseeColorToRGB(dfSet("XbasePrintEasyReadColor"), .T.)
   ENDIF

   IF lThread
      sleep(20)
   ELSE
      //dfPIOn("Attesa...", "Anteprima pagina "+ALLTRIM(STR(++nPag)))
      dfPIOn(dfStdMsg1(MSG1_DFPRNMENU07), dfStdMsg1(MSG1_DFPRNMENU04)+ALLTRIM(STR(++nPag)))
   ENDIF              

   // Le pagine successive alla prima sono ad una coord. Y fuori dallo schermo
   // altrimenti si sovrappongono alla prima
   //
   // ::nPageHeight e ::aMatrix sono usate in XbpMultiPagePreview per
   // spostare il PS e le immagini alla coord. Y giusta per le pagine successive
   // alla prima.
   IF ::lUseMatrix
      ::viewPreview:nPageHeight := nPageHeight
      aMatrix  := GraInitMatrix()      // get transformation matrix
      // Sposto le stringhe alla coord. Y corretta
      GraTranslate( oPs, aMatrix, 0   , nPageHeight, GRA_TRANSFORM_REPLACE)
      ::viewPreview:aMatrix     := aMatrix
   ELSE
      ::viewPreview:nPageHeight := 0
      ::viewPreview:aMatrix     := NIL
   ENDIF
   // The entire display is stored in one segment
   nSegment := GraSegOpen( oPS )

   nFileLen:=DIRECTORY(cFile)[1][2]

   oFile      := dfFile():new()
   nHandle    := oFile:Open( cFile )     // Open file
   nCurrPage  := 1
   lEvidenzia := .T.

   DO WHILE ! oFile:Eof()               // until not EOF()

      IF bBreak != NIL .AND. EVAL(bBreak)
         EXIT
      ENDIF

      nY -= nFontHeight
      cString:= oFile:Read()      // Read line

      nSize += LEN(cString)+2

      IF ! lThread
         IF ! dfPIStep(nSize, nFileLen)
            EXIT
         ENDIF
      ENDIF

      // Tolgo codici _CR o _LF iniziali
      DO WHILE ! EMPTY(cString) .AND. LEFT(cString, 1) $ CRLF
         cString := SUBSTR(cString, 2)
      ENDDO

      IF nY < 0 .OR. LEFT( ALLTRIM(cString), 1 ) == NEWPAGE

         // Close segment
         GraSegClose( oPS )

         IF lThread .AND. nCurrPage == 1
            sleep(20)
         ENDIF
         IF ! ::lUseMatrix
            oPS:drawMode(GRA_DM_RETAIN)
         ENDIF

         ::addPageSegment({nSegment, aImg})

         aImg := {}

         nCurrPage++

         lEvidenzia := .T.

         // The entire display is stored in one segment
         nSegment := GraSegOpen( oPS )

         nY := nPageHeight - nFontHeight
         nLine := 0
         IF LEFT( ALLTRIM(cString), 1 ) == NEWPAGE
            cString := STRTRAN(cString, NEWPAGE, "")
         ENDIF

         IF ! lThread
            //dfPIUpdMsg("Anteprima pagina "+ALLTRIM(STR(++nPag)))
            dfPIUpdMsg(dfStdMsg1(MSG1_DFPRNMENU04)+ALLTRIM(STR(++nPag)))
         ENDIF     
      ENDIF

      IF lEvidenzia .AND. nBGColor != NIL
         // evidenziazione righe 
         aAttr := GraSetAttrArea(oPS)
         aAttr1 := ACLONE(aAttr)
         aAttr1[GRA_AA_COLOR] := nBGColor
         GraSetAttrArea(oPS, aAttr1)
         FOR nLine := nY TO 0 STEP -2*nFontHeight
            aBoxPos := { nMargX, IIF(::lUseMatrix .AND. nCurrPage > 1, -nPageHeight, 0) + nMargY+nLine }
            aBoxPos[2] -= nFontHeight*10/100
            //cString := dfPrintBoxString(0, 0, 512, 1, .T., cType)+cString
            GraBox(oPS, aBoxPos, {aPaperSize[5], aBoxPos[2]+(nFontHeight*90/100) }, GRA_FILL)
         NEXT
         GraSetAttrArea(oPS, aAttr)

         lEvidenzia := .F.
      ENDIF

      DO WHILE .T.
         cInitString := cString

         cString := dfFile2WPrnDrawBox(cString, oPS, nMargX, ;
                                       IIF(::lUseMatrix .AND. nCurrPage > 1, ;
                                           -nPageHeight, 0) +nMargY+nY, ;
                                       nFontHeight, cDevice, aCurrAttr, .T., ;
                                       bFont, .T., ::aFontCache )

         IF cString == cInitString
            EXIT
         ENDIF
      ENDDO

      // Stampa la stringa con gli attributi correnti
      // le pagine successive alla prima non sono visibili perchŠ
      // hanno coord. Y fuori dello schermo, saranno spostate dal
      // xbpMultiPagePreview
      dfWinPrnStringAt( oPS, { nMargX, IIF(::lUseMatrix .AND. nCurrPage > 1, ;
                                           -nPageHeight, 0) + nMargY+nY }, ;
                        cString, cDevice, ;
                        aCurrAttr, .T., nSegment, bFont, bImg, ::aImgCache, ;
                        nFontHeight, ::aFontCache, ::lUseMatrix)

      oFile:Skip()
   ENDDO
   oFile:Close()

   IF ! lThread
      dfPIOff()
   ENDIF

   // Close segment
   GraSegClose( oPS )

   ::addPageSegment({nSegment, aImg})

   ::nDrawing--

   // Return segment ID in an array
   // XbpMultiPagePreview expects an array containing segment IDs
RETURN NIL

METHOD S2PreviewDialog:addPageSegment(a)
   LOCAL nMaxPages

   AADD(::viewPreview:segments, a)
   ::viewPreview:adjustCurrPage()

   nMaxPages := ::viewPreview:NumPages()
   ::spnPage:setNumLimits(1, nMaxPages)
   ::sayNumPages:setCaption(" / "+ALLTRIM(STR(nMaxPages)))

   // Forzo display per la prima pagina
   IF nMaxPages == 1 .AND. ::viewPreview:lRenderInThread
      //sleep(20)
      ::viewPreview:drawPage()
      ::spnPage:setData(1)
   ENDIF

RETURN self

