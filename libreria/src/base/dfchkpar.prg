/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfChkPar( cPar )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .F., nPar

cPar := UPPER(ALLTRIM(cPar))
FOR nPar := 0 TO dfArgC()
   IF ALLTRIM(UPPER(dfArgV(nPar)))==cPar
      lRet := .T.
   ENDIF
NEXT

RETURN lRet
