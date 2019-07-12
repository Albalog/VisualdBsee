#include "Gra.ch"
#include "Xbp.ch"
#include "Common.ch"
#include "Appevent.ch"
#include "Font.ch"
#include "dfReport.ch"
#include "dfWinRep.ch"
#include "dfMsg1.ch"
#include "s2crwpri.ch"
#include "dfReport.ch"
#include "dfXbase.ch"
#include "XBPDEV.CH"


#define _LF (CHR(10))

// Dispositivo di stampa
// Anteprima

CLASS S2PrintDispCRWPreview FROM S2PrintDisp
   PROTECTED:
      VAR oCurrDisp

   EXPORTED:
      VAR xExportData

      METHOD init
      METHOD exitMenu
      METHOD execute
      INLINE METHOD setCurrDisp(o); ::oCurrDisp := o; RETURN self
      METHOD Close
      METHOD viewCRM, viewPDF,getExportTypes 
ENDCLASS



METHOD S2PrintDispCRWPreview:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::S2PrintDisp:init( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::dispName := dfStdMsg1(MSG1_S2PDISCV01)

RETURN self

METHOD S2PrintDispCRWPreview:exitMenu(nAction, aBuf)
   LOCAL oPrn, cDevName

   IF nAction > 0

      DEFAULT oPrn TO dfCRWPrinterObject()

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
         //Gerr. 4002 Luca: avvolte accade che oPrn non Š empty ma oPrn:Devname SI 
         //IF ! EMPTY(oPrn)
         IF ! EMPTY(oPrn) .AND. !EMPTY(oPrn:devName)
            cDevName := oPrn:devName
         ENDIF
         DEFAULT cDevName TO dfStdMsg1(MSG1_S2PDISPR04)
         dbMsgErr(dfStdMsg1(MSG1_S2PDISPR02)+cDevName+dfStdMsg1(MSG1_S2PDISPR03))
         nAction := -1
      ENDIF

   ENDIF
RETURN nAction


//Mantis 1196
METHOD S2PrintDispCRWPreview:execute()   
   LOCAL cPDF        := dfSet("XbasePreviewPDF")
   LOCAL aExpType    := ::getExportTypes()
   LOCAL nPos
   LOCAL cFile       := IIF(!EMPTY(::aBuffer[REP_FNAME]),ALLTRIM(::aBuffer[REP_FNAME]),"FILE")
   LOCAL aFName      := dfFNameSplit(cFile)
   LOCAL cFilePDF    := aFName[1]+aFName[2]+aFName[3]+".PDF"

   DEFAULT cPDF TO "NO"

   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //Mantis 2209 :Richiesta di poter impostare il settaggio Preview PDF in modo indipendente solo per Report Crystal
   IF !EMPTY(dfSet("XbaseCrystalReportPreviewPDF")  )
      cPDF := dfSet("XbaseCrystalReportPreviewPDF")
   ENDIF 
   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

   // GERR 3910 - Simone 29-8-03
   // Invia l'anteprima di stampa su PDF


   nPos := ASCAN(aExpType,{|aArr| aArr[DFCRWET_ID] == S2UXFPDFType } ) 
   IF nPos == 0
      cPDF := "NO"
   ELSE
      // simone 03/04/09
      // mantis 0001913: Runtime Errore lanciando due volte una stampa.  
      // se il file esiste ne creo un altro temporaneo
      // per evitare problemi che sia in uso
      IF FILE(cFilePDF)
         cFilePdf := aFName[1]+aFname[2]
         // Creo un file nello stesso path
         FCLOSE( dfFileTemp( @cFilePDF, NIL, NIL, ".PDF" ))
      ENDIF
      ::xExportData := {aExpType[nPos][DFCRWET_ID], IIF(.T., S2UXDApplicationType, S2UXDDiskType), cFilePDF}
   ENDIF

   IF cPDF $ "YES-THREAD" 
      ::viewPDF(cPDF == "THREAD")
   ELSE
      ::viewCRM()
   ENDIF
   dfXbaseExitProcAdd( dfExecuteActionDelFile():new(cFilePDF) )

RETURN .T.

METHOD S2PrintDispCRWPreview:viewPDF(lThread)
   LOCAL lRet      := .T.
   LOCAL oRT       := ::aBuffer[REP_XBASEREPORTTYPE]
   LOCAL oCRWOut   := oRT:getOutput()
   LOCAL oCRWPrint := oRT:getPrint()
   LOCAL aArrFName := oCRWOut:getFName()
   LOCAL cArrFName := dfArr2Str(aArrFName, ", ")
   LOCAL oPrn
   LOCAL nErr
   LOCAL lFascicola  := .F.
   LOCAL aOpt
   LOCAL nCopie

//   // Provo a creare un file temporaneo con nome significativo
//   nHandle := dfFileTemp(@cFilePDF, cFile, LEN(cFile)+5, ".PDF")
//   IF nHandle == -1
//      // Errore: provo con un nome standard (DBSxxxx.PDF)
//      cFilePDF := NIL
//      nHandle := dfFileTemp(@cFilePdf, NIL, NIL, ".PDF")
//   ENDIF
//
//   IF nHandle == -1
//      ::viewTXT() // visual. standard
//      //Errore creazione File Pdf
//      //dbMsgErr(dfStdMsg1(MSG1_S2PDISFI08))
//   ELSE
//      FCLOSE(nHandle)
//      dfTxt2Pdf( cFileTxt,cFilePdf,cTitle, aExtra, nOptions,cTipoFormatoPagina,cVerso,bEnd)
//   ENDIF


   // Cancello il file TESTO temporaneo
   FERASE( ::aBuffer[REP_FNAME] )

   // Chiudo il file DBF contenente i dati
   oCRWOut:close()

   DEFAULT oPrn TO dfCRWPrinterObject()

   IF !EMPTY(dfSet("XbaseCrystalReportPreviewOption")  ) .AND.; 
      dfSet("XbaseCrystalReportPreviewOption") == "YES"
      IF ! EMPTY(::oCurrDisp) 
         lFascicola  := ::oCurrDisp:lFascicola

         oPrn:setCollationMode(IIF(lFascicola,XBPPRN_COLLATIONMODE_ON,XBPPRN_COLLATIONMODE_OFF)) 
         oPrn:setNumCopies(::aBuffer[REP_COPY])
         nCopie               := ::oCurrDisp:spnCopies:getData()
         ::aBuffer[REP_COPY]  := nCopie

         ::aBuffer[REP_TOPAGE] := MIN(::aBuffer[REP_TOPAGE], 9999) 
         IF lFascicola 
            aOpt := {::aBuffer[REP_FROMPAGE], ::aBuffer[REP_TOPAGE], ::aBuffer[REP_COPY],XBPPRN_COLLATIONMODE_ON}
         ELSE 
            aOpt := {::aBuffer[REP_FROMPAGE], ::aBuffer[REP_TOPAGE], ::aBuffer[REP_COPY],XBPPRN_COLLATIONMODE_OFF}
         ENDIF 
      ENDIF
   ENDIF  


   IF dfCRWEngineLoaded()



      //nErr := oCRWPrint:exportTo(oCRWPrint:cRepName, ::xExportData, ;
      //                        oRT:setFormula(), aArrFName) 
      nErr := oCRWPrint:exportTo(oCRWPrint:cRepName, ::xExportData, ;
                              oRT:setFormula(), aArrFName, oPrn, aOpt) 

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
      //oCRWOut:FErase() 
      //////////////////////////////////////
      //Luca 11/02/2016
      IF dfSet("XbaseCRWTempFileErase") == "NO"

      ELSE
         oCRWOut:FErase() 
      ENDIF 
      //////////////////////////////////////
   ENDIF

RETURN lRet

//Mantis 1196
METHOD S2PrintDispCRWPreview:viewCRM() // cFile, cTitle, xDevice)
   LOCAL lRet      := .T.
   LOCAL oRT       := ::aBuffer[REP_XBASEREPORTTYPE]
   LOCAL oCRWOut   := oRT:getOutput()
   LOCAL oCRWPrint := oRT:getPrint()
   LOCAL aArrFName := oCRWOut:getFName()
   LOCAL cArrFName := dfArr2Str(aArrFName, ", ")
   LOCAL oPrn
   LOCAL nErr       
   LOCAL lFascicola  := .F.
   LOCAL aOpt
   LOCAL nCopie



   // Cancello il file TESTO temporaneo
   FERASE( ::aBuffer[REP_FNAME] )

   // Chiudo il file DBF contenente i dati
   oCRWOut:close()

   DEFAULT oPrn TO dfCRWPrinterObject()

   IF !EMPTY(dfSet("XbaseCrystalReportPreviewOption")  ) .AND.; 
      dfSet("XbaseCrystalReportPreviewOption") == "YES"
      IF ! EMPTY(::oCurrDisp) 
         lFascicola  := ::oCurrDisp:lFascicola
         nCopie      := ::oCurrDisp:spnCopies:getData()
         ::aBuffer[REP_COPY]  := nCopie
         oPrn:setCollationMode(IIF(lFascicola,XBPPRN_COLLATIONMODE_ON,XBPPRN_COLLATIONMODE_OFF)) 
         oPrn:setNumCopies(::aBuffer[REP_COPY])
         ::aBuffer[REP_TOPAGE] := MIN(::aBuffer[REP_TOPAGE], 9999) 

         IF lFascicola 
            aOpt := {::aBuffer[REP_FROMPAGE], ::aBuffer[REP_TOPAGE], ::aBuffer[REP_COPY],XBPPRN_COLLATIONMODE_ON}
         ELSE 
            aOpt := {::aBuffer[REP_FROMPAGE], ::aBuffer[REP_TOPAGE], ::aBuffer[REP_COPY],XBPPRN_COLLATIONMODE_OFF}
         ENDIF 
      ENDIF
   ENDIF  



   IF dfCRWEngineLoaded()

      // Preview
      //nErr := oCRWPrint:preview(oCRWOut:cRPT, ::aBuffer[REP_NAME], ;
      //                          oRT:setFormula(), oRT:setFlag(), ;
      //                          {oCRWOut:cFName}, oPrn)

      ////////////////////////////////////////////////////////////////////////////////////
      // Mantis 1195
      // Luca: commentato il 4/1/2007 Perche i clienti si lamentavono della presenza del menu di configurazione della stampante
      // Il motivo del perche Š stato inserito il settaggio non Š chiaro!!!
      //oPrn:setupDialog()
      ////////////////////////////////////////////////////////////////////////////////////


      nErr := oCRWPrint:preview(oCRWPrint:cRepName, ::aBuffer[REP_NAME], ;
                                oRT:setFormula(), oRT:setFlag(), ;
                                aArrFName, oPrn,; 
                                aOpt)

      lRet := nErr == 0

      IF ! lRet  
         IF nErr == -1
            //dbMsgErr(dfStdMsg1(MSG1_S2PDISCV02)+oCRWOut:cRPT)
            dbMsgErr(dfStdMsg1(MSG1_S2PDISCV02)+oCRWPrint:cRepName)
         ELSE
            //dbMsgErr(dfStdMsg1(MSG1_S2PDISCV05)+oCRWOut:cRPT+"//"+;
            dbMsgErr(dfStdMsg1(MSG1_S2PDISCV05)+oCRWPrint:cRepName+"//"+;
                     ALLTRIM(STR(oCRWPrint:nErrCode))+"-"+STRTRAN(oCRWPrint:cErrMsg, _LF, "//") )
         ENDIF
      ELSEIF dfCRWDesign()
         //dfAlert(dfStdMsg1(MSG1_S2PDISCV03)+oCRWOut:cFName)
         dfAlert(dfStdMsg1(MSG1_S2PDISCV03)+cArrFName)

      ENDIF
      oPrn:updDevMode() 
   ELSE
      dbMsgErr(dfStdMsg1(MSG1_S2PDISCV04))
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
      oCRWOut:FErase() 
   ENDIF


RETURN lRet


//Ger 4287 Luca 22/10/2004
// Inserito Per la chiusura delle dei file aperti quando non c'Š nulla da stampare
METHOD S2PrintDispCRWPreview:Close()
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

METHOD S2PrintDispCRWPreview:getExportTypes()
RETURN ACLONE( dfCRWGetExportTypes() )
