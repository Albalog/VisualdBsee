// ------------------------------------------------------------------------
// Classe S2Mail
// Serve a spedire un messaggio di posta elettronica
//
// Super classes
//    niente
//
// Sub classes
//    niente
// ------------------------------------------------------------------------
//
#include "Common.ch"
#include "dfSet.ch"
#include "dll.ch"

#ifdef _TEST_
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Main( cser, cuser, cpwd )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL oMail := S2Mail():new()
   LOCAL cRes

   oMail:cServer  := cser //"relay.comm2000.it"
   oMail:cFROM    := "hot@albalog.it"
   oMail:cSubject := "prova"
   oMail:cBody    := "dentro il body"+CHR(13)+CHR(10)+"riga2"
   omail:cHTMLBody:= "dentro il <b>body</b>"+CHR(13)+CHR(10)+"riga2"
   oMail:cReplyTo := "hot@albalog.it"

   IF ! EMPTY(cUser)
      omail:nLoginMethod := 2
      default cuser to ""
      default cpwd to ""
      omail:cuser := cuser
      omail:cpassword := cpwd
   endif

   oMail:addto( "simone.degl@tiscalinet.it" )
   oMail:addTo( "hot@albalog.it" )
   oMail:addcc( "aa.degl@tiscalinet.it" )
   oMail:addbcc( "satwinbug@albalog.it" )
   oMail:addAttach( "c:\askinstall\askinstall.zip" )

   oMail:send()
   ?oMail:nError, oMail:cMsg
   wait

RETURN NIL

func dfalert(c); retu msgbox(c)
func _dllPrepareCall(x, y, z, l); RETURN dllPrepareCall(x, y, z, l)

#endif

//-------------------------------------------------
// Simone 26/4/2002
// - aggiunto metodo sendEmail che non ha interfaccia utente (dfAlert)
// - aggiunte variabili per controllo errori dopo invio email:
//   nError contiene il codice di errore: 0=ok
//   cMsg   contiene la descrizione di errore

CLASS S2Mail
   PROTECTED:
      VAR aTo,aCC,aBCC
      VAR aAttach

   EXPORTED:
      VAR cServer
      VAR cFROM
      VAR cSubject
      VAR cBody
      VAR cHTMLBody
      VAR cHTMLContentBase
      VAR nLoginMethod     // 0 = no login, 1=crammd5 , 2=athentication login, 3=login plain
      VAR cUser
      VAR cPassword
      VAR nConnectionPort  
      VAR nConnectionTimeOut
      VAR nSsl
      VAR cReplyTo
      VAR cMsg      READONLY
      VAR nError    READONLY

      VAR bOnSend
      VAR cBCC

      METHOD Init
      METHOD addTo
      METHOD addCC
      METHOD addBCC
      METHOD addAttach
      METHOD send
      METHOD sendEmail
      METHOD getAttachments
      METHOD getTo
      METHOD getCC
      METHOD getBCC
      METHOD clearAttachments
      METHOD clearTo
      METHOD clearCC
      METHOD clearBCC
ENDCLASS

METHOD S2Mail:Init()
   ::cServer  := ""
   ::cFROM    := ""
   ::aTo      := {}
   ::aCC      := {}
   ::aBCC     := {}
   ::cSubject := ""
   ::cBody    := ""
   ::cReplyTo := ""
   ::aAttach  := {}
   ::cMsg     := ""
   ::nError   := 0

   ::cHTMLBody:= NIL
   ::cHTMLContentBase:=""
   ::nLoginMethod := NIL
   ::cUser     :=""
   ::cPassword := ""
   ::nConnectionPort := 25
   ::nConnectionTimeOut := 60
   ::nSsl      := 0     

   ::bOnSend   := dfSet(AI_EMAILFAX_CB)
   ::cBCC      := dfSet("XbaseBCCEmail")
RETURN self

METHOD S2Mail:addTO(cMail,cNick)
   DEFAULT cNick TO ""
   AADD( ::aTo, {cMail, cNick} )
RETURN self

METHOD S2Mail:addCC(cMail,cNick)
   DEFAULT cNick TO ""
   AADD( ::aCC, {cMail, cNick} )
RETURN self

METHOD S2Mail:addBCC(cMail,cNick)
   DEFAULT cNick TO ""
   AADD( ::aBCC, {cMail, cNick} )
RETURN self

METHOD S2Mail:addATTACH(cFile)
   AADD( ::aAttach, cFile )
RETURN self

METHOD S2Mail:getAttachments()
RETURN ::aAttach

METHOD S2Mail:getTO()
RETURN ::aTo

METHOD S2Mail:getCC()
RETURN ::aCC

METHOD S2Mail:getBCC()
RETURN ::aBCC

METHOD S2Mail:clearAttachments()
RETURN ASIZE(::aAttach, 0)

METHOD S2Mail:clearTO()
RETURN ASIZE(::aTo, 0)

METHOD S2Mail:clearCC()
RETURN ASIZE(::aCC, 0)

METHOD S2Mail:clearBCC()
RETURN ASIZE(::aBCC, 0)

METHOD S2Mail:send(lShowError)

   DEFAULT lShowError TO .T.

   ::sendEmail()

   IF ! lShowError
      // non fa niente

   ELSEIF LEFT(::cMsg, 11) == "ERROR:LOAD:"
      dfAlert( SUBSTR(::cMsg, 12) )

   ELSEIF LEFT(::cMsg, 6) == "ERROR:" .AND. ; // simone 23/8/04 mostra tutti gli errori
       dfSet("XbaseEmailSendShowError")=="YES" 
      
      dfAlert( ::cMsg )
   ENDIF
RETURN self

// Invia una email
// Ritorna un numero che Š il codice di errore
// imposta il codice di errore in ::nError
// imposta la descrizione in ::cMsg
// ::cMsg pu• assumeere: 
//       "OK."   Tutto Ok
//       "ERROR:LOAD:xx"      Errore in caricamento DLL
//       "ERROR:CONNECT:xx"   Errore in connessione server SMTP
//       "ERROR:SEND:xx"      Errore in invio msg
//       dove xx Š una descrizione pi— specifica dell'errore

METHOD S2Mail:sendEmail()
//   LOCAL nDll := DllLoad( "DBMAIL.DLL")
   LOCAL cInit
   LOCAL cADDTO
   LOCAL cADDCC
   LOCAL cADDBCC
   LOCAL cSend
   LOCAL cAttList := ""
   LOCAL nAttach  := 0
   LOCAL nInd
   LOCAL cErrMsg  := ""
   LOCAL nRet     := 0
   LOCAL nLoginMethod := NIL
   LOCAL xHBody, xHCB
   LOCAL cBCC    := ::cBCC  //BCC impostato sul dbstart.ini
   LOCAL nDll    := 0
   LOCAL oCDOMsg
   LOCAL oCDOCfg

   ::cMsg     := ""
   ::nError   := 0

   nDll := DllLoad( "DBMAIL.DLL")
   IF nDll != 0
      cInit   := _DllPrepareCall( nDLL, DLL_STDCALL, "dbmailinit", .F.)
      cADDTO  := _DllPrepareCall( nDLL, DLL_STDCALL, "dbmailto", .F.)
      cADDCC  := _DllPrepareCall( nDLL, DLL_STDCALL, "dbmailcc", .F.)
      cADDBCC := _DllPrepareCall( nDLL, DLL_STDCALL, "dbmailbcc", .F.)
      cSend   := _DllPrepareCall( nDLL, DLL_STDCALL, "dbmailsend", .F.)

      IF len(cInit) != 0
         DLLExecuteCall( cInit )
         AEVAL( ::aTo    , {|aSubTo | DLLExecuteCall( cADDTO , aSubTO[1] , aSubTO[2]  ) } )
         AEVAL( ::aCC    , {|aSubCC | DLLExecuteCall( cADDCC , aSubCC[1] , aSubCC[2]  ) } )
         AEVAL( ::aBCC   , {|aSubBCC| DLLExecuteCall( cADDBCC, aSubBCC[1], aSubBCC[2] ) } )

         //Maudp 07/04/2011 Aggiungo nel BCC gli indirizzi impostati sul dbstart.ini
         IF !EMPTY(cBCC)
            DLLExecuteCall( cADDBCC,STRTRAN(ALLTRIM(cBCC),",",";"),"" ) 
         ENDIF
         
         FOR nInd := 1 TO LEN(::aAttach)
            IF FILE(::aAttach[nInd])
               
               // Da fare:
               //   copia su file temporaneo con "," sostituita in "_"
               //IF "," $ ::aAttach[nInd]
               //ENDIF

               cAttList+=::aAttach[nInd]+","
               nAttach++
            ENDIF
         NEXT

         IF nAttach > 0
            // Tolgo "," finale
            cAttList := LEFT(cAttList,LEN(cAttList)-1)
         ENDIF

         // body HTML
         IF ::cHtmlBody == NIL
            xHBody := 0
            xHCB   := ""
         ELSE
            xHBody := ::cHTMLBody
            xHCB   := ::cHTMLContentBase
         ENDIF

         nLoginMethod := ::nLoginMethod
         // se non specificato imposta il metodo di login 2 se c'Š user
         DEFAULT nLoginMethod TO IIF(EMPTY(::cUser), 0, 2)

         cErrMsg := SPACE(1100)
         nRet := DLLExecuteCall( cSend, ::cServer, ::cFROM, ::cSubject, ::cBody, ::cReplyto, ;
                                 cAttList, nAttach, @cErrMsg, ;
                                 xHBody, xHCB, nLoginMethod, ::cUser, ;
                                 ::cPassword, ::nConnectionPort, 0)

         nInd:=AT(CHR(0), cErrMsg)
         IF nInd > 0
            cErrMsg := LEFT(cErrMsg, nInd-1)
         ENDIF
         ::cMsg := cErrMsg
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

   // Simone 2/2/11
   // per log invio email/fax
   IF ::bOnSend != NIL
      EVAL(::bOnSend, self, ::nError, ::cMsg)
   ENDIF
RETURN nRet
