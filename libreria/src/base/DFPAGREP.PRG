//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per STAMPE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "dfReport.ch" // Struttura Report e Virtual record
#INCLUDE "dfCTRL.ch"   // Maschere di Data Entry
#INCLUDE "dfSet.ch"    // Settaggi d'ambiente
#INCLUDE "dfMsg.ch"    // Messaggistica
#INCLUDE "dfStd.ch"    // Standard
#INCLUDE "dfWinRep.ch" // report windows

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfPageRep( aBuf ) // Settaggio Margini
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aPage := {}
LOCAL lAllPage := aBuf[REP_ALLPAGE]
LOCAL nFromPg  := aBuf[REP_FROMPAGE]
LOCAL nToPg    := aBuf[REP_TOPAGE]

dfPushAct()

ATTACH "01" TO aPage GET AS CHECKBOX aBuf[REP_ALLPAGE]  ;
                     PROMPT  dfStdMsg(MSG_DFPRNSTART41) AT 1, 0 ;
                     VALUEON  .T.                       ;
                     VALUEOFF .F.                       ;
                     GAP 1                              ;
                     MESSAGE dfStdMsg(MSG_DFPRNSTART41)

ATTACH "02" TO aPage BOX 1 AT 2,  3, 5, 22 FILL " "

ATTACH "03" TO aPage GET aBuf[REP_FROMPAGE]             ;
                     AT  3, 17                          ;
                     PROMPT dfStdMsg(MSG_DFPRNSTART43)  ;
                     PROMPTAT 3, 4                      ;
                     MESSAGE dfStdMsg(MSG_DFPRNSTART44) ;
                     PICTURESAY "99999"                 ;
                     ACTIVE !aBuf[REP_ALLPAGE]

ATTACH "04" TO aPage GET aBuf[REP_TOPAGE]               ;
                     AT  4, 17                          ;
                     PROMPT dfStdMsg(MSG_DFPRNSTART45)  ;
                     PROMPTAT 4, 4                      ;
                     MESSAGE dfStdMsg(MSG_DFPRNSTART46) ;
                     PICTURESAY "99999"                 ;
                     ACTIVE !aBuf[REP_ALLPAGE]

IF ! dfAutoForm( NIL, NIL, aPage, dfStdMsg(MSG_DFPRNSTART47) )
   // Simone 5/1/05 gerr 4260
   aBuf[REP_ALLPAGE] := lAllPage 
   aBuf[REP_FROMPAGE]:= nFromPg  
   aBuf[REP_TOPAGE]  := nToPg    
ENDIF

dfPopAct()
RETURN
