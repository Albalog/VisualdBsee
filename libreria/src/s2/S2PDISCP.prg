#include "Gra.ch"
#include "Xbp.ch"
#include "Common.ch"
// #include "Appevent.ch"
// #include "Font.ch"
#include "dfReport.ch"
#include "dfXbase.ch"
#include "dfMsg1.ch"
#include "dfWinRep.ch"
#include "XBPDEV.CH"



#define _LF (CHR(10))

// Dispositivo di stampa
// Stampante Windows
CLASS S2PrintDispCRWPrinter FROM S2PrintDisp
   EXPORTED:
      VAR cmbPrinter
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
      VAR chkFascicola

      VAR lNoPrinters
      VAR lFascicola

      METHOD init
      METHOD create
      METHOD exitMenu
      METHOD execute
      METHOD isDefault

      METHOD configurePrinter
      METHOD setupPrinter
      METHOD getPrinterSets
      METHOD setPrinterSets
      METHOD Close
ENDCLASS

METHOD S2PrintDispCRWPrinter:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oXbp
   ::S2PrintDisp:init( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::dispName := dfStdMsg1(MSG1_S2PDISCP01)

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

   oXbp      := XbpSpinbutton():new( self, , {456,38}, {48,24}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 3
   oXbp:clipSiblings := .T.
   oXbp:tabStop := .T.
   oXbp:setNumLimits(1, 999)
   oXbp:endSpin := {| uNIL1, uNIL2, oSp| IIF(oSp:GetData() <=1,::chkFascicola:Disable(), ::chkFascicola:Enable() ) }

   ::spnCopies := oXbp
   ::addShortCut(::txtCopies:caption, oXbp)

   oXbp              := XbpCheckbox():new( self, , {520,42}, {0,0}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } }  )
   oXbp:caption      := dfStdMsg1(MSG1_S2PDISFI13)
   oXbp:clipSiblings := .T.
   oXbp:tabStop      := .T.
   oXbp:autoSize     := .T.
   oXbp:selected     := {|l| ::lFascicola := l }

   //::addShortCut(oXbp:caption, oXbp)
   ::chkFascicola    := oXbp

   IF dfSet("XbaseCrystalPrintwithLoop") == "YES" 
      ::chkFascicola:hide() 
   ENDIF 

   //Luca Inserito Settaggio per gestione defualt Fascicola Mantis 2208. del 30/10/2012
   /////////////////////////////////
   ::lFascicola      := .F.
   /////////////////////////////////

   ::oPrinter := S2CRWPrinter():new()
   ::aPrinters := dfWinPrinters()
   ::aErrPrinters := {}

RETURN self

METHOD S2PrintDispCRWPrinter:isDefault()
RETURN dfIsWinPrinter(::aBuffer)
// RETURN ! UPPER(ALLTRIM(::aBuffer[REP_PRINTERPORT])) == "FILE" .AND. ;
//        dfIsWinPrinter(::aBuffer)


METHOD S2PrintDispCRWPrinter:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::S2PrintDisp:create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::txtPrinter:create()
   ::cmbPrinter:create()

   ::btnProperties:create()

   ::cmbPaper:create()
   ::txtPaper:create()

   ::txtTray:create()
   ::cmbTray:create()

   ::txtCopies:create()
   ::spnCopies:create()
   ::chkFascicola:create()


   ::spnCopies:setData(::aBuffer[REP_COPY])

   IF ::spnCopies:GetData() <=1
      ::chkFascicola:disable()
   ENDIF 

   IF dfAnd( ::aBuffer[REP_DISABLE], PRN_DISABLE_COPY ) != 0
      ::spnCopies:hide()
      ::chkFascicola:hide() 
   ENDIF

   IF ::isDefault()
      dfCRWPrinterObjSet( ALLTRIM(::aBuffer[REP_PRINTERARR][PRINTER_INFO]) )
   ENDIF


   IF ! EMPTY(dfCRWPrinterObject())
      ::oPrinter := dfCRWPrinterObject()

   ELSEIF ::oPrinter != NIL
      ::oPrinter:create()
   ENDIF

   AEVAL(::aPrinters, {|x| ::cmbPrinter:addItem(x) })

   ::aErrPrinters := {}

   ::lNoPrinters := .F.

   IF ::cmbPrinter:numItems() == 0
      ::cmbPrinter:addItem( dfStdMsg1(MSG1_S2PDISWP08) )
      ::lNoPrinters := .T.

   ELSEIF ::oPrinter:devName != NIL
      ::cmbPrinter:XbpSLE:setData(::oPrinter:devName)
      ::getPrinterSets()

   ENDIF

   IF ::lNoPrinters
      ::cmbPrinter:disable()
      ::btnProperties:disable()
      ::spnCopies:disable()
      ::cmbPaper:disable()
      ::cmbTray:disable()
      ::chkFascicola:disable()
   ENDIF


   // WorkAround per gestione tastiera dei combobox
   ::ComboBoxWorkAround(::childList())
RETURN self

METHOD S2PrintDispCRWPrinter:getPrinterSets()
   LOCAL nCurr
   LOCAL cPrinter := ""
   LOCAL aForms, nCurrForm
   LOCAL aBins, nCurrBin
   LOCAL lOk := .F.
   LOCAL nFascicola   := XBPPRN_COLLATIONMODE_ON 
   LOCAL nFronteRetro := XBPPRN_DUPLEXMODE_OFF
   LOCAL oErr := ErrorBlock({|e| break(e) })

   BEGIN SEQUENCE
      // A volte ho un runtime error in questa fase
      // per problemi del driver di stampa

      // 17:06:23 mercoledç 10 gennaio 2001
      // tolto perchä stampa N volte
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
      ::nPaperOrientation := ::oPrinter:setOrientation()
      nFronteRetro := ::oPrinter:setDuplexMode()
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
   /////////////////////////////////////////////////////////////////////////
   //Mantis 2237
   //Modifica Luca del 15/10/2013 
   //::cmbTray:XbpSLE:setData( IIF(nCurr==0, SPACE(30), aBins[nCurr][2]) )
   IF nCurr == 0 .OR. LEN(aBins) <1 
      ::cmbTray:XbpSLE:setData( SPACE(30) )
   ELSE
      ::cmbTray:SetData(nCurr)
   ENDIF
   /////////////////////////////////////////////////////////////////////////


   IF nFascicola <> NIL
      IF nFascicola == XBPPRN_COLLATIONMODE_OFF 
         ::lFascicola := .F.
      ELSE 
         ::lFascicola := .T.
      ENDIF   
      ::chkFascicola:setData(::lFascicola)
   ENDIF 
RETURN self


METHOD S2PrintDispCRWPrinter:setPrinterSets()
   LOCAL nN, nPOS
   LOCAL aCurr
   LOCAL cStr   := ""
   LOCAL oErr   := ERRORBLOCK({|e| dfErrBreak(e)})//ErrorBlock({|e| break(e) })

   BEGIN SEQUENCE
      // A volte ho un runtime error in questa fase
      // per problemi del driver di stampa



   /////////////////////////////////////////////////////////////////////////
   /////////////////////////////////////////////////////////////////////////
   //Mantis 2237
   //Modifica Luca del 15/10/2013 
      aCurr := ::cmbPaper:getData()
      cStr  := ::cmbPaper:XbpSLE:GetData()
      nPOS  :=  0
      IF !EMPTY(cStr)
         FOR nN := 1 TO LEN(::oPrinter:forms())
             IF (LEFT(cStr,1)  == "A" .OR. LEFT(cStr,1)  == "B" ) .AND.; 
                 LEFT(cStr,2)  ==LEFT(::oPrinter:forms()[nN][2],2)
                 nPOS := nN
                 EXIT
             ENDIF 
         NEXT
      ELSE 
         FOR nN := 1 TO LEN(::oPrinter:forms())
             IF "A4" == LEFT(::oPrinter:forms()[nN][2],2)
                nPOS := nN
                EXIT
             ENDIF 
         NEXT
      ENDIF 
      IF nPOS>0
         aCurr[1] := nPOS
      ENDIF 
   /////////////////////////////////////////////////////////////////////////
   /////////////////////////////////////////////////////////////////////////

   /////////////////////////////////////////////////////////////////////////
   /////////////////////////////////////////////////////////////////////////
      IF ! EMPTY(aCurr) .AND. LEN(::oPrinter:forms()) >= aCurr[1]
         ::oPrinter:setFormSize(::oPrinter:forms()[ aCurr[1] ][1])
      ELSE 
         IF LEN(::oPrinter:forms()) >= 1
            ::oPrinter:setFormSize(::oPrinter:forms()[ 1][1])
         ENDIF 
      ENDIF

      aCurr := ::cmbTray:getData()
      IF ! EMPTY(aCurr) .AND. LEN(::oPrinter:paperBins()) >= aCurr[1]
         ::oPrinter:setPaperBin(::oPrinter:paperBins()[ aCurr[1] ][1])
      ELSE
         IF LEN(::oPrinter:PaperBins()) >= 1
            ::oPrinter:setPaperBin(::oPrinter:PaperBins()[ 1][1])
         ENDIF 
      ENDIF
    /////////////////////////////////////////////////////////////////////////
   /////////////////////////////////////////////////////////////////////////


      /////////////////////////////////////////////////////////////////
      ::oPrinter:setOrientation(::nPaperOrientation)
      /////////////////////////////////////////////////////////////////
      ::oPrinter:setCollationMode(IIF(::lFascicola,XBPPRN_COLLATIONMODE_ON,XBPPRN_COLLATIONMODE_OFF)) 
      /////////////////////////////////////////////////////////////////


      // 17:06:23 mercoledç 10 gennaio 2001
      // tolto perchä stampa N volte
      // IF ::oPrinter:setNumCopies() != NIL
      //    ::oPrinter:setNumCopies(::spnCopies:getData())
      // ENDIF

   END SEQUENCE
   ErrorBlock(oErr)

RETURN self

METHOD S2PrintDispCRWPrinter:configurePrinter()
   LOCAL aSel := ::cmbPrinter:XbpListBox:getData()
   LOCAL cPrinter
   LOCAL lRet := .F.
   IF LEN(aSel) > 0
      cPrinter := ::aPrinters[aSel[1]]

      IF ! cPrinter == ::oPrinter:devName
         // Destroy printer object to free
         // resources
         ::oPrinter:destroy()

         // Re-create the object using the
         // printer name selected
         ::oPrinter:create( cPrinter )

         ::setPrinterSets()

         // La imposto come default per eventuale anteprima o stampa
         dfCRWPrinterObjSet( cPrinter )

      ENDIF

      lRet := .T.
   ENDIF

RETURN lRet

METHOD S2PrintDispCRWPrinter:setupPrinter()
   IF ::configurePrinter()
      ::setPrinterSets()
      ::oPrinter:setupDialog()
      ::getPrinterSets()
   ENDIF
RETURN self

METHOD S2PrintDispCRWPrinter:exitMenu(nAction, aBuf)
   LOCAL aSel := ::cmbPrinter:XbpListBox:getData()
   LOCAL cPrinter
   LOCAL aCurr
   LOCAL nPag

   IF nAction > 0 .AND. LEN(aSel) > 0
      cPrinter := ::aPrinters[aSel[1]]

      IF ASCAN(::aErrPrinters, {|x| cPrinter==x }) == 0

         IF ::configurePrinter()
            ::setPrinterSets()
         ENDIF

         dfPrnSet( aBuf, dfGetPrnID( cPrinter ) )
         dfCRWPrinterObjSet( cPrinter )

         // Porta fittizia, non sarÖ usata ma serve poi per la gestione
         aBuf[REP_PRINTERPORT] := "LPT1"

      ELSE
         dbMsgErr(dfStdMsg1(MSG1_S2PDISWP10) + cPrinter + ;
                  dfStdMsg1(MSG1_S2PDISWP11))
         nAction := -1
      ENDIF
   ENDIF

   aBuf[REP_COPY]         := ::spnCopies:getData()

   //////////////////////////////////////////////////////
   //Modifica inserit il 22/07/2013 per gestire correttamente sulla stampante il formato carta selezionato nel menó 
   aCurr := ::cmbPaper:getData()
   /////////////////////////////////////////////////////////////////////////////////////
   //IF !EMPTY(aCurr)
   //Luca 30/03/2015: inserito controllo sulla lunghezza del array del formato pagina
   IF !EMPTY(aCurr)   
      nPag  :=  aCurr[1]
      IF EMPTY(nPag)
         nPAG  :=  1
      ENDIF 
   ELSE
     nPAG  :=  1
   ENDIF 
   IF !EMPTY(aCurr)   .AND. LEN(::oPrinter:forms()) >= nPag 
   /////////////////////////////////////////////////////////////////////////////////////
      aBuf[REP_PAGE_FORMAT ] := ::oPrinter:forms()[ nPag ][1]
      ::oPrinter:setformsize( aBuf[REP_PAGE_FORMAT ] )
   ENDIF
   IF !EMPTY(::nPaperOrientation)
      aBuf[REP_ORIENTATION ]    := ::nPaperOrientation
      ::oPrinter:setOrientation( aBuf[REP_ORIENTATION ] )
   ENDIF 
   /////////////////////////////////////////////////////////////////
   ::oPrinter:setCollationMode(IIF(::lFascicola,XBPPRN_COLLATIONMODE_ON,XBPPRN_COLLATIONMODE_OFF)) 
   /////////////////////////////////////////////////////////////////
RETURN nAction


METHOD S2PrintDispCRWPrinter:execute()
   LOCAL lRet      := .T.
   LOCAL oRT       := ::aBuffer[REP_XBASEREPORTTYPE]
   LOCAL oCRWOut   := oRT:getOutput()
   LOCAL oCRWPrint := oRT:getPrint()
   LOCAL aArrFName := oCRWOut:getFName()
   LOCAL cArrFName := dfArr2Str(aArrFName, ", ")
   LOCAL nErr
   LOCAL nI
   LOCAL aOPT
   LOCAL cOldPrintLoop 
   LOCAL aForms

   // Cancello il file TESTO temporaneo
   FERASE( ::aBuffer[REP_FNAME] )

   // Chiudo il file DBF contenente i dati
   oCRWOut:close()

   IF dfCRWEngineLoaded()


      IF ::aBuffer[REP_ALLPAGE]
         aOpt := NIL


         IF EMPTY(::aBuffer[REP_COPY])  
            ::aBuffer[REP_COPY] := 1
         ENDIF 
         ///////////////////////////////////////////////////////////////////////////////////////////////////////////
         ::oPrinter:setCollationMode(IIF(::lFascicola,XBPPRN_COLLATIONMODE_ON,XBPPRN_COLLATIONMODE_OFF)) 
         IF ::lFascicola 
             aOpt := {1, 9999, ::aBuffer[REP_COPY],XBPPRN_COLLATIONMODE_ON }
         //ELSE
         //    aOpt := {::aBuffer[REP_FROMPAGE], ::aBuffer[REP_TOPAGE], ::aBuffer[REP_COPY],XBPPRN_COLLATIONMODE_ON }
            // Se si utilizza il fascicola allora non si puï usare la versione con loop
            cOldPrintLoop  := dfSet("XbaseCrystalPrintwithLoop","NO") 
            ::oPrinter:setNumCopies(::aBuffer[REP_COPY])
         ELSE 
            aOpt := {1, 9999, 1,XBPPRN_COLLATIONMODE_OFF }
            ::oPrinter:setNumCopies(1)
         ENDIF 
         ///////////////////////////////////////////////////////////////////////////////////////////////////////////
      ELSE
         ///////////////////////////////////////////////////////////////////////////////////////////////////////
         //luca 08/01/2014
         //Inserito settaggio per gestire correttamente la fascicolazione 
         ///////////////////////////////////////////////////////////////////////////////////////////////////////

         ///////////////////////////////////////////////////////////////////////////////////////////////////////
         //Mantis 2242 Luca C. 04/03/2014
         IF EMPTY(::aBuffer[REP_FROMPAGE])  
            ::aBuffer[REP_FROMPAGE] := 1
         ENDIF 
         IF EMPTY(::aBuffer[REP_TOPAGE])  
            ::aBuffer[REP_TOPAGE] := 9999
         ENDIF 
         IF EMPTY(::aBuffer[REP_COPY])  
            ::aBuffer[REP_COPY] := 1
         ENDIF 
         ///////////////////////////////////////////////////////////////////////////////////////////////////////


         ::oPrinter:setCollationMode(IIF(::lFascicola,XBPPRN_COLLATIONMODE_ON,XBPPRN_COLLATIONMODE_OFF)) 
         IF ::lFascicola 
            aOpt := {::aBuffer[REP_FROMPAGE], ::aBuffer[REP_TOPAGE], ::aBuffer[REP_COPY],XBPPRN_COLLATIONMODE_ON}
         ELSE 
            aOpt := {::aBuffer[REP_FROMPAGE], ::aBuffer[REP_TOPAGE], ::aBuffer[REP_COPY],XBPPRN_COLLATIONMODE_OFF}
         ENDIF 
         ///////////////////////////////////////////////////////////////////////////////////////////////////////
      ENDIF

      //dfalert(IIF(::lFascicola,"Utilizza la fascicolazione","NON Utilizza la fascicolazione"))

      // Stampo
      //nErr := oCRWPrint:print(oCRWOut:cRpt, ::aBuffer[REP_COPY], ;
      //                        oRT:setFormula(), {oCRWOut:cFName}, ;
      //                        ::oPrinter) 
      //nErr := oCRWPrint:print(oCRWPrint:cRepName, ::aBuffer[REP_COPY], ;
      //                        oRT:setFormula(), aArrFName, ;
      //                        ::oPrinter) 
      nErr := oCRWPrint:print(oCRWPrint:cRepName, ::aBuffer[REP_COPY], ;
                              oRT:setFormula(), aArrFName, ;
                              ::oPrinter, aOpt) 

      lRet := nErr == 0

      IF ! lRet  
         IF nErr == -1
            //dbMsgErr(dfStdMsg1(MSG1_S2PDISCP02)+oCRWOut:cRPT)
            dbMsgErr(dfStdMsg1(MSG1_S2PDISCP02)+oCRWPrint:cRepName)
         ELSE
            //dbMsgErr(dfStdMsg1(MSG1_S2PDISCP05)+oCRWOut:cRPT+"//"+;
            dbMsgErr(dfStdMsg1(MSG1_S2PDISCP05)+oCRWPrint:cRepName+"//"+;
                     ALLTRIM(STR(oCRWPrint:nErrCode))+"-"+STRTRAN(oCRWPrint:cErrMsg, _LF, "//") )
         ENDIF
      ELSEIF dfCRWDesign()
         dfAlert(dfStdMsg1(MSG1_S2PDISCV03)+cArrFName)
      ENDIF

   ELSE
      dbMsgErr(dfStdMsg1(MSG1_S2PDISCP04))
      lRet := .F.
   ENDIF


   IF cOldPrintLoop <> NIL
      dfSet("XbaseCrystalPrintwithLoop",cOldPrintLoop) 
   ENDIF 

   // Se sono in modalitÖ di DESIGN non cancello il file
   // DBF cosi posso costruirci sopra il REPORT con crystal

   //Gerr. 3438 30/10/03 Luca: Aggiunta la possibilitÖ di non cancellare il file 
   // dbf temporaneo creato.
   IF ! dfCRWDesign() 
      // Cancello il file DBF contenente i dati
      //FERASE(oCRWOut:cFName)

      //////////////////////////////////////
      //Luca 11/02/2016
      IF dfSet("XbaseCRWTempFileErase") == "NO"

      ELSE
         oCRWOut:FErase() 
      ENDIF 
      //////////////////////////////////////
   ENDIF

/*
   DO WHILE ::aBuffer[REP_COPY]-->0 .AND. lRet
      lRet := dfFile2WPrn( ::aBuffer[REP_FNAME], ::aBuffer[REP_NAME], ;
                             ::aBuffer[REP_XBASEPRINTOBJ], ;
                             ::aBuffer[REP_XBASEPRINTEXTRA], ;
                             IIF(::aBuffer[REP_COPY]>0, 2, 3) ) // Eseguo la cancellazione sull'ultima copia

      // 17:06:23 mercoledç 10 gennaio 2001
      // La scelta delle copie dovrebbe essere fatta a livello di
      // mashera dBsee, altrimenti crei doppioni
      //IF ::oPrinter:setNumCopies() != NIL
      //   EXIT
      //ENDIF
   ENDDO
*/
RETURN lRet

//Ger 4287 Luca 22/10/2004
// Inserito Per la chiusura delle dei file aperti quando non c'ä nulla da stampare
METHOD S2PrintDispCRWPrinter:Close()
   LOCAL lRet      := .F.
   LOCAL oRT       := ::aBuffer[REP_XBASEREPORTTYPE]
   LOCAL oCRWOut   := oRT:getOutput()
   // Eseguo Metodo di chiusura della classe padre
   ::S2PrintDisp:Close()
   // Chiudo il file DBF contenente i dati
   oCRWOut:close()
   // Cancello il file DBF contenente i dati
   IF ! dfCRWDesign() 

      oCRWOut:FErase() 
   ENDIF
   lRet := .T. 
RETURN lRet

