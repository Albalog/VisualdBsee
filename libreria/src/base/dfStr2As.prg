/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/
#INCLUDE "common.ch"

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
FUNCTION dfStr2ASCII( cRet )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
DEFAULT cRet TO ""

IF VALTYPE(cRet)=="C"
   cRet := strtran( cRet, "�", "-" )
   cRet := strtran( cRet, "�", "-" )
   cRet := strtran( cRet, "�", "-" )
   cRet := strtran( cRet, "�", "+" )
   cRet := strtran( cRet, "�", "+" )
   cRet := strtran( cRet, "�", "+" )
   cRet := strtran( cRet, "�", "+" )
   cRet := strtran( cRet, "�", "+" )
   cRet := strtran( cRet, "�", "|" )
   cRet := strtran( cRet, "�", "|" )
   cRet := strtran( cRet, "�", "|" )
ENDIF

RETURN cRet
