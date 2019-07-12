/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/
#include "dfReport.ch"

#ifdef __XPP__
   #include "dfWinRep.ch"
#endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfPrnIni( aBuf )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cStr := aBuf[REP_SETUP] // Setto la Stampante

IF aBuf[REP_IS_CONDENSED    ]; cStr += aBuf[REP_COND_ON]; ENDIF // Attivo Condensed
IF aBuf[REP_IS_NLQ          ]; cStr += aBuf[REP_NLQ_ON ]; ENDIF // Attivo NLQ
IF aBuf[REP_USEUSER1        ]; cStr += aBuf[REP_USER1ON]; ENDIF // Attivo User1
IF aBuf[REP_USEUSER2        ]; cStr += aBuf[REP_USER2ON]; ENDIF // Attivo User2
IF aBuf[REP_USEUSER3        ]; cStr += aBuf[REP_USER3ON]; ENDIF // Attivo User3

#ifdef __XPP__
IF ! EMPTY(aBuf[REP_XBASEFONT]); cStr += DFWINREP_FONTON+aBuf[REP_XBASEFONT]+";"; ENDIF // Attivo User3
#endif

// Devo finire di gestirlo
//IF dfSet(AI_REPUSEPAGELENGHT); cStr += aBuf[REP_USER3ON]; ENDIF // Attivo User3

RETURN cStr
