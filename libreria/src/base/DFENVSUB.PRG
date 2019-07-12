//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per ENVIRONMENT
//Programmatore  : Baccan Matteo
//*****************************************************************************

#include "common.ch"

// Simone 14/2/2005
// mantis 0000582: uscita improvvisa in compilazione applicativo.
// per loop se la variabile ambiente LIB=%LIB%
// aggiunta gestione array aStack

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
FUNCTION dfEnvSub( cStr, aStack,lPathchk) // Sostituzione con i path
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
LOCAL cRet := ""
LOCAL nLeft, nRight

DEFAULT aStack TO {}
DEFAULT lPathchk TO .T.
DEFAULT cStr     TO ""
nLeft  :=  AT( "%", cStr )
nRight := RAT( "%", cStr )
IF nRight>nLeft
   cRet := SUBSTR(cStr,nLeft+1,nRight-nLeft-1)
   IF ASCAN(aStack, UPPER(cRet)) == 0
      AADD(aStack, UPPER(cRet))
      IF lPathchk
         cRet := STRTRAN( cStr, "%" +cRet +"%", dfPathChk(GETENV(cRet), aStack) )
      ELSE
         cRet := STRTRAN( cStr, "%" +cRet +"%", GETENV(cRet) )
      ENDIF
   ELSE
      cRet := STRTRAN( cStr, "%" +cRet +"%", "" )
   ENDIF
ELSE
   cRet := STRTRAN( cStr, "%", "" )
ENDIF
RETURN cRet
