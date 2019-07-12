//////////////////////////////////////////////////////////////////////
// Modifica Risoluzione File BMP per Xbase++ 1.6
//
// Compilare e linkare con:
//    XPP BMPRES /M/N/W/Q/LINK
//
//////////////////////////////////////////////////////////////////////

#include "Fileio.ch"
#include "common.ch"

// PROCEDURE Main(cNomeFile, cDpi)
//
//    LOCAL nHandle
//    LOCAL nDpi := 300
//    LOCAL nPPM
//
//    ? "Imposta la risoluzione in un file .BMP"
//    IF EMPTY(cNomeFile)
//       ? "Uso: BMPRES nomefile.bmp [risoluzione]"
//
//       ? "Esempio:"
//       ? "  BMPRES prova.bmp      imposta la risoluzione a 300 dpi"
//       ? "  BMPRES prova.bmp 96   imposta la risoluzione a 96 dpi"
//       RETURN
//    ENDIF
//
//    DEFAULT cDpi TO "300"
//
//    nDpi := VAL(cDpi)
//
//    nHandle := FOPEN( cNomeFile, FO_READWRITE + FO_SHARED )
//
//    IF FERROR() <> 0
//       ? "Errore ",FERROR()," in apertura del file",cNomeFile
//       RETURN
//    ENDIF
//
//    FSEEK ( nHandle, 0x26 )
//
//    // converto da Dot per Inch a Pixel per metro
//    nPpm := nDPI * 100 / 2.54
//
//    FWRITE( nHandle, w2bin(nPPM) + w2bin(0) + w2bin(nPPM) + w2bin(0) )
//    ? "File: ", cNomeFile
//    ? "Risoluzione impostata: ",nDPI, "dpi"
//
//    IF ! FCLOSE( nHandle )
//       ? "Errore di chiusura File " + FERROR()
//    Endif
//
//
// RETURN

FUNCTION dfSetBmpRes(cNomeFile, nDPI)
   LOCAL nHandle
   LOCAL nPPM
   DEFAULT nDpi TO 300

   nHandle := FOPEN( cNomeFile, FO_READWRITE + FO_SHARED )

   IF FERROR() <> 0
      RETURN .F.
   ENDIF

   FSEEK ( nHandle, 0x26 )

   // converto da Dot per Inch a Pixel per metro
   nPpm := nDPI * 100 / 2.54

   FWRITE( nHandle, w2bin(nPPM) + w2bin(0) + w2bin(nPPM) + w2bin(0) )

   FCLOSE( nHandle )

RETURN .T.

// Ritorna risoluzione BMP: NIL=errore lettura file
// altrimenti torna array con risoluzione X e Y in DPI

FUNCTION dfGetBmpRes(cNomeFile)
   LOCAL nHandle, cBuff
   LOCAL nX, nY

   nHandle := FOPEN( cNomeFile, FO_READWRITE + FO_SHARED )

   IF FERROR() <> 0
      RETURN NIL
   ENDIF

   FSEEK ( nHandle, 0x26 )

   cBuff := SPACE(4)
   FREAD(nHandle, @cBuff, 4)  // X Res in PixPerMetro

   nX := bin2U(cBuff)

   nX *= 2.54/100          // Converto in DPI

   cBuff := SPACE(4)
   FREAD(nHandle, @cBuff, 4)  // Y Res in PixPerMetro
   nY := bin2U(cBuff)

   nY *= 2.54/100          // Converto in DPI

   FCLOSE( nHandle )

RETURN {ROUND(nX, 0), ROUND(nY, 0)}
