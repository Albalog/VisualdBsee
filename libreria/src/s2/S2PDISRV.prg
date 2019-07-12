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
// Anteprima RM

CLASS S2PrintDispRMPreview FROM S2PrintDisp
   PROTECTED:
      VAR oCurrDisp

   EXPORTED:
      VAR xExportData

      METHOD init
      METHOD exitMenu
      METHOD execute
      INLINE METHOD setCurrDisp(o); ::oCurrDisp := o; RETURN self
      METHOD Close
      METHOD viewRM
      METHOD viewPDF
      METHOD getExportTypes
ENDCLASS



METHOD S2PrintDispRMPreview:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::S2PrintDisp:init( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::dispName := dfStdMsg1(MSG1_S2PDISCV01)

RETURN self

METHOD S2PrintDispRMPreview:exitMenu(nAction, aBuf)
   LOCAL oPrn, cDevName

   IF nAction > 0

      //DEFAULT oPrn TO dfRMPrinterObject()
      DEFAULT oPrn TO dfWinPrinterObject()

      IF ! EMPTY(oPrn) .AND. ;
         oPrn:status()==XBP_STAT_CREATE


         // Se il dispositivo Š una stampante Crystal
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

//METHOD S2PrintDispRMPreview:execute()
//   ::viewRM()
//RETURN .T.


//Mantis 1196
METHOD S2PrintDispRMPreview:execute()
   LOCAL cPDF     := dfSet("XbasePreviewPDF")
   LOCAL aExpType := ::getExportTypes()
   LOCAL nPos
   LOCAL cFile       := IIF(!EMPTY(::aBuffer[REP_FNAME]),ALLTRIM(::aBuffer[REP_FNAME]),"FILE")
   LOCAL aFName      := dfFNameSplit(cFile)
   LOCAL cFilePDF    := aFName[1]+aFName[2]+aFName[3]+".PDF"

   DEFAULT cPDF TO "NO"

   // GERR 3910 - Simone 29-8-03
   // Invia l'anteprima di stampa su PDF

   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //Mantis 2210 :Richiesta di poter impostare il settaggio Preview PDF in modo indipendente solo per Report Manager
   IF !EMPTY( dfSet("XbaseRMPreviewPDF")  )
      cPDF := dfSet("XbaseRMPreviewPDF")
   ENDIF 
   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////



   nPos := ASCAN(aExpType,{|aArr| aArr[DFRMET_ID] == RM_EXPORT_PDF} )
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
         FERASE(cFilePDF)
         FCLOSE( dfFileTemp( @cFilePDF, NIL, NIL, ".PDF" ))
         /////////////////////
         //Mantis 2113
         //10/12/2009 Luca : Cancellazione del file temporaneo creato in anteprima 
         //FERASE(cFilePDF)
         dfXbaseExitProcAdd( dfExecuteActionDelFile():new(cFilePDF) )
         /////////////////////////
      ENDIF
      ::xExportData := {aExpType[nPos][DFRMET_ID], cFilePDF}
   ENDIF

   IF cPDF $ "YES-THREAD"
      ::viewPDF(cPDF == "THREAD")
   ELSE
      ::viewRM()
   ENDIF
RETURN .T.

METHOD S2PrintDispRMPreview:viewPDF(lThread)
   LOCAL lRet      := .F.
   LOCAL oRT       := ::aBuffer[REP_XBASEREPORTTYPE]
   LOCAL oRMOut   := oRT:getOutput()
   LOCAL oRMPrint := oRT:getPrint()
   LOCAL aArrFName := oRMOut:getFName()
   LOCAL cArrFName := dfArr2Str(aArrFName, ", ")
   LOCAL oPrn
   LOCAL nErr
   LOCAL aTmpDbf
   LOCAL aRpt
   LOCAL cTmpRep
   LOCAL cFilePDF

   // Cancello il file TESTO temporaneo
   FERASE( ::aBuffer[REP_FNAME] )

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
                                    oRT:setFormula())

            lRet := nErr == 0

            IF lRet
               cFilePDF := ::xExportData[2]
               // Provo a visualizzare con acrobat, se non è installato
               // vado su visualizzazione standard
               IF dfPDFView(cFilePDF)
                  // Mi assicuro che alla fine il file temporaneo venga cancellato
                  //dfXbaseExitProcAdd( dfExecuteActionDelFile():new(cFilePDF) )
               ELSE
                  FERASE(cFilePDF)
                  ::viewRM()
               ENDIF
               dfXbaseExitProcAdd( dfExecuteActionDelFile():new(cFilePDF) )
            ELSE
               IF nErr == -1
                  //dbMsgErr(dfStdMsg1(MSG1_S2PDISCF02)+oRMOut:cRPT)
                  dbMsgErr(dfStdMsg1(MSG1_S2PDISCF02)+oRMPrint:cRepName)
      //         ELSEIF "CANCEL" $ UPPER(oRMPrint:cErrMsg) .AND. ;
      //                "USER" $ UPPER(oRMPrint:cErrMsg)
                  // codice di errore USER CANCELLED (ha premuto ESC)
                  // non do errore! per il controllo non uso oRM:nErrCode
                  // perche pu• cambiare!!
               ELSE
                  //dbMsgErr(dfStdMsg1(MSG1_S2PDISCF05)+oRMOut:cRPT+"//"+;
                  dbMsgErr(dfStdMsg1(MSG1_S2PDISCF05)+oRMPrint:cRepName+"//"+;
                           ALLTRIM(STR(oRMPrint:nErrCode))+"-"+STRTRAN(oRMPrint:cErrMsg, _LF, "//"))
               ENDIF
            ENDIF
            FERASE(cTmpRep)
            dfXbaseExitProcAdd( dfExecuteActionDelFile():new(cTmpRep) )

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

      //Mantis 679
      //INLINE METHOD _out(aBuf )
METHOD S2PrintDispRMPreview:viewRM() // cFile, cTitle, xDevice)
   LOCAL oRT       := ::aBuffer[REP_XBASEREPORTTYPE]
   LOCAL oRMOut   := oRT:getOutput()
   LOCAL oRMPrint := oRT:getPrint()
   LOCAL aArrFName := oRMOut:getFName()
   LOCAL cArrFName := dfArr2Str(aArrFName, ", ")

   LOCAL aTmpDbf
   LOCAL aRpt
   LOCAL cTmpRep
   LOCAL lRet := .F.

   // Cancello il file TESTO temporaneo
   FERASE( ::aBuffer[REP_FNAME] )

   // Chiudo il file DBF contenente i dati
   oRMOut:close()

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

            oRMPrint:preview(cTmpRep, ::aBuffer[REP_NAME],NIL,NIL,dfWinPrinterObject())
            FERASE(cTmpRep)
         ELSE
            dbMsgErr(dfMsgTran(dfStdMsg1(MSG1_DFREPTYP02), "file=" + cTmpRep))
         ENDIF
         lRet := .T.
      ENDIF
      dfXbaseExitProcAdd( dfExecuteActionDelFile():new(cTmpRep) )
   ENDIF
   IF dfSet("XbaseRepManTempFileErase") == "NO"

   ELSE
      oRMOut:FErase()
   ENDIF
RETURN lRet

//Ger 4287 Luca 22/10/2004
// Inserito Per la chiusura delle dei file aperti quando non c'Š nulla da stampare
METHOD S2PrintDispRMPreview:Close()
   LOCAL lRet      := .F.
   LOCAL oRT       := ::aBuffer[REP_XBASEREPORTTYPE]
   LOCAL oRMOut   := oRT:getOutput()
   // Eseguo Metodo di chiusura della classe padre
   ::S2PrintDisp:Close()
   // Chiudo il file DBF contenente i dati
   oRMOut:close()
   // Cancello il file DBF contenente i dati
   //IF ! dfCRWDesign()
      oRMOut:FErase()
   //ENDIF
   lRet := .T.
RETURN lRet

METHOD S2PrintDispRMPreview:getExportTypes()
RETURN ACLONE( dfRMGetExportTypes() )

