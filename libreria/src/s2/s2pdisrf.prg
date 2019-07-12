#include "Gra.ch"
#include "Xbp.ch"
#include "Common.ch"
#include "Appevent.ch"
#include "Font.ch"
#include "dfReport.ch"
#include "dfWinRep.ch"
#include "dfMsg1.ch"

#include "dfRepMan.ch"

#define _LF (CHR(10))

// simone 18/2/08
// 0000652: i report di tipo reportmanager non hanno menu di stampa
// Dispositivo di stampa
// Esportazione RM

CLASS S2PrintDispRMFile FROM S2PrintDisp
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

      METHOD isDefault

      METHOD exitMenu
      METHOD execute
      INLINE METHOD setCurrDisp(o); ::oCurrDisp := o; RETURN self

      METHOD sfoglia
      METHOD outputSelect
      VAR lOpen
      VAR nFmt

      //Ger 4287 Luca 22/10/2004
      // Inserito Per la chiusura delle dei file aperti quando non c'ä nulla da stampare
      METHOD Close

ENDCLASS

METHOD S2PrintDispRMFile:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
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

METHOD S2PrintDispRMFile:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL cPrinter, aBuf:= ::aBuffer
   LOCAL aFile
   LOCAL nSel := 0
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
      AEVAL(::aTipOutPut, {|x| ::cmbSelect:addItem(x[DFRMET_DEX]) })
      ::cmbSelect:XbpSLE:setData(::aTipOutPut[ ::nFmt ][DFRMET_DEX])

      ::chkBox:create()
      ::chkBox:enable()

      // SD 22/01/08 - GERR 5043
      // imposta la stampa in un path da settaggio .ini
      ************************************************************
      IF EMPTY(::aBuffer[REP_FNAME])
         ::aBuffer[REP_FNAME] := "File"+::aTipOutPut[ ::nFmt ][DFRMET_EXT]
      ENDIF
/*
      IF ! EMPTY( dfSet("XbasePathPrintFile") )
         ::aBuffer[REP_FNAME] := dfFNameBuild(::aBuffer[REP_FNAME], dfSet("XbasePathPrintFile"))
      ENDIF
*/
      cXBasePathPrintFile := dfSet("XbasePathPrintFile")
      IF ! EMPTY( cXBasePathPrintFile ) .AND. dfChkDir(cXBasePathPrintFile)
         ::aBuffer[REP_FNAME] := dfFNameBuild(::aBuffer[REP_FNAME], cXBasePathPrintFile)
      ENDIF
      ***********************************************************

      //Modificato --->
      //::sleFile:setData(::aBuffer[REP_FNAME])
      IF EMPTY(::aBuffer[REP_FNAME])
         ::sleFile:setData("File"+::aTipOutPut[ ::nFmt ][DFRMET_EXT])
      ELSE

         // SD 12/12/2005 gerr 4573
         aFile :=  dfFNameSplit(::aBuffer[REP_FNAME])

         // Gerr 3794 Luca 15/05/03
//         IF AT(".",::aBuffer[REP_FNAME]) <1
//            ::sleFile:setData(ALLTRIM(::aBuffer[REP_FNAME])+::aTipOutPut[ ::nFmt ][DFRMET_EXT])
//         ENDIF
         IF EMPTY(aFile[4])
            ::sleFile:setData(ALLTRIM(::aBuffer[REP_FNAME])+::aTipOutPut[ ::nFmt ][DFRMET_EXT])
         ELSE
            // SD 12/12/2005 gerr 4573
            ::sleFile:setData(ALLTRIM(::aBuffer[REP_FNAME]))
         ENDIF
      ENDIF
   ENDIF

   ::lOpen := .F.

RETURN self

// SD 17/11/08 
// aggiunto metodo isDefault() 
// per attivare la stampa direttamente su FILE
METHOD S2PrintDispRMFile:isDefault()
RETURN UPPER(ALLTRIM(::aBuffer[REP_PRINTERPORT])) == "FILE"

METHOD S2PrintDispRMFile:exitMenu(nAction, aBuf)
   LOCAL oPrn, cDevName
   LOCAL cFileName, aFile
   LOCAL cPath
   IF ::nFmt == 0 .AND. nAction > 0
      dbMsgErr(dfStdMsg1(MSG1_S2PDISCF06)) //"export not available"
      nAction := -1  // rimane nel menu

   ELSEIF nAction > 0 .AND. EMPTY(dfFNameSplit(::sleFile:getData())[3])
      dbMsgErr(dfStdMsg1(MSG1_S2PDISFI12))
      nAction := -1  // rimane nel menu

   ELSEIF nAction > 0
      DEFAULT oPrn TO dfWinPrinterObject()

      ///////////////////////////////////////////////////////////////////////////////
      ///////////////////////////////////////////////////////////////////////////////
      ///////////////////////////////////////////////////////////////////////////////
      cFileName     := Alltrim(::sleFile:getData())
      aFile         := dfFNameSplit(cFileName)
      cPath         := aFile[1]+aFile[2]
      IF !EMPTY(dfset("XbaseDefaultSavePath"))  .AND. Empty(aFile[1]+aFile[2])
         cPath      := dfpathchk(dfset("XbaseDefaultSavePath"))
         dfMD(cPath)  
      ENDIF 
      IF EMPTY(aFile[4])
         cFileName  := cPath+aFile[3]+::aTipOutput[::nFmt][DFRMET_EXT]
      ELSE 
         cFileName  := cPath+aFile[3]+aFile[4]
      ENDIF 
      ///////////////////////////////////////////////////////////////////////////////
      //::xExportData := {::aTipOutput[::nFmt][DFRMET_ID], ::sleFile:getData()}
      ::xExportData := {::aTipOutput[::nFmt][DFRMET_ID], cFileName}
      ///////////////////////////////////////////////////////////////////////////////
      ///////////////////////////////////////////////////////////////////////////////

      // SD 03/04/09
      // per congruenza con gli altri dispositivi di stampa su file
      // salvo il nome del file in aBuf[REP_FNAME]
      aBuf[REP_FNAME] := cFileName

      IF ! EMPTY(oPrn) .AND. ;
         oPrn:status()==XBP_STAT_CREATE


         // Se il dispositivo ä una stampante Crystal
         // Aggiorno le scelte del menu in modo che il Preview
         // sia coerente con le scelte (formato carta, ecc.)
         IF ! EMPTY(::oCurrDisp) .AND. ;
            ::oCurrDisp:isDerivedFrom("S2PrintDispRMPrinter") .AND. ;
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
                                                    

METHOD S2PrintDispRMFile:sfoglia()
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
      dfMD(cPath)  
   ENDIF 
   xRet  := dfWinFileDlg(cPath,NIL, dfStdMsg1(MSG1_S2PDISFI04), cFile, .T.)

   IF ! EMPTY(xRet)
      ::sleFile:setData(xRet)

      xRet  := dfFNameBuild(xRet)
      aFName:= dfFNameSplit(xRet)
      dfset("XbaseDefaultSavePath",aFName[1]+aFName[2] )
   ENDIF


RETURN .F.

METHOD S2PrintDispRMFile:execute()
   LOCAL lRet      := .F.
   LOCAL oRT       := ::aBuffer[REP_XBASEREPORTTYPE]
   LOCAL oRMOut    := oRT:getOutput()
   LOCAL oRMPrint  := oRT:getPrint()
   LOCAL aArrFName := oRMOut:getFName()
   LOCAL cArrFName := dfArr2Str(aArrFName, ", ")
   LOCAL oPrn
   LOCAL nErr
   LOCAL aTmpDbf
   LOCAL aRpt
   LOCAL cTmpRep
   LOCAL cFileOut
   LOCAL cFILE := ::aBuffer[REP_FNAME]

   // Cancello il file TESTO temporaneo
   FERASE( cFILE )


   // SD 03/04/09
   // ä inutile perchä adesso ::xExportData[2] corrisponde a cFile
//   IF ::xExportData[1] == RM_EXPORT_PDF
//      ::xExportData[2] := cFILE
//   ENDIF 

   // Chiudo il file DBF contenente i dati
   oRMOut:close()

   //DEFAULT oPrn TO dfRMPrinterObject()
   DEFAULT oPrn TO dfWinPrinterObject()

   IF ! EMPTY(aArrFName)
      // copio il file .REP nella cartella contenente i dbf temporanei
      aTmpDbf := dfFnameSplit(aArrFName[1])
      aRpt := dfFNameSplit( oRMPrint:cRepName )
      cTmpRep := aTmpDbf[1]+aTmpDbf[2]+aRpt[3]+aRpt[4]

      // Simone 28/1/2005
      // Mantis 0000512: se nell'applicazione generata la dll di gestione Report Manager non esiste si ha errore di runtime in stampa
      // Mantis 0000513: se l'applicazione generata non trova il file di layout report si ha un errore di runtime in stampa
      IF ! oRMPrint:isLoaded()
         //dbMsgErr("Report Manager print engine (reportman.ocx) non trovato//Impossibile stampare.")
         dbMsgErr(dfStdMsg1(MSG1_DFREPTYP01))
      ELSEIF ! FILE(oRMPrint:cRepName)
         //"Report File non trovato//"+::oPrint:cRepName)
         dbMsgErr(dfMsgTran(dfStdMsg1(MSG1_DFREPTYP02), "file=" + oRMPrint:cRepName))
      ELSE
         // simone 8/3/2005 la finestra di anteprima
         // non visualizza il titolo del report
         IF dfFileCopy(oRMPrint:cRepName, cTmpRep)

            //Mantis 1247
            //Inserito per permettere di eseguire una funzione prima della Stampa o preview
            EVAL(oRT:bDecodePrePrint, cTmpRep, self)

            nErr := oRMPrint:exportTo(cTmpRep, ::xExportData, ;
                                      oRT:setFormula(), oPrn)

            lRet := nErr == 0

            IF lRet
               cFileOut := ::xExportData[2]
               IF ::lOpen .AND. FILE(cFileOut)
                  IF ::xExportData[1] == RM_EXPORT_PDF
                     dfPDFView(cFileOut)
                  ELSE
                     S2OpenRegisteredFile( cFileOut ) //Bisogna pasargli il path corrente
                  ENDIF
               ENDIF
            ELSE
               IF nErr == -1
                  //dbMsgErr(dfStdMsg1(MSG1_S2PDISCF02)+oRMOut:cRPT)
                  dbMsgErr(dfStdMsg1(MSG1_S2PDISCF02)+oRMPrint:cRepName)
      //         ELSEIF "CANCEL" $ UPPER(oRMPrint:cErrMsg) .AND. ;
      //                "USER" $ UPPER(oRMPrint:cErrMsg)
                  // codice di errore USER CANCELLED (ha premuto ESC)
                  // non do errore! per il controllo non uso oRM:nErrCode
                  // perche puï cambiare!!
               ELSE
                  //dbMsgErr(dfStdMsg1(MSG1_S2PDISCF05)+oRMOut:cRPT+"//"+;
                  dbMsgErr(dfStdMsg1(MSG1_S2PDISCF05)+oRMPrint:cRepName+"//"+;
                           ALLTRIM(STR(oRMPrint:nErrCode))+"-"+STRTRAN(oRMPrint:cErrMsg, _LF, "//"))
               ENDIF
            ENDIF
            FERASE(cTmpRep)
         ELSE
            dbMsgErr(dfMsgTran(dfStdMsg1(MSG1_DFREPTYP02), "file=" + cTmpRep))
         ENDIF
      ENDIF
   ENDIF

   IF dfSet("XbaseRepManTempFileErase") == "NO"

   ELSE
      oRMOut:FErase()
   ENDIF
RETURN lRet


METHOD S2PrintDispRMFile:OutPutSelect()
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

   ::sleFile:SetData(cPath + cFile + ::aTipOutPut[ ::nFmt ][DFRMET_EXT])
RETURN NIL

METHOD S2PrintDispRMFile:getExportTypes()
RETURN ACLONE( dfRMGetExportTypes() )
  
//Ger 4287 Luca 22/10/2004
// Inserito Per la chiusura delle dei file aperti quando non c'ä nulla da stampare
METHOD S2PrintDispRMFile:Close()
   LOCAL lRet      := .F.
   LOCAL oRT       := ::aBuffer[REP_XBASEREPORTTYPE]
   LOCAL oRMOut   := oRT:getOutput()

   // Eseguo Metodo di chiusura della classe padre
   ::S2PrintDisp:Close()
   // Chiudo il file DBF contenente i dati
   oRMOut:close()
   // Cancello il file DBF contenente i dati
//   IF ! dfRMDesign() 
      oRMOut:FErase() 
//   ENDIF
   lRet := .T. 
RETURN lRet
