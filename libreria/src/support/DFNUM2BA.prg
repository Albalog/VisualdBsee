/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function
Programmer  : Simone Degl'Innocenti
******************************************************************************/

#include "dfStd.ch"

// Converte da numero in base 10 a stringa corrispondente al 
// numero convertito in base X
// Es.
//  dfNum2Base(100, "0123456789")        -> "100"  in decimale
//  dfNum2Base(255, "0123456789ABCDEF")  -> "FF"   in esadecimale
//  dfNum2Base(256, "0123456789ABCDEF")  -> "100"  in esadecimale
//  dfNum2Base(  5, "01")                -> "101"  in binario

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfNum2Base(n, cSym)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL nBase := LEN(cSym)
   LOCAL cStr  := ""
   LOCAL nChar

   IF EMPTY(cSym)
      RETURN cStr
   ENDIF

   n := ABS(INT(n))
   IF EMPTY(n)
      // Š 0
      RETURN LEFT(cSym,1)
   ENDIF

   DO WHILE n > 0
      nChar := n % nBase
      n     := INT(n/nBase)
      cStr  := SUBSTR(cSym, nChar+1, 1) + cStr
   ENDDO

RETURN cStr



// Converte da una stringa in base X a un numero in base 
// Es.
//  dfBase2Num("100", "0123456789")       -> 100  
//  dfBase2Num("FF" , "0123456789ABCDEF") -> 255 
//  dfBase2Num("100", "0123456789ABCDEF") -> 256
//  dfBase2Num("101", "01")               -> 5  

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfBase2Num(cStr, cSym)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL nBase := LEN(cSym)
   LOCAL cChar
   LOCAL n
   LOCAL nLen  := LEN(cStr)-1
   LOCAL nRet  := 0
   LOCAL nPos  := 0

   IF EMPTY(cSym)
      RETURN NIL
   ENDIF

   FOR n := 0 TO nLen 
      // 'n'esimo carattere a destra
      cChar := DFCHAR(cStr, 1+nLen-n)
      nPos  := AT(cChar, cSym)-1
      
      // carattere non presente nella base?
      IF nPos < 0
         RETURN NIL
      ENDIF

      nRet += nPos * (nBase^n)
   NEXT

RETURN nRet

