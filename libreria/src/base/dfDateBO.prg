/******************************************************************************
Project     : dBsee 4.5
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "common.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDateBOM( dDate )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nMese

IF !EMPTY(dDate) .AND. VALTYPE(dDate)=="D"

    nMese := MONTH(dDate)
    WHILE MONTH(dDate)==nMese
        dDate--
    ENDDO
    dDate++

ENDIF

RETURN dDate
