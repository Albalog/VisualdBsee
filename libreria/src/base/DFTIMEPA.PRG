/*******************************************************************************
Progetto       : dBsee 4.3
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
*******************************************************************************/
#include "Common.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfTimePack( cTime )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cReturn := ""

DEFAULT cTIME TO TIME()

DO CASE
   CASE LEN(cTime) == 5
        cReturn := CHR(VAL(LEFT(cTime,2))) +CHR(VAL(RIGHT(cTime,2)))
   CASE LEN(cTIME) == 8
        cReturn := CHR(VAL(LEFT(cTime,2))) +CHR(VAL(SUBSTR(cTime,4,2))) +CHR(VAL(RIGHT(cTime,2)))
ENDCASE

RETURN cReturn


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfTimeUnpack( cPackTime )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cTime := ""

DO CASE
   CASE LEN(cPackTime) == 2
        cTime := STRZERO(ASC(SUBSTR(cPackTime,1,1)),2)+":"+STRZERO(ASC(SUBSTR(cPackTime,2,1)),2)
   CASE LEN(cPackTime) == 3
        cTime := STRZERO(ASC(SUBSTR(cPackTime,1,1)),2)+":"+STRZERO(ASC(SUBSTR(cPackTime,2,1)),2)+":"+STRZERO(ASC(SUBSTR(cPackTime,3,1)),2)
ENDCASE

RETURN cTime
