// Come la dfIsDigit ma torna .T. anche se Š un numero negativo
#include "common.ch"

FUNCTION S2IsNumber(cVal, nLen)

   DEFAULT nLen TO LEN(cVal)

   // Tolgo il "+" o "-" iniziale
   IF nLen >= 1 .AND. LEFT(cVal, 1) $ "+-"
      cVal := SUBSTR(cVal,2)
      nLen--
   ENDIF

RETURN dfIsDigit(cVal, nLen)
