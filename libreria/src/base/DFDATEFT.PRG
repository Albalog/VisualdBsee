/*******************************************************************************
Progetto       : dBsee 4.4
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
*******************************************************************************/
#include "dfWin.ch"
#include "dfCTRL.ch"
#include "dfMsg.ch"
#include "Set.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDateFT( dStart, dEnd, cForm )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aForm := {}
LOCAL cDateFmt := "99/99/99"

IF ! EMPTY( SET(_SET_DATEFORMAT) )
   cDateFmt := UPPER( SET(_SET_DATEFORMAT) )
   cDateFmt := STRTRAN(cDateFmt, "Y", "9")
   cDateFmt := STRTRAN(cDateFmt, "M", "9")
   cDateFmt := STRTRAN(cDateFmt, "D", "9")
ENDIF


ATTACH "nFat" TO aForm GET dStart  AT 1, 20                                ;
                           PICTUREGET cDateFmt                             ;
                           CONDITION {|ab|dStart(ab,@dStart)}              ;
                           PROMPT dfStdMsg( MSG_DFDATEFT01 ) PROMPTAT 1, 1 ;
                           COMBO

ATTACH "nFat" TO aForm GET dEnd    AT 2, 20                                ;
                           PICTUREGET cDateFmt                             ;
                           CONDITION {|ab|dEnd(ab,@dEnd,dStart)}           ;
                           PROMPT dfStdMsg( MSG_DFDATEFT02 ) PROMPTAT 2, 1 ;
                           COMBO

RETURN dfAutoForm( ,,aForm, cForm )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dStart(ab,dDat)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T.

DO CASE
   CASE ab==FORM_PREGET

   CASE ab==FORM_POSTGET .OR. ab==FORM_CHKGET
        IF M->Act$"Ada-Cda"
           dDat := dfCalendar( dDat )
           M->Act:="rep"
        ENDIF
        lRet := !EMPTY(dDat)
ENDCASE

RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dEnd(ab,dDat,dStart)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T.

DO CASE
   CASE ab==FORM_PREGET

   CASE ab==FORM_POSTGET .OR. ab==FORM_CHKGET
        IF M->Act$"Ada-Cda"
           dDat := dfCalendar( dDat )
           M->Act:="rep"
        ENDIF
        lRet := !EMPTY(dDat) .AND. dDat>=dStart
ENDCASE

RETURN lRet
