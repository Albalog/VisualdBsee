/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/
#include "Common.ch"
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfArr2Str( aSrc, cDelim )
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL cStr := ""

DEFAULT cDelim TO ";"

AEVAL( aSrc, {|cSub|cStr+=(dfAny2Str(cSub)+cDelim)})
IF !EMPTY(cStr)
   cStr := LEFT(cStr,LEN(cStr)-LEN(cDelim))
ENDIF
RETURN cStr
