//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per STAMPE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "dfReport.ch" // Struttura Report e Virtual record
#INCLUDE "dfCTRL.ch"   // Maschere di Data Entry
#INCLUDE "dfSet.ch"    // Settaggi d'ambiente
#INCLUDE "dfMsg.ch"    // Messaggistica
#INCLUDE "dfStd.ch"    // Standard

// simone 16/2/05
// abilita il log di ogni dfPrnStart
// normalmente disabilitato, serve in caso si debba
// effettuare il log delle chiamate magari per debug
// #define _LOG_PRINT_

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION _dfPrnStart( aVRec, nMode, bOut )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nFile, aBuf, nAbsPos := 0, cBuf, nPos
LOCAL xRet := .T.
LOCAL nStyle
LOCAL aAhead := {}

DEFAULT nMode TO PRINT_ALL

aBuf := dfPrnArr()

aBuf[REP_EMPTYREPORT] := .T.

// Filtri
dfPrnConfig( aBuf )

// File
aBuf[REP_FHANDLE] := FOPEN( aBuf[REP_FNAME], FO_READWRITE )

IF aBuf[REP_FHANDLE]<1
   dbMsgErr( dfStdMsg(MSG_DFPRNSTART01) +" " +ALLTRIM(aBuf[REP_FNAME]) )
   RETURN .F.// Da migliorare
ENDIF

// Riga di partenza del footer
aBuf[REP_FOOTER_LINE] := aBuf[REP_PAGELENGHT] -aBuf[REP_MGN_BOTTOM]

#ifdef _LOG_PRINT_
   _logMsg("I", "inizio stampa")
#endif

nStyle := dfSet(AI_XBASEPRINTPROGRESSSTYLE)

DO CASE
   CASE nStyle ==AI_PRINTPROGRESSSTYLE_FANCY
      dfPIOn(dfStdMsg(MSG_DFFILE2PRN02), aBuf[REP_NAME], .F., AI_PROGRESSSTYLE_FANCY)

   // Simone 06/10/08
   // mantis 0001977: velocizzare le stampe 
   CASE nStyle ==AI_PRINTPROGRESSSTYLE_FANCY_THREAD
      dfPIOn(dfStdMsg(MSG_DFFILE2PRN02), aBuf[REP_NAME], .T., AI_PROGRESSSTYLE_FANCY)

   OTHERWISE
      // Setup
      dbFrameOn( (MAXROW()/2)-4, 9, (MAXROW()/2)+3, 69, aBuf[REP_NAME] )
ENDCASE

// Simone 17/12/09
// imposta il read AHEAD su ADS per velocizzare il report
dfADSReadAheadSet(aAhead, "REPORT")

// Prima di Partire con la stampa controllo se esiste
// un allineamento tale da riuscire a stampare qualcosa
FOR nFile := 1 TO LEN(aVRec)
    DO CASE
       CASE nStyle ==AI_PRINTPROGRESSSTYLE_FANCY
//          dfPIUpdMsg(dfStdMsg(MSG_DFPRNSTART03) +" " +aVRec[nFile][VR_NAME])
       CASE nStyle ==AI_PRINTPROGRESSSTYLE_FANCY_THREAD

       OTHERWISE
          dbFrameDis( dfStdMsg(MSG_DFPRNSTART03) +" " +aVRec[nFile][VR_NAME] )
          dbFrameDis( "" )
          dbFrameDis( "" )
          dbFrameDis( "" )
          dbFrameDis( "" )
    ENDCASE

    // HO Qualcosa sul Master
    //IF (aVRec[nFile][VR_NAME])->(dfPrnCheck( aVRec[nFile], nMode ))

    IF aBuf[REP_EMPTYREPORT]                        // Inizializzo la stampa
       FWRITE( aBuf[REP_FHANDLE], dfPrnIni( aBuf ) )
    ENDIF
    dfPrnHEADER(aBuf)               // Header di Prima Pagina
    IF aBuf[REP_EMPTYREPORT]                        // Valuto i byte del file
       aBuf[REP_EMPTYREPORT] := .F.
       nAbsPos := dfStaPos( aBuf )
    ENDIF

    (aVRec[nFile][VR_NAME])->(SvilLev(aVRec[nFile],.T.,nMode)) // Stampa
    IF aBuf[REP_IS_ABORT]           // Se ho Abortito esco
       EXIT
    ENDIF

    //END
NEXT

// Simone 17/12/09
// toglie il read AHEAD su ADS
dfADSReadAheadDel(aAhead)

// NON ho stampato nulla e NON ho nulla in cache
IF nAbsPos==dfStaPos( aBuf ) .AND. !dfisPrnBuf()
   aBuf[REP_EMPTYREPORT] := .T.
ENDIF

IF !aBuf[REP_EMPTYREPORT]
   IF !aBuf[REP_IS_ABORT]
      dfReportFooter( aBuf )         // Report Footer
      dfFlushBuf( aBuf )             // Vuoto i buffer
      dfPrnFOOTER( aBuf )            // Footer di Ultima Pagina
      IF aBuf[REP_ITEMINPAGE]==0     // Tolgo le pagine vuote finali
         FSEEK( aBuf[REP_FHANDLE], aBuf[REP_POSINFILE]-1, FS_SET )
         IF FREADSTR( aBuf[REP_FHANDLE], 1 )!=NEWPAGE
            FWRITE( aBuf[REP_FHANDLE], NEWPAGE )
         ENDIF
         dfFileTrim( aBuf )
      ENDIF
      #ifdef __XPP__
      // Se XPP tolgo l'ultimo salto pagina SOLO sulle stampe windows
      // o sui preview, che utilizzano dei motori windows
      IF aBuf[REP_NO_LAST_EJECT]                                     .OR.;
         dfIsWinPrinter(ALLTRIM(aBuf[REP_PRINTERARR][PRINTER_INFO])) .OR.;
         aBuf[REP_PRINTERPORT]=="VIDEO"                              .OR.;
         aBuf[REP_IS_QUIT]
      #else
      IF aBuf[REP_NO_LAST_EJECT] // Tolgo l'ultimo salto pagina, fino al CRLF
      #endif
         FSEEK( aBuf[REP_FHANDLE], -1, FS_END )
         IF FREADSTR( aBuf[REP_FHANDLE], 1 )==NEWPAGE
            cBuf := SPACE(1024)
            FSEEK( aBuf[REP_FHANDLE], -1024, FS_END )
            FREAD( aBuf[REP_FHANDLE], @cBuf, 1024 )
            nPos := RAT( CRLF, cBuf )
            IF nPos==0; nPos := 1024; ENDIF
            FSEEK( aBuf[REP_FHANDLE], -(1025-nPos), FS_END )
            dfFileTrim( aBuf )
         ENDIF
      ENDIF
   ENDIF
   FWRITE( aBuf[REP_FHANDLE], dfPrnEnd( aBuf ) )
ENDIF

DO CASE
   CASE nStyle ==AI_PRINTPROGRESSSTYLE_FANCY
      dfPIOff()

   CASE nStyle ==AI_PRINTPROGRESSSTYLE_FANCY_THREAD
      dfPIOff()

   OTHERWISE
      dbFrameOff()
ENDCASE

FCLOSE( aBuf[REP_FHANDLE] )                       // Close Handle

#ifdef _LOG_PRINT_
   _logMsg("O", "fine stampa")
#endif

IF !aBuf[REP_EMPTYREPORT]
   IF bOut == NIL
      // Routine standard di stampa
      dfPrnOut( aBuf )
   ELSE
      //EVAL(bOut, aBuf)
      EVAL(bOut, aBuf, .T.)
   ENDIF
ELSE
#ifdef __XPP__
   IF bOut == NIL
      // Routine standard di stampa
      IF dfSet( AI_XBASEPRNMENUNEW)
         _dfXPrnClose(aBuf)
      ENDIF
   ELSE
      EVAL(bOut, aBuf, .F.)
   ENDIF
#endif
   FERASE( aBuf[REP_FNAME] )
   IF !dfSet( AI_DISABLENOTHINGTOPRINT )
      #ifdef __XPP__
      dfAlert( dfStdMsg(MSG_DFPRNSTART31) )
      #else
      dbMsgErr( dfStdMsg(MSG_DFPRNSTART31) )
      #endif
   ENDIF
ENDIF

DEFAULT aBuf[REP_QRY_EXP] TO ""

RETURN !aBuf[REP_IS_ABORT]

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfStaPos( aBuf )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN FSEEK( aBuf[REP_FHANDLE], 0, FS_END ) // Byte della stampa

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfFileTrim( aBuf )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
#ifdef __XPP__
// Creo un file temporaneo
LOCAL cDmm, nSize
LOCAL nHandle := dfFileTemp( @cDmm )
FCLOSE( nHandle )

// Prendo il size e chiudo il file
nSize := FSEEK( aBuf[REP_FHANDLE], 0, FS_RELATIVE )
FCLOSE( aBuf[REP_FHANDLE] )

// Copio l'attuale nel nuovo
dfFileCopy( aBuf[REP_FNAME], cDmm, nSize )

// Ricopio nel vecchio
dfFileCopy( cDmm, aBuf[REP_FNAME], nSize )

// Pulisco
FERASE( cDmm )
//Mantis 2180
//////////////////////////////////////////////////////////
dfXbaseExitProcAdd( dfExecuteActionDelFile():new(cDmm))
//////////////////////////////////////////////////////////

// Riapro
aBuf[REP_FHANDLE] := FOPEN( aBuf[REP_FNAME], FO_READWRITE )

// Vado alla fine
FSEEK( aBuf[REP_FHANDLE], 0, FS_END )
#else
FWRITE( aBuf[REP_FHANDLE], "" )
#endif
RETURN

#ifdef __XPP__
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfFileCopy( cFrom, cTo, nByte )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nHandleFrom := FOPEN( cFrom )
LOCAL nHandleTo   := FCREATE( cTo )
LOCAL cBuff   := SPACE( 4000 )
LOCAL nReaded := 0
LOCAL nTot    := 0

DEFAULT nByte TO dfFileSize( nHandleFrom )

WHILE (nReaded:=FREAD( nHandleFrom, @cBuff, 4000 ))>0
   nTot += nReaded
   IF nTot>nByte
      nReaded -= (nTot-nByte)
      IF nReaded>0
         FWRITE( nHandleTo, cBuff, nReaded )
      ENDIF
      EXIT
   ELSE
      FWRITE( nHandleTo, cBuff, nReaded )
   ENDIF
ENDDO

FCLOSE(nHandleFrom)
FCLOSE(nHandleTo  )

RETURN
#endif

#ifdef _LOG_PRINT_
static func _logMsg(cMode, x)
   IF ! EMPTY( dfDllCallSetLog() )

      // log
      EVAL( dfDllCallSetLog(), cMode, "dfPrnstart", "dfPrnExe", x)
   ENDIF
RETURN nil
#endif