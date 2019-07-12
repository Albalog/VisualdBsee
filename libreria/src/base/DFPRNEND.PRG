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
FUNCTION dfPrnEnd( aBuf )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cStr := ""

IF aBuf[REP_USEUSER3    ]; cStr += aBuf[REP_USER3OFF]; ENDIF // Disattivo User3
IF aBuf[REP_USEUSER2    ]; cStr += aBuf[REP_USER2OFF]; ENDIF // Disattivo User2
IF aBuf[REP_USEUSER1    ]; cStr += aBuf[REP_USER1OFF]; ENDIF // Disattivo User1
IF aBuf[REP_IS_NLQ      ]; cStr += aBuf[REP_NLQ_OFF ]; ENDIF // Disattivo NLQ
IF aBuf[REP_IS_CONDENSED]; cStr += aBuf[REP_COND_OFF]; ENDIF // Disattivo Condensed

#ifdef __XPP__
IF ! EMPTY(aBuf[REP_XBASEFONT]); cStr += DFWINREP_FONTOFF; ENDIF // Attivo User3
#endif

cStr += aBuf[REP_RESET]       // Resetto la stampante

RETURN cStr
