/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/
#INCLUDE "common.ch"

* �����������������������������������������������������������������������������
FUNCTION dfStr2ASCII( cRet )
* �����������������������������������������������������������������������������
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
