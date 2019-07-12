//*****************************************************************************
//Progetto       : dBsee 4.1
//Descrizione    : Funzioni di utilita' per FILE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfSec2Time( nSec )  // Converte i secondi in ora - HH:MM:SS
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nTmpSec := 0, cRet := "00:00:00"

DEFAULT nSec TO SECONDS()

nSec    := INT(nSec)
IF nSec>0
   nTmpSec := INT( nSec/3600 )
   cRet    := ALLTRIM(STR(nTmpSec))
   cRet    := PADL(cRet,MAX(2,LEN(cRet)),"0")+":"
   nSec    := nSec - nTmpSec*3600

   nTmpSec := INT( nSec/60 )
   cRet    += PADL(ALLTRIM(STR(nTmpSec)),2,"0")+":"
   nSec    := nSec - nTmpSec*60

   cRet    += PADL(ALLTRIM(STR(nSec)),2,"0")
ENDIF

RETURN cRet
