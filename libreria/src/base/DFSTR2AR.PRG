/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/

#include "Common.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfStr2Arr( cStr, cDelim, aRet )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nTok, nAct

DEFAULT aRet   TO {}
DEFAULT cDelim TO ";"
IF LEN(cDelim) > 1
   RETURN S2Str2Arr(cStr, cDelim)
ENDIF

nTok := dfNumToken( cStr, cDelim )

FOR nAct := 1 TO nTok
  AADD( aRet, dfToken(cStr,cDelim,nAct) )
NEXT

RETURN aRet


// Come la dfStr2Arr, ma funzionante con delimitatori > 1 byte
STATIC FUNCTION S2Str2Arr(cStr, cDelim, aRet)
   LOCAL nPos := 0
   LOCAL nLen := 0

   DEFAULT aRet   TO {}
   DEFAULT cDelim TO ";"

   nLen := LEN(cDelim)

   DO WHILE (nPos := AT( cDelim, cStr)) > 0
      AADD(aRet, LEFT( cStr, nPos-1 ))
      cStr := SUBSTR( cStr, nPos+nLen )
   ENDDO

   IF ! cStr == ""
      AADD(aRet, cStr)
   ENDIF

RETURN aRet
