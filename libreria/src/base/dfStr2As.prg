/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/
#INCLUDE "common.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfStr2ASCII( cRet )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
DEFAULT cRet TO ""

IF VALTYPE(cRet)=="C"
   cRet := strtran( cRet, "Ä", "-" )
   cRet := strtran( cRet, "Â", "-" )
   cRet := strtran( cRet, "Á", "-" )
   cRet := strtran( cRet, "Ú", "+" )
   cRet := strtran( cRet, "¿", "+" )
   cRet := strtran( cRet, "À", "+" )
   cRet := strtran( cRet, "Ù", "+" )
   cRet := strtran( cRet, "Å", "+" )
   cRet := strtran( cRet, "³", "|" )
   cRet := strtran( cRet, "Ã", "|" )
   cRet := strtran( cRet, "´", "|" )
ENDIF

RETURN cRet
