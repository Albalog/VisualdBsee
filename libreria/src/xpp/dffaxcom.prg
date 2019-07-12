//*****************************************************************************
//Progetto       : dBsee for Xbase++
//Descrizione    : Invio Fax
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


* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
FUNCTION dfFaxCompose(cTo   ,;  // Send To
                      cSubj ,;  // Subject of message
                      cBody ,;  // Body of message
                      aAtt  ,;  // Array of Attachment
                      lSend ,;   // Send the FAX
                      bAddressBook, ; // code block to show the address list
                      cEnable ) // enabled fields
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
   LOCAL oFax
   LOCAL aTo
   LOCAL aCC
   LOCAL aBCC
   LOCAL lOk

#ifndef __XPP__
   // if it is not Xbase++ return NIL
   RETURN NIL
#endif


   DEFAULT cTo   TO ""
   DEFAULT cSubj TO ""
   DEFAULT cBody TO ""
   DEFAULT aAtt  TO {}
   DEFAULT lSend TO .T.
   DEFAULT cEnable TO "-TO-SUBJECT-BODY-"

   cTo   := PAD(cTo  , 200)
   cSubj := PAD(cSubj, 200)

   cEnable := UPPER(ALLTRIM(cEnable))


   lOk   := dfFaxForm(@cTo, @cSubj, @cBody, aAtt, bAddressBook, cEnable)

   // Normalize the Fax address and subject so they can be
   // returned by reference
   // Simone 5/set/03 gerr 3927
   aTo   := S2EmailAddressNormalize(@cTo)
//   aTo   := dfNormalize(@cTo)
//   aCC   := dfNormalize(@cCC)
//   aBCC  := dfNormalize(@cBCC)
   cSubj := RTRIM(cSubj)

   IF lOk

      oFax := S2MapiFax():new()

      // Set the subject and body of message
      oFax:cSubject := cSubj
      oFax:cBody    := cBody

      // Set the address to send
      AEVAL(aTo , {|cAddr| oFax:addTo(cAddr)  })

      // Set the attach files
      AEVAL(aAtt, {|cFile| oFax:addAttach(cFile) })

      IF lSend
         oFax:send()
      ENDIF

   ENDIF
RETURN oFax

// Show the email form
STATIC FUNCTION dfFaxForm(cTo,cSubj,cBody,aAtt,bAddressBook, cEnable)
   LOCAL aCtrl := {}
   LOCAL lsbAtt
//   ATTACH "box0004" TO aCtrl BOX 01                                        ;
//                    AT   0,  0,  6, 70                                     ;
//                    COLOR {"W+/G","B+/G","N/G"}

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
                       CONDITION {|ab| "-TO-" $ cEnable .AND. dfChkTo(ab,cTo) }                      ;
                       MESSAGE dfStdMsg1(MSG1_DFMAILCO02)                     ;
                       VARNAME "cTo"

   ELSE
      ATTACH "cTo" TO aCtrl GET cTo AT   1, 10                                ;
                       COLOR  {"N/G","G+/G","N/W*","W+/BG"}                   ;
                       PROMPT  dfStdMsg1(MSG1_DFMAILCO01)                     ;
                       PROMPTAT   1 ,  6                                      ;
                       PICTURESAY "@S60"                                      ;
                       CONDITION {|ab| "-TO-" $ cEnable .AND. dfChkTo(ab,cTo) }                      ;
                       MESSAGE dfStdMsg1(MSG1_DFMAILCO02)                     ;
                       VARNAME "cTo"

   ENDIF
   ATTACH "cSubj" TO aCtrl GET cSubj AT   3, 10                            ;
                    COLOR  {"N/G","G+/G","N/W*","W+/BG"}                   ;
                    PROMPT  dfStdMsg1(MSG1_DFMAILCO07)                     ;
                    PROMPTAT   3 ,  0                                      ;
                    PICTURESAY "@S60"                                      ;
                    CONDITION {|ab| "-SUBJECT-" $ cEnable .AND. dfChkSubject(ab,cSubj) }               ;
                    MESSAGE dfStdMsg1(MSG1_DFMAILCO08)                     ;
                    VARNAME "cSubj"

   ATTACH "cBody" TO aCtrl GET AS TEXTFIELD cBody AT   5,  0, 15, 70       ;
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
/*
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
                          PICTURE REPLICATE("X", 65)                 ;
                          WIDTH    58                                ;
                          COLOR  {"B+/W*","BG/W*","W+/BG"}           ;
                          MESSAGE ""
   tbArrLen( lsbAtt ,LEN(aAtt) )
   ATTACH "lsbAtt" TO aCtrl GET AS LISTBOX USING lsbAtt

   ATTACH "__ATT"   TO aCtrl GET AS PUSHBUTTON dfStdMsg1(MSG1_DFMAILCO13)  ;
                    AT  19.6, 0.0, 21.6, 18                                     ;
                    COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}     ;
                    FUNCTION {||dfAddAttach(lsbAtt,aAtt)}                  ;
                    MESSAGE dfStdMsg1(MSG1_DFMAILCO13)                                          

*/
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

STATIC FUNCTION dfChkTo(ab, cTo)
   LOCAL lRet := .T.

   IF ab == FORM_CHKGET .AND. EMPTY(cTo)
      dbMsgErr(dfStdMsg1(MSG1_DFMAILCO18))
      lRet := .F.
   ENDIF
RETURN lRet
/*
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
*/
