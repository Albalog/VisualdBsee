#include "common.ch"
#include "dfXbase.ch"

FUNCTION S2EMailGeneric(xTo, cType, cServer, cFrom, cReply, cUser, cPwd, nLoginMethod)
   LOCAL oMail
   LOCAL lSMTP := .T.
   LOCAL aTo := {}

   IF VALTYPE(xTo) == "C"
      //aTo := dfStr2Arr(xTo, ";")
      aTo := S2EmailAddressNormalize(xTo)
   ENDIF

   DEFAULT cType   TO "" // Tutte

   cType := UPPER(ALLTRIM(cType))
   //Luca 14/07/2015
   //IF EMPTY(cType) .OR. cType == DFEMAILGENERIC_SMTP // TUTTE o solo SMTP
   IF EMPTY(cType) .OR. cType == UPPER(ALLTRIM(DFEMAILGENERIC_SMTP)) // TUTTE o solo SMTP
      DEFAULT cServer TO dfSet("XbaseSMTPServer")
      DEFAULT cFrom   TO dfSet("XbaseSMTPFrom")
      DEFAULT cReply  TO dfSet("XbaseSMTPReplyTo")
      DEFAULT cUser   TO dfSet("XbaseSMTPUser")
      DEFAULT cPwd    TO dfSet("XbaseSMTPPassword")
      DEFAULT nLoginMethod TO dfSet("XbaseSMTPLoginMethod")
      IF nLoginMethod != NIL
         nLoginMethod := VAL(nLoginMethod)
      ENDIF


      lSMTP := ! EMPTY(cServer) .AND. ! EMPTY(cFrom)
      IF lSMTP
         AEVAL(aTo, {|x| IIF(S2EmailIsOK(x), NIL, lSMTP := .F. ) })
      ENDIF

   ELSE
      lSMTP := .F.
   ENDIF

   // Se ci sono tutte le condizioni per usare SMTP
   // lo usa altrimenti usa MAPI
   IF lSMTP

      oMail := S2Mail():new()
      oMail:cServer  := cServer
      oMail:cFROM    := cFrom
      oMail:cReplyTo := IIF(cReply != NIL, cReply, oMail:cFrom)
      oMail:cUser    := cUser
      oMail:cPassword:= cPwd
      oMail:nLoginMethod:=nLoginMethod
   ELSE
      oMail := S2Mapi():new()
   ENDIF

   AEVAL(aTo, {|cTo| oMail:addTo( cTO ) })

RETURN oMail

// Controlla se un indirizzo EMAIL Š OK
FUNCTION S2EmailIsOk(cEmail)
   LOCAL nPos := 0
   LOCAL lOk := ! EMPTY(cEmail) .AND. LEN(cEmail) >= 3 // almeno x@y

   IF lOk
      nPos := AT("@", cEmail)
      lOk := nPos > 1 .AND. nPos < LEN(cEmail)
   ENDIF

RETURN lOk

// Simone 5/set/03 gerr 3927
// Normalize the email address
// return an array of addresses
// return by reference the normalized address

FUNCTION S2EmailAddressNormalize(cAddr)
   LOCAL aAddr
   cAddr := STRTRAN(ALLTRIM(cAddr), ",", ";")
   aAddr := dfStr2Arr(cAddr, ";")
   cAddr := ""
   AEVAL(aAddr, {|x,n| aAddr[n] := ALLTRIM(aAddr[n]), ;
                       cAddr += aAddr[n] + IIF(n < LEN(aAddr), ";", "")})
RETURN aAddr
