/*******************************************************************************
Project     : dBsee 4.4
Description : Internal Table Function
Programmer  : Baccan Matteo
*******************************************************************************/

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfTab2Str( nStart, nLen, cType )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cRet

IF nStart = -1
   cRet := SUBSTR( dbTabd->TabCode,      1, nLen )
ELSE
   cRet := SUBSTR( dbTabd->TabData, nStart, nLen )
ENDIF
cRet := dbTabConv( cRet, cType )

RETURN cRet
