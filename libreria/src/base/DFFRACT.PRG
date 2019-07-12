#include "Common.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfFract( nDec, nTol )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPar, nNum, nDen, cRet

DEFAULT nTol TO 0.001

nNum := 1
nDen := 1/nDec
DO WHILE nNum<100/nTol
   nPar = nNum * nDen
   IF ABS(ROUND(nPar,0)- nPar)/ABS(nPar) <= nTol
      EXIT
   ELSE
      nNum++
   ENDIF
ENDDO

cRet := ALLTRIM(STR(nNum,0)) + "/" + ALLTRIM(STR(ROUND(nNum * nDen,0),0))

IF "-"$cRet
   cRet := "-" +STRTRAN( cRet, "-" )
ENDIF

RETURN cRet
