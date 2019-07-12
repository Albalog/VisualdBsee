// *****************************************************************************
// Copyright (C) ISA - Italian Software Agency
// Description : Centralised copy text file to printer function
// *****************************************************************************
#include "common.ch"
#include "dfmsg.ch"
#include "dfReport.ch"
#include "Gra.ch"
#include "dfWinRep.ch"
#include "xbp.ch"
#include "XBPDEV.CH"
#include "dfMsg1.ch"

STATIC oSerialPrint

FUNCTION dfFile2WPrn( cFile, cTitle, xDevice, aExtra, nOptions, nCopies )
   LOCAL oThread
   LOCAL lRet
   LOCAL oDC
   LOCAL lPrintDestroy := .F.
   LOCAL aImgCache := {}
   LOCAL aFontCache := {}
   LOCAL nMaxStop :=  10, nStop

   DEFAULT nOptions TO 0  // 0 = SENZA THREAD, 1=SENZA THREAD + ERASE FILE
                          // 2 = CON THREAD  , 3= CON THREAD+ERASE FILE

   BEGIN SEQUENCE

      // xDevice pu• essere:
      //   una stringa che Š il nome della stampante
      //   oppure un Device Context di stampa in status CREATO
      IF ! EMPTY(xDevice)        .AND. ;
         VALTYPE(xDevice) == "C" .AND. ;
         ASCAN(dfWinPrinters(), {|x| x==xDevice }) == 0

         //dbMsgErr("Stampante non valida//"+xDevice)
         dbMsgErr(dfStdMsg1(MSG1_DFPRNMENU02)+"//"+xDevice)

         lRet := .F.
         BREAK
      ENDIF

      DO CASE
         CASE VALTYPE(xDevice) == "O"
            oDC := xDevice

         CASE ! EMPTY(dfWinPrinterObject()) .AND. ;
              (EMPTY(xDevice) .OR. ;
               xDevice == dfWinPrinterObject():devName)

            oDC := dfWinPrinterObject()

         OTHERWISE
            lPrintDestroy := .T.
            oDC := S2Printer():new()
            oDC:Create(xDevice)

      ENDCASE

      IF EMPTY(oDC)   // Non dovrebbe mai succedere
         //dbMsgErr("Stampante non definita")
         dbMsgErr(dfStdMsg1(MSG1_DFPRNMENU05))
         BREAK
      ENDIF
      /////////////////////////////////////////////////////////////
      //Gerr 4596
      IF EMPTY(oDc:devName)
         dbMsgErr(dfStdMsg1(MSG1_DFPRNMENU05))
         BREAK
      ENDIF
      /////////////////////////////////////////////////////////////

      IF oDC:status() != XBP_STAT_CREATE
         // Pu• essere dovuto a scelte di stampanti che non
         // sono in realt… stampanti
         // esempio "Rendering subsystem"

         //dbMsgErr("Stampante non valida//"+oDc:devName)
         dbMsgErr(dfStdMsg1(MSG1_DFPRNMENU02)+"//"+oDc:devName)
         BREAK
      ENDIF


      IF oSerialPrint==NIL
         oSerialPrint := SerialPrint():new()
      ENDIF

      //Spostata in Gioia
      ///////////////////////////////////////////////////////
      ////Luca 9/01/2006 Soluzione suggerit da PDR Alaska 1400.
      ////Gerr 4583 : Problemi di stampa sequenziale documenti
      //IF dfIsWin2000()
      //   IF nOptions >  2
      //      nOptions -= 2
      //   ENDIF
      //ENDIF
      ///////////////////////////////////////////////////////

      IF nOptions >= 2


         oThread := Thread():new()
         // Salvo ENVID dato che Š privata e quindi thread local
         // altrimenti non trovo EnvID nella dfWinPrnFont()
         oThread:cargo := { {"ENVID", M->EnvId} }
         oThread:start({|| oSerialPrint:print( cFile, cTitle, oDc, aExtra, .T., nOptions >= 3, aImgCache, aFontCache, nCopies ) })

         ///////////////////////////////////////////////////////
         //Luca 9/01/2006 Soluzione suggerit da PDR Alaska 1400.
         //Gerr 4583 : Problemi di stampa sequenziale documenti
         oThread:synchronize(1)
         ///////////////////////////////////////////////////////

         lRet := .T.
      ELSE
         lRet := oSerialPrint:print( cFile, cTitle, oDc, aExtra, .F., nOptions >= 1, aImgCache, aFontCache, nCopies  )
      ENDIF

      // Faccio il destroy DOPO aver stampato altrimenti ho errore
      // se sulla stessa pagina ho 2 riferimenti allo stesso oggetto!
      AEVAL(aImgCache, {|x| x[2]:destroy()})
      AEVAL(aFontCache, {|x| IIF(x[2]:status() == XBP_STAT_CREATE, ;
                                 x[2]:destroy(), NIL)})

   END SEQUENCE

   IF lPrintDestroy
      oDc:destroy()
   ENDIF
RETURN lRet

STATIC CLASS SerialPrint
PROTECTED:
   SYNC METHOD _print

EXPORTED:
   SYNC METHOD print
ENDCLASS

SYNC METHOD SerialPrint:print(cFile, cTitle, xDevice, aExtra, lThread, lErase, aImgCache, aFontCache, nCopies )
   LOCAL lRet := .T.
   LOCAL oDC := xDevice
   LOCAL nOldCop
   LOCAL nOldCollate
   LOCAL xCollate
   LOCAL nCount := 0
   LOCAL cTit

   DEFAULT nCopies    TO 1
   DEFAULT cTitle     TO ""

   IF EMPTY(oDC) .OR. nCopies <= 1 .OR. oDC:setNumCopies() == NIL .OR. ;
      oDC:setCollationMode() == NIL

      // La stampante non supporta opzione "numero copie" o "fascicola copie"
      DO WHILE ++nCount <= nCopies .AND. lRet
         IF nCopies > 0
            cTit := cTitle+" "+ALLTRIM(STR(nCount))+"/"+ALLTRIM(STR(nCopies))
         ENDIF
         lRet := ::_print(cFile, cTit, xDevice, aExtra, lThread, ;
                          lErase, aImgCache, aFontCache)
      ENDDO

   ELSEIF nCopies > 1

      nOldCollate := oDC:setCollationMode( XBPPRN_COLLATIONMODE_ON )
      nOldCop     := oDC:setNumCopies( nCopies )
      //dfalert({odc:devname, odc:setNumcopies(), nCopies})
      lRet := ::_print(cFile, cTitle, xDevice, aExtra, lThread, lErase, aImgCache, aFontCache)

      oDC:setCollationMode( nOldCollate )
      oDC:setNumCopies(nOldCop)
   ENDIF

   IF lRet .AND. lErase
      FERASE(cFile)
   ENDIF  

RETURN lRet

SYNC METHOD SerialPrint:_print(cFile, cTitle, xDevice, aExtra, lThread, lErase, aImgCache, aFontCache)
   LOCAL nHandle, cString, aFrame, cCol, nCount := 0, nFileLen, lRet := .T.
   LOCAL nDevice, cRet := "", lDefault, aPaperSize

   LOCAL oPs, oDc, aCreate
   LOCAL aTextBox, nFontHeight, nFontWidth, nY, aPageSize
   LOCAL oFont, aAttr
   LOCAL aCurrAttr := dfWinPrnReset()
   LOCAL nSize := 0
   LOCAL nPag := 0
   LOCAL lPrintDestroy := .F.
   LOCAL cDevice
   LOCAL nPageHeight
   LOCAL nMargX := 0
   LOCAL nMargY := 0
   LOCAL bFont
   LOCAL cInitString
   LOCAL oFile
   LOCAL nLine := 0
   LOCAL nBGColor
   LOCAL aBoxPos
   LOCAL aAttr1
   LOCAL lEvidenzia
   // LOCAL aImg  := {}
   LOCAL bImg  := {|oPS,oImg,aPos| oImg:draw(oPS, aPos, {0,0,oImg:xSize,oImg:ySize}, ;
                                   GRA_BLT_ROP_SRCCOPY, GRA_BLT_BBO_IGNORE) }

   BEGIN SEQUENCE

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

      DEFAULT cTitle  TO ""       // Title
      DEFAULT aExtra TO dfWinPrnExtra()

      lDefault := ( dfSet( AI_LOGMESSAGE )!=NIL )

      DO WHILE .T.
         //IF dfPrnChk(nDevice)     // Verifying printer
            EXIT
         //ENDIF
         IF !dfYesNo( dfStdMsg(MSG_DFFILE2PRN01), !lDefault )
            lRet := .F.
            EXIT
         ENDIF
      ENDDO

      IF ! lRet; BREAK; ENDIF

      IF ! EMPTY(dfSet("XbasePrintEasyReadColor"))
         nBGColor := S2DbseeColorToRGB(dfSet("XbasePrintEasyReadColor"), .T.)
      ENDIF

      // xDevice pu• essere:
      //   una stringa che Š il nome della stampante
      //   oppure un Device Context di stampa in status CREATO
      // IF ! EMPTY(xDevice)        .AND. ;
      //    VALTYPE(xDevice) == "C" .AND. ;
      //    ASCAN(dfWinPrinters(), {|x| x==xDevice }) == 0
      //
      //    dbMsgErr("Stampante non valida//"+xDevice)
      //
      //    lRet := .F.
      //    BREAK
      // ENDIF
      //
      // DO CASE
      //    CASE VALTYPE(xDevice) == "O"
      //       oDC := xDevice
      //
      //    CASE ! EMPTY(dfWinPrinterObject()) .AND. ;
      //         (EMPTY(xDevice) .OR. ;
      //          xDevice == dfWinPrinterObject():devName)
      //
      //       oDC := dfWinPrinterObject()
      //
      //    OTHERWISE
      //       lPrintDestroy := .T.
      //       oDC := S2Printer():new()
      //       oDC:Create(xDevice)
      //
      // ENDCASE
      //
      // IF oDC:status() != XBP_STAT_CREATE
      //    // Pu• essere dovuto a scelte di stampanti che non
      //    // sono in realt… stampanti
      //    // esempio "Rendering subsystem"
      //    BREAK
      // ENDIF

      oDc := xDevice

      cDevice := oDC:devName

      oPs := XbpPresSpace():new()

   #ifdef _XBASE15_
      // Simone 11/02/02
      // tolto perche la qualita diminuisce!
      // oPs:mode := XBPPS_MODE_HIGH_PRECISION
   #endif

      aPaperSize := oDC:paperSize()

      oPs:Create(oDc, ;
                 {oDc:paperSize()[5] - oDc:paperSize()[3], ;
                  oDc:paperSize()[6] - oDc:paperSize()[4]}, GRA_PU_LOMETRIC)

      // Controllo per errore
      // IF EMPTY(oPS:device()) .OR. ! isMemberVar(oPS:device(), "devName")
      //
      //    dbMsgErr("Per effettuare la stampa e' necessario//"+;
      //             "installare una stampante in Windows.")
      //
      //    oPS:destroy()
      //
      //    IF lPrintDestroy
      //       oDc:destroy()
      //    ENDIF
      //
      //    BREAK
      // ENDIF

      IF ! lThread
         //dfPIOn(cTitle, "Stampa pagina "+ALLTRIM(STR(++nPag)))
         dfPIOn(cTitle,dfStdMsg1(MSG1_DFPRNMENU06) +ALLTRIM(STR(++nPag)))
      ENDIF

      aPageSize := oPS:setPageSize()[1]

      aPageSize[1]--
      aPageSize[2]--

      nPageHeight := aPageSize[2]
      nY          := nPageHeight
      nLine       := 0
      lEvidenzia  := .T.

      oDc:startDoc(cTitle)

      oFont := dfWinPrnFont( NIL, oPS, NIL, .F.  )

      IF ! EMPTY( oFont )
         oPS:setFont( oFont )
      ENDIF

      // Imposto il colore NERO
      oPS:setColor(GRA_CLR_BLACK)

      aAttr := ARRAY( GRA_AS_COUNT )
      aAttr[GRA_AS_COLOR] := GRA_CLR_BLACK
      oPS:setAttrString( aAttr )

      aTextBox    := GraQueryTextBox( oPS, "w" )
      nFontWidth  := aTextBox[3,1] - aTextBox[2,1]
      aTextBox    := GraQueryTextBox( oPS, "^g" )
      nFontHeight := aTextBox[3,2] - aTextBox[2,2]

      IF ! EMPTY(aExtra)

         IF aExtra[DFWINREP_EX_MARGTOP] != NIL
            nMargY := aExtra[DFWINREP_EX_MARGTOP] - ;
                      (aPaperSize[2] - aPaperSize[6])
         ENDIF

         IF aExtra[DFWINREP_EX_MARGLEFT] != NIL
            nMargX += aExtra[DFWINREP_EX_MARGLEFT] - aPaperSize[3]
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

      DO WHILE !oFile:Eof()              // until not EOF()
         cString:=oFile:Read()      // Read line
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

         nY -= nFontHeight

         IF nY < 0 .OR. LEFT( ALLTRIM(cString), 1 ) == NEWPAGE
            // Stampo tutte le immagini della pagina
            // AEVAL(aImg, {|x| x[2]:draw(oPS, x[3], {0,0,x[2]:xSize,x[2]:ySize}, ;
            //                            GRA_BLT_ROP_SRCCOPY, GRA_BLT_BBO_IGNORE)})
            // aImg := {}

            oDc:newPage()

            nY         := nPageHeight - nFontHeight
            nLine      := 0
            lEvidenzia := .T.

            IF LEFT( ALLTRIM(cString), 1 ) == NEWPAGE
               cString := STRTRAN(cString, NEWPAGE, "")
            ENDIF

            IF ! lThread
               dfPIUpdMsg(dfStdMsg1(MSG1_DFPRNMENU06)+ALLTRIM(STR(++nPag))) // "Stampa pagina "+ALLTRIM(STR(++nPag))
            ENDIF
         ENDIF


         IF lEvidenzia .AND. nBGColor != NIL
            aAttr := GraSetAttrArea(oPS)
            aAttr1 := ACLONE(aAttr)
            aAttr1[GRA_AA_COLOR] := nBGColor
            GraSetAttrArea(oPS, aAttr1)
            FOR nLine := nY TO 0 STEP -2*nFontHeight
               aBoxPos := { nMargX, nLine - nMargY }
               aBoxPos[2] -= nFontHeight*10/100
               GraBox(oPS, aBoxPos, { aPaperSize[5], aBoxPos[2]+(nFontHeight*90/100) }, GRA_FILL)
            NEXT
            GraSetAttrArea(oPS, aAttr)

            lEvidenzia := .F.
         ENDIF

         DO WHILE .T.
            cInitString := cString

            // cString := DrawImage(cString, oPS, nMargX, nY - nMargY, ;
            //                      nFontWidth, nFontHeight)

            cString := dfFile2WPrnDrawBox(cString, oPS, nMargX, nY - nMargY, ;
                                          nFontHeight, cDevice, aCurrAttr, .F., ;
                                          bFont, .F., aFontCache)
            IF cString == cInitString
               EXIT
            ENDIF
         ENDDO

         // Stampa la stringa con gli attributi correnti
         dfWinPrnStringAt( oPS, { nMargX, nY - nMargY }, cString, cDevice, ;
                           aCurrAttr, .F., NIL, bFont, bImg, aImgCache, ;
                           nFontHeight, aFontCache, .T.)

         oFile:Skip()
      ENDDO

      // Stampo tutte le immagini della pagina
      // AEVAL(aImg, {|x| x[2]:draw(oPS, x[3], {0,0,x[2]:xSize,x[2]:ySize}, ;
      //                            GRA_BLT_ROP_SRCCOPY, GRA_BLT_BBO_IGNORE)})
      //
      // aImg := {}

      oDc:endDoc()

      oFile:Close()

      IF ! lThread
         dfPIOff()
      ENDIF

      oPs:destroy()

   END SEQUENCE

   IF ! EMPTY(oFile)
      oFile:destroy()
   ENDIF

RETURN lRet

