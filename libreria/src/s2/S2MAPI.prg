// ------------------------------------------------------------------------
// Classe S2Mapi
// Serve a spedire un messaggio di posta elettronica
//
// Super classes
//    niente
//
// Sub classes
//    niente
// ------------------------------------------------------------------------
// Simone 21/04/04 
// aggiunta possibilit… di impostare il profilo outlook

// Simone 4/6/09
// abilita invio tramite activex Microsoft CDOSys
// vedi http://www.etechs.it/cdonts-using-sending-emailphp/
// #define _ENABLE_CDO_


#include "Common.ch"
#include "dfSet.ch"
#include "dll.ch"

//--error codes from MAPI.H
#define SUCCESS_SUCCESS                     0
#define MAPI_USER_ABORT                     1
#define MAPI_E_FAILURE                      2
#define MAPI_E_LOGIN_FAILURE                3
#define MAPI_E_DISK_FULL                    4
#define MAPI_E_INSUFFICIENT_MEMORY          5
#define MAPI_E_ACCESS_DENIED                6
#define MAPI_E_TOO_MANY_SESSIONS            8
#define MAPI_E_TOO_MANY_FILES               9
#define MAPI_E_TOO_MANY_RECIPIENTS          10
#define MAPI_E_ATTACHMENT_NOT_FOUND         11
#define MAPI_E_ATTACHMENT_OPEN_FAILURE      12
#define MAPI_E_ATTACHMENT_WRITE_FAILURE     13
#define MAPI_E_UNKNOWN_RECIPIENT            14
#define MAPI_E_BAD_RECIPTYPE                15
#define MAPI_E_NO_MESSAGES                  16
#define MAPI_E_INVALID_MESSAGE              17
#define MAPI_E_TEXT_TOO_LARGE               18
#define MAPI_E_INVALID_SESSION              19
#define MAPI_E_TYPE_NOT_SUPPORTED           20
#define MAPI_E_AMBIGUOUS_RECIPIENT          21
#define MAPI_E_MESSAGE_IN_USE               22
#define MAPI_E_NETWORK_FAILURE              23
#define MAPI_E_INVALID_EDITFIELDS           24
#define MAPI_E_INVALID_RECIPS               25
#define MAPI_E_NOT_SUPPORTED                26

//--ID´s for Message items
#define ID_SUBJECT                0
#define ID_MESSAGE                1
#define ID_MESSAGE_TYPE           2
#define ID_DATE                   3
#define ID_ORIGINATOR_NAME        4
#define ID_ORIGINATOR_ADRESS      5
#define ID_RECIPIENT_NAME         6
#define ID_RECIPIENT_ADRESS       7
#define ID_ATTACHMENT_PATHNAME    8
#define ID_ATTACHMENT_FILENAME    9
#define ID_CONVERSATION_ID        10

//--Message Flags
#define NOFLAG                    0
#define FLAG_UNREAD               1
#define FLAG_RECEIPT_REQUESTED    2 
#define FLAG_SENT                 4 

//--SKIP Flags
#define SKIP_ONLY                 0
#define DELETE_THEN_SKIP          1


//-------------------------------------------------
// Simone 01/9/2003
// - aggiunto metodo sendEmail che non ha interfaccia utente (dfAlert)
//   e che uso la nuova DLL SOCMAPI.DLL 
//   (rinominata in DBMAPI.DLL) invece della DBMAIL.DLL
// - rinominato vecchio metodo send che usa DBMAIL.DLL in send1
// - aggiunte variabili per controllo errori dopo invio email:
//   nError contiene il codice di errore: 0=ok
//   cMsg   contiene la descrizione di errore

#ifdef _TEST_
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Main(  )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL oMail := S2Mapi():new()

      oMail:cSubject := "prova"
      oMail:cBody    := "dentro il body"+CHR(13)+CHR(10)+"riga2"

      oMail:addTo( "simone.degl@tin.it" )
      oMail:addTo( "hot@albalog.it" )
      oMail:addcc( "simone.degl@tiscalinet.it" )
      oMail:addcc( "simonedegl@hotmail.com" )
      oMail:addbcc( "gioiawinbug@albalog.it" )
      oMail:addbcc( "satwinbug@albalog.it" )
      oMail:addAttach( "c:\delphi source\askinstall\askinstall.zip" )
      oMail:addAttach( "C:\AUTOEXEC.BAT" )
      oMail:send()
      ?oMail:nError, oMail:cMsg

      oMail := S2Mapi():new()
      oMail:cSubject := "prova 1"
      oMail:cBody    := "dentro il body"+CHR(13)+CHR(10)+"riga2"
      oMail:addTo( "consulting@Albalog.it" )
      oMail:addAttach( "C:\File.zip" )
      oMail:send()
      ?oMail:nError, oMail:cMsg
      wait
RETURN NIL

func dfalert(c); retu msgbox(c)

#endif

CLASS S2Mapi
   PROTECTED:
      VAR aTo,aCC,aBCC
      VAR aAttach
      
   EXPORTED:
      VAR cServer
      VAR cFROM
      VAR cSubject
      VAR cBody
      VAR cReplyTo
      VAR cMsg      READONLY
      VAR nError    READONLY
      VAR cProfile
      VAR cProfilePwd

      VAR bOnSend
      VAR cBCC

      METHOD Init
      METHOD addTo
      METHOD addCC
      METHOD addBCC
      METHOD addAttach
      METHOD send       // invia email con dfAlert, come sendEmail
      METHOD sendEmail  // invia email senza dfAlert(), prova con DBMAPI
                        // se non riesce prova con DBMAIL
      METHOD send1      // invia email con DBMAIL
#ifdef _ENABLE_CDO_
      METHOD sendCDO    // invia email tramite ActiveX (CDO MAPI.Session)
      METHOD _makeCDOMessage    // crea il messaggio CDO
      METHOD exeCB      // esegue un metodo su un activeX senza dare errori runtime
#endif
      METHOD getErrorMsg
      METHOD getAttachments
      METHOD getTo
      METHOD getCC
      METHOD getBCC
      METHOD clearAttachments
      METHOD clearTo
      METHOD clearCC
      METHOD clearBCC
ENDCLASS

METHOD S2Mapi:Init(cProf, cPwd)
   DEFAULT cProf TO ""
   DEFAULT cPwd TO ""
 
   ::cProfile := cProf
   ::cProfilePwd := cPwd
   ::cServer  := "" // inutile
   ::cFROM    := "" // inutile
   ::aTo      := {}
   ::aCC      := {}
   ::aBCC     := {}
   ::cSubject := ""
   ::cBody    := ""
   ::cReplyTo := dfSet("XbaseSMTPReplyTo")  //"" // inutile
   ::aAttach  := {}
   ::cMsg     := ""
   ::nError   := 0

   ::bOnSend   := dfSet(AI_EMAILFAX_CB)
   ::cBCC      := dfSet("XbaseBCCEmail")
RETURN self

METHOD S2Mapi:addTO(cMapi,cNick)
   DEFAULT cNick TO ""
   // Per mandare un FAX aggiungere "[FAX: " all'indirizzo di posta e "]" alla fine
   AADD( ::aTo, {cMapi, cNick} )
RETURN self

METHOD S2Mapi:addCC(cMapi,cNick)
   DEFAULT cNick TO ""
   AADD( ::aCC, {cMapi, cNick} )
RETURN self

METHOD S2Mapi:addBCC(cMapi,cNick)
   DEFAULT cNick TO ""
   AADD( ::aBCC, {cMapi, cNick} )
RETURN self

METHOD S2Mapi:addATTACH(cFile, cFileTitle)
   LOCAL aFName

   IF cFileTitle == NIL
      aFName := dfFnameSplit(cFile)
      cFileTitle := aFName[3]+aFName[4]
   ENDIF

   AADD( ::aAttach, {cFile, cFileTitle} )
RETURN self

METHOD S2Mapi:getAttachments()
RETURN ::aAttach

METHOD S2Mapi:getTO()
RETURN ::aTo

METHOD S2Mapi:getCC()
RETURN ::aCC

METHOD S2Mapi:getBCC()
RETURN ::aBCC

METHOD S2Mapi:clearAttachments()
RETURN ASIZE(::aAttach, 0)

METHOD S2Mapi:clearTO()
RETURN ASIZE(::aTo, 0)

METHOD S2Mapi:clearCC()
RETURN ASIZE(::aCC, 0)

METHOD S2Mapi:clearBCC()
RETURN ASIZE(::aBCC, 0)

// simone da testare 29/8/03 uso SOCMAPI
METHOD S2Mapi:sendEmail(lPopUp, nFlag)
   STATIC snDllHandle 
   STATIC scDLLSocMapiIsInit
   STATIC scDLLSocMapiInit
   STATIC scDLLSocMapiSendMail
   STATIC scDLLSocMapiPostMail
   LOCAL nErr         := 0
   LOCAL cAddresses   := ""
   LOCAL cAttachments := ""
   LOCAL cDir
   LOCAL cFunction
   LOCAL cSubject     
   LOCAL cBody
   LOCAL lConvToAnsi := dfSet("XbaseMapiConvToAnsi") == "YES"
   LOCAL cBCC        := ::cBCC
   LOCAL aBcc        := {}

   DEFAULT lPopUp   TO .F.
   DEFAULT nFlag    TO NOFLAG

   ::cMsg     := ""
   ::nError   := 0

#ifdef _ENABLE_CDO_
   // invio tramite CDO (activeX)
   IF ::sendCDO() == 0
      // Simone 2/2/11
      // per log invio email/fax
      IF ::bOnSend  != NIL
         EVAL(::bOnSend, self, ::nError, ::cMsg)
      ENDIF

      RETURN nErr
   ENDIF
#endif

   // Ricordo dov'ero
   cDir   := dfPathGet()

   // uso DBMAPI (Š SOCMAPI ver. 3 vedi ACSN di Alaska)
   IF snDllHandle == NIL
      snDllHandle       := DllLoad( "DBMAPI.Dll" )
      IF snDllHandle != 0
         //Get Function handles from DLL.
         scDLLSocMapiIsInit    := DllPrepareCall( snDllHandle, DLL_STDCALL, "SocMapiIsInit"     )
         scDLLSocMapiInit      := DllPrepareCall( snDllHandle, DLL_STDCALL, "SocMapiInit"       )
         scDLLSocMapiSendMail  := DllPrepareCall( snDllHandle, DLL_STDCALL, "SocMapiSendMail"   )
         scDLLSocMapiPostMail  := DllPrepareCall( snDllHandle, DLL_STDCALL, "SocMapiPostMail"   )
         IF DllExecuteCall( scDLLSocMapiIsInit ) == 0
            nErr := DllExecuteCall( scDLLSocMapiInit )
            IF nErr != 0
               snDllHandle := 0
            ENDIF
         ENDIF
      ENDIF
  ENDIF

  // errore, uso routine vecchia
  IF snDllHandle == 0
     ::send1()
  ELSE
     // Uso routine nuova che forse Š meglio
     cAddresses := ""
     cAttachments := ""
     IF ! EMPTY(::aTo)
        AEVAL( ::aTo    , {|aSubTo | cAddresses+= aSubTO[1]+";" } )
        cAddresses := LEFT(cAddresses, LEN(cAddresses)-1)
     ENDIF
     IF ! EMPTY(::aCC)
        IF ! EMPTY(cAddresses)
           cAddresses += ";"
        ENDIF
************************************************************************************************************************
//Maudp 08/04/2011 Questo punto CC Š sbagliato, il MAPI vuole che ogni indirizzo CC sia preceduto dalla sigla CC:
//Altrimenti li mette come indirizzi principali
************************************************************************************************************************
//        cAddresses+="CC:"
//        AEVAL( ::aCC    , {|aSubCC | cAddresses+= aSubCC[1]+";" } )
        AEVAL( ::aCC    , {|aSubCC | cAddresses+= "CC:" + aSubCC[1]+";" } )
        cAddresses := LEFT(cAddresses, LEN(cAddresses)-1)
     ENDIF

     IF ! EMPTY(::aBCC) .OR. !EMPTY(cBCC)
        IF ! EMPTY(cAddresses)
           cAddresses += ";"
        ENDIF
************************************************************************************************************************
//Maudp 08/04/2011 Questo punto BCC Š sbagliato, il MAPI vuole che ogni indirizzo BCC sia preceduto dalla sigla BCC:
//Altrimenti li mette come indirizzi principali
************************************************************************************************************************
//        cAddresses+="BCC:"
//         AEVAL( ::aBCC    , {|aSubBCC | cAddresses+= aSubBCC[1]+";" } )
        IF !EMPTY(::aBCC)
           AEVAL( ::aBCC    , {|aSubBCC | cAddresses+= "BCC:" + aSubBCC[1]+";" } )
        ENDIF

        IF !EMPTY(cBCC)
           aBcc := _Str2Arr(ALLTRIM(cBcc),",")

           AEVAL(aBcc, {|cInd | cAddresses+= "BCC:" + ALLTRIM(cInd)+";" } )
        ENDIF

        cAddresses := LEFT(cAddresses, LEN(cAddresses)-1)
     ENDIF

     IF ! EMPTY(::aAttach)
        AEVAL( ::aAttach, {|aSubAtt| IIF(FILE(aSubAtt[1]), ;
                                         cAttachments += aSubAtt[1]+";", ;
                                         NIL) } )
        cAttachments:= LEFT(cAttachments, LEN(cAttachments)-1)
     ENDIF

     

     cFunction := IIF(lPopUp, scDLLSocMapiSendMail, scDLLSocMapiPostMail)
 

********************************************************************** 
     //Maudp 18/03/2011 Il MAPI utilizza il charset ANSI e non OEM, 
     //converto se ho settato a YES il settaggio XBASEMAPICONVTOANSI (lConvToAnsi)
     //per evitare problemi per clienti che hanno visualdbsee che potrebbero aver gestito
     //gi… la cosa

     IF lConvToAnsi
        cSubject := ConvToAnsiCP(::cSubject)
        cBody    := ConvToAnsiCP(::cBody   )
     ELSE
        cSubject := ::cSubject
        cBody    := ::cBody   
     ENDIF
********************************************************************** 

     nErr := DllExecuteCall( cFunction, cAddresses   , cSubject  ,;
                             cBody    , cAttachments , nFlag)


     ::cMsg := ""
     IF nErr != SUCCESS_SUCCESS
        ::cMsg := "ERROR:SEND:"
     ENDIF
     ::cMsg += ::getErrorMsg(nErr)
     ::nError := nErr
  ENDIF

  // Mi rimetto a posto
  dfPathSet( cDir )

  // Simone 2/2/11
  // per log invio email/fax
  IF ::bOnSend != NIL
     EVAL(::bOnSend, self, ::nError, ::cMsg)
  ENDIF

RETURN nErr

METHOD S2Mapi:getErrorMsg(nErr)
   LOCAL cErr := ""
   DO CASE
      CASE nErr==SUCCESS_SUCCESS                ; cErr := "OK."
      CASE nErr==MAPI_USER_ABORT                ; cErr := "USER_ABORT"
      CASE nErr==MAPI_E_FAILURE                 ; cErr := "FAILURE"
      CASE nErr==MAPI_E_LOGIN_FAILURE           ; cErr := "LOGIN_FAILURE"
      CASE nErr==MAPI_E_DISK_FULL               ; cErr := "DISK_FULL"
      CASE nErr==MAPI_E_INSUFFICIENT_MEMORY     ; cErr := "INSUFFICIENT_MEMORY"
      CASE nErr==MAPI_E_ACCESS_DENIED           ; cErr := "ACCESS_DENIED"
      CASE nErr==MAPI_E_TOO_MANY_SESSIONS       ; cErr := "TOO_MANY_SESSIONS"
      CASE nErr==MAPI_E_TOO_MANY_FILES          ; cErr := "TOO_MANY_FILES"
      CASE nErr==MAPI_E_TOO_MANY_RECIPIENTS     ; cErr := "TOO_MANY_RECIPIENTS"
      CASE nErr==MAPI_E_ATTACHMENT_NOT_FOUND    ; cErr := "ATTACHMENT_NOT_FOUND"
      CASE nErr==MAPI_E_ATTACHMENT_OPEN_FAILURE ; cErr := "ATTACHMENT_OPEN_FAILURE"
      CASE nErr==MAPI_E_ATTACHMENT_WRITE_FAILURE; cErr := "ATTACHMENT_WRITE_FAILURE"
      CASE nErr==MAPI_E_UNKNOWN_RECIPIENT       ; cErr := "UNKNOWN_RECIPIENT"
      CASE nErr==MAPI_E_BAD_RECIPTYPE           ; cErr := "BAD_RECIPTYPE"
      CASE nErr==MAPI_E_NO_MESSAGES             ; cErr := "NO_MESSAGES"
      CASE nErr==MAPI_E_INVALID_MESSAGE         ; cErr := "INVALID_MESSAGE"
      CASE nErr==MAPI_E_TEXT_TOO_LARGE          ; cErr := "TEXT_TOO_LARGE"
      CASE nErr==MAPI_E_INVALID_SESSION         ; cErr := "INVALID_SESSION"
      CASE nErr==MAPI_E_TYPE_NOT_SUPPORTED      ; cErr := "TYPE_NOT_SUPPORTED"
      CASE nErr==MAPI_E_AMBIGUOUS_RECIPIENT     ; cErr := "AMBIGUOUS_RECIPIENT"
      CASE nErr==MAPI_E_MESSAGE_IN_USE          ; cErr := "MESSAGE_IN_USE"
      CASE nErr==MAPI_E_NETWORK_FAILURE         ; cErr := "NETWORK_FAILURE"
      CASE nErr==MAPI_E_INVALID_EDITFIELDS      ; cErr := "INVALID_EDITFIELDS"
      CASE nErr==MAPI_E_INVALID_RECIPS          ; cErr := "INVALID_RECIPS"
      CASE nErr==MAPI_E_NOT_SUPPORTED           ; cErr := "NOT_SUPPORTED"
      OTHERWISE                                 ; cErr := "Unknown Mapi Error"
   ENDCASE

   cErr += " ("+dfAny2Str(nErr)+")"
RETURN cErr


// Ritorna un numero che Š il codice di errore
// imposta il codice di errore in ::nError
// imposta la descrizione in ::cMsg
// ::cMsg pu• assumeere: 
//       "OK."   Tutto Ok
//       "ERROR:LOAD:xx"      Errore in caricamento DLL
//       "ERROR:CONNECT:xx"   Errore in connessione server SMTP
//       "ERROR:SEND:xx"      Errore in invio msg
//       dove xx Š una descrizione pi— specifica dell'errore

METHOD S2Mapi:send(lPopUp, nFlag, lShowError)

   DEFAULT lShowError TO .T.

   ::sendEmail(lPopUp, nFlag)

   IF ! lShowError
      // non fa niente

   ELSEIF LEFT(::cMsg, 11) == "ERROR:LOAD:"
      dfAlert( SUBSTR(::cMsg, 12) )

   ELSEIF LEFT(::cMsg, 6) == "ERROR:" .AND. ; // simone 23/8/04 mostra tutti gli errori
       dfSet("XbaseEmailSendShowError")=="YES" 
      
      dfAlert( ::cMsg )
   ENDIF
RETURN self

METHOD S2Mapi:send1()
   LOCAL nDll := DllLoad( "DBMAIL.DLL")
   LOCAL cInit
   LOCAL cADDTO
   LOCAL cADDCC
   LOCAL cADDBCC
   LOCAL cADDATT
   LOCAL cSend
   LOCAL cSendEx
   LOCAL cDir
   LOCAL nRet := -1
   LOCAL cSubject
   LOCAL cBody
   LOCAL lConvToAnsi := dfSet("XbaseMapiConvToAnsi") == "YES"
   LOCAL cBCC        := ::cBCC

   ::cMsg     := ""
   ::nError   := 0

   IF nDll != 0
      cInit   := _DllPrepareCall( nDLL, DLL_STDCALL, "dbmapiinit", .F.)
      cADDTO  := _DllPrepareCall( nDLL, DLL_STDCALL, "dbmapito", .F.)
      cADDCC  := _DllPrepareCall( nDLL, DLL_STDCALL, "dbmapicc", .F.)
      cADDBCC := _DllPrepareCall( nDLL, DLL_STDCALL, "dbmapibcc", .F.)
      cADDATT := _DllPrepareCall( nDLL, DLL_STDCALL, "dbmapiaddattach", .F.)
      cSend   := _DllPrepareCall( nDLL, DLL_STDCALL, "dbmapisend", .F.)
      cSendEx := _DllPrepareCall( nDLL, DLL_STDCALL, "dbmapisendex", .F.)

      IF len(cInit) != 0
         DLLExecuteCall( cInit )
         AEVAL( ::aTo    , {|aSubTo | DLLExecuteCall( cADDTO , aSubTO[1]    ) } )
         AEVAL( ::aCC    , {|aSubCC | DLLExecuteCall( cADDCC , aSubCC[1]    ) } )
         AEVAL( ::aBCC   , {|aSubBCC| DLLExecuteCall( cADDBCC, aSubBCC[1] ) } )
         AEVAL( ::aAttach, {|aSubAtt| IIF(FILE(aSubAtt[1]), ;
                                          DLLExecuteCall( cADDAtt, aSubAtt[1], ;
                                                                   aSubAtt[2] ), ;
                                          NIL) } )


         //Maudp 07/04/2011 Aggiungo nel BCC gli indirizzi impostati sul dbstart.ini

         IF !EMPTY(cBCC)
            DLLExecuteCall( cADDBCC,STRTRAN(ALLTRIM(cBCC),",",";"),"" ) 
         ENDIF

         // Incredibile, viene cambiato disco e directory corrente !!

         // Ricordo dov'ero
         cDir   := dfPathGet()




    ********************************************************************** 
         //Maudp 18/03/2011 Il MAPI utilizza il charset ANSI e non OEM, 
         //converto se ho settato a YES il settaggio XBASEMAPICONVTOANSI (lConvToAnsi)
         //per evitare problemi per clienti che hanno visualdbsee che potrebbero aver gestito
         //gi… la cosa

         IF lConvToAnsi
            cSubject := ConvToAnsiCP(::cSubject)
            cBody    := ConvToAnsiCP(::cBody   )
         ELSE
            cSubject := ::cSubject
            cBody    := ::cBody   
         ENDIF
    ********************************************************************** 

         IF LEN(cSendEx) == 0

            DLLExecuteCall( cSend, ::cProfile, ::cProfilePWD, cSubject, cBody, ::cReplyto )
            nRet := SUCCESS_SUCCESS
         ELSE

            nRet := DLLExecuteCall( cSendEx, ::cProfile, ::cProfilePWD, cSubject, cBody, ::cReplyto )
            IF nRet != SUCCESS_SUCCESS
               ::cMsg := "ERROR:SEND:"
            ENDIF
         ENDIF

         ::cMsg += ::getErrorMsg(nRet)

         // Mi rimetto a posto
         dfPathSet( cDir )

      ELSE
         ::cMsg := "ERROR:LOAD:DBMAIL.DLL too old. Upgrade it" 
         nRet := -2
      ENDIF
      DllUnload(nDll)
   ELSE
      ::cMsg := "ERROR:LOAD:Unable to load DBMAIL.DLL" 
      nRet := -1
   ENDIF
   ::nError := nRet
RETURN nRet

#ifdef _ENABLE_CDO_

// invia una email tramite MAPI 
// usando CDO
METHOD S2Mapi:sendCDO()
   LOCAL objSession
   LOCAL objNewMessage
   LOCAL cRegKey
   LOCAL cProfile
   LOCAL nErr:=0, cErr:=""
   LOCAL lLogOff := .F.
   LOCAL cDir

#if XPPVER < 01900000
   nErr := -1
   cErr := "ERROR:LOAD:NOT SUPPORTED" 
#else

   // Ricordo dov'ero
   cDir   := dfPathGet()

   objSession := CreateObject("MAPI.Session")
   IF EMPTY(objSession)
      nErr := -999
      cErr := "ERROR:LOAD:Unable to create MAPI.Session" 
   ELSE
      lLogOff     := .F.

      // provo a fare Logon con sessione MAPI di default (se outlook Š gi… attivo)
      IF ::exeCB({|| objSession:Logon("", "", .F., .F., 0) } )
         lLogOff  := .T.
      ELSE
         // se non riesco, leggo il profilo MAPI di default dal registro di sistema
         IF dfOSFamily() == "WIN9X"
            cRegKey := "Software\Microsoft\Windows Messaging Subsystem\Profiles"
         ELSE
            cRegKey := "Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles"
         ENDIF
         cProfile := dfQueryRegistry("HKCU", cRegKey, "DefaultProfile")
         // provo a fare Logon con profilo di Default
         IF EMPTY(cProfile)
            nErr := -2
            cErr := "UNABLE TO GET DEFAULT PROFILE FROM: "+cRegKey
         ELSE
            IF ::exeCB({|| objSession:Logon(cProfile, "", .F., .T., 0) }, NIL, NIL, @nErr, @cErr)
               lLogOff := .T.
            ENDIF
         ENDIF
      ENDIF

      IF lLogOff
         // crea il messaggio
         IF ::exeCB({|| objNewMessage:= ::_makeCDOMessage(objSession) }, NIL, NIL, @nErr, @cErr)
            // invia il messaggio
            ::exeCB({|| objNewMessage:send() }, NIL, NIL, @nErr, @cErr)
         ENDIF
         
         // Logoff from MAPI Session
         ::exeCB({|| objSession:Logoff() } )
      ENDIF
      IF nErr != 0
         cErr := "ERROR:SEND:"+cErr
      ENDIF
      
   ENDIF
#endif

   ::nError := -1 * ABS(nErr) // metto errore in negativo
   ::cMsg   := cErr

   // Mi rimetto a posto
   dfPathSet( cDir )
RETURN nErr

// crea il messaggio
METHOD S2Mapi:_MakeCDOMessage(objSession)
   LOCAL objNewMessage
   LOCAL n
   LOCAL aSubAtt
   LOCAL objAttachment

#if XPPVER < 01900000
#else
   objNewMessage := objSession:Outbox:Messages:Add()
   objNewMessage:Subject := ::cSubject
   objNewMessage:Text := ::cBody

   AEVAL( ::aTo    , {|aSubTo, r|  r:= objNewMessage:Recipients:Add(), r:Name :=aSubTO[1], r:type := 1 } ) //, r:Resolve() //1=CdoTo
   AEVAL( ::aCC    , {|aSubTo, r|  r:= objNewMessage:Recipients:Add(), r:Name :=aSubTO[1], r:type := 2 } ) //, r:Resolve() //2=CdoCc
   AEVAL( ::aBCC   , {|aSubTo, r|  r:= objNewMessage:Recipients:Add(), r:Name :=aSubTO[1], r:type := 3 } ) //, r:Resolve() //3=CdoBcc
   FOR n := 1 TO LEN(::aAttach)

      aSubAtt := ::aAttach[n]

      IF FILE(aSubAtt[1])
         objAttachment := objNewMessage:Attachments:Add()

         objAttachment:Position := 0

         objAttachment:Type := 1 // CdoFileData
         objAttachment:Source := aSubAtt[1]
         objAttachment:ReadFromFile(aSubAtt[1])
      ENDIF
   NEXT
//   objNewMessage:Update()
#endif
RETURN objNewMessage

METHOD S2Mapi:exeCB(bBlock, xRet, oErr, nErr, cErr)
   LOCAL lRet:=.F., e
#if XPPVER < 01900000
#else
   LOCAL bErr := ERRORBLOCK({|e| dfErrBreak(e)})
   oErr := NIL
   nErr := 0
   cErr := ""
   BEGIN SEQUENCE
       xRet := EVAL(bBlock)
       lRet := .T.
   RECOVER USING e
       oErr := e
       nErr := ComLastError()
       cErr := ComLastMessage()
       IF nErr == 0
          nErr := -100
       ENDIf
       IF EMPTY(cErr)
          cErr:= "Unkown error "+var2char(oErr:operation)
       ENDIF
   END SEQUENCE
   ERRORBLOCK(bErr)
#endif
RETURN lRet

/*
invio con ACTIVEX

'Create MAPI session
Dim objSession
Set objSession = CreateObject("MAPI.Session")

'In VB and VBA use:
'Dim objSession 'As MAPI.Session
'Set objSession 'As New MAPI.Session

' Logon using an existing MAPI session
'objSession.Logon "", "", False, False, 0


' Or, logon using an existing MAPI profile with a new session
objSession.Logon "albalog", "", False, True, 0

' il profilo viene da chiave di registro
' per NT
'    HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles
'      valore  DefaultProfile
' per win95
'    HKCU\Software\Microsoft\Windows Messaging Subsystem\Profiles
'      valore  DefaultProfile
Software\Microsoft\" & _

' Or, logon using an new MAPI session with a dynamically created profile
'strProfileInfo = "<Your Servername>" & vbLf & "<Your Mailbox>"
'objSession.Logon "", "", False, True, 0, False, strProfileInfo

' Create a new message
Set objNewMessage = objSession.Outbox.Messages.Add

' Add a subject
objNewMessage.Subject = "This is a message created with CDO"

' Add text to the message body
' Note that CDO 1.x cannot add text formatted with RTF or HTML
' Only Plain Text is supported in the current version
objNewMessage.Text = "Welcome to the world of CDO. Enjoy your life!"

' Add recipient and resolve against the directory
Set objRecipient = objNewMessage.Recipients.Add
objRecipient.Name = "[fax:055]"
objRecipient.Resolve

' Send message
objNewMessage.Update
objNewMessage.Send

' Logoff from MAPI Session
objSession.Logoff
*/

#endif

STATIC FUNCTION _Str2Arr(cStr, cDelim)
   LOCAL aRet := {}
   LOCAL nPos := 0
   LOCAL nLen := 0

   DEFAULT cDelim TO ";"

   nLen := LEN(cDelim)

   DO WHILE (nPos := AT( cDelim, cStr)) > 0
      AADD(aRet, LEFT( cStr, nPos-1 ))
      cStr := SUBSTR( cStr, nPos+nLen )
   ENDDO

   IF ! cStr == ""
      AADD(aRet, cStr)
   ENDIF

RETURN aRet