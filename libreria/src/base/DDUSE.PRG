//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per FILE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
#include "dfMsg.CH"
#include "dfset.ch"
#include "dfStd.ch"
#include "error.ch"
#include "dfAdsDbe.ch"

// simone 16/2/05
// abilita il log di ogni dduse
// normalmente disabilitato, serve in caso si debba
// effettuare il log delle chiamate magari per debug
// #define _LOG_OPEN_

// simone 26/3/08
// mantis 0001786: supporto dizionario dati ADS
// abilita gestione dizionario dati ADS
//#define _ENABLE_ADS_DD_

// simone 20/11/09 
// gestione multithread per ora disabilitato
//#define _MULTITHREAD_

#ifdef _ENABLE_ADS_DD_
  STATIC cADSDDAutoFile
#endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddUse( cFName ,; // Nome del file da aprire
                cAlias ,; // Alias
                nNdx   ,; // Numero di indice da aprire
                cMode  ,; // Modalita' d'apertura
                cRDD    ) // RDD da—sare
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aNdx := {}, cFNdx, cPath, cVarName, nNdxNum, cDriver, lRet, cDate, cTime
LOCAL oSession := NIL, cConnID
LOCAL lOpenNdx := .T.

DEFAULT cAlias TO ""
DEFAULT nNdx   TO 1

// simone 27/11/08 possibilit… di NON aprire gli indici
// passando .F. come numero indice da aprire
IF VALTYPE(nNdx) == "L" 
   lOpenNdx := nNdx
   nNdx := 0
ENDIF

cFName := UPPER(PADR(cFName,8))
cFNdx  := cFName
IF EMPTY(cAlias)                 // Alias
   cAlias := cFNdx
ENDIF
nNdx   := MAX( nNdx, 0 )

// in questo momento ho caricato il NOME e l'ALIAS
IF DFISSELECT( cAlias )               // Se il file e' aperto
   SELECT ( cAlias )                  // viene selezionato
   SET ORDER TO nNdx                  // messo sull'indice passato
   RETURN .T.
ENDIF

IF !dbCfgOpen( "dbDD" )         // Apro il dizionario
   RETURN .F.
ENDIF

IF !ddFilePos( cFname )         // Posiziono il file
   RETURN .F.
ENDIF

IF ddFileIsTab()
   RETURN .F.
ENDIF

IF EMPTY(cFName := ddFileName()) // File name
   RETURN .F.
ENDIF

DEFAULT cMode TO dbdd->File_Mode // Modalita apertura file

IF cRDD!=NIL
   cDriver := cRDD                  // Driver
ELSE
   cDriver := ddFileDriver()        // Driver
ENDIF

cPath   := ddFilePath()          // Path del file.

#ifdef _MULTITHREAD_
IF VALTYPE(dfSet("XbaseMT_ddUse"))=="B"
   EVAL(dfSet("XbaseMT_ddUse"), 0, @cFName, @cMode, @cDriver, @cPath)
ENDIF
#endif


/////////////////////////////////////////////////////////////////////////////////////////////////////
////Mantis 953
IF dfSet("XbaseUserPathChk") != "NO" .AND. !dfRDDFile(cPath +cFName +dfDbfExt( cDriver ), cDriver)
   dbMsgErr( dfStdMsg(MSG_DDUSE01) +"//"+ cPath +cFName +dfDbfExt( cDriver ))
   RETURN .F.
ENDIF
///////////////////////////////////////////////////////////////////////////////////////////////////////

#ifdef _ENABLE_ADS_DD_

// prendo l'ID di connessione DAC della tabella corrente
cConnID := ddFileDACConnID()
IF ! EMPTY(cConnID)
   IF ! dfDACConnIDRegistered(cConnID)

      // Apertura del file 
      // definito il settaggio per nome file dizionario dati automatico?
      IF cADSDDAutoFile == NIL
         cADSDDAutoFile := dfSet("XbaseADSDDAutoFile")
         IF EMPTY(cADSDDAutoFile)
            cADSDDAutoFile := ""
         ELSE
            // metto estensione .ADD
            cADSDDAutoFile := dfFNameBuild(cADSDDAutoFile, "", "."+ADSRDD_EXT_ADD)
         ENDIF
      ENDIF

      IF ! EMPTY(cADSDDAutoFile) .AND. FILE(cPath+cADSDDAutoFile)
         oSession := dfDACConnStringGet(cPath+cADSDDAutoFile)
         IF EMPTY(oSession)
            cConnID := NIL // non carico dizionario dati
         ELSE
            dfDACConnIDRegister( cConnID , oSession)
         ENDIF
         oSession := NIL
      ELSE
         cConnID := NIL // non carico dizionario dati
      ENDIF
   ENDIF

   IF ! EMPTY(cConnID)
      // se Š registrato fra le connessioni DAC prendo o creo la connessione
      // per il thread corrente
      oSession := dfDACConnIDGetSession(cConnID, .T., .T.)
   ENDIF
ENDIF

#endif


DO CASE
   CASE cMode $ [ -0]             // FLOAT
        IF !dfSet(AI_NET)         // se la rete non e' attiva
           cMode := USE_EXCLUSIVE // aperti in EXCLUSIVE
        ELSE                      // altrimenti
           cMode := USE_SHARED    // aperti in SHARED
        ENDIF
   CASE cMode == USE_EXCLUSIVE
   CASE cMode == USE_SHARED
   OTHERWISE
        dbMsgErr( dfStdMsg(MSG_DDUSE04) )
        RETURN .F.
ENDCASE

dbdd->(dbSeek( "NDX"+cFNdx ))
nNdxNum := 0
IF lOpenNdx
WHILE UPPER(dbdd->RecTyp +dbdd->file_name) = "NDX"+cFNdx .AND. ;
      nNdxNum <= 15                                      .AND. ;
      !dbdd->(EOF())

   nNdxNum++

   IF LEFT(dbdd->FILE_ALI,1) == "@"               // nome file variabile
      cVarName := SUBSTR(dbdd->file_ali,2)        // lo prendo
      IF TYPE( cVarName ) # "C"
         dbMsgErr( dfStdMsg(MSG_DDUSE05) +cFNdx    +"//"+;
                   dfStdMsg(MSG_DDUSE03) +cVarName       )
         RETURN .F.
      ENDIF
      aAdd(aNdx,UPPER(&cVarName))                 // Aggiungo all'array
   ELSE                                           // il nome dell'indice
      aAdd(aNdx,TRIM(dbdd->FILE_ALI))
   ENDIF
   dbdd->(dbskip())

ENDDO
ENDIF

cDate := DATE()
cTime := TIME()

lRet := dbfopen(cPath,cFName,cAlias,nNdx,cMode,aNdx,cDriver, oSession)

IF dfSET( AI_OPENFILECB )!=NIL
   EVAL( dfSET( AI_OPENFILECB ), cAlias, cDate, cTime, DATE(), TIME() )
ENDIF

#ifdef _MULTITHREAD_
IF VALTYPE(dfSet("XbaseMT_ddUse"))=="B"
   EVAL(dfSet("XbaseMT_ddUse"), 100, @cFName, @cMode, @cDriver, @cPath)
ENDIF
#endif

RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dbfopen( cPath   ,;
                         cFName  ,;
                         cAlias  ,;
                         nNdxNum ,;
                         cMode   ,;
                         aNdx    ,;
                         cDriver ,;
                         oSession )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nSecond   := 0
LOCAL lRet      := .T.
LOCAL lActive   := .F.
LOCAL nStartSec := SECONDS()
LOCAL nTimeOut, nStart, lOldDeleted
LOCAL cIndexName

LOCAL bErr, oIdxErr, oOpenErr
LOCAL nPrev
LOCAL cMessage
LOCAL lOpen := .F.

IF dfSet( AI_DBTMAXSIZE )>0
   IF dfFileSize( cPath +cFName +".DBT" )>dfSet( AI_DBTMAXSIZE )
      dbMsgErr( cPath +cFName +".DBT" +" over max size " +ALLTRIM(STR(dfSet( AI_DBTMAXSIZE )) ))
      RETURN .F. 
   ENDIF
ENDIF

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³CONTROLLO TIMEOUT ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IF EMPTY( nTimeOut := dfSet(AI_LOCKREPEATTIME) ) // SE 0 DEFAULT a 5
   nTimeOut := 5
ENDIF

//
// Per velocizzare le operazioni
// apro il file ignorando i deleted, in modo che CLIPPER
// non vada a cercare il primo record vuoto
//
IF !dfSet( AI_DISABLEUSEMESSAGE )
   dfUsrMsg( dfStdMsg(MSG_DDUSE02) +" " +cPath +cFName )
ENDIF
lOldDeleted := SET( _SET_DELETED, .F. )

///////////////////////////////////////////////////////////////////////////////////////////////////////
////Mantis 953
nPrev := SELECT()

bErr := ERRORBLOCK()

  DO WHILE .T.
  #ifdef _LOG_OPEN_
     _logMsg("0", "Apertura "+cPath +cFName+" alias: "+cAlias+" mode: "+cMode+" driver: "+cDriver, .T.)
  #endif

   oOpenErr := NIL
   ERRORBLOCK( {|e| oOpenErr := e, dfErrBreak(e, "//", .T.)} )
   BEGIN SEQUENCE
      IF EMPTY(oSession)
         lOpen := dfUseFile( cPath +cFName, cAlias, cMode!=USE_SHARED, cDriver )
      ELSE
         // apertura da connessione DAC (es DIZ.DATI ADS)
         lOpen := dfUseFile( cFName, cAlias, cMode!=USE_SHARED, oSession )
      ENDIF
   END SEQUENCE
   ERRORBLOCK(bErr)

   IF ! lOpen

        IF !lActive
           dfPIOn( dfStdMsg(MSG_DDUSE07), dfStdMsg(MSG_DDUSE08) +"//" +;
                                          cFName                +"//" +;
                                          dfStdMsg(MSG_DDUSE09)       +;
                                          STR(nTimeOut) )
           lActive := .T.
        ELSE
           IF !dfPIStep( nSecond, nTimeout )
              nStartSec := SECONDS() -nTimeout
           ENDIF
        ENDIF

        IF nTimeout == 0                      // Tentativi infiniti sino al
           LOOP                               // successo dell'operazione
        ENDIF

        nSecond := SECONDS() -nStartSec       // Incrementa i secondi
        IF nSecond >= nTimeout                // Se si raggiunge il valore di
           dfPIOff()
           lRet := .F.
           EXIT                               // TimeOut sospende l'operazione
        ENDIF

     ELSE
        IF lActive
           dfPIOff()
        ENDIF

      ERRORBLOCK( {|e| dfErrBreak(e, "//", .T.)} )
      BEGIN SEQUENCE
         IF oSession == NIL

            // Simone 20/11/09
            // correzione per utilizzo CDX
            // se il driver sul DBDD="DBFNTX" ma apro con ADS configurato per i CDX
            // allora non funziona il controllo se il file esiste perchè 
            // controlla estensione NTX invece di CDX
            cDriver := (cAlias)->(RDDNAME()) // imposto il DRIVER utilizzato realmente

        IF !dfRddCanCompound( cDriver )
           IF cDriver!="RQBRDD" .AND. !dfAsDriver( cDriver )
  #ifdef _LOG_OPEN_
              _logMsg("1", "  prima ORDLISTCLEAR", .T.)
  #endif
              ORDLISTCLEAR()                          // CLEAR INDEX
              FOR nStart := 1 TO LEN(aNdx)
                 cIndexName := cPath +aNdx[nStart]
                 IF dfRddFile( cIndexName +dfIndExt(cDriver), cDriver )
  #ifdef _LOG_OPEN_
                    _logMsg("2", "     prima ADD: "+cIndexName+dfIndExt(cDriver), .T.)
  #endif
                    ORDLISTADD( cIndexName )
                 ELSE
                    CLOSE
                    lRet := .F.
                    dbMsgErr( dfStdMsg(MSG_DDUSE10) +"//" +cIndexName +dfIndExt(cDriver) )
                        break(NIL) //EXIT
                 ENDIF
              NEXT
           ENDIF
           IF dfAsDriver( cDriver )
              FOR nStart := 1 TO LEN(aNdx)
                  ORDLISTADD( cPath +aNdx[nStart] )
              NEXT
           ENDIF
        ELSE
           IF LEN(aNdx)>0
              cIndexName := cPath +cFName
              IF dfRddFile( cIndexName +dfIndExt(cDriver), cDriver )
                 ORDLISTADD( cIndexName )
              ELSE
                 CLOSE
                 lRet := .F.
                 dbMsgErr( dfStdMsg(MSG_DDUSE10) +"//" +cIndexName +dfIndExt(cDriver) )
                     break(NIL) //EXIT
                  ENDIF
              ENDIF
           ENDIF
        ENDIF

        IF lRet .AND. LEN(aNdx)>=nNdxNum
  #ifdef _LOG_OPEN_
           _logMsg("3", " prima setorder to "+dfAny2Str(nNdxNum), .T.)
  #endif
           SET ORDER TO nNdxNum
        ENDIF
      RECOVER USING oIdxErr

      END SEQUENCE
      ERRORBLOCK(bErr)
        EXIT
     ENDIF
  ENDDO

// assicuro che sia attiva gestione errori precedente
ERRORBLOCK(bErr)
// se non aperto e ho avuto errore in apertura e non ho errore su indici
IF ! lOpen .AND. oOpenErr != NIL .AND. oIdxErr == NIL
   lRet     := .F.
   IF !dfSet("XbaseDisableErrorMsgddUse")=="YES"
      cMessage := VDBErrorMessage(oOpenErr, "//", .T., .T.)
      IF oOpenErr:osCode == 32 // errore di condivisione
         dbMsgErr(dfMsgTran(dfStdMsg(MSG_DDUSE11), "file="+cFName))
      ELSE
         dbMsgErr( dfStdMsg(MSG_DDUSE07) +"//"+ cPath +cFName +dfDbfExt( cDriver )+"// //"+cMessage )
      ENDIF
   ENDIF
ENDIF
IF oIdxErr != NIL
   lRet     := .F.

   /////////////////////////////////////////////////////////////////////////////////////////////////////
   ////Mantis 1226
   IF !dfSet("XbaseDisableErrorMsgddUse")=="YES"
      cMessage := VDBErrorMessage(oIdxErr, "//", .T., .T.)
      dbMsgErr( dfStdMsg(MSG_DDUSE07) +"//"+ cPath +cFName +dfDbfExt( cDriver )+"// //"+cMessage )
   ENDIF
   /////////////////////////////////////////////////////////////////////////////////////////////////////
ENDIF

IF lOpen .AND. ! lRet
   // simone 5/12/07
   // mantis 0001686: su errore in apertura indice tabella, la tabella rimane aperta
   // se l'errore Š in apertura degli indici la tabella rimane aperta!
   // invece va chiusa
   IF DFISSELECT(cAlias)
      (cAlias)->(DBCLOSEAREA())
   ENDIF
   DBSELECTAREA(nPrev)
ENDIF

//
// Reimposto i deleted come in partenza
//
SET( _SET_DELETED, lOldDeleted )

IF lRet
   DBGOTOP()
   dfCngAlias( cAlias, cFName )
ENDIF

IF !dfSet( AI_DISABLEUSEMESSAGE )
   dfUsrMsg()
ENDIF

RETURN lRet


#ifdef _LOG_OPEN_
static func _logMsg(c, x)
   IF ! EMPTY( dfDllCallSetLog() )
      // log
      EVAL( dfDllCallSetLog(), c, "dduse", "dduseexe", x)
   ENDIF
RETURN nil
#endif

#ifdef _ENABLE_ADS_DD_
FUNCTION dfADSDDAutoFileSet(x)
   LOCAL cRet := cADSDDAutoFile

   IF x == NIL .OR. VALTYPE(x) $ "CM"
      cADSDDAutoFile := x
   ENDIF
RETURN cRet
#endif



