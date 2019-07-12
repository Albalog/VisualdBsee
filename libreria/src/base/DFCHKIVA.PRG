/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/
#include "common.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfChkIva( cIva )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet, nSom := 0, nPari := 0, nCheck := 0, cPari := " ", iInd := 1

DEFAULT cIva TO ""
cIva := ALLTRIM(cIva)

lRet := LEN(cIva)==11

WHILE .T.
   nPari := VAL(SUBSTR(cIva,iInd + 1,1))
   nSom  +=  VAL(SUBSTR(cIva,iInd,1))
   nPari := nPari * 2
   IF nPari > 9
      cPari := STR(nPari,2,0)
      nPari := VAL(SUBSTR(cPari,1,1)) + VAL(SUBSTR(cPari,2,1))
   ENDIF
   nSom += nPari
   iInd += 2
   IF iInd > 9
      EXIT
   ENDIF
ENDDO

nCheck := 10 - VAL(SUBSTR( STR(nSom,2,0) ,2,1))
nCheck := VAL(SUBSTR( STR(nCheck,2,0) ,2,1))

IF nCheck != VAL(SUBSTR(cIva,11,1))
   lRet := .F.
ENDIF

RETURN lRet
