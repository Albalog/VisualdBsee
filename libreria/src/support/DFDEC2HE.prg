/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDec2Hex( nDec )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cStr :="0123456789ABCDEF"
LOCAL cHex := ""

cHex += SUBSTR(cStr, MOD( INT(nDec/(16*16*16)), 16 )+1, 1)
cHex += SUBSTR(cStr, MOD( INT(nDec/(16*16)   ), 16 )+1, 1)
cHex += SUBSTR(cStr, MOD( INT(nDec/(16)      ), 16 )+1, 1)
cHex += SUBSTR(cStr, MOD( INT(nDec           ), 16 )+1, 1)

RETURN cHex
