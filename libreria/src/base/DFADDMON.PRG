/******************************************************************************
Progetto       : dBsee 4.3
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
FUNCTION dfAddMonth( dDate, nMonths )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
LOCAL nMonth, nDay, nYear, dNewDate

IF EMPTY(dDate)
   dNewDate := dDate
ELSE
   nMonth := MONTH( dDate ) +nMonths
   nDay   := DAY( dDate )
   nYear  := YEAR( dDate )

   WHILE nMonth>12
      nYear++
      nMonth -= 12
   END

   WHILE nMonth<1
      IF --nYear<0
         nYear := 9999
      ENDIF
      nMonth += 12
   END

   WHILE EMPTY(dNewDate := dfNtoD( nDay--, nMonth, nYear )); END
ENDIF

RETURN dNewDate
