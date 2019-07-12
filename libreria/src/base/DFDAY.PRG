//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
FUNCTION dfDay()
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
STATIC aDay := {}
//Gerr 3749 la funzione dfDay parte dal giorno sbagliato in base al set Epoch
//Luca 10/04/03 
//LOCAL dDate := CTOD( "10/10/93" )+1 // S.Firmino LUNEDI
LOCAL dDate := CTOD( "10/10/1993" )+1 // S.Firmino LUNEDI
LOCAL nCount

IF EMPTY(aDay)
   FOR nCount := 1 TO 7
      AADD( aDay, CDOW(dDate++) )
   NEXT
ENDIF

RETURN aDay
