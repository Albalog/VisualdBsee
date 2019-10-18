//
// ADS support works only with Xbase++ 1.5
//

#ifdef _XBASE15_

#include "common.ch"
#include "dac.ch"
#include "fileio.ch"
#include "dfStd.ch"

#include "dfAdsDbe.ch"

#include "DMLB.CH"
#include "dll.CH"
#define ACE_SUCCESS      0

/*
 * results of AX_TableType():
 */
#define ADS_NO_TABLE         0
#define ADS_STANDARD_TABLE   1
#define ADS_ENCRYPTED_TABLE  2

STATIC aSessions := {}
STATIC xAdsTablePwd := NIL

//STATIC snAdsDllHandle
//STATIC scDllGetTblHandle
//STATIC scDllEnableEncription
//STATIC scDllDisableEncription
//STATIC scDllEncryptTable
//STATIC scDllDecryptTable

EXIT PROCEDURE _AXSDisconnect()
   dfAxsDisconnect()
RETURN

FUNCTION dfAxsSessionArray()
RETURN aSessions

FUNCTION dBsee4AXS()
   STATIC lAxs
   IF lAxs==NIL
      lAxs := ASCAN(DbeList(),{|a| ADSRDD $ UPPER(a[1])}) > 0
            // simone 29/11/06
            // mantis 0001175: supportare percorsi UNC
              // .AND. dfAxsConnect()
   ENDIF
RETURN lAxs

//Mantis 1811
//Correzione luca 07/04/2008 per problema connessione ADS con la dfusefile()
//FUNCTION dfAXSLoaded(cFile)
FUNCTION dfAXSLoaded(cFile, cDriver)
   LOCAL aFn
   LOCAL lRet := .F.

                  // simone 29/11/06
                  // mantis 0001175: supportare percorsi UNC
   IF dbsee4Axs() //.AND. dfAxsConnect()

      //Mantis 1811
      //Correzione luca 07/04/2008 per problema connessione ADS con la dfusefile()
      //IF ! dfSet("XbaseAXSAutoUse") == "NO"  
      IF ! dfSet("XbaseAXSAutoUse") == "NO"  .OR. ;
         (!EMPTY(cDriver) .AND. VALTYPE(cDriver) $ "CM" .AND. ; 
           UPPER(cDriver) == ADSRDD )

         aFn:= dfFNameSplit(cFile)
         IF EMPTY(aFn[1])
            // simone 29/11/06
            // mantis 0001175: supportare percorsi UNC
            aFN[1]:=dfPathRoot() //CURDRIVE()+":"
         ENDIF
         lRet := dfAXSOnDrives( UPPER(ALLTRIM(aFN[1])) )
      ENDIF
   ENDIF
RETURN lRet

FUNCTION dfAxsIsLoaded( cAlias )
   DEFAULT cAlias TO ALIAS()
   IF EMPTY(cAlias)
      RETURN .F.
   ENDIF
RETURN (cAlias)->(DbInfo(DBO_DBENAME)) == ADSRDD

FUNCTION dfAXSDriver(cDriver)
   LOCAL cRet := ""
   IF dbsee4Axs()
      cRet := _AxsDriver(cDriver)
   ENDIF
RETURN cRet

STATIC FUNCTION _AxsDriver(cDriver)
   STATIC cDriv := ADSRDD
   IF cDriver != NIL
      cDriv:=cDriver
   ENDIF
RETURN cDriv

FUNCTION dfAXSDefau()
   LOCAL cRet := ""
   IF dbsee4Axs()
      cRet := ADSRDD
   ENDIF
RETURN cRet

FUNCTION dfAXSExclusive()
RETURN .F.

// Ritorna la sessione
FUNCTION dfAxsSession(oNew, nThread)
   LOCAL nPos
   LOCAL oOld
   LOCAL oDefault

   DEFAULT nThread TO ThreadID() // La connessione Š THREAD-LOCAL

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

FUNCTION dfAXSOnDrives(xNew)
   STATIC aArr := {}
   LOCAL lRet := .T.
   LOCAL nPos
   LOCAL cArr
   LOCAL nID := ThreadID()

   nPos := ASCAN(aArr,{|x|x[1]==nID})

   IF VALTYPE(xNew)=="A"
      cArr := "*"+UPPER(dfArr2Str(xNew,"*"))+"*"
      IF nPos == 0
         AADD(aArr,{nID,cArr})
      ELSE
         aArr[nPos][2] := cArr
      ENDIF
   ELSE
      cArr := IIF(nPos==0, "", aArr[nPos][2])

      lRet := "*"+UPPER(xNew)+"*" $ cArr

      // simone 29/11/06
      // mantis 0001175: supportare percorsi UNC
      // se il thread non Š gi… connesso con ADS
      IF ! lRet .AND. dfAXSSession() == NIL
         // provo a connettermi
         lRet := _IsOnDrive(xNew)
      ENDIF
   ENDIF
RETURN lRet

// simone 29/11/06
// mantis 0001175: supportare percorsi UNC
// controlla se c'Š ADS su xNew
// non posso eseguirla se sono gi… connesso ad ADS
// perchŠ dovrei staccare la connessione corrente
// e riconnettere
STATIC FUNCTION _IsOnDrive(xNew)
   STATIC aList := {}
   LOCAL  lOK   := .F.
   LOCAL  nPos
   LOCAL  oConn
   LOCAL  nID := ThreadID()
   LOCAL  xTmp
   LOCAL  aNew:={}
   LOCAL  aMapDrives:={}

   xNew := UPPER(ALLTRIM(xNew))

   nPos := ASCAN(aList, {|x| x[1] == xNew .AND. x[2]==nID})

   IF nPos > 0 // test connessione gi… effettuato
      RETURN aList[nPos][3]
   ENDIF

   // se sono già connesso su un altro thread o
   // se il test connessione è positivo
   IF ASCAN(aList, {|x| x[1] == xNew}) > 0 .OR. ;
      TestConn(xNew) != 0

      // connetto ad ADS
      oConn := AXSConnect(xNew)

      IF oConn:isConnected() // connesso!
         oConn:setDefault(.T.) // connessione di default della workarea
         dfAxsSession(oConn)

         // Simone 21/01/09
         // miglioramento per percorsi UNC e percorsi mappati
         // aggiungo sia la mappatura che il percorso mappato
         aNew := {xNew}
         aMapDrives := S2WNetListNetworkDrives()
         IF ! EMPTY(aMapDrives) // se ci sono mappature di rete
            xTmp := UPPER(dfFNameSplit(xNew, 1)) // drive o percorso UNC
            IF EMPTY(xTmp)
               // non faccio niente

            ELSEIF LEFT(xTmp, 2)=="\\" // Š UNC?
               // cerco se Š mappato su un drive e lo aggiungo
               nPos := ASCAN(aMapDrives, {|x| UPPER(x[2])==xTmp .AND. ! EMPTY(x[1]) })
               IF nPos > 0
                  AADD(aNew, aMapDrives[nPos][1])
               ENDIF
            ELSE
               // cerco se Š mappato su un percoso UNC e lo aggiungo
               nPos := ASCAN(aMapDrives, {|x| UPPER(x[1])==xTmp .AND. ! EMPTY(x[2]) })
               IF nPos > 0
                  AADD(aNew, aMapDrives[nPos][2])
               ENDIF
            ENDIF
         ENDIF
         dfAxsOnDrives(aNew)
         lOK := .T.
      ELSE
         dbMsgErr("Errore durante la connessione al server ADS su drive "+xNew+"//"+;
                  "errore: "+dfAny2Str(oConn:getLastError())+"//"+;
                  "messaggio: "+dfAny2Str(oConn:getLastMessage()) )
         xNew := NIL // riprovo successivamente
      ENDIF
   ENDIF
   IF xNew != NIL
      AADD(aList, {xNew, nID, lOK})
   ENDIF
RETURN lOK

FUNCTION dfAxsScanDrives(cNew)
   STATIC cServ
   IF cNew != NIL
      cServ := cNew
   ENDIF
RETURN cServ

// simone 29/11/06
// mantis 0001175: supportare percorsi UNC
// funzione rimasta solo per compatibilit…
// adesso la connessione Š fatta on demand
// solo sul path della dfAXSOnDrives()
FUNCTION dfAxsConnect(cServ)
RETURN .T.

/*
FUNCTION dfAxsConnect(cServ)
   LOCAL oConn, nServ, aServ
   LOCAL lOk := .F.
   LOCAL aServOK  := {}
   LOCAL aLocalOK := {}
   LOCAL aConnOK  := {}
   LOCAL nConn    := 0

   IF dfAxsSession() == NIL

      DEFAULT cServ TO dfAxsScanDrives()

      IF ! EMPTY(cServ)
         // Testo la connessione solo sui drives specificati
         cServ := UPPER(ALLTRIM(cServ))

         aServ := dfStr2Arr(cServ, ",")

         FOR nServ := 1 TO LEN(aServ)
            nConn := TestConn(aServ[nServ])
            IF nConn == 1                   // Advantage Database Server
               AADD(aServOk, aServ[nServ])
            ELSEIF nConn == 2               // Advantage Local Server
               AADD(aLocalOk, aServ[nServ])
            ENDIF
         NEXT

      ELSE
         // Testo la connessione su tutti i drive
         FOR nServ := ASC("C") TO  ASC("Z")
            cServ :=CHR(nServ)+":"
            nConn := TestConn(cServ)
            IF nConn == 1                   // Advantage Database Server
               AADD(aServOk, cServ)
            ELSEIF nConn == 2               // Advantage Local Server
               AADD(aLocalOk, cServ)
            ENDIF
         NEXT
      ENDIF

      // Se Š disponibile connessione con Database Server uso quella
      // altrimenti uso connessione con Local server
      aConnOK := IIF(LEN(aServOK) > 0, aServOK, aLocalOK)

      IF LEN(aConnOK) >0
         oConn := AXSConnect(aConnOK[1])

         IF oConn:isConnected()
            dfAxsSession(oConn)
            dfAxsOnDrives(aConnOK)
            lOk := .T.
         ELSE
            dbMsgErr("Errore durante la connessione al server ADS su drive "+aConnOK[1]+"//"+;
                     "errore: "+dfAny2Str(oConn:getLastError())+"//"+;
                     "messaggio: "+dfAny2Str(oConn:getLastMessage()) )

         ENDIF
      ENDIF
   ELSE
      lOk := .T.
   ENDIF
RETURN lOk
*/

STATIC FUNCTION TestConn(cServ)
   LOCAL oConn := AXSConnect(cServ)
   LOCAL nRet  := 0
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

   LogConnection(cServ, oConn, nRet)

RETURN nRet

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

STATIC FUNCTION AXSConnect(cServ)
RETURN DacSession():new("DBE="+ADSRDD+";SERVER="+cServ)

FUNCTION dfAxsDisconnect()
RETURN .T.
//    LOCAL oConn
//    AEVAL(aSessions, {|x|oConn := x[2], ;
//                         IIF(oConn != NIL .AND. oConn:isConnected(), ;
//                             oConn:disconnect(), NIL) })
// RETURN .T.

// FUNCTION dfAxsDisconnect()
//    LOCAL lRet := .F.
//    LOCAL oConn := dfAxsSession()
//
//    IF oConn != NIL .AND. oConn:isConnected()
//       oConn:disconnect()
//       lRet := .T.
//    ENDIF
// RETURN lRet

FUNCTION dfAxsSessionError(nRet)
   LOCAL xRet
   LOCAL oConn := dfAxsSession()

   DEFAULT nRet TO 0
   DO CASE
      CASE oConn == NIL
         // Nessuna connessione torno NIL

      CASE nRet == 0
         xRet := oConn:getLastError()

      CASE nRet == 1
         xRet := oConn:getLastMessage()
   ENDCASE

RETURN xRet


FUNCTION dfADSTableEncrypt(cDbf, lEnc, cPwd)
   LOCAL lRet := .F.
   LOCAL nOld := SELECT()
   LOCAL oErr 

   DEFAULT cPwd TO dfADSGetPwd(cDbf)

   oErr := ERRORBLOCK({|e|dfErrBreak(e)})
   BEGIN SEQUENCE
      IF dfUseFile(cDbf, "__ADSENC__", .T., dfAXSDriver(), .F., .T.)

         __AX_SetPass(cPwd)

         IF lEnc
            lRet := __AX_DBFEncrypt()
         ELSE
            lRet := __AX_DBFDecrypt()
         ENDIF
         DEFAULT lRet TO .F.
      ENDIF
   END SEQUENCE
   ERRORBLOCK(oErr)

   IF SELECT("__ADSENC__") > 0
      __ADSENC__->(DBCLOSEAREA())
   ENDIF
   DBSELECTAREA(nOld)
RETURN lRet


FUNCTION dfADSTableIsEncrypted(cDbf)
   LOCAL lRet := .F.
   LOCAL nOld := SELECT()
   LOCAL oErr 
   LOCAL x

   oErr := ERRORBLOCK({|e|dfErrBreak(e)})
   BEGIN SEQUENCE
      IF dfUseFile(cDbf, "__ADSENC__", .T., dfAXSDriver(), .F., .T.)
         x:= __AX_TableType() 
         IF x <> NIL .AND. x ==  ADS_ENCRYPTED_TABLE
            lRet := .T.
         ENDIF
      ENDIF
   END SEQUENCE
   ERRORBLOCK(oErr)

   IF SELECT("__ADSENC__") > 0
      __ADSENC__->(DBCLOSEAREA())
   ENDIF
   DBSELECTAREA(nOld)
RETURN lRet

       
//Imposta la password per decrypt tabelle aperte con ADS o ALS
FUNCTION dfADSSetPwd(cNew)
   IF VALTYPE(cNew) $ "CMB"
      xAdsTablePwd := cNew
   ELSE
      xAdsTablePwd := NIL
   ENDIF
RETURN .T.

//Ritorna la password per decrypt tabelle aperte con ADS o ALS
FUNCTION dfADSGetPwd(cFName, lEval)
   LOCAL xPwd
   LOCAL aFName

   DEFAULT lEval TO (cFname != NIL)

   xPwd := xAdsTablePwd

   IF lEval .AND. VALTYPE(xPwd) == "B"
      aFname := dfFNameSplit(cFname)
      xPwd := EVAL(xPwd, aFname[3]+aFname[4], aFname[1]+aFname[2])
      IF xPwd != NIL .AND. ! VALTYPE(xPwd) $ "CM"
         xPwd := NIL
      ENDIF
   ENDIF
RETURN xPwd

//Imposta la password nella workarea
FUNCTION dfADSDbfSetPwd(cFName)
   LOCAL x
   LOCAL cPwd 
   IF dfAxsIsLoaded( NIL ) .AND. cFName != NIL .AND. ;
      (cPwd := dfADSGetPwd(cFname)) != NIL 

      x:= __AX_TableType() 
      IF x <> NIL .AND. x ==  ADS_ENCRYPTED_TABLE
         __AX_SetPass(cPwd)
      ENDIF
   ENDIF
RETURN NIL

STATIC FUNCTION __AX_TableType()
RETURN DLLCall("ADSUTIL.DLL", DLL_XPPCALL , "AX_TABLETYPE")

STATIC FUNCTION __AX_SetPass(cPwd)
   IF cPwd == NIL
      RETURN DLLCall("ADSUTIL.DLL", DLL_XPPCALL , "AX_SETPASS")
   ENDIF
RETURN DLLCall("ADSUTIL.DLL", DLL_XPPCALL , "AX_SETPASS", cPwd)

STATIC FUNCTION __AX_DBFEncrypt()
RETURN DLLCall("ADSUTIL.DLL", DLL_XPPCALL , "AX_DBFENCRYPT")

STATIC FUNCTION __AX_DBFDecrypt()
RETURN DLLCall("ADSUTIL.DLL", DLL_XPPCALL , "AX_DBFDECRYPT")

// Simone 21/09/09
// controlla esistenza file con funzione di ADS
// per vedere se si risolve il problema di TADDEI (LaTecnocopie)
// su PC Vista con ADS su Windows Server2008
FUNCTION dfADSFile(cFname, oSession)
   LOCAL lExist   := .F.
   LOCAL hConnect 

   DEFAULT oSession TO dfAxsSession()

   IF ! EMPTY(oSession) 
      hConnect:=oSession:getConnectionHandle()
      DLLCall("ACE32.DLL", DLL_STDCALL, "AdsCheckExistence", hConnect, cFname, @lExist)
   ENDIF
RETURN lExist

// Ritorna se per l'alias corrente si Š connessi ad un dizionario dati ADS
FUNCTION dfADSUseDD()
   LOCAL lRet := .F.
   LOCAL oSession := dbSession()

   IF EMPTY(oSession)
      RETURN lRet
   ENDIF

   IF "."+UPPER(ADSRDD_EXT_ADD) $ UPPER(oSession:getConnectionString()) // se uso ADS e diz.dati
      lRet := .T.
   ENDIF
RETURN lRet

#else
function dBsee4AXS()       ; return .f.
function dfAXSLoaded()     ; return .f.
function dfAXSDriver()     ; return ""
function dfAXSDefau()      ; return ""
function dfAXSExclusive()  ; return .f.
function dfAXSScanDrives(x); return x
#endif