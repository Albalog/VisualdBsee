#include "Gra.ch"
#include "Xbp.ch"
#include "Common.ch"
// #include "Appevent.ch"
// #include "Font.ch"
#include "dfReport.ch"
#include "dfXbase.ch"
#include "dfMsg1.ch"
#include "XBPDEV.CH"


// Dispositivo di stampa
// Stampante Windows
CLASS S2PrintDispWinPrinter FROM S2PrintDisp
   EXPORTED:
      VAR cmbPrinter
      VAR btnSet
      VAR btnProperties
      VAR spnCopies
      VAR cmbPaper
      VAR txtPaper
      VAR txtTray
      VAR cmbTray
      VAR txtCopies
      VAR txtPrinter
      VAR aPrinters
      VAR aErrPrinters
      VAR oPrinter

      VAR lNoPrinters

      METHOD init
      METHOD create
      METHOD exitMenu
      METHOD execute
      METHOD isDefault
      METHOD getPrintersList

      METHOD configurePrinter
      METHOD setupPrinter
      METHOD getPrinterSets
      METHOD setPrinterSets
      METHOD Imposta

      INLINE METHOD canSupportFont(); RETURN .T.
      INLINE METHOD canSupportImg() ; RETURN .T.
      INLINE METHOD canSupportBox() ; RETURN .T.

ENDCLASS

METHOD S2PrintDispWinPrinter:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oXbp
   ::S2PrintDisp:init( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::dispName := dfStdMsg1(MSG1_S2PDISWP01)

   oXbp     := XbpStatic():new( self, , {12,110}, {72,14} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISWP02)
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_BOTTOM
   ::txtPrinter := oXbp

   oXbp     := XbpCombobox():new( self, , {12,02}, {492,108}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:clipSiblings := .T.
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:tabStop := .T.
   oXbp:itemSelected := {|| ::configurePrinter(), ::getPrinterSets() }
   ::cmbPrinter := oXbp
   ::addShortCut(::txtPrinter:caption, oXbp)

   oXbp  := XbpPushButton():new( self, , {528,86}, {96,24} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISWP03)
   oXbp:clipSiblings := .T.
   oXbp:tabStop := .T.
   oXbp:activate := {|| ::setupPrinter() }
   ::btnProperties := oXbp
   ::addShortCut(oXbp:caption, oXbp)

   oXbp         := XbpPushButton():new( self, , {528,50}, {96,24} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISWP04)
   oXbp:clipSiblings := .T.
   oXbp:tabStop := .T.
   oXbp:activate := {|| ::imposta() }
   ::btnSet := oXbp
   ::addShortCut(oXbp:caption, oXbp)

   oXbp       := XbpStatic():new( self, , {12,62}, {84,24} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISWP05)
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_BOTTOM
   ::txtPaper := oXbp

   oXbp       := XbpCombobox():new( self, , {12,-34}, {216,96}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:clipSiblings := .T.
   oXbp:tabStop := .T.
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   ::cmbPaper := oXbp
   ::addShortCut(::txtPaper:caption, oXbp)

   oXbp        := XbpStatic():new( self, , {240,62}, {84,24} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISWP06)
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_BOTTOM
   ::txtTray := oXbp

   oXbp        := XbpCombobox():new( self, , {240,-34}, {204,96}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:clipSiblings := .T.
   oXbp:tabStop := .T.
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   ::cmbTray := oXbp
   ::addShortCut(::txtTray:caption, oXbp)

   oXbp      := XbpStatic():new( self, , {456,62}, {36,24} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISWP07)
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_BOTTOM
   ::txtCopies := oXbp

   //oXbp      := XbpSpinbutton():new( self, , {456,38}, {48,24}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp      := XbpSpinXP():new( self, , {456,38}, {48,24}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 3
   oXbp:clipSiblings := .T.
   oXbp:tabStop := .T.
   oXbp:setNumLimits(1, 999)

   ::spnCopies := oXbp
   ::addShortCut(::txtCopies:caption, oXbp)

   ::oPrinter := S2Printer():new()
   ::aPrinters := ::getPrintersList() 
   ::aErrPrinters := {}

RETURN self

METHOD S2PrintDispWinPrinter:isDefault()
RETURN ! UPPER(ALLTRIM(::aBuffer[REP_PRINTERPORT])) == "FILE" .AND. ;
       dfIsWinPrinter(::aBuffer)

// simone 22/09/2006
// mantis 0001148: il menu di stampa visualizza il nome della stampante in modo diverso da windows
// ritorna elenco stampanti
METHOD S2PrintDispWinPrinter:getPrintersList()
   LOCAL aRet := {}
   LOCAL aArr := dfWinPrinters()
   LOCAL cName
   LOCAL n
   LOCAL cAppo    := ""
   LOCAL nPos

   ASIZE(aRet, LEN(aArr))

   FOR n := 1 TO LEN(aArr)
      // converte nome di rete "\\Massimo\RICOH Aficio 220 PCL 5e"
      // in "RICOH Aficio 220 PCL 5e su Massimo"
      cName := ALLTRIM( aArr[n] )
      IF LEFT(cName,2) == "\\"
         cName := SUBSTR(cName, 3)
         nPos  := AT("\", cName)
         cAppo := SUBSTR(cName, 1, nPos-1)
         cName := SUBSTR(cName, nPos+1) + " su " + cAppo
      ENDIF

      aRet[n] := {cName, aArr[n]}
   NEXT
RETURN aRet


METHOD S2PrintDispWinPrinter:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL n
   ::S2PrintDisp:create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::txtPrinter:create()
   ::cmbPrinter:create()

   ::btnProperties:create()
   ::btnSet:create()

   ::cmbPaper:create()
   ::txtPaper:create()

   ::txtTray:create()
   ::cmbTray:create()

   ::txtCopies:create()
   ::spnCopies:create()

   ::spnCopies:setData(::aBuffer[REP_COPY])

   IF dfAnd( ::aBuffer[REP_DISABLE], PRN_DISABLE_COPY ) != 0
      ::txtCopies:hide()
      ::spnCopies:hide()

      // SD 6/2/08
      // mantis 0001757: clasee XbpSpinXP non funziona bene metodo hide()
      // workaround imposto dimensione 0
      ::spnCopies:setSize({0, 0})
   ENDIF

   IF ::isDefault()
      dfWinPrinterObjSet( ALLTRIM(::aBuffer[REP_PRINTERARR][PRINTER_INFO]) )
   ENDIF

   IF ! EMPTY(dfWinPrinterObject())
      ::oPrinter := dfWinPrinterObject()

   ELSEIF ::oPrinter != NIL
      ::oPrinter:create()
   ENDIF

   // simone 22/09/2006
   // mantis 0001148: il menu di stampa visualizza il nome della stampante in modo diverso da windows
   AEVAL(::aPrinters, {|x| ::cmbPrinter:addItem(x[1]) })

   ::aErrPrinters := {}

   ::lNoPrinters := .F.

   IF ::cmbPrinter:numItems() == 0
      ::cmbPrinter:addItem( dfStdMsg1(MSG1_S2PDISWP08) )
      ::lNoPrinters := .T.

   ELSEIF ::oPrinter:devName != NIL
      // simone 22/09/2006
      // mantis 0001148: il menu di stampa visualizza il nome della stampante in modo diverso da windows
      n := ASCAN(::aPrinters, {|x|UPPER(ALLTRIM(x[2]))==UPPER(ALLTRIM(::oPrinter:devName))})
      IF n > 0
         ::cmbPrinter:XbpSLE:setData(::aPrinters[n][1])
      ENDIF
      ::getPrinterSets()

   ENDIF

   IF ::lNoPrinters
      ::cmbPrinter:disable()
      ::btnSet:disable()
      ::btnProperties:disable()
      ::spnCopies:disable()
      ::cmbPaper:disable()
      ::cmbTray:disable()
   ENDIF


   // WorkAround per gestione tastiera dei combobox
   ::ComboBoxWorkAround(::childList())
RETURN self

METHOD S2PrintDispWinPrinter:getPrinterSets()
   LOCAL nCurr
   LOCAL cPrinter := ""
   LOCAL aForms, nCurrForm
   LOCAL aBins, nCurrBin
   LOCAL lOk  := .F.
   LOCAL nFascicola   := XBPPRN_COLLATIONMODE_ON 
   LOCAL nFronteRetro := XBPPRN_DUPLEXMODE_OFF
   LOCAL oErr := ErrorBlock({|e| break(e) })




   BEGIN SEQUENCE
      // A volte ho un runtime error in questa fase
      // per problemi del driver di stampa

      // 17:06:23 mercoled 10 gennaio 2001
      // tolto perchŠ stampa N volte
      // nCurr := ::oPrinter:setNumCopies()
      //
      // IF nCurr == NIL
      //    //::spnCopies:disable()
      // ELSE
      //    //::spnCopies:enable()
      //    ::spnCopies:setData(nCurr)
      // ENDIF
      cPrinter     := ::oPrinter:devName
      aForms       := ::oPrinter:forms()
      nCurrForm    := ::oPrinter:setFormSize()
      aBins        := ::oPrinter:paperBins()
      nCurrBin     := ::oPrinter:setPaperBin()
      nFascicola   := ::oPrinter:setCollationMode()
      nFronteRetro := ::oPrinter:setDuplexMode()
      ::nPaperOrientation := ::oPrinter:setOrientation()


      lOk := .T.
   END SEQUENCE

   ErrorBlock(oErr)

   IF ! lOk

      IF VALTYPE(cPrinter) != "C" .OR. EMPTY(cPrinter)
         cPrinter := dfStdMsg1(MSG1_S2PDISWP09)
      ELSE
         // L'aggiungo all'elenco delle stampanti da non utilizzare
         AADD(::aErrPrinters,cPrinter)
      ENDIF
      dbMsgErr(dfStdMsg1(MSG1_S2PDISWP10) + cPrinter + ;
               dfStdMsg1(MSG1_S2PDISWP11))

   ENDIF

   DEFAULT aForms    TO {}
   DEFAULT nCurrForm TO 0
   DEFAULT aBins     TO {}
   DEFAULT nCurrBin  TO 0

   ::cmbPaper:clear()

   AEVAL(aForms, {|x| ::cmbPaper:addItem(x[2]) })

   nCurr := ASCAN(aForms, {|x| x[1]==nCurrForm})

   IF nCurr == 0 .AND. LEN(aForms)>1
      nCurr := 1
   ENDIF

   //::cmbPaper:XbpSLE:setData( IIF(nCurr==0, SPACE(30), aForms[nCurr][2]) )
   //Gerr. 4291 Luca 28/10/2004
   IF nCurr == 0 .OR. LEN(aForms) <1 
      ::cmbPaper:XbpSLE:setData( SPACE(30) )
   ELSE
      ::cmbPaper:SetData(nCurr)
   ENDIF

   ::cmbTray:clear()
   AEVAL(aBins, {|x| ::cmbTray:addItem(x[2]) })
   nCurr := ASCAN(aBins, {|x| x[1]==nCurrBin})

   IF nCurr == 0 .AND. LEN(aBins)>1
      nCurr := 1
   ENDIF
   ::cmbTray:XbpSLE:setData( IIF(nCurr==0, SPACE(30), aBins[nCurr][2]) )

RETURN self


METHOD S2PrintDispWinPrinter:setPrinterSets()
   LOCAL aCurr
   LOCAL oErr := ErrorBlock({|e| break(e) })
   LOCAL nPag


   BEGIN SEQUENCE
      // A volte ho un runtime error in questa fase
      // per problemi del driver di stampa

      aCurr := ::cmbPaper:getData()
      IF !EMPTY(aCurr)   
         nPag  :=  aCurr[1]
         IF EMPTY(nPag)
            nPAG  :=  1
         ENDIF 
      ELSE
        nPAG  :=  1
      ENDIF 
      IF ! EMPTY(aCurr) .AND. LEN(::oPrinter:forms()) >= nPag 
         ::oPrinter:setFormSize(::oPrinter:forms()[ nPag ][1])
      ENDIF

      aCurr := ::cmbTray:getData()
      IF !EMPTY(aCurr)   
         nPag  :=  aCurr[1]
         IF EMPTY(nPag)
            nPAG  :=  1
         ENDIF 
      ELSE
        nPAG  :=  1
      ENDIF 
      IF ! EMPTY(aCurr) .AND. LEN(::oPrinter:paperBins()) >= nPag 
         nPag  := aCurr[1]
         ::oPrinter:setPaperBin(::oPrinter:paperBins()[ nPag ][1])
      ENDIF


      /////////////////////////////////////////////////////////////////
      IF !EMPTY(::nPaperOrientation)
         ::oPrinter:setOrientation(::nPaperOrientation)
      ENDIF 
      /////////////////////////////////////////////////////////////////

      // 17:06:23 mercoled 10 gennaio 2001
      // tolto perchŠ stampa N volte
      // IF ::oPrinter:setNumCopies() != NIL
      //    ::oPrinter:setNumCopies(::spnCopies:getData())
      // ENDIF

   END SEQUENCE
   ErrorBlock(oErr)

RETURN self

METHOD S2PrintDispWinPrinter:imposta()
   LOCAL oDlg
   LOCAL oPS

   IF ::configurePrinter()
      ::setPrinterSets()

      dfWinPrnFontDlg(::oPrinter)
   ENDIF
RETURN self

METHOD S2PrintDispWinPrinter:configurePrinter()
   LOCAL aSel := ::cmbPrinter:XbpListBox:getData()
   LOCAL cPrinter
   LOCAL lRet := .F.
   IF LEN(aSel) > 0
      // simone 22/09/2006
      // mantis 0001148: il menu di stampa visualizza il nome della stampante in modo diverso da windows
      cPrinter := ::aPrinters[aSel[1]][2]

      IF ! cPrinter == ::oPrinter:devName
         // Destroy printer object to free
         // resources
         ::oPrinter:destroy()

         // Re-create the object using the
         // printer name selected
         ::oPrinter:create( cPrinter )

         // La imposto come default per eventuale anteprima o stampa
         dfWinPrinterObjSet( cPrinter )

      ENDIF

      lRet := .T.
   ENDIF

RETURN lRet

METHOD S2PrintDispWinPrinter:setupPrinter()
   IF ::configurePrinter()
      ::setPrinterSets()
      ::oPrinter:setupDialog()
      ::getPrinterSets()
   ENDIF
RETURN self

METHOD S2PrintDispWinPrinter:exitMenu(nAction, aBuf)
   LOCAL aSel := ::cmbPrinter:XbpListBox:getData()
   LOCAL cPrinter
   LOCAL aCurr := {}

   IF nAction > 0 .AND. LEN(aSel) > 0
      // simone 22/09/2006
      // mantis 0001148: il menu di stampa visualizza il nome della stampante in modo diverso da windows
      cPrinter := ::aPrinters[aSel[1]][2]

      IF ASCAN(::aErrPrinters, {|x| cPrinter==x }) == 0

         IF ::configurePrinter()
            ::setPrinterSets()
         ENDIF

         dfPrnSet( aBuf, dfGetPrnID( cPrinter ) )
         dfWinPrinterObjSet( cPrinter )

         // Porta fittizia, non sar… usata ma serve poi per la gestione
         aBuf[REP_PRINTERPORT] := "LPT1"

      ELSE
         dbMsgErr(dfStdMsg1(MSG1_S2PDISWP10) + cPrinter + ;
                  dfStdMsg1(MSG1_S2PDISWP11))
         nAction := -1
      ENDIF
   ENDIF

   aBuf[REP_COPY] := ::spnCopies:getData()

   //////////////////////////////////////////////////////
   //Modifica inserit il 22/07/2013 per gestire correttamente sulla stampante il formato carta selezionato nel men— 
   aCurr := ::cmbPaper:getData()
   IF !EMPTY(aCurr)
      aBuf[REP_PAGE_FORMAT ] := ::oPrinter:forms()[ aCurr[1] ][1]
      ::oPrinter:setformsize( aBuf[REP_PAGE_FORMAT ] )
   ENDIF
   IF !EMPTY(::nPaperOrientation)
      aBuf[REP_ORIENTATION ]    := ::nPaperOrientation
      ::oPrinter:setOrientation( aBuf[REP_ORIENTATION ] )
   ENDIF 
   //////////////////////////////////////////////////////


RETURN nAction

METHOD S2PrintDispWinPrinter:execute()
   LOCAL lPrint := .T.
   LOCAL nCopies
   /////////////////////////////////////////////////////////////////////
   //Gerr 4583
   LOCAL nThread
   LOCAL cThread  := dfset("XbaseWinPrinterThreadMode")
   IF cThread != NIL .AND. S2IsNumber(cThread) .AND. ! EMPTY(cThread) 
      nThread := VAL(cThread)
      IF nThread <= 0
         nThread := 0
      ENDIF
      IF nThread >= 3
         nThread := 3
      ENDIF
   ENDIF
     // 0 = SENZA THREAD, 1=SENZA THREAD + ERASE FILE
     // 2 = CON THREAD  , 3= CON THREAD+ERASE FILE
   DEFAULT nThread TO 3
   /////////////////////////////////////////////////////////////////////


   //lPrint := dfFile2WPrn( ::aBuffer[REP_FNAME], ::aBuffer[REP_NAME], ;
   //                       ::aBuffer[REP_XBASEPRINTOBJ], ;
   //                       ::aBuffer[REP_XBASEPRINTEXTRA], ;
   //                       3, ; 
   //                       ::aBuffer[REP_COPY]) 
   lPrint := dfFile2WPrn( ::aBuffer[REP_FNAME], ::aBuffer[REP_NAME], ;
                          ::aBuffer[REP_XBASEPRINTOBJ], ;
                          ::aBuffer[REP_XBASEPRINTEXTRA], ;
                          nThread, ; 
                          ::aBuffer[REP_COPY]) 

   ::aBuffer[REP_COPY] := 0

//   IF EMPTY(::oPrinter) .OR. ::oPrinter:setNumCopies() == NIL
      // La stampante non supporta questa opzione
//
//      DO WHILE ::aBuffer[REP_COPY]-->0 .AND. lPrint
//         lPrint := dfFile2WPrn( ::aBuffer[REP_FNAME], ::aBuffer[REP_NAME], ;
//                                ::aBuffer[REP_XBASEPRINTOBJ], ;
//                                ::aBuffer[REP_XBASEPRINTEXTRA], ;
//                                IIF(::aBuffer[REP_COPY]>0, 2, 3) ) // Eseguo la cancellazione sull'ultima copia
//
         // 17:06:23 mercoled 10 gennaio 2001
         // La scelta delle copie dovrebbe essere fatta a livello di
         // mashera dBsee, altrimenti crei doppioni
         //IF ::oPrinter:setNumCopies() != NIL
         //   EXIT
         //ENDIF
//      ENDDO
//
//   ELSEIF ::aBuffer[REP_COPY] > 0
//      nCopies := ::oPrinter:setNumCopies()
//
//      ::oPrinter:setNumCopies(::aBuffer[REP_COPY])
//      lPrint := dfFile2WPrn( ::aBuffer[REP_FNAME], ::aBuffer[REP_NAME], ;
//                             ::aBuffer[REP_XBASEPRINTOBJ], ;
//                             ::aBuffer[REP_XBASEPRINTEXTRA], ;
//                             3 ) // Eseguo la cancellazione sull'ultima copia
//
//      ::oPrinter:setNumCopies(nCopies)
//      ::aBuffer[REP_COPY] := 0
//   ENDIF

   // Non serve, ora Š fatto dalla dfFile2Wprn
   // IF lPrint  // Se la stampa e' andata a buon fine
   //    FERASE( ::aBuffer[REP_FNAME] )
   // ENDIF

RETURN lPrint

//   IF ::nAction != 0 .AND. ;
//      ::configurePrinter()
//      ::setPrinterSets()
//
//      dfWinPrinterObject(::oPrinter)
//   ENDIF

