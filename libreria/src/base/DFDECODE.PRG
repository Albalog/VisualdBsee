//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per STRINGHE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDecode( cString, cDecode )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nChar, nDecode:=0, nLenStr, nLenDec, cRet:=""

DEFAULT cDecode TO "Isa"

nLenStr:=LEN(cString)
nLenDec:=LEN(cDecode)

FOR nChar := 1 TO nLenStr
   nDecode++
   IF nDecode>nLenDec; nDecode:=1; END
   cRet+=CHR( _dfdecode( cString, nChar, cDecode, nDecode ) )
NEXT
RETURN cRet
