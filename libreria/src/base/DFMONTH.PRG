//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfStd.ch" // Server per XPP
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfMonth()
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
STATIC aMonth := {}
LOCAL dDate, nCount

IF EMPTY(aMonth)
   dDate := CTOD( "01/01/93" ) // Fine Gennaio
   FOR nCount := 1 TO 12
      AADD( aMonth, CMONTH( dDate ) )
      dDate += 31
   NEXT
ENDIF

RETURN aMonth
