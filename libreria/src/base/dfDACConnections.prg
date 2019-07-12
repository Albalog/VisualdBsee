#include "common.ch"
#include "fileio.ch"
#include "dfStd.ch"
#include "dfAdsDbe.ch"

#define CONN_ID        1
#define CONN_STRING    2
#define CONN_SESSIONS  3

/*

   Simone 26/3/08
   Gestione dizionario dati ADS
   L'idea Š quella di poter mettere in dbstart.ini
     UserPathXX=stringa di connessione
   oppure
     UserPathXX=percorso dizionario dati ADS
  Esempio
     UserPath01=DBE=ADSDBE;SERVER=c:\dati\pippo.add
     UserPath02=DBE=c:\dati\pluto.add

  In questo caso nella ddUse() quando apre le tabelle su path 1 o 2
  dovrebbe connettersi al dizionario dati corretto e non aprire gli
  indici (perchŠ con ADS si aprono automaticamente)

  Per maggiore compatibilit… poi nell'array dei path dovrebbe salvarsi
  il percorso del dizionario dati (cioŠ c:\dati) in modo che il nome del file
  si possa creare con dbDbfPath(1)+"pippo.dbf" -> c:\dati\pippo.dbf

  Questo comporta che i files .dbf e .ntx si devono trovare nella stessa
  cartella del dizionario dati.

*/

// Array di ID, stringhe connessione, sessioni di connessione
// es.
// { { "USERPATH01", "DBE=ADSDBE;SERVER=c:\pippo.add", { {1,DACSession()}} },;
//   { "USERPATH11", "DBE=ADSDBE;SERVER=c:\pluto.add", { {1,DACSession()},
//                                                       {3,DACSession()}} } }

STATIC aConn:={}

// array user/pwd per connessione
STATIC aAuth := { {0, "", ""} }
//STATIC aAuth := { {0, "ADSSYS", ""} }

// Torna l'ID di connessione per un path "n"
// es. dfDACConnIDBuild(12) -> "USERPATH12"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDACConnIDBuild(x)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL nPath

   IF VALTYPE(x) == "N"
      nPath := x
   ELSEIF dfIsDigit(x)
      nPath := VAL(x)
   ELSE
      RETURN NIL
   ENDIF
RETURN "USERPATH"+PADL( ALLTRIM(STR(nPath)) ,2,"0" )

// Torna l'ID di connessione per un path "n"
// es. dfDACConnIsID("USERPATH12") -> .T.
// es. dfDACConnIsID("DBDDPATH") -> .F.

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDACConnIsID(x)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN UPPER(LEFT(x, 8))=="USERPATH"

// Torna una connessione per un file in base al suo path
// es.
// - dfDACConnIDRegister("USERPATH02", "DBE=ADSDBE;SERVER=c:\pippo\ads.add")
//
// - cFile := "c:\pippo\test.dbf"
//   cDriver := "DBFNTX"
//   dfDACConnADSDDSession(@cFile, @cDriver) -> .T. (cFile="TEST.DBF", cDriver=DACSession())
//
// - cFile := "c:\pluto\test.dbf"
//   cDriver := "DBFNTX"
//   dfDACConnADSDDSession(@cFile, @cDriver) -> .F. (cFile e cDriver rimangono invariati)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDACConnADSDDSession(cFName, cDriver)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL cPath
   LOCAL aConn

   cPath := dfFNameSplit(cFname, 1+2) // path del file
   aConn := dfDACConnFindADSDD(cPath)
   IF EMPTY(aConn)
      RETURN .F.
   ENDIF
   cFName  := dfFNamesplit(cFName, 4+8) // tolgo path del file
   cDriver := dfDACConnIDGetSession(aConn[1][CONN_ID]) // connessione
RETURN .T.

// esegue un codeblock su tutte le stringhe di connessione
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDACConnEval(bEval)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN AEVAL(aConn, bEval)

// trova tutte le connessioni ADS su dizionario dati ADS in un certo PATH
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDACConnFindADSDD(cPath)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL aRet := {}
   dfDACConnEval( {|x| _addADSDD(x, cPath, aRet)} )
RETURN aRet

STATIC FUNCTION _addADSDD(aCS, cPath, aRet)
   LOCAL cFile

   cFile := _GetADSServer(aCS[CONN_STRING])

   IF EMPTY(cFile)
      RETURN .T.
   ENDIF

   // Š un dizionario dati?
   IF ! UPPER(dfFNameSplit(cFile, 8)) == "."+UPPER(ADSRDD_EXT_ADD)
      RETURN .T.
   ENDIF

   cPath := UPPER(dfFNameBuild(dfFNameSplit(cFile, 4+8), cPath))

   cFile := UPPER(dfFNameBuild(cFile))

   IF ! cPath == cFile
      RETURN .T.
   ENDIF

   AADD(aRet, aCS)
RETURN .T.

STATIC FUNCTION _getADSServer(cConn)
   LOCAL cFile, aConn, n

   // Š una connessione ADS?
   IF ! "DBE=ADSDBE" $ UPPER(cConn)
      RETURN NIL
   ENDIF

   aConn := dfStr2Arr(cConn, ";")
   FOR n := 1 TO LEN(aConn)
      IF "=" $ aConn[n] .AND. ;
         UPPER(ALLTRIM(dfLeft(aConn[n])))=="SERVER"
         cFile := ALLTRIM(dfRight(aConn[n]))
         EXIT
      ENDIF
   NEXT

/*
   n := ASCAN(aConn, {|x| LEFT(UPPER(ALLTRIM(x)),7) == "SERVER=" })
   IF n == 0
      RETURN NIL
   ENDIF

   cFile := ALLTRIM(SUBSTR(aConn[n], 8))
*/
RETURN cFile


// decodifica una stringa di connessione
// by reference in cNew torna il path del dizionario dati
// es.
//
//  cPath := "c:\pippo\" // percorso standard
//  dfDACConnStringGet(@cPath) -> NIL (cPath non cambia)
//
//  cPath := "c:\pippo.add"
//  dfDACConnStringGet(@cPath) -> "DBE=ADSDBE;SERVER=c:\pippo.add" (cPath -> "C:\")
//
//  cPath := "DBE=ADSDBE;SERVER=c:\test\pluto.add"
//  dfDACConnStringGet(@cPath) -> "DBE=ADSDBE;SERVER=c:\test\pluto.add" (cPath -> "C:\test\")
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDACConnStringGet(cNew)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL cConn := NIL
   LOCAL cFile

   IF EMPTY(cNew)
      // non faccio niente

   ELSEIF LEFT(UPPER(ALLTRIM(cNew)), 4) == "DBE="
      DO WHILE RIGHT(cNew,1) == "\"
         cNew := LEFT(cNew,LEN(cNew)-1)
      ENDDO
      cConn := cNew
      cFile := _GetADSServer(cConn)

      // Š un dizionario dati?
      IF ! EMPTY(cFile) .AND. ;
         UPPER(dfFNameSplit(cFile, 8)) == "."+UPPER(ADSRDD_EXT_ADD)
         cNew := dfPathChk(dfFNameSplit(cFile, 1+2)) // by reference ritorna percorso del file .ADD
      ENDIF

   ELSEIF "."+UPPER(ADSRDD_EXT_ADD) $ UPPER(cNew)
      cFile := cNew
      DO WHILE RIGHT(cFile,1) == "\"
         cFile := LEFT(cFile,LEN(cFile)-1)
      ENDDO

      IF UPPER(dfFNameSplit(cFile, 8)) == "."+UPPER(ADSRDD_EXT_ADD)  // connessione dizionario dati ADS?
         cConn := "DBE=ADSDBE;SERVER="+cFile+";UID=%user%;PWD=%pwd%"
         cNew  := dfPathChk(dfFNameSplit(cFile, 1+2)) // by reference ritorna percorso del file .ADD
      ENDIF
   ENDIF
RETURN cConn

// controlla se un certo ID (es "USERPATH01") Š registrato
// (quindi deve essere aperto tramite una sessione)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDACConnIDRegistered(cID)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN  _ConnStringFind(cID) != NIL

// Registra un certo ID (es "USERPATH01") con una stringa di connessione
// es. dfDACConnIDRegister("USERPATH03", "DBE=ADSDBE;SERVER=c:\test\pluto.add")
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDACConnIDRegister(cID, cConn)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL nPos
   LOCAL aReg
   LOCAL cFind

   cFind := cID

   aReg := _ConnStringFind(@cFind)
   IF aReg != NIL
      RETURN 1 // gi… registrato
   ENDIF

   AADD(aConn, { UPPER(ALLTRIM(cFind)), cConn, {} })
RETURN 0 // OK

// Deregistra un certo ID (es "USERPATH01")
// es. dfDACConnIDUnregister("USERPATH03")
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDACConnIDUnregister(cID)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL nPos
   LOCAL aReg
   LOCAL oSession
   LOCAL oDefault

   aReg := _ConnStringFind(cID, @nPos)

   IF EMPTY(aReg)
      RETURN .F.
   ENDIF

   // non posso disconnettere tutti.. se Š su pi— thread?
   //AEVAL(aReg[3], {|o| IIF(o:isConnected(), o:disconnect(), NIL)})
   oSession := _SetSession(aReg[CONN_SESSIONS])
   IF oSession != NIL .AND. oSession:isConnected()
      oDefault := DACSession():getDefault()

      oSession:disconnect()

      // Simone 26/10/09
      // assicuro di imposta la sessione di default 
      // (oDefault dovrebbe corrispondere con oOld)
      IF DACSession():getDefault() != oDefault .AND. oDefault != oSession
         oDefault:setDefault(.T.)
      ENDIF
   ENDIF

   AREMOVE(aConn, nPos)
RETURN .T.

// torna una connessione DAC (vedi documentazione DACSession)
// per una certo ID (es. "USERPATH01")
// lConnect = .T. se la connessione non Š creata la crea
// lMsg=.T. mostra messaggi di errore
// Es. dfDACConnIDGetSession("USERPATH01", .T., .T.)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDACConnIDGetSession(cID, lConnect, lMsg)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL aReg
   LOCAL oSession

   DEFAULT lConnect TO .T.
   DEFAULT lMsg     TO .T.

   aReg := _ConnStringFind(cID)
   IF EMPTY(aReg)
      IF lMsg
         dbMsgErr(dfMsgTran("Connection id %id% not registered.", "id="+cID))
      ENDIF
      RETURN NIL
   ENDIF

   oSession := _SetSession(aReg[CONN_SESSIONS])

   IF oSession != NIL .OR. ! lConnect
      RETURN oSession
   ENDIF

   oSession := _CreateSession(aReg[CONN_STRING], lMsg) // creo connessione

   IF oSession == NIL // errore
      RETURN NIL
   ENDIF

   _SetSession(aReg[CONN_SESSIONS], oSession) // la salvo per futuri usi
RETURN oSession

STATIC FUNCTION _ConnStringFind(cID, nPos)
   LOCAL cConn

   cConn := UPPER(ALLTRIM(cID))

   nPos := ASCAN(aConn, {|x| x[CONN_ID]==cConn })
   IF nPos == 0
      RETURN NIL
   ENDIF
RETURN aConn[nPos]

// Ritorna la sessione
STATIC FUNCTION _SetSession(aSessions, oNew)
   LOCAL nThread := ThreadID()  // La connessione Š THREAD-LOCAL
   LOCAL nPos
   LOCAL oOld
   LOCAL oDefault

   nPos := ASCAN(aSessions, {|x| x[1]==nThread })
   IF nPos > 0

      oOld := aSessions[nPos][2]

      IF nThread > 1 .AND. ! _FilesOpen()
         oDefault := DACSession():getDefault()

         // Se non sono nel thread principale e non ho files aperti
         // effettuo sconnessione e
         // riconnessione perchŠ se nel frattempo il thread Š terminato
         // e riiniziato utilizzo una connessione che non Š pi— valida
         // e ho un runtime error sulla DBUSEAREA()
         oOld:disconnect()
         oOld:connect()

         // Simone 26/10/09
         // assicuro di imposta la sessione di default 
         // (oDefault dovrebbe corrispondere con oOld)
         IF DACSession():getDefault() != oDefault 
            oDefault:setDefault(.T.)
         ENDIF
      ENDIF

      IF oNew != NIL .AND. oNew:isConnected()
         aSessions[nPos][2] := oNew
      ENDIF
   ELSE
      oOld := NIL
      IF oNew != NIL .AND. oNew:isConnected()
         AADD(aSessions, {nThread,oNew})
      ENDIF
   ENDIF
RETURN oOld

// Controlla se c'è un file aperto in una workarea
// per maggiore velocità controlla solo 20 workarea
// invece che tutte
STATIC FUNCTION _FilesOpen()
   LOCAL lRet := .F.
   LOCAL n

   FOR n := 1 TO 20
      IF ! EMPTY( ALIAS(n) )
         lRet := .T.
         EXIT
      ENDIF
   NEXT
RETURN lRet

STATIC FUNCTION _CreateSession(cConn, lMsg)
   LOCAL nRet  := 0
   LOCAL oConn
   LOCAL oOld
   LOCAL cConn1, n, cID
/*
   LOCAL nType
   IF oConn:isConnected()

      nType := oConn:setProperty(ADSDBE_SERVER_TYPE)
      IF nType == ADSDBE_LOCAL
         nRet := 2     // Advantage Local server
      ELSE
         nRet := 1     // Advantage Database server (NT o NETWARE)
      ENDIF
      oConn:disconnect()

   ENDIF
*/

   oOld := DACSession():getDefault()

   cConn1 := cConn

   // conversione stringhe "%user1%" con dati di autenticazione
   IF "%user" $ cConn1 .OR. "%pwd" $ cConn1
      FOR n := 1 TO LEN(aAuth)

          IF aAuth[n][1] == 0
             cConn1 := STRTRAN(cConn1, "%user%", aAuth[n][2])
             cConn1 := STRTRAN(cConn1, "%pwd%", aAuth[n][3])
          ENDIF

          cID := ALLTRIM(STR(aAuth[n][1]))
          cConn1 := STRTRAN(cConn1, "%user"+cID+"%", aAuth[n][2])
          cConn1 := STRTRAN(cConn1, "%pwd"+cID+"%", aAuth[n][3])
      NEXT
   ENDIF

   oConn := DacSession():new(cConn1)

   // questa connessione NON deve essere quella di default della workarea
   // altrimenti di default posso aprire solo le tabelle definite nel dizionario dati
   oConn:setDefault(.F.)

   LogConnection(cConn, oConn, nRet)

   IF ! oConn:isConnected()
      IF lMsg
         dbMsgErr("Error connecting to the server.//"+;
                  "Connection string: "+cConn+"//"+;
                  "Error: "+dfAny2Str(oConn:getLastError())+" - "+dfAny2Str(oConn:getLastMessage()) )
      ENDIF
      oConn := NIL
   ENDIF

   IF ! EMPTY(oOld)
      oOld:setDefault(.T.)
   ENDIF
RETURN oConn

STATIC FUNCTION LogConnection(cServ, oConn, nRet)
   LOCAL nH, cF, cStr
   cF := dfSet("XbaseADSLogConnectionFile")
   IF cF != NIL
      nH := IIF(FILE(cF), FOPEN(cF, FO_WRITE), FCREATE(cF))
      IF nH > 0
         FSEEK(nH,0,FS_END)
         cStr := DTOS(DATE())+" "+TIME()+" Thread: "+dfAny2Str(ThreadID())+" Server: "+cServ+" Type: "+STR(nRet,3)+;
                 " error: "+dfAny2Str(oConn:getLastError())+" "+dfAny2Str(oConn:getLastMessage())
         FWRITE(nH, cStr+CRLF)
         FCLOSE(nH)
      ENDIF
   ENDIF
RETURN NIL

FUNCTION dfDACConnAuthSet(cUser, cPwd, nID)
   LOCAL nPos

   DEFAULT nID TO 0

   nPos := ASCAN(aAuth, {|x|x[1]==nID})

   IF nPos == 0
      DEFAULT cUser TO "ADSSYS"
      DEFAULT cPwd  TO ""
      AADD(aAuth, {nID, cUser, cPwd})
   ELSE
      IF cUser != NIL
         aAuth[nPos][2] := cUser
      ENDIF
      IF cPwd != NIL
         aAuth[nPos][3] := cPwd
      ENDIF
   ENDIF
RETURN .T.

FUNCTION dfDACConnAuthGet(nID)
   LOCAL nPos

   DEFAULT nID TO 0

   nPos := ASCAN(aAuth, {|x|x[1]==nID})

   IF nPos == 0
      RETURN NIL
   ENDIF
RETURN {aAuth[nPos][2], aAuth[nPos][3]}
