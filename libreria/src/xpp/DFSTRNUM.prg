// Conta il numero di righe in una stringa
#include "dfStd.ch"
#include "Common.ch"

FUNCTION dfStrNumLines(cStr, cEol)
   LOCAL nNum := 0

   DEFAULT cEol TO CRLF

   nNum := dfStrCount(cStr, cEol)

   IF ! RIGHT(cStr, LEN(cEol)) == cEol
      nNum++
   ENDIF
RETURN nNum

