//*****************************************************************************
//Progetto       : dBsee for Xbase++
//Descrizione    : Invio Email
//Programmatore  : Simone Degl'Innocenti
//*****************************************************************************
*/

#INCLUDE "Common.CH"
#INCLUDE "dfWin.ch"
#INCLUDE "dfMsg.CH"
#INCLUDE "dfMsg1.CH"
#INCLUDE "dfset.ch"
#INCLUDE "dfNet.ch"
#INCLUDE "dfCTRL.ch"


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfMailCompose(cTo   ,;  // Send To
                       cCC   ,;  // Send CC
                       cBCC  ,;  // Send BCC
                       cSubj ,;  // Subject of message
                       cBody ,;  // Body of message
                       aAtt  ,;  // Array of Attachment
                       xMail ,;  // Mail Method
                       lSend ,;   // Send the email
                       bAddressBook, ; // code block to show the address list
                       cEnable ) // enabled fields
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL oMail
   LOCAL aTo
   LOCAL aCC
   LOCAL aBCC
   LOCAL lOk

#ifndef __XPP__
   // if it is not Xbase++ return NIL
   RETURN NIL
#endif


   DEFAULT cTo   TO ""
   DEFAULT cCC   TO ""
   DEFAULT cBCC  TO ""
   DEFAULT cSubj TO ""
   DEFAULT cBody TO ""
   DEFAULT aAtt  TO {}
   DEFAULT lSend TO .T.
   DEFAULT cEnable TO "-TO-CC-BCC-SUBJECT-BODY-"

   cTo   := PAD(cTo  , 200)
   cCC   := PAD(cCC  , 200)
   cBCC  := PAD(cBCC , 200)
   cSubj := PAD(cSubj, 200)

   cEnable := UPPER(ALLTRIM(cEnable))

   lOk   := dfMailForm(@cTo, @cCC, @cBCC, @cSubj, @cBody, aAtt, bAddressBook, cEnable)

   // Normalize the email address and subject so they can be
   // returned by reference
   // Simone 5/set/03 gerr 3927
   aTo   := S2EmailAddressNormalize(@cTo)
   aCC   := S2EmailAddressNormalize(@cCC)
   aBCC  := S2EmailAddressNormalize(@cBCC)
//   aTo   := dfNormalize(@cTo)
//   aCC   := dfNormalize(@cCC)
//   aBCC  := dfNormalize(@cBCC)
   cSubj := RTRIM(cSubj)

   IF lOk

      // Different methods to initialize the email object (via MAPI or SMTP)
      DO CASE
         CASE VALTYPE(xMail) == "O"
            // If xMail is an object use it
            // (suppose it is of class S2Mail/S2MAPI)
            oMail := xMail

         CASE VALTYPE(xMail) == "A" .AND. LEN(xMail) >= 2
            // If xMail is an array of at least 2 elements
            // use SMTP email
            // - The first element is the smtp server
            // - The second the name of the sender address
            // - The third if defined is the reply-to address
            //   (defaults to the sender address)

            // Set the object to send email via SMTP
            oMail := S2Mail():new()

            // The SMTP server  ex. "smtp.dbsee.com"
            oMail:cServer  := ALLTRIM(xMail[1])

            // The from address ex. "Supporto dBsee <supportx@dbsee.com>"
            oMail:cFROM    := ALLTRIM(xMail[2])
            oMail:cReplyTo := IIF(LEN(xMail) >= 3, xMail[3], oMail:cFROM)
            oMail:cUser    := IIF(LEN(xMail) >= 5, xMail[4], oMail:cUser)
            oMail:cPassword:= IIF(LEN(xMail) >= 5, xMail[5], oMail:cPassword)
            oMail:nLoginMethod:= IIF(LEN(xMail) >= 6, xMail[6], oMail:nLoginMethod)

         CASE VALTYPE(xMail) == "C"
            // if xMail is a character suppose it is a parameter
            // for S2EmailGeneric() function and use it
            oMail := S2EmailGeneric(NIL, xMail)

         OTHERWISE
            // DEFAULT: Set the object to send email via MAPI
            //Luca cambiato il defualt. Se Š impostato SMTP deve usare smtp
            //oMail := S2Mapi():new()
            oMail := S2EmailGeneric(NIL)
      ENDCASE

      // Set the subject and body of message
      oMail:cSubject := cSubj
      oMail:cBody    := cBody

      // Set the address to send
      AEVAL(aTo , {|cAddr| oMail:addTo(cAddr)  })
      AEVAL(aCC , {|cAddr| oMail:addCC(cAddr)  })
      AEVAL(aBCC, {|cAddr| oMail:addBCC(cAddr) })

      // Set the attach files
      AEVAL(aAtt, {|cFile| oMail:addAttach(cFile) })

      IF lSend
         oMail:send()
      ENDIF

   ENDIF
RETURN oMail

// Normalize the email address
//STATIC FUNCTION dfNormalize(cAddr)
//   LOCAL aAddr
//   cAddr := STRTRAN(ALLTRIM(cAddr), ",", ";")
//   aAddr := dfStr2Arr(cAddr, ";")
//   cAddr := ""
//   AEVAL(aAddr, {|x,n| aAddr[n] := ALLTRIM(aAddr[n]), ;
//                       cAddr += aAddr[n] + IIF(n < LEN(aAddr), ";", "")})
//RETURN aAddr

// Show the email form
STATIC FUNCTION dfMailForm(cTo,cCC,cBCC,cSubj,cBody,aAtt,bAddressBook, cEnable)
   LOCAL aCtrl := {}
   LOCAL lsbAtt
   //Mantis 2249 Luca 18/08/2014
   ATTACH "box0004" TO aCtrl BOX 01                                        ;
                    AT   -0.2,  0,  6.9, 70                                   ;
                 BOXTEXT "Informazioni di spedizione..."          ; // BOX Text
                 BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                 COLOR {"W+/G","B+/G","N/G"}         // Array dei colori

//   ATTACH "box0006" TO aCtrl BOX 01                                        ;
//                    AT   0,  0,  4, 70                                     ;
//                    COLOR {"W+/G","B+/G","N/G"}

   IF VALTYPE(bAddressBook)=="B"
      ATTACH "_TO"   TO aCtrl GET AS PUSHBUTTON dfStdMsg1(MSG1_DFMAILCO01)  ;
                       AT  0, 1, 2, 9                                     ;
                       COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}     ;
                       FUNCTION {||setaddress(bAddressBook, 1, @cTo, "cTo")}     ;
                       ACTIVE {|| "-TO-" $ cEnable }                         ;
                       MESSAGE ""

      ATTACH "cTo" TO aCtrl GET cTo AT   1, 10                                ;
                       COLOR  {"N/G","G+/G","N/W*","W+/BG"}                   ;
                       PICTURESAY "@S60"                                      ;
                       CONDITION {|ab| "-TO-" $ cEnable .AND. dfChkTo(ab,cTo,cCC,cBCC) }             ;
                       MESSAGE dfStdMsg1(MSG1_DFMAILCO02)                     ;
                       VARNAME "cTo"

      ATTACH "_CC"   TO aCtrl GET AS PUSHBUTTON dfStdMsg1(MSG1_DFMAILCO03)  ;
                       AT  1.1, 1, 3.1, 9                                     ;
                       COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}     ;
                       FUNCTION {||setaddress(bAddressBook, 2, @cCC, "cCC")}     ;
                       ACTIVE {|| "-CC-" $ cEnable }                         ;
                       MESSAGE ""
      ATTACH "cCC" TO aCtrl GET cCC AT   2.1, 10                                ;
                       COLOR  {"N/G","G+/G","N/W*","W+/BG"}                   ;
                       PICTURESAY "@S60"                                      ;
                       CONDITION {|ab| "-CC-" $ cEnable .AND. dfChkTo(ab,cTo,cCC,cBCC) }             ;
                       MESSAGE dfStdMsg1(MSG1_DFMAILCO04)                     ;
                       VARNAME "cCC"

      ATTACH "_BCC"   TO aCtrl GET AS PUSHBUTTON dfStdMsg1(MSG1_DFMAILCO05)  ;
                       AT  2.2, 1, 4.2, 9                                     ;
                       COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}     ;
                       FUNCTION {||setaddress(bAddressBook, 3, @cBCC, "cBCC")}     ;
                       ACTIVE {|| "-BCC-" $ cEnable }                         ;
                       MESSAGE ""

      ATTACH "cBCC" TO aCtrl GET cBCC AT   3.2, 10                              ;
                       COLOR  {"N/G","G+/G","N/W*","W+/BG"}                   ;
                       PICTURESAY "@S60"                                      ;
                       CONDITION {|ab| "-BCC-" $ cEnable .AND. dfChkTo(ab,cTo,cCC,cBCC) }             ;
                       MESSAGE dfStdMsg1(MSG1_DFMAILCO06)                     ;
                       VARNAME "cBCC"
   ELSE
      ATTACH "cTo" TO aCtrl GET cTo AT   1, 10                                ;
                       COLOR  {"N/G","G+/G","N/W*","W+/BG"}                   ;
                       PROMPT  dfStdMsg1(MSG1_DFMAILCO01)                     ;
                       PROMPTAT   1 ,  6                                      ;
                       PICTURESAY "@S60"                                      ;
                       CONDITION {|ab| "-TO-" $ cEnable .AND. dfChkTo(ab,cTo,cCC,cBCC) }             ;
                       MESSAGE dfStdMsg1(MSG1_DFMAILCO02)                     ;
                       VARNAME "cTo"

      ATTACH "cCC" TO aCtrl GET cCC AT   2.1, 10                                ;
                       COLOR  {"N/G","G+/G","N/W*","W+/BG"}                   ;
                       PROMPT  dfStdMsg1(MSG1_DFMAILCO03)                     ;
                       PROMPTAT   2.1 ,  5                                      ;
                       PICTURESAY "@S60"                                      ;
                       CONDITION {|ab| "-CC-" $ cEnable .AND. dfChkTo(ab,cTo,cCC,cBCC) }             ;
                       MESSAGE dfStdMsg1(MSG1_DFMAILCO04)                     ;
                       VARNAME "cCC"

      ATTACH "cBCC" TO aCtrl GET cBCC AT   3.2, 10                              ;
                       COLOR  {"N/G","G+/G","N/W*","W+/BG"}                   ;
                       PROMPT  dfStdMsg1(MSG1_DFMAILCO05)                     ;
                       PROMPTAT   3.2 ,  4                                      ;
                       PICTURESAY "@S60"                                      ;
                       CONDITION {|ab| "-BCC-" $ cEnable .AND. dfChkTo(ab,cTo,cCC,cBCC) }             ;
                       MESSAGE dfStdMsg1(MSG1_DFMAILCO06)                     ;
                       VARNAME "cBCC"
   ENDIF
   ATTACH "cSubj" TO aCtrl GET cSubj AT   5.3, 10                            ;
                    COLOR  {"N/G","G+/G","N/W*","W+/BG"}                   ;
                    PROMPT  dfStdMsg1(MSG1_DFMAILCO07)                     ;
                    PROMPTAT   5.3 ,  1                                      ;
                    PICTURESAY "@S60"                                      ;
                    CONDITION {|ab| "-SUBJECT-" $ cEnable .AND. dfChkSubject(ab,cSubj) }               ;
                    MESSAGE dfStdMsg1(MSG1_DFMAILCO08)                     ;
                    VARNAME "cSubj"

   ATTACH "cBody" TO aCtrl GET AS TEXTFIELD cBody AT   7,  0, 15, 70       ;
                    COLOR {"W+/G","G+/G","N/W*","W+/BG","N/G","BG/G"}      ;
                    PROMPT dfStdMsg1(MSG1_DFMAILCO09)                      ;
                    CONDITION {|ab| "-BODY-" $ cEnable }                  ;
                    VARNAME "cBody"                                        ;
                    MESSAGE dfStdMsg1(MSG1_DFMAILCO10)

   ATTACH "__WRI"   TO aCtrl GET AS PUSHBUTTON dfStdMsg1(MSG1_DFMAILCO11)  ;
                    AT  16, 61, 20, 69                                     ;
                    COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}     ;
                    FUNCTION {||dbAct2Kbd("wri")}                          ;
                    MESSAGE ""

   lsbAtt := 0->(tbBrwNew( 16, 0.5, 20, 58.5, W_OBJ_ARRAYBOX))

   lsbAtt:W_TITLE      := dfStdMsg1(MSG1_DFMAILCO12)
   lsbAtt:W_COLORARRAY[AC_LSB_BACK  ]      := "N/W*"
   lsbAtt:W_COLORARRAY[AC_LSB_TOPLEFT]     := "N/G"
   lsbAtt:W_COLORARRAY[AC_LSB_BOTTOMRIGHT] := "BG/G"
   lsbAtt:W_COLORARRAY[AC_LSB_PROMPT]      := "GR+/G"
   lsbAtt:W_COLORARRAY[AC_LSB_HILITE]      := "W+/BG"
   lsbAtt:W_COLORARRAY[AC_LSB_HOTKEY]      := "G+/G"
   lsbAtt:COLORSPEC    := "N/W*"
   lsbAtt:W_MOUSEMETHOD:= W_MM_EDIT + W_MM_VSCROLLBAR
   lsbAtt:W_HEADERROWS := 0

   ADDKEY "anr" TO lsbAtt:W_KEYBOARDMETHODS           ;
          BLOCK   {||dfAddAttach(lsbAtt,aAtt)}          ;
          MESSAGE dfStdMsg1(MSG1_DFMAILCO13)
   ADDKEY "ecr" TO lsbAtt:W_KEYBOARDMETHODS           ;
          BLOCK   {||dfDelAttach(lsbAtt,aAtt)}          ;
          MESSAGE dfStdMsg1(MSG1_DFMAILCO14)

   ATTACH COLUMN "expAttach" TO lsbAtt                               ;
                          BLOCK    {|| tbGetArr(lsbAtt,aAtt,NIL) }   ;
                          PICTURE REPLICATE("X", 100)                ;
                          WIDTH    100                               ;
                          COLOR  {"B+/W*","BG/W*","W+/BG"}           ;
                          MESSAGE ""
   tbArrLen( lsbAtt ,LEN(aAtt) )
   ATTACH "lsbAtt" TO aCtrl GET AS LISTBOX USING lsbAtt

   ATTACH "__ATT"   TO aCtrl GET AS PUSHBUTTON dfStdMsg1(MSG1_DFMAILCO13)  ;
                    AT  19.6, 0.0, 21.6, 18                                     ;
                    COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}     ;
                    FUNCTION {||dfAddAttach(lsbAtt,aAtt)}                  ;
                    MESSAGE dfStdMsg1(MSG1_DFMAILCO13)                                          


RETURN dfAutoForm(NIL,NIL,aCtrl, dfStdMsg1(MSG1_DFMAILCO15))

STATIC FUNCTION setaddress(bAddressBook, nID, cVar, cVarID)
   LOCAL oWin := S2FormCurr()
   LOCAL cNew := TRIM(cVar)

   EVAL(bAddressBook, nID, @cNew, oWin)

   IF ! cNew == cVar
      cVar := PAD(cNew, LEN(cVar))
      tbDisItm(oWin, cVarID)
   ENDIF
RETURN .T.

STATIC FUNCTION dfChkSubject(ab, cSubj)
   LOCAL lRet := .T.

   IF ab == FORM_CHKGET .AND. EMPTY(cSubj)
      lRet := dfYesNo(dfStdMsg1(MSG1_DFMAILCO17))
   ENDIF
RETURN lRet

STATIC FUNCTION dfChkTo(ab, cTo, cCC,cBCC)
   LOCAL lRet := .T.

   IF ab == FORM_CHKGET .AND. EMPTY(cTo) .AND. EMPTY(cCC) .AND. EMPTY(cBCC)
      dbMsgErr(dfStdMsg1(MSG1_DFMAILCO18))
      lRet := .F.
   ENDIF
RETURN lRet

STATIC FUNCTION dfAddAttach(lsbAtt, aAtt)
   LOCAL cFile
   cFile := dfWinFileDlg(NIL,NIL,dfStdMsg1(MSG1_DFMAILCO16))

   // Work around because the focus is set to next control
   // after the call to dfWinFileDlg()
   dbAct2Kbd("Stb")

   IF ! EMPTY(cFile)
      AADD(aAtt,cFile)
      tbAtr(lsbAtt)
   ENDIF

RETURN .T.

STATIC FUNCTION dfDelAttach(lsbAtt, aAtt)
   LOCAL nInd := tbRow(lsbAtt)
   IF LEN(aAtt) > 0 .AND. nInd >= 1 .AND. nInd <= LEN(aAtt)
      IF nInd > LEN(aAtt)-1
         tbUp(lsbAtt)
      ENDIF
      DFAERASE(aAtt, nInd)
      lsbAtt:W_AI_LENGHT := LEN(aAtt)
      tbRtr(lsbAtt)
   ENDIF
RETURN .T.

