#include "common.ch"
#include "dfmsg.ch"
#include "dfmsg1.ch"
#include "dfReport.ch"
#include "Gra.ch"
#include "dfWinRep.ch"
#include "xbp.ch"
#include "XBPDEV.CH"
#include "dfPdf.ch"

FUNCTION dfTxt2Pdf( cFile,cFileOut, cTitle, aExtra, nOptions,cTipoFormato,cVerso, bAtEnd, cCompoundFont)
   LOCAL oThread
   LOCAL lRet
   LOCAL oPdfPrint
   LOCAL lPrintDestroy  := .F.
   LOCAL aImgCache      := {}
   LOCAL aFontCache     := {}
   LOCAL cPath,cFilename
   LOCAL aFile

   DEFAULT nOptions TO 0  // 0 = SENZA THREAD, 1=SENZA THREAD + ERASE FILE
                          // 2 = CON THREAD  , 3= CON THREAD+ERASE FILE
   BEGIN SEQUENCE

      IF oPdfPrint==NIL
         oPdfPrint := PdfPrint():new()
      ENDIF

      cFileOut := oPdfPrint:GetPDFName(cFile,cFileOut)

      IF nOptions >= 2
         oThread := Thread():new()

         // Salvo ENVID dato che Š privata e quindi thread local
         // altrimenti non trovo EnvID nella dfWinPrnFont()
         oThread:cargo := { {"ENVID", M->EnvId} }
         oThread:start({|| oPdfPrint:print( cFile, cFileOut, cTitle, aExtra, .T., nOptions==3 .OR. nOptions==1,cTipoFormato,cVerso,bAtEnd) })
         lRet := .T.
      ELSE
         lRet := oPdfPrint:print( cFile, cFileOut, cTitle, aExtra, .F., nOptions==3 .OR. nOptions==1,cTipoFormato,cVerso,bAtEnd, cCompoundFont)
      ENDIF


   END SEQUENCE

RETURN lRet

STATIC CLASS PdfPrint
PROTECTED:
   SYNC METHOD _print

EXPORTED:
   SYNC METHOD print

   INLINE METHOD GetPDFName(cFileIn, cFileOut)
      LOCAL aFileIn
      LOCAL aFileOut
      LOCAL cPathIn,cPathOut
      LOCAL lFname := .T.

      cFileIn   := dfFNameBuild(cFileIn)

      DEFAULT cFileOut TO cFileIn

      aFileIn   := dfFNameSplit(cFileIn)
      aFileOut  := dfFNameSplit(cFileOut)

      IF EMPTY(aFileOut[1])
         aFileOut[1] := aFileIn[1]
      ENDIF
      IF EMPTY(aFileOut[2])
         aFileOut[2] := aFileIn[2]
      ENDIF
      IF EMPTY(aFileOut[3])
         aFileOut[3] := aFileIn[3]
         lFname := .F. // il nome file non era passato
      ENDIF

      //IF EMPTY(aFileOut[4])
      //   aFileOut[4] := ".Pdf"
      //ENDIF

      cFileOut := aFileOut[1] + aFileOut[2] + aFileOut[3] + ".pdf"

      // simone 26/2/08 correzione per nome file input con estensione .pdf
      IF FILE(cFileOut) .AND. ! lFName // se il nome file Š calcolato, lo ricalcolo univoco
         cFileOut := aFileOut[1] + aFileOut[2]
         FCLOSE(dfFileTemp(@cFileOut, aFileOut[3]+"_", LEN(aFileOut[3]+"_")+3, ".pdf"))
         ///////////////////////
         //Inserito per evitare file tempornei che non vengono cancellati.
         ///////////////////////
         FERASE(cFileOut)
         ///////////////////////
      ENDIF


//      DEFAULT cFileOut   TO cFileIn
//
//      aFileIn   := dfFNameSplit(cFileIn)
//      aFileOut  := dfFNameSplit(cFileOut)
//
//
//      cFileIn := dfFNameBuild(cFileIn,@cPathIn)
//
//      cPathOut  := aFileOut[1]+aFileOut[2]
//      IF EMPTY(cPathOut )
//         cPathOut  := cPathIn
//      ENDIF
//      cFileOut  := cPathIn + aFileOut[3]+".Pdf"

   RETURN cFileOut

ENDCLASS

METHOD PdfPrint:print(cFileIn,cFileOut, cTitle, aExtra, lThread, lErase,cTipoFormato,cVerso,bAtEnd,cCompoundFont )
   LOCAL lRet := .T.
   LOCAL oPdf
   LOCAL nOldCop
   LOCAL nOldCollate
   LOCAL xCollate
   LOCAL nCount   := 0
   LOCAL bMessage

   DEFAULT cTitle     TO ""

   IF ! lThread
      // aggiorna il testo nel progress bar
      bMessage := {|cMes,lOn| dfPIUpdMsg(dfStdMsg1(MSG1_DFPDF02)+;
                                         IIF(EMPTY(cMes), "", "////"+cMes)) }
   ENDIF

   FERASE(cFileOut)
   oPdf:= dfPdf():New(  cFileOut,200,.T.,bMessage)

   //IF EMPTY(oPdf)   // Non dovrebbe mai succedere
   //   dbMsgErr(dfStdMsg1(MSG1_DFPDF01) )
   //   BREAK
   //ENDIF

   lRet := ::_print(cFileIn, cTitle, oPdf, aExtra, lThread,cTipoFormato,cVerso, cCompoundFont)
   IF lRet
      //Viene fatto dalla Funzione dfpdfview() con in imput il file di testo
      //oPdf:Execute( cFileOut )
   ENDIF

   IF VALTYPE(bAtEnd)=="B"
      lRet := EVAL(bAtEnd, cFileOut, lRet, cFileIn, cTitle, oPdf, aExtra, lThread,cTipoFormato,cVerso)
   ENDIF

   IF lRet .AND. lErase
      FERASE(cFileIn )
   ENDIF


RETURN lRet

//Aggiunto cCompoundFont per passare il font voluto
METHOD PdfPrint:_print(cFile, cTitle, oPdf, aExtra, lThread,cTipoFormato,cVerso, cCompoundFont)
   LOCAL nHandle, cString, aFrame, cCol, nCount := 0, nFileLen, lRet := .T.
   LOCAL nDevice, cRet := "", lDefault, aPaperSize

   LOCAL oPs, oDc, aCreate
   LOCAL aTextBox, nFontHeight,nFontHeightMin, nFontWidth, nY, aPageSize
   LOCAL aFont, aAttr,aPos
   LOCAL aCurrAttr      := dfWinPrnReset()
   LOCAL nLine          := 0
   LOCAL nSize          := 0
   LOCAL nPag           := 0
   LOCAL lPrintDestroy  := .F.
   LOCAL nMargX         := 0
   LOCAL nMargY         := 0
   LOCAL nLpi           := 6
   LOCAL nPage          := 0
   LOCAL oFont
   LOCAL cInitString
   LOCAL cDevice
   LOCAL nPageHeight
   LOCAL oFile
   LOCAL _cFont, _nType, _nSize, cId,cFont,bFont
   LOCAL nBGColor
   LOCAL aBoxPos

   DEFAULT cTipoFormato TO PDF_PAGE_A4
   DEFAULT cVerso       TO PDF_VERTICAL
   DEFAULT cTitle       TO ""       // Title
   DEFAULT aExtra       TO dfWinPrnExtra()
   BEGIN SEQUENCE

      IF ! EMPTY(cTitle)
         cTitle := " - "+cTitle
      ENDIF

      cVerso := ALLTRIM(cVerso)
      IF !(cVerso $ PDF_VERTICAL + PDF_HORIZONTAL)
         cVerso := PDF_VERTICAL
      ENDIF

      nFileLen:=DIRECTORY(cFile)

      IF LEN(nFileLen) != 1
         lRet := .F.
         BREAK
      ENDIF
      nFileLen := nFileLen[1][2]

      oFile := dfFile():new()

      nHandle:=oFile:Open( cFile )     // Open file
      IF nHandle <= 0
         lRet := .F.
         BREAK
      ENDIF

      IF ! EMPTY(dfSet("XbasePrintEasyReadColor"))
         nBGColor := S2DbseeColorToRGB(dfSet("XbasePrintEasyReadColor"), .T.)

         // conversione colore in formato PDF
         nBGColor := dfRgb2PdfColor(nBgColor)
      ENDIF

      oFont := dfPdfFONT():NEW(oPdf)
      oFont:Create(cCompoundFont)
      oFont:SetPdfFont()

      IF ! lThread
         dfPIOn(cTitle, dfStdMsg1(MSG1_DFPDF02)+" "+ALLTRIM(STR(++nPag)))
      ENDIF
      oPdf:PageOrient(cVerso)  //Orientamento pagina Verticale
      oPdf:PageSize(cTipoFormato)
      oPdf:SetLPI(nlpi)
      aPageSize    := ARRAY(2)
      aPageSize[1] := oPdf:aReport[ PDF_PAGEX        ]
      aPageSize[2] := oPdf:aReport[ PDF_PAGEY        ]

      aPageSize[1]--
      aPageSize[2]--

      nFontHeight := oFont:Height
      nFontHeight := nFontHeight * 1.1 //Incremento interlinea di 1%

      nPageHeight := aPageSize[2]
      nMargX         := 2
      nMargY         := 3
      nFontHeight := oPdf:X2M(nFontHeight)

      nFontWidth  := oPdf:Length( "W" )
      nMargX      := nMargX* nFontWidth
      nMargY      := nMargY* nFontHeight
      nPageHeight := oPdf:X2M(nPageHeight)

      IF ! EMPTY(aExtra)

         IF aExtra[DFWINREP_EX_MARGTOP] != NIL
            nMargY := aExtra[DFWINREP_EX_MARGTOP]/10
         ENDIF

         IF aExtra[DFWINREP_EX_MARGLEFT] != NIL
            nMargX := aExtra[DFWINREP_EX_MARGLEFT]/10
         ENDIF

         IF aExtra[DFWINREP_EX_INTERLINE] != NIL
            nFontHeight := aExtra[DFWINREP_EX_INTERLINE]/10
         ENDIF

         IF aExtra[DFWINREP_EX_PAGEHEIGHT] != NIL
            nPageHeight := aExtra[DFWINREP_EX_PAGEHEIGHT]/10
         ENDIF

         IF aExtra[DFWINREP_EX_FONTS] != NIL
            bFont := aExtra[DFWINREP_EX_FONTS]
         ENDIF
      ENDIF

      nFontHeightMin := nFontHeight          //Server per determinare l'interlinea Minima

      nY             := nPageHeight //per fare Creare subito una pagina Nuova
      oPdf:BookOpen()

      DO WHILE !oFile:Eof()              // until not EOF()
         cString := oFile:Read()           // Read line

         nSize   += LEN(cString)+2

         IF ! lThread
            IF ! dfPIStep(nSize, nFileLen)
               EXIT
            ENDIF
         ENDIF

         // Tolgo codici _CR o _LF iniziali
         DO WHILE ! EMPTY(cString) .AND. LEFT(cString, 1) $ CRLF
            cString := SUBSTR(cString, 2)
         ENDDO

         IF nFontHeightMin > oPdf:X2M(oFont:Height)
            nFontHeight := nFontHeightMin
         ELSE
            nFontHeight := oPdf:X2M(oFont:Height)
         ENDIF

         nY += nFontHeight
         IF nY >nPageHeight  .OR. LEFT( ALLTRIM(cString), 1 ) == NEWPAGE
            oPdf:aReport[ PDF_PDFLEFT ]  := 0
            oPdf:aReport[ PDF_PDFTOP  ]  := 0
            oPdf:NewPage( cTipoFormato, cVerso, nLPI )

            ++nPage

            // SIMONE 10/3/03 funziona perfettamente, ma Š inutile
            // dato che acrobat aggiunge da se la visualizzazione delle
            // pagine come miniature
            //oPdf:BookAdd( dfStdMsg1(MSG1_DFPRNMENU03)+" "+STR(nPage)+cTitle, 1, oPdf:aReport[ PDF_REPORTPAGE ], 0 )

            nY := nMargY
            nLine := 0

            // evidenziazione righe 
            IF nBGColor != NIL
               FOR nLine := nY TO nPageHeight STEP nFontHeight*2
                  aBoxPos := { 0, nPageHeight-nLine , 0, 0}
                  aBoxPos[2] -= nFontHeight*10/100
                  aBoxPos[3] := oPdf:X2M(aPageSize[1])
                  aBoxPos[4] := aBoxPos[2]+(nFontHeight*90/100)
   
                  // converto in UM
                  aBoxPos[1] := oPdf:M2X(aBoxPos[1])
                  aBoxPos[2] := oPdf:M2Y(aBoxPos[2])
                  aBoxPos[3] := oPdf:M2X(aBoxPos[3]) 
                  aBoxPos[4] := oPdf:M2Y(aBoxPos[4])
   
                  oPdf:Box1( aBoxPos[2], aBoxPos[1], ;
                             aBoxPos[4], aBoxPos[3], ;
                             0, NIL, nBGColor) 
               NEXT
            ENDIF

            IF LEFT( ALLTRIM(cString), 1 ) == NEWPAGE
               cString := STRTRAN(cString, NEWPAGE, "")
            ENDIF


            IF ! lThread
               dfPIUpdMsg(dfStdMsg1(MSG1_DFPDF02)+" "+ALLTRIM(STR(nPage)))
            ENDIF
         ENDIF

         aPos := ARRAY(2)
         aPos[1] := nMargX
         aPos[2] := nY
         DO WHILE .T.
            cInitString := cString

            //Stampa un Box
            cString := dfFile2PdfDrawBox(cString, oPdf, aPos[1], aPos[2] , ;
                                          nFontHeight, oFont, aCurrAttr)

            //Stampa un Immagine
            //cString := AddImg(cString, oPdf, aPos,  oFont, nFontHeight)

            IF cString == cInitString
               EXIT
            ENDIF
         ENDDO

         //Mantis  2153 Correzione impostazione font Luca il 4/maggio/2011
         //Correzione del 10/06/2011 fatta da : 
         //  Correzione inAzienda - Guido se manca il riferimento a cCompoundFont si perde 
         //  l'impostazione del caratter (es. Compresso) dal Men— di Stampa
         IF !EMPTY(oFont) .AND. !Empty(cCompoundFont)
            //cString := oFont:SetPdfFont(cString)
            bFont :=  {||oFont}
         ENDIF 
         // Stampa la stringa con gli attributi correnti
         dfPdfStringAt( cString, oPdf, aPos , nFontHeight , @oFont,aCurrAttr ,bFont)

         oFile:Skip()
      ENDDO
      oPdf:Close()

      oFile:Close()
      lRet := .T.


      IF ! lThread
         dfPIOff()
      ENDIF


   END SEQUENCE

   IF ! EMPTY(oFile)
      oFile:destroy()
   ENDIF
   IF ! EMPTY(oPdf)
      oPdf:Destroy()
   ENDIF
RETURN lRet

