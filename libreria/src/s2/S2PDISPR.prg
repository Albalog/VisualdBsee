#include "Gra.ch"
#include "Xbp.ch"
#include "Common.ch"
#include "Appevent.ch"
#include "Font.ch"
#include "dfReport.ch"
#include "dfWinRep.ch"
#include "dfMsg1.ch"
#include "dfPDF.ch"
#include "XbpDev.ch"

// Dispositivo di stampa
// Anteprima

CLASS S2PrintDispPreview FROM S2PrintDisp
   PROTECTED:
      VAR oCurrDisp

   EXPORTED:
                                // Simone 29/1/10 XL 1562
      CLASS VAR nA4MaxColStd    // n. massimo colonne A4 non compresso
      CLASS VAR nA4MaxColCompr  // n. massimo colonne A4 compresso

      METHOD init
      METHOD exitMenu
      METHOD execute
      METHOD calcPaperSize
      METHOD viewPDF, end_execute, viewTXT

      INLINE METHOD canSupportFont(); RETURN .T.
      INLINE METHOD canSupportImg() ; RETURN .T.
      INLINE METHOD canSupportBox() ; RETURN .T.
      INLINE METHOD setCurrDisp(o); ::oCurrDisp := o; RETURN self

ENDCLASS

METHOD S2PrintDispPreview:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::S2PrintDisp:init( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::dispName := dfStdMsg1(MSG1_S2PDISPR01)

RETURN self

METHOD S2PrintDispPreview:exitMenu(nAction, aBuf)
   LOCAL oPrn, cDevName

   IF nAction > 0

      oPrn := ::aBuffer[REP_XBASEPRINTOBJ]

      DEFAULT oPrn TO dfWinPrinterObject()

      IF ! EMPTY(oPrn) .AND. ;
         oPrn:status()==XBP_STAT_CREATE

         // Se il dispositivo corrente Š una stampante Windows
         // Aggiorno le scelte del menu in modo che il Preview
         // sia coerente con le scelte (formato carta, ecc.)
         IF ! EMPTY(::oCurrDisp) .AND. ;
            ::oCurrDisp:isDerivedFrom("S2PrintDispWinPrinter") .AND. ;
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
         IF ! EMPTY(oPrn) .AND. !EMPTY(oPrn:devName)
            cDevName := oPrn:devName
         ENDIF
         DEFAULT cDevName TO dfStdMsg1(MSG1_S2PDISPR04)
         dbMsgErr(dfStdMsg1(MSG1_S2PDISPR02)+cDevName+dfStdMsg1(MSG1_S2PDISPR03))
         nAction := -1
      ENDIF

   ENDIF
RETURN nAction

METHOD S2PrintDispPreview:execute() // cFile, cTitle, xDevice)
   LOCAL oPDF
   LOCAL cPDF := dfSet("XbasePreviewPDF")
   LOCAL lRest     := !dfSet("XbaseDisablePrintAutoSize") == "YES"

   DEFAULT cPDF TO "NO"

   // GERR 3910 - Simone 29-8-03
   // Invia l'anteprima di stampa su PDF
   IF cPDF $ "YES-THREAD" 
      IF lRest
         IF ::calcPaperSize()=="A3"
            ::viewPDF(PDF_PAGE_A3, PDF_HORIZONTAL, cPDF == "THREAD")
         ELSE
            ::viewPDF(PDF_PAGE_A4, PDF_VERTICAL, cPDF == "THREAD")
         ENDIF
      ELSE
        IF EMPTY(::aBuffer[REP_PDF_ORIENTATION])
           IF ::calcPaperSize()=="A3"
              ::aBuffer[REP_PDF_ORIENTATION] := PDF_HORIZONTAL
           ELSE
              ::aBuffer[REP_PDF_ORIENTATION] := PDF_VERTICAL
           ENDIF
        ENDIF
        IF EMPTY(::aBuffer[REP_PDF_PAGE_FORMAT])
           IF ::calcPaperSize()=="A3"
              ::aBuffer[REP_PDF_PAGE_FORMAT] := PDF_PAGE_A3
           ELSE
              ::aBuffer[REP_PDF_PAGE_FORMAT] := PDF_PAGE_A4
           ENDIF
        ENDIF
        ::viewPDF(::aBuffer[REP_PDF_PAGE_FORMAT], ::aBuffer[REP_PDF_ORIENTATION], cPDF == "THREAD")
      ENDIF
/*
      oPDF := S2PrintDispFile():new()
      oPDF:aBuffer := ::aBuffer
      oPDF:lPDF    := .T.
      oPDF:lOpen   := .T.
      // GERR 3901 - Simone 29-8-03
      // Aggiusta automaticamente la dimensione della pagina
      // se Š un A4 verticale e necessita un A3 allora imposta A3
      ::aBuffer[REP_PDF_PAGE_FORMAT] := IIF(::calcPaperSize()=="A3", PDF_PAGE_A3, PDF_PAGE_A4)
      ::aBuffer[REP_PDF_ORIENTATION] := PDF_VERTICAL
      oPDF:execute()
*/
   ELSE
      ::viewTXT()
   ENDIF
RETURN .T.

// Preview standard
METHOD S2PrintDispPreview:viewTXT()
   LOCAL oPrinter
   LOCAL nFormSize := NIL
   LOCAL nOrient   := NIL
   LOCAL lRest     := !dfSet("XbaseDisablePrintAutoSize") == "YES"

   oPrinter := ::aBuffer[REP_XBASEPRINTOBJ]
   IF EMPTY(oPrinter)
      oPrinter := dfWinPrinterObject()
   ENDIF

   // GERR 3901 - Simone 29-8-03
   // Aggiusta automaticamente la dimensione della pagina
   // se Š un A4 verticale e necessita un A3 allora imposta A3

   // 13/01/04 Luca GERR 4041
   // Inserito parametro per disabilitare l'autosize. Per alcuni clienti non va bene!
   IF ! EMPTY(oPrinter)         .AND. ;
      lRest                     .AND. ; 
      ::calcPaperSize() == "A3" .AND. ;
      oPrinter:setFormSize() == XBPPRN_FORM_A4 .AND. ;
      oPrinter:setOrientation() ==XBPPRN_ORIENT_PORTRAIT

      // Imposta formato carta A3
      nFormSize := oPrinter:setFormSize( XBPPRN_FORM_A3 )
      nOrient   := oPrinter:setOrientation( XBPPRN_ORIENT_LANDSCAPE )
      /////////////////////////////////////////////////////////////////
      //::aBuffer[REP_PAGE_FORMAT] := nFormSize
      //::aBuffer[REP_ORIENTATION] := nOrient  
      /////////////////////////////////////////////////////////////////

   ENDIF

   dfTView(NIL, NIL, NIL, NIL, ::aBuffer[REP_FNAME], ::aBuffer[REP_NAME],;
            ::aBuffer[REP_XBASEPRINTOBJ], ::aBuffer[REP_XBASEPRINTEXTRA])

   //FERASE( ::aBuffer[REP_FNAME] )
   dfXbaseExitProcAdd( dfExecuteActionDelFile():new(::aBuffer[REP_FNAME]) )

   // Ripristina formato carta
   IF nFormSize != NIL
      oPrinter:setFormSize(nFormSize)
      oPrinter:setOrientation( nOrient )
   ENDIF
RETURN .T.

// Ritorna la dimensione della carta necessaria per 
// visualizzare il preview
// A4 oppure A3
METHOD S2PrintDispPreview:calcPaperSize(aBuffer)
   // Simone 29/1/10 XL 1562
   LOCAL nStd   := ::nA4MaxColStd
   LOCAL nCompr := ::nA4MaxColCompr

   DEFAULT aBuffer TO ::aBuffer

   DEFAULT nStd   TO 80
   DEFAULT nCompr TO 132

   // Se la colonna massima raggiunta in stampa Š > 
   // della colonna max per la carta A4 allora Š un A3
RETURN IIF(aBuffer[REP_MAX_COL] > IIF(aBuffer[REP_IS_CONDENSED], nCompr, nStd), "A3", "A4")

METHOD S2PrintDispPreview:viewPDF(cTipoFormatoPagina, cVerso, lThread)
   LOCAL nHandle := -1
   LOCAL lRet        := .F.
   LOCAL cFile       := IIF(!EMPTY(::aBuffer[REP_FNAME]),ALLTRIM(::aBuffer[REP_FNAME]),"FILE")
   LOCAL aFName      := dfFNameSplit(cFile)
   LOCAL cFileTxt    := aFName[1]+aFName[2]+aFName[3]+".Txt"
   LOCAL cFilePdf    := NIL
   LOCAL cTitle      := ::aBuffer[REP_NAME]
   LOCAL aExtra      := ::aBuffer[REP_XBASEPRINTEXTRA]
   //LOCAL aExtra      := NIL  //Non viene utilizato ::aBuffer[REP_XBASEPRINTEXTRA]
   LOCAL nOptions    := IIF(lThread, 3, 1)
   LOCAL bEnd        := {|cFilePdf,lOk| ::End_Execute(cFilePdf,lOk,.T.,nOptions)}
   LOCAL cPATH       := ""

   cFileTxt := dfFNameBuild(UPPER(cFileTxt))
   cFile    := dfFNameBuild(UPPER(cFile))

   //E' necessario rinominare il file altrimenti in input 
   //ci sara Nome.pdf e in output Nome.pdf
   //Quindi la funzione dftxt2pdf() da un errore e non crea il pdf
   // Rinomino il file temporaneo in .TXT
   IF !cFile == cFileTxt
      FERASE(cFileTxt)
      FRENAME(cFile, cFileTxt)
      ::aBuffer[REP_FNAME] := cFileTxt
   ENDIF

   IF !EMPTY(aFName[1]+aFName[2] ) 
      cFilePDF :=  aFName[1]+aFName[2]
      dfMD(cFilePDF)  
   ELSE
      IF !EMPTY(dfset("XbaseDefaultSavePath"))
         cFilePDF  := dfpathchk(dfset("XbaseDefaultSavePath"))
         dfMD(cFilePDF)  
      ENDIF 
   ENDIF 
   IF EMPTY(aFName[3]) .OR. aFName[3] == "FILE"
      cFile := ALLTRIM(cTitle)
      IF LEN(cFile) > 150
         cFile := LEFT(cFile, 150)
      ENDIF
   ENDIF

   // Toglie caratteri che danno errore in creazione file
   cFile := dfChgFName(cFile)
   cFile += "_"

   // Provo a creare un file temporaneo con nome significativo
   nHandle := dfFileTemp(@cFilePDF, cFile, LEN(cFile)+5, ".PDF")
   dfXbaseExitProcAdd( dfExecuteActionDelFile():new(cFilePDF) )
   IF nHandle == -1
      // Errore: provo con un nome standard (DBSxxxx.PDF)
      cFilePDF := NIL
      nHandle := dfFileTemp(@cFilePdf, NIL, NIL, ".PDF")
   ENDIF

   IF nHandle == -1
      ::viewTXT() // visual. standard
      FERASE(cFilePdf) 
      //Errore creazione File Pdf
      //dbMsgErr(dfStdMsg1(MSG1_S2PDISFI08))
   ELSE
      FCLOSE(nHandle)
      dfTxt2Pdf( cFileTxt,cFilePdf,cTitle, aExtra, nOptions,cTipoFormatoPagina,cVerso,bEnd)
      //FERASE(cFileTxt)
      dfXbaseExitProcAdd( dfExecuteActionDelFile():new(cFileTxt) )
      dfXbaseExitProcAdd( dfExecuteActionDelFile():new(cFilePDF) )
   ENDIF
   lRet := .T.
RETURN lRet

// sono in un thread separato!!
METHOD S2PrintDispPreview:End_Execute(cFilePdf,lOk,lOpen,nOptions)
   IF lOk
      IF lOpen
         //S2OpenRegisteredFile(cFilePdf)
         // GERR 3911 - Simone 28/8/03

         // Provo a visualizzare con acrobat, se non Š installato
         // vado su visualizzazione standard
         IF dfPDFView(cFilePDF)
            // Mi assicuro che alla fine il file temporaneo venga cancellato
            //FERASE(cFilePDF)
         ELSE
            //FERASE(cFilePDF)
            ::viewTXT()
         ENDIF

          dfXbaseExitProcAdd( dfExecuteActionDelFile():new(cFilePDF) )

/*

  NOTA: questo funziona ma potrebbe fare casino di sincronizzazione
        cancello i files solo all'uscita dal programma

         // attendo 2 minuti prima di provare a cancellare
         // il PDF temporaneo
         // per dare il tempo ad acrobat di aprirsi
         sleep(2*60*100) 

         // cerca di cancellare il PDF 
         DO WHILE .T.
            sleep(1000) // attendo 10 secondi e riprovo
            IF ! FILE(cFilePDF) .OR. FERASE(cFilePDF) == 0
               EXIT
            ENDIF
         ENDDO
*/
      ENDIF
      IF nOptions >=2 .AND. ! lOpen
         dfalert(dfStdMsg1(MSG1_S2PDISFI11))
      ENDIF
   ELSE
      //Errore creazione File Pdf
      dbMsgErr(dfStdMsg1(MSG1_S2PDISFI08))
   ENDIF
RETURN lOk

