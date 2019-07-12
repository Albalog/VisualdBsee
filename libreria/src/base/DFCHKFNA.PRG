/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfChkFName( cName ) // Verifica correttezza nome file
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T. , nInd := 0

cName := UPPER( RTRIM(cName) )

FOR nInd := 1 TO LEN(cName)
    IF !SUBSTR( cName, nInd, 1 ) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-."
       lRet := .F.
       EXIT
    ENDIF
NEXT

RETURN lRet
