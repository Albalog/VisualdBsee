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
PROCEDURE dfChoSet( aBuf ) // Settaggio Margini
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aLayOut := {}, nGap := LEN(aBuf[REP_NAME]) +10
LOCAL nPageLen := aBuf[REP_PAGELENGHT]
LOCAL nMgnTop  := aBuf[REP_MGN_TOP]
LOCAL nMgnBott := aBuf[REP_MGN_BOTTOM]
LOCAL nMgnLeft := aBuf[REP_MGN_LEFT]
LOCAL lNoEject := aBuf[REP_NO_EJECT]

dfPushAct()
nGap := INT(MAX(nGap-27,0)/2)
ATTACH "01" TO aLayOut GET aBuf[REP_PAGELENGHT]       ;
                    AT  1, 22+nGap                    ;
                    PROMPT dfStdMsg(MSG_DFPRNSTART23) ;
                    PROMPTAT 1, 3+nGap                ;
                    MESSAGE dfStdMsg(MSG_DFPRNSTART23);
                    PICTUREGET "999"

ATTACH "02" TO aLayOut GET aBuf[REP_MGN_TOP]          ;
                    AT  2, 22+nGap                    ;
                    PROMPT dfStdMsg(MSG_DFPRNSTART24) ;
                    PROMPTAT 2, 3+nGap                ;
                    CONDITION {|ab|dfMgnTop(ab,aBuf)}      ; // When/Valid function
                    MESSAGE dfStdMsg(MSG_DFPRNSTART24);
                    PICTUREGET "999"

ATTACH "03" TO aLayOut GET aBuf[REP_MGN_BOTTOM]       ;
                    AT  3, 22+nGap                    ;
                    PROMPT dfStdMsg(MSG_DFPRNSTART25) ;
                    PROMPTAT 3, 3+nGap                ;
                    MESSAGE dfStdMsg(MSG_DFPRNSTART25);
                    PICTUREGET "999"

ATTACH "04" TO aLayOut GET aBuf[REP_MGN_LEFT]         ;
                    AT  4, 22+nGap                    ;
                    PROMPT dfStdMsg(MSG_DFPRNSTART26) ;
                    PROMPTAT 4, 3+nGap                ;
                    MESSAGE dfStdMsg(MSG_DFPRNSTART26);
                    PICTUREGET "999"

ATTACH "05" TO aLayOut GET AS CHECKBOX aBuf[REP_NO_EJECT] ;
                       PROMPT  dfStdMsg(MSG_DFPRNSTART30) AT 6, nGap  ;
                       VALUEON  .T.                       ;
                       VALUEOFF .F.                       ;
                       GAP 1                              ;
                       MESSAGE dfStdMsg(MSG_DFPRNSTART30)


IF ! dfAutoForm( NIL, NIL, aLayOut, dfStdMsg(MSG_DFPRNSTART27) +" - " +aBuf[REP_NAME] )
   // simone 5/1/05 gerr 4260
   // su ESC ripristino
   // nota: negli ATTACH uso sempre aBuf perche la dfMgnTop() funziona su aBuf
   aBuf[REP_PAGELENGHT] := nPageLen  
   aBuf[REP_MGN_TOP]    := nMgnTop   
   aBuf[REP_MGN_BOTTOM] := nMgnBott  
   aBuf[REP_MGN_LEFT]   := nMgnLeft  
   aBuf[REP_NO_EJECT]   := lNoEject  
ENDIF
dfPopAct()
RETURN
