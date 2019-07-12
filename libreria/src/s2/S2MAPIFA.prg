CLASS S2MapiFAX FROM S2Mapi
   PROTECTED:
      METHOD CvtIndirizzo
      METHOD Cvt2Std

   EXPORTED:
      METHOD getTo
      METHOD getCC
      METHOD getBCC

      METHOD addTo
      METHOD addCC
      METHOD addBCC

      METHOD init //Ridefinisco metodo init per byPassare il BCC
ENDCLASS

// Aggiunge la stringa [FAX: ]
METHOD S2MapiFAX:CvtIndirizzo(cMapi)
   IF ! EMPTY(cMapi) .AND. VALTYPE(cMapi) $ "CM"
      cMapi := "[FAX: "+ALLTRIM(cMapi)+"]"
   ENDIF
RETURN cMapi

METHOD S2MapiFAX:addTo(cMapi,cNick)
   ::S2Mapi:addTo( ::CvtIndirizzo(cMapi), cNick)
RETURN self

METHOD S2MapiFAX:addCC(cMapi,cNick)
   ::S2Mapi:addCC( ::CvtIndirizzo(cMapi), cNick)
RETURN self

METHOD S2MapiFAX:addBCC(cMapi,cNick)
   ::S2Mapi:addBCC( ::CvtIndirizzo(cMapi), cNick)
RETURN self

METHOD S2MapiFAX:cvt2Std(a)
   LOCAL aRet := {}
   LOCAL n, c
   LOCAL cAddrTo

   FOR n := 1 TO LEN(a)
      cAddrTo := a[n][1]

      IF LEFT(cAddrTo, 6) == "[FAX: "
         // tolgo eventuale indirizzo in formato FAX MAPI
         cAddrTo := SUBSTR(cAddrTo, 6)  // escludo "[FAX:" iniziale
         cAddrTo := LEFT(cAddrTo, LEN(cAddrTo)-1) // escludo "]" finale
         cAddrTo := ALLTRIM(cAddrTo)
      ENDIF
      AADD(aRet, {cAddrTo, a[n][2]})
   NEXT
RETURN aRet

METHOD S2MapiFAX:getTo()
RETURN ::cvt2std(::S2Mapi:getTo())

METHOD S2MapiFAX:getCC()
RETURN ::cvt2std(::S2Mapi:getCC())

METHOD S2MapiFAX:getBCC()
RETURN ::cvt2std(::S2Mapi:getBCC())

//simone 08/04/2011 Tolgo gli indirizzi BCC per l'invio dei FAX
METHOD S2MapiFAX:init(cProf, cPwd)
   ::S2Mapi:init(cProf, cPwd)

   // disattivo indirizzo BCC non valido per FAX
   ::cBCC := ""
RETURN self
