#include "common.ch"

// Come la STRTRAN ma ignora maiuscole/minuscole
// Esempio: dfStrTran("PIPPO","pp","x") -> "PIxO"
//          dfStrTran("PIpPO","pP","x") -> "PIxO"

FUNCTION dfStrTran(cStr,cSea,cRep,nStart,nCount)
   LOCAL cUSea := ""
   LOCAL cRet  := ""
   LOCAL nSea  := 0
   LOCAL nAt   := 0

   DEFAULT cRep   TO ""
   DEFAULT nStart TO 1

   IF nStart > 1
      cRet := LEFT(cStr, nStart-1)
      cStr := SUBSTR(cStr,nStart)
   ENDIF

   cUSea := UPPER(cSea)
   nSea  := LEN(cSea)

   DO WHILE .T.
      nAt := AT(cUSea, UPPER(cStr))
      IF nAt <= 0
         EXIT
      ENDIF

      cRet += LEFT(cStr,nAt-1)+cRep

      cStr := SUBSTR(cStr,nAt+nSea)

      IF nCount != NIL
         nCount--
         IF nCount <= 0
            EXIT
         ENDIF
      ENDIF

   ENDDO

   cRet += cStr
RETURN cRet
