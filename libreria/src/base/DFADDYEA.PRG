/******************************************************************************
Progetto       : dBsee 4.3
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfAddYear( dDate, nYears )
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL nMonth, nDay, nYear, dNewDate

IF EMPTY(dDate) .OR. DTOS(dDate)=="00000000"
   dNewDate := dDate
ELSE
   nMonth := MONTH( dDate )
   nDay   := DAY( dDate )
   nYear  := YEAR( dDate )  +nYears

   WHILE EMPTY(dNewDate := dfNtoD( nDay--, nMonth, nYear )); END
ENDIF

RETURN dNewDate
