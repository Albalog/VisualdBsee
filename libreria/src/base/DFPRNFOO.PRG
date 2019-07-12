//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per STAMPE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "fileio.ch" // Struttura Report e Virtual record
#INCLUDE "dfReport.ch" // Struttura Report e Virtual record
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfPrnFOOTER( aBuf ) // Stampa il Footer di Pagina
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
aBuf[REP_IS_FOOTER] := .T.
   aBuf[REP_BAN_ROW] := aBuf[REP_ACT_ROW]

   // I buffer devo scaricarli solo se c'e' il flag di REP_NO_EJECT a .F.,
   // perche' altrimenti sono gia' scaricati
   IF !aBuf[REP_NO_EJECT]
      IF aBuf[REP_FLOATPF]
         dfPrintBuf( aBuf, 1 )
      ELSE
         dfPrintBuf( aBuf, aBuf[REP_FOOTER_LINE] -aBuf[REP_ACT_ROW] )
      ENDIF
   ENDIF
   dfPushBuffer()
   aBuf[REP_BAN_ROW] := aBuf[REP_ACT_ROW]
   IF aBuf[REP_IS_BANNER]
      IF aBuf[REP_BANNER_FORMAT] .AND. EVAL( aBuf[REP_CANPF] )
         dfPrintBand( aBuf[REP_PF] )
      ENDIF
   ELSE
      IF EVAL( aBuf[REP_CANPF] )
         dfPrintBand( aBuf[REP_PF] )
      ENDIF
   ENDIF
   dfFlushBuf( aBuf )
   IF !aBuf[REP_NO_PAGE_EJECT]
      dfPrint( aBuf[REP_ACT_ROW]- aBuf[REP_BAN_ROW] +1,0,NEWPAGE)  // flush Buffer .AND. Print NEWPAGE
   ENDIF
   aBuf[REP_IS_BANNER] := .F.
   dfPopBuffer()
   aBuf[REP_ACT_PAGE]++
   IF !aBuf[REP_ALLPAGE]
      DO CASE
         CASE aBuf[REP_FROMPAGE]>=aBuf[REP_ACT_PAGE]
              FSEEK( aBuf[REP_FHANDLE], LEN(dfPrnIni(aBuf)), FS_SET ) // Go top
             #ifdef __XPP__
              // Clear File
              FCLOSE( aBuf[REP_FHANDLE] )
              FCLOSE( FCREATE(aBuf[REP_FNAME]) )
              aBuf[REP_FHANDLE] := FOPEN( aBuf[REP_FNAME], FO_READWRITE )
             #else
              FWRITE( aBuf[REP_FHANDLE], "" )       // Clear File
             #endif
         CASE aBuf[REP_TOPAGE]<aBuf[REP_ACT_PAGE]
              aBuf[REP_IS_ABORT] := .T.             // Report Quit
              FWRITE( aBuf[REP_FHANDLE], dfPrnEnd( aBuf ) )
              FCLOSE( aBuf[REP_FHANDLE] )           // Close Handle
              aBuf[REP_FHANDLE] := FOPEN( aBuf[REP_FNAME], FO_READ )
              dfStaPos( aBuf ) // Go to the end of report
      ENDCASE
   ENDIF
   aBuf[REP_ACT_ROW] := 1                   // Fix Report Row
   aBuf[REP_ACT_COL] := 0                   // Fix Report Col
aBuf[REP_IS_FOOTER]  := .F.
RETURN
