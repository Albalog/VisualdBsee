//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per BROWSE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "dfWin.ch"

#ifdef __XPP__
   #define MAX_ARR_LEN MAX( 1, oWar:W_AI_LENGHT )
#else
   #define MAX_ARR_LEN         oWar:W_AI_LENGHT
#endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION _tbASkip( oWar, nRec ) // Skipper
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nRecSkipped := 0

nRecSkipped := nRec

DO CASE
   CASE nRec == 0
   CASE nRec > 0
        IF MAX_ARR_LEN -oWar:W_CURRENTREC <= nRec
           nRecSkipped := MAX_ARR_LEN -oWar:W_CURRENTREC
        ENDIF
   CASE nRec < 0
        IF oWar:W_CURRENTREC <= (-nRec)+1
           nRecSkipped := -(oWar:W_CURRENTREC-1)
        ENDIF
ENDCASE

oWar:W_CURRENTREC += nRecSkipped

RETURN nRecSkipped
