#include "Gra.ch"
#include "Xbp.ch"
#include "Common.ch"
#include "Appevent.ch"
#include "Font.ch"
#include "dfReport.ch"
#include "dfWinRep.ch"
#include "dfMsg1.ch"

#include "s2crwpri.ch"

#define _LF (CHR(10))

// Dispositivo di stampa
// Esportazione CRW

CLASS S2PrintDispCRWFile FROM S2PrintDisp
   PROTECTED:
      METHOD getExportTypes

      VAR oCurrDisp
      VAR xExportData
      VAR aTipOutput

   EXPORTED:
      VAR txtFile
      VAR txtSelection
      VAR sleFile
      VAR txtOrienta

      VAR btnBrowse
      VAR cmbSelect
      VAR chkBox

      METHOD init
      METHOD create

      METHOD exitMenu
      METHOD execute
      INLINE METHOD setCurrDisp(o); ::oCurrDisp := o; RETURN self

      METHOD sfoglia
      METHOD outputSelect
      VAR lOpen
      VAR nFmt

      //Ger 4287 Luca 22/10/2004
      // Inserito Per la chiusura delle dei file aperti quando non c'Š nulla da stampare
      METHOD Close

ENDCLASS

METHOD S2PrintDispCRWFile:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oXbp

   ::S2PrintDisp:init( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::dispName := dfStdMsg1(MSG1_S2PDISCF01)

   oXbp     := XbpStatic():new( self, , {12,92}, {72,24} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISFI02)
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_BOTTOM
   ::txtFile := oXbp

   oXbp     := XbpSle():new( self, , {12,65}, {300,24}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:clipSiblings := .T.
   oXbp:autoTab := .T.
   oXbp:tabStop := .T.
   oXbp:bufferLength := 250
   ::addShortCut(::txtFile:caption, oXbp)
   ::sleFile := oXbp

   oXbp       := XbpPushButton():new( self, , {324,65}, {96,24} )
   oXbp:caption := dfStdMsg1(MSG1_S2PDISFI03)
   oXbp:clipSiblings := .T.
   oXbp:tabStop := .T.
   oXbp:activate := {|| ::sfoglia() }
   ::addShortCut(oXbp:caption, oXbp)
   ::btnBrowse := oXbp

   //Implementato il 07/02/2003 per Stampa su Pdf. Luca
   oXbp     := XbpStatic():new( self, , {12,45}, {140,15} )
   oXbp:caption      := dfStdMsg1(MSG1_S2PDISFI05)
   oXbp:clipSiblings := .T.
   oXbp:options      := XBPSTATIC_TEXT_BOTTOM
   ::txtSelection    := oXbp

   oXbp              := XbpCombobox():new( self, , {12,-58}, {120,100}, { { XBP_PP_FGCLR, XBPSYSCLR_WINDOWTEXT }, { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:clipSiblings := .T.
   oXbp:type         := XBPCOMBO_DROPDOWNLIST
   oXbp:tabStop      := .T.
   oXbp:itemSelected := {|| ::OutPutSelect() }
   ::addShortCut(::txtSelection:caption, oXbp)
   ::cmbSelect       := oXbp

   oXbp              := XbpCheckbox():new( self, , {150,24}, {0,0} )
   oXbp:caption      := dfStdMsg1(MSG1_S2PDISFI06)
   oXbp:clipSiblings := .T.
   oXbp:tabStop      := .T.
   oXbp:autoSize     := .T.
   oXbp:selected     := {|l| ::lOpen := l }
   ::addShortCut(oXbp:caption, oXbp)
   ::chkBox          := oXbp

   ::aTipOutPut := ::GetExportTypes() 
RETURN self

METHOD S2PrintDispCRWFile:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL cPrinter, aBuf:= ::aBuffer
   LOCAL aFile
   LOCAL nSel := 0
   LOCAL nPOS
   LOCAL cXBasePathPrintFile := ""

   ::S2PrintDisp:create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::txtFile:create()
   ::sleFile:create()


   ::btnBrowse:create()

   //Luca
   ::txtSelection:create()

   ::cmbSelect:create()
   IF LEN(::aTipOutput)==0
      ::nFmt := 0
      ::sleFile:setData(dfStdMsg1(MSG1_S2PDISCF06)) //"export not available"
      ::cmbSelect:XbpSle:setData(dfStdMsg1(MSG1_S2PDISCF06)) //"export not available"
      ::cmbSelect:disable()
      ::chkBox:create()
      ::chkBox:disable()
      ::sleFile:disable()
      ::btnBrowse:disable()
   ELSE
      ::nFmt := 1
      ::cmbSelect:enable()
      AEVAL(::aTipOutPut, {|x| ::cmbSelect:addItem(x[DFCRWET_DEX]) })
      ::cmbSelect:XbpSLE:setData(::aTipOutPut[ ::nFmt ][DFCRWET_DEX])

      ::chkBox:create()
      ::chkBox:enable()

      // SD 22/01/08 - GERR 5043
      // imposta la stampa in un path da settaggio .ini
      ************************************************************
      IF EMPTY(::aBuffer[REP_FNAME])
         ::aBuffer[REP_FNAME] := "File"+::aTipOutPut[ ::nFmt ][DFCRWET_EXT]
      ENDIF

      cXBasePathPrintFile := dfSet("XbasePathPrintFile")
      IF ! EMPTY( cXBasePathPrintFile ) .AND. dfChkDir(cXBasePathPrintFile)
         ::aBuffer[REP_FNAME] := dfFNameBuild(::aBuffer[REP_FNAME], cXBasePathPrintFile)
      ENDIF
      ***********************************************************

      //Modificato --->
      //::sleFile:setData(::aBuffer[REP_FNAME])
      IF EMPTY(::aBuffer[REP_FNAME])
         ::sleFile:setData("File"+::aTipOutPut[ ::nFmt ][DFCRWET_EXT])
      ELSE

         // SD 12/12/2005 gerr 4573
         aFile :=  dfFNameSplit(::aBuffer[REP_FNAME])
         //Mantis 2097
         ////////////////////////////////////////////////////////////////
         //LC 31/05/2010 Richiesta di avere il defualt se richiesto in PDF
         IF !EMPTY(aFile[4]) .AND. Alltrim(UPPER(aFile[4])) == ".PDF" 
            nPOS  := ASCAN(::aTipOutPut, {|x|  UPPER(x[DFCRWET_EXT]) == ".PDF" })
            IF nPOS>0 .AND. ! UPPER(::aTipOutPut[ ::nFmt ][DFCRWET_EXT]) == ".PDF"
               ::nFmt := nPOS
               ::cmbSelect:XbpSLE:setData(::aTipOutPut[ ::nFmt ][DFCRWET_DEX])
            ENDIF 
         ENDIF 
         ////////////////////////////////////////////////////////////////


         // Gerr 3794 Luca 15/05/03
//         IF AT(".",::aBuffer[REP_FNAME]) <1
//            ::sleFile:setData(ALLTRIM(::aBuffer[REP_FNAME])+::aTipOutPut[ ::nFmt ][DFCRWET_EXT])
//         ENDIF
         IF EMPTY(aFile[4])
            ::sleFile:setData(ALLTRIM(::aBuffer[REP_FNAME])+::aTipOutPut[ ::nFmt ][DFCRWET_EXT])
         ELSE
            // SD 12/12/2005 gerr 4573
            ::sleFile:setData(ALLTRIM(::aBuffer[REP_FNAME]))
         ENDIF
      ENDIF
   ENDIF

   ::lOpen := .F.

RETURN self

METHOD S2PrintDispCRWFile:exitMenu(nAction, aBuf)
   LOCAL oPrn, cDevName

   IF ::nFmt == 0 .AND. nAction > 0
      dbMsgErr(dfStdMsg1(MSG1_S2PDISCF06)) //"export not available"
      nAction := -1  // rimane nel menu

   ELSEIF nAction > 0 .AND. EMPTY(dfFNameSplit(::sleFile:getData())[3])
      dbMsgErr(dfStdMsg1(MSG1_S2PDISFI12))
      nAction := -1  // rimane nel menu

   ELSEIF nAction > 0
      DEFAULT oPrn TO dfCRWPrinterObject()

      ::xExportData := {::aTipOutput[::nFmt][DFCRWET_ID], IIF(::lOpen, S2UXDApplicationType, S2UXDDiskType), ::sleFile:getData()}

      IF ! EMPTY(oPrn) .AND. ;
         oPrn:status()==XBP_STAT_CREATE


         // Se il dispositivo Š una stampante Crystal
         // Aggiorno le scelte del menu in modo che il Preview
         // sia coerente con le scelte (formato carta, ecc.)
         IF ! EMPTY(::oCurrDisp) .AND. ;
            ::oCurrDisp:isDerivedFrom("S2PrintDispCRWPrinter") .AND. ;
            ::oCurrDisp:configurePrinter()
            ::oCurrDisp:setPrinterSets()
         ENDIF

         aBuf[REP_PRINTERPORT] := "VIDEO"

         aBuf[REP_SETUP      ] := DFWINREP_SETUP
         aBuf[REP_RESET      ] := DFWINREP_RESET
         aBuf[REP_BOLD_ON    ] := DFWINREP_BOLDON
         aBuf[REP_BOLD_OFF   ] := DFWINREP_BOLDOFF
         aBuf[REP_ENL_ON     ] := DFWINREP_ENLARGEDON
         aBuf[REP_ENL_OFF    ] := DFWINREP_ENLARGEDOFF
         aBuf[REP_UND_ON     ] := DFWINREP_UNDERLINEON
         aBuf[REP_UND_OFF    ] := DFWINREP_UNDERLINEOFF
         aBuf[REP_SUPER_ON   ] := DFWINREP_SUPERSCRIPTON
         aBuf[REP_SUPER_OFF  ] := DFWINREP_SUPERSCRIPTOFF
         aBuf[REP_SUBS_ON    ] := DFWINREP_SUBSCRIPTON
         aBuf[REP_SUBS_OFF   ] := DFWINREP_SUBSCRIPTOFF
         aBuf[REP_COND_ON    ] := DFWINREP_CONDENSEDON
         aBuf[REP_COND_OFF   ] := DFWINREP_CONDENSEDOFF
         aBuf[REP_ITA_ON     ] := DFWINREP_ITALICON
         aBuf[REP_ITA_OFF    ] := DFWINREP_ITALICOFF
         aBuf[REP_NLQ_ON     ] := DFWINREP_NLQON
         aBuf[REP_NLQ_OFF    ] := DFWINREP_NLQOFF
         aBuf[REP_USER1ON    ] := DFWINREP_USER01ON
         aBuf[REP_USER1OFF   ] := DFWINREP_USER01OFF
         aBuf[REP_USER2ON    ] := DFWINREP_USER02ON
         aBuf[REP_USER2OFF   ] := DFWINREP_USER02OFF
         aBuf[REP_USER3ON    ] := DFWINREP_USER03ON
         aBuf[REP_USER3OFF   ] := DFWINREP_USER03OFF
      ELSE
         IF ! EMPTY(oPrn)
            cDevName := oPrn:devName
         ENDIF
         DEFAULT cDevName TO dfStdMsg1(MSG1_S2PDISPR04)
         dbMsgErr(dfStdMsg1(MSG1_S2PDISPR02)+cDevName+dfStdMsg1(MSG1_S2PDISPR03))
         nAction := -1
      ENDIF
   ENDIF
RETURN nAction
                                                    
METHOD S2PrintDispCRWFile:execute() // cFile, cTitle, xDevice)
   LOCAL lRet      := .T.
   LOCAL oRT       := ::aBuffer[REP_XBASEREPORTTYPE]
   LOCAL oCRWOut   := oRT:getOutput()
   LOCAL oCRWPrint := oRT:getPrint()
   LOCAL aArrFName := oCRWOut:getFName()
   LOCAL cArrFName := dfArr2Str(aArrFName, ", ")
   LOCAL oPrn
   LOCAL nErr       

   // Cancello il file TESTO temporaneo
   FERASE( ::aBuffer[REP_FNAME] )

   // Chiudo il file DBF contenente i dati
   oCRWOut:close()

   DEFAULT oPrn TO dfCRWPrinterObject()


   IF dfCRWEngineLoaded()

      // Preview
      //nErr := oCRWPrint:preview(oCRWOut:cRPT, ::aBuffer[REP_NAME], ;
      //                          oRT:setFormula(), oRT:setFlag(), ;
      //                          {oCRWOut:cFName}, oPrn)

//      ::xExportData := dfSet("crwexport") //{1, 0, "appa"}
//      ::xExportData := &(::xExportData)
      nErr := oCRWPrint:exportTo(oCRWPrint:cRepName, ::xExportData, ;
                              oRT:setFormula(), aArrFName) 

      lRet := nErr == 0

      IF ! lRet  
         IF nErr == -1
            //dbMsgErr(dfStdMsg1(MSG1_S2PDISCF02)+oCRWOut:cRPT)
            dbMsgErr(dfStdMsg1(MSG1_S2PDISCF02)+oCRWPrint:cRepName)
         ELSEIF "CANCEL" $ UPPER(oCRWPrint:cErrMsg) .AND. ;
                "USER" $ UPPER(oCRWPrint:cErrMsg)
            // codice di errore USER CANCELLED (ha premuto ESC)
            // non do errore! per il controllo non uso oCRW:nErrCode 
            // perche pu• cambiare!!
         ELSE
            //dbMsgErr(dfStdMsg1(MSG1_S2PDISCF05)+oCRWOut:cRPT+"//"+;
            dbMsgErr(dfStdMsg1(MSG1_S2PDISCF05)+oCRWPrint:cRepName+"//"+;
                     ALLTRIM(STR(oCRWPrint:nErrCode))+"-"+STRTRAN(oCRWPrint:cErrMsg, _LF, "//"))
         ENDIF
      ELSEIF dfCRWDesign()
         //dfAlert(dfStdMsg1(MSG1_S2PDISCF03)+oCRWOut:cFName)
         dfAlert(dfStdMsg1(MSG1_S2PDISCF03)+cArrFName)

      ENDIF

   ELSE
      dbMsgErr(dfStdMsg1(MSG1_S2PDISCF04))
      lRet := .F.
   ENDIF

   // Se sono in modalit… di DESIGN non cancello il file
   // DBF cosi posso costruirci sopra il REPORT con crystal
   //Gerr. 3438 30/10/03 Luca: Aggiunta la possibilit… di non cancellare il file 
   // dbf temporaneo creato.
   //IF ! dfCRWDesign()
   IF ! dfCRWDesign() 
      // Cancello il file DBF contenente i dati
      //FERASE(oCRWOut:cFName)
      //Luca 11/02/2016
      IF dfSet("XbaseCRWTempFileErase") == "NO"

      ELSE
         oCRWOut:FErase() 
      ENDIF 
   ENDIF

RETURN lRet

METHOD S2PrintDispCRWFile:sfoglia()
   LOCAL cFile := ::sleFile:getData()
   LOCAL aFName
   LOCAL cPath := NIL
   LOCAL xRet  := ""

   // Simone 18/9/03 gerr 3937
   // il nome del file non viene prevalorizzato 
   // con quello impostato nel campo del menu di stampa.
   IF ! EMPTY(cFile)
      cFile := dfFNameBuild(cFile)
      aFName:= dfFNameSplit(cFile)
      cPath := aFName[1]+aFName[2]
      cFile := aFName[3]+aFName[4] // nome file
      IF EMPTY(cPath)
         cPath := NIL
      ENDIF
   ENDIF

   IF EMPTY(cFile)
//      cFile := "File"+IIF(::lPdf, ".Pdf", ".Txt")
   ENDIF

   IF !EMPTY(dfset("XbaseDefaultSavePath")) 
      cPATH := dfpathchk(dfset("XbaseDefaultSavePath"))
   ENDIF 

   xRet  := dfWinFileDlg(cPath,NIL, dfStdMsg1(MSG1_S2PDISFI04), cFile, .T.)

   IF ! EMPTY(xRet)
      ::sleFile:setData(xRet)
   ENDIF

RETURN .F.

METHOD S2PrintDispCRWFile:OutPutSelect()
   LOCAL cFile, cPath

   ::nFmt := ::cmbSelect:XbpListBox:getData()[1]

   cPath    := ::sleFile:GetData()
   cFile    := dfFindName(cPath)
   IF EMPTY(cFile)
      cFile := "File"
   ELSE
      cFile := ALLTRIM(cFILE)
   ENDIF
   cPath    := dfPathchk(LEFT(cPath,AT(cFile,cPath)-1))
   IF EMPTY(cPath)
      //cPath := dfPathchk(dfCurPath())
   ENDIF

   ::sleFile:SetData(cPath + cFile + ::aTipOutPut[ ::nFmt ][DFCRWET_EXT])
RETURN NIL

METHOD S2PrintDispCRWFile:getExportTypes()
RETURN ACLONE( dfCRWGetExportTypes() )
  
//Ger 4287 Luca 22/10/2004
// Inserito Per la chiusura delle dei file aperti quando non c'Š nulla da stampare
METHOD S2PrintDispCRWFile:Close()
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
