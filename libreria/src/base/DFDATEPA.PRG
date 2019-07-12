/*******************************************************************************
Progetto       : dBsee 4.3
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
*******************************************************************************/
#include "Common.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDatePack( dDate )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
DEFAULT dDate TO DATE()
RETURN CHR(DAY(dDate))+CHR(MONTH(dDate))+I2BIN(YEAR(dDate))

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDateUnpack( cDate )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL dDate    := CTOD("")
LOCAL cSet     := SET(_SET_DATEFORMAT)
LOCAL lCentury := LEN(DTOC(DATE())) == 10

DEFAULT cDate TO ""

SET DATE FORMAT "dd/mm/yyyy"

IF !lCentury
   SET CENTURY on
ENDIF

IF !EMPTY(cDate) .and. LEN(cDate) == 4
   dDate := CTOD(STRZERO(ASC(SUBSTR(cDate,1,1)))+"/"+ ;
                 STRZERO(ASC(SUBSTR(cDate,2,1)))+"/" + ;
                 STRZERO(BIN2W(RIGHT(cDate,2)),4))
ENDIF

IF !lCENTURY
    SET CENTURY off
ENDIF

SET(_SET_DATEFORMAT,cSet)

RETURN dDATE
