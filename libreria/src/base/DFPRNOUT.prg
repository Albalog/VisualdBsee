//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per STAMPE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Fileio.ch"
#INCLUDE "dfReport.ch" // Struttura Report e Virtual record
#INCLUDE "dfStd.ch"    // Standard

FUNCTION dfPrnOut( aBuf )
LOCAL lRet := .F.
#ifdef __XPP__
   IF dfSet( AI_XBASEPRNMENUNEW )
      lRet := _dfXPrnOut( aBuf )
   ELSE
      lRet := _dfPrnOut( aBuf )
   ENDIF
#else
   lRet := _dfPrnOut( aBuf )
#endif
RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION _dfPrnOut( aBuf )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lPrint := .T., lWindow := .F.

#ifdef __XPP__
// Forse Š meglio lo san delle stampanti window
lWindow := dfIsWinPrinter(ALLTRIM(aBuf[REP_PRINTERARR][PRINTER_INFO]))
#endif

DO CASE
   CASE aBuf[REP_PRINTERPORT]=="VIDEO" .OR. aBuf[REP_IS_QUIT] // Video
        dfTView( 0, 0, MAXROW()-2, MAXCOL(), aBuf[REP_FNAME], aBuf[REP_NAME] )
        FERASE( aBuf[REP_FNAME] )

   CASE aBuf[REP_PRINTERPORT]=="FILE" // File

   CASE "LPT"$aBuf[REP_PRINTERPORT]   // Stampante
        IF aBuf[REP_SPOOLER] .AND. dfIsSpl() .AND. dfRealMode()
           WHILE aBuf[REP_COPY]-->0
              dfSplFile(aBuf[REP_FNAME])
           ENDDO
        ELSE
           WHILE aBuf[REP_COPY]-->0 .AND. lPrint
              #ifdef __XPP__
              IF lWindow
                 lPrint := dfFile2WPrn(aBuf[REP_FNAME], aBuf[REP_NAME] )
              ELSE
              #endif
                 lPrint := dfFile2Prn(aBuf[REP_FNAME], aBuf[REP_NAME], aBuf[REP_PRINTERPORT] )
              #ifdef __XPP__
              ENDIF
              #endif
           ENDDO
           IF lPrint  // Se la stampa e' andata a buon fine
              FERASE( aBuf[REP_FNAME] )
           ENDIF
        ENDIF

   CASE "COM"$aBuf[REP_PRINTERPORT]   // COM
        WHILE aBuf[REP_COPY]-->0 .AND. lPrint
           #ifdef __XPP__
           IF lWindow
              lPrint := dfFile2WPrn(aBuf[REP_FNAME], aBuf[REP_NAME], aBuf[REP_PRINTERID] )
           ELSE
           #endif
              lPrint := dfFile2Prn(aBuf[REP_FNAME], aBuf[REP_NAME], aBuf[REP_PRINTERPORT] )
           #ifdef __XPP__
           ENDIF
           #endif
        ENDDO
        IF lPrint  // Se la stampa e' andata a buon fine
           FERASE( aBuf[REP_FNAME] )
        ENDIF
ENDCASE

RETURN lPrint
