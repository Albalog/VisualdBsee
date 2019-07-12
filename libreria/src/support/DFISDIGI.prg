/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "Common.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfIsDigit( cString, nLen )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lDigit := .T., nPos, nVal
DEFAULT nLen TO LEN(cString)
nPos := 1
WHILE nPos<=nLen
   nVal := ASC( SUBSTR(cString,nPos,1) )
   IF nVal>57 .OR. nVal<48
      lDigit := .F.
      EXIT
   ENDIF
   nPos++
ENDDO

RETURN lDigit

