#include "dfStd.ch"

// normalizza un nome di file 
// togliendo tutti i caratteri speciali
FUNCTION dfFNameNorm(cFName)
   LOCAL cRet := "", c, n

   FOR n := 1 TO LEN(cFName)
      c := DFCHAR(cFName, n)
      cRet += IIF(UPPER(c) $ " _-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", c, "_")
   NEXT
RETURN cRet