#include "dfPdf.ch"
#include "dfMsg1.ch"
#include "common.ch"
#include "Appevent.ch" 

#define CRLF chr(13)+chr(10)
#define HKEY_LOCAL_MACHINE          2147483650

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfPdfView(cFile,cTitle) //Input file testo o pdf -> Apre Acrobat
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL cParam

   // GERR 3911 - Simone 28/8/03 aggiunge il /s che non
   // fa vedere l'immagine iniziale di acrobat
   cParam := dfSet("XbasePDFViewParam")

RETURN _PdfExe(cFile, cTitle, cParam)


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfPdfPrint(cFile,xPrinter, cTitle, lAsync) //Input file testo o pdf -> Apre Acrobat
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL cParam

   IF VALTYPE(xPrinter)=="O"
      xPrinter := xPrinter:devName
   ELSEIF ! VALTYPE(xPrinter) $ "CM"
      xPrinter := NIL
   ENDIF

   // GERR 3911 - Simone 28/8/03 aggiunge il /s che non
   // fa vedere l'immagine iniziale di acrobat
   cParam := dfSet("XbasePDFPrintParam")

RETURN _PdfExe(cFile, cTitle, cParam, "print", xPrinter, lAsync)


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION _PdfExe(cFile, cTitle, cParam, cMode, cPrinter, lAsync) 
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

   Local lret  := .F.
   Local lView := .F.
   Local oPdf  := NIL
   Local cFileOut
  // Local cParam 
   Local cExe
   Local oErr

   DEFAULT lAsync TO .T.

   IF EMPTY(cFile)
      // non posso eseguire ESCO
      RETURN lRet
   ENDIF

   cFile := ALLTRIM(cFile)

   IF UPPER(RIGHT(cFile,4)) == ".TXT"
      lView     := dfTxt2Pdf( cFile, @cFileOut,cTitle)
      cFile     := cFileOut
   ELSEIF UPPER(RIGHT(cFile,4)) == ".PDF"
      lView     := .T.
   ENDIF

   IF EMPTY(cPrinter) 
      cPrinter := ""

   ELSEIF " " $ cPrinter
      cPrinter:= CHR(34)+cPrinter+CHR(34)

   ENDIF

   IF ! lView
      // non posso eseguire ESCO
      RETURN lRet
   ENDIF

   cFile    := dfFNameBuild(cFile)

   // Il default Š di aprire acrobat reader
   // in un'altra finestra (/n) e senza splash screen (/s)
   // ma se premo control li mette tutti in una finestra sola
   IF AppKeyState( xbeK_SHIFT ) == APPKEY_DOWN
      DEFAULT cParam TO "/s" // NO SPLASH SCREEN DI ACROBAT
   ELSE
      DEFAULT cParam TO "/n /s" // APRE ALTRA FINESTRA e NO SPLASH SCREEN 
   ENDIF

   IF (EMPTY(cParam) .OR. cParam == "NOPARAM") .AND. EMPTY(cPrinter)
      lRet := S2OpenRegisteredFile(cFile, NIL, NIL, cMode)
   ELSE
      // Usato S2FindExecutable perche altrimenti
      // la S2OpenRegisteredFile non funziona con il /s
      cExe := S2FindExecutable(cFile)
      IF EMPTY(cExe)
         lRet := S2OpenRegisteredFile(cFile, cParam, NIL, cMode) //Bisogna pasargli il path corrente
      ELSE
         // Simone 5/11/07
         // mantis 0001638: anteprima PDF non funziona con adobe reader 8
         IF " " $ cFile
            cFile := CHR(34)+cFile+CHR(34)
         ENDIF

         // devo stampare?
         IF ! EMPTY(cMode) .AND. UPPER(ALLTRIM(cMode))=="PRINT"
            cParam += " /T " // abilito la stampa
         ENDIF

         // simone 06/02/09 
         // correzione per errore IDSC su ShellExecute (rilevato su xbase 1.82) 
         //lRet := S2OpenRegisteredFile(cExe, cParam+" "+cFile) //Bisogna pasargli il path corrente
         oErr := ERRORBLOCK({|e| dfErrBreak(e, NIL, .T.)})
         BEGIN SEQUENCE
             lRet := RunShell(cParam+" "+cFile+" "+cPrinter, cExe, lAsync)
             IF VALTYPE(lRet)=="N" .AND. lRet != -1
                lRet := 33
             ELSE
                lRet := 0
             ENDIF
         RECOVER 
             lRet := 0
         END SEQUENCE
         ERRORBLOCK(oErr)
      ENDIF
   ENDIF

   lRet := lRet > 32
RETURN lRet


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfGetAcrobatPath(lMsg)  // Ritorna path di registro di Acrobat Reader
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL nHKey      := HKEY_LOCAL_MACHINE
   LOCAL cKeyName   := ""
   LOCAL cEntryName := ""
   LOCAL lEsc       := .F.
   LOCAL nVer       := 1.0
   LOCAL cVer       := "1.0"


   DO WHILE !lEsc  .AND. nVer<999
      cKeyName   := "SOFTWARE\ADOBE\ACROBAT READER\"+cVer+"\InstallPath"
      IF !EMPTY(QueryRegistry(nHKey, cKeyName, cEntryName))
         lEsc := .T.
      ENDIF
      nVer += 0.1
      cVer := ALLTRIM(STR(nVer,4,1))
   ENDDO

   IF !EMPTY(QueryRegistry(nHKey, cKeyName, cEntryName))
      RETURN QueryRegistry(nHKey, cKeyName, cEntryName)
   ELSEIF VALTYPE(lMsg)=="L" .AND. lMsg
      dbmsgErr(dfStdMsg1(MSG1_DFPDF05))
   ENDIF

RETURN ""

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfPdfGetOrientation()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL aArr := {}
   AADD(aArr,{PDF_VERTICAL  , dfStdMsg1(MSG1_S2PDISFI09)})
   AADD(aArr,{PDF_HORIZONTAL, dfStdMsg1(MSG1_S2PDISFI10)})
RETURN aArr

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfPdfGetForms()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL aForms := {}
   AADD(aFORMS,PDF_PAGE_LETTER   )
   AADD(aFORMS,PDF_PAGE_LEGAL    )
   AADD(aFORMS,PDF_PAGE_LEDGER   )
   AADD(aFORMS,PDF_PAGE_EXECUTIVE)
   AADD(aFORMS,PDF_PAGE_A4       )
   AADD(aFORMS,PDF_PAGE_A3       )
   AADD(aFORMS,PDF_PAGE_JIS_B4   )
   AADD(aFORMS,PDF_PAGE_JIS_B5   )
   AADD(aFORMS,PDF_PAGE_JPOST    )
   AADD(aFORMS,PDF_PAGE_JPOSTD   )
   AADD(aFORMS,PDF_PAGE_COM10    )
   AADD(aFORMS,PDF_PAGE_MONARCH  )
   AADD(aFORMS,PDF_PAGE_C5       )
   AADD(aFORMS,PDF_PAGE_DL       )
   AADD(aFORMS,PDF_PAGE_B5       )
   //Mantis 2179 
   AADD(aFORMS,PDF_PAGE_A5       )
RETURN aForms

// converte un colore in formato PDF
// es. cPdfColor := dfRgb2PdfColor( GraMakeRgbColor({10, 200, 30}) )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfRgb2PdfColor(nColor)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   nColor := GraGetRGBIntensity(nColor)
   IF VALTYPE(nColor) =="A" .AND. LEN(nColor) >= 3
      nColor := CHR(nColor[1])+CHR(nColor[2])+CHR(nColor[3])
   ELSE
      nColor := NIL
   ENDIF
RETURN nColor


