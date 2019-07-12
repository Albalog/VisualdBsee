//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' VARIE
//Programmatore  : Baccan Matteo
//*****************************************************************************

#include "nls.ch"
#include "common.ch"

// simone 01/12/04 
// per correzione mantis  
// 0000349: Il dbup (Reverse) se effettuato prima delle ore 10 segnalava tutte le entit… modificate da fare il Reverse
///////////////////
//nAddSeconds -> Aggiunto per dare un certo margine nel controllo di Reverse engine 
//////////////////
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfTimeStd(cSep, lZeroAsSpace,nAddSeconds)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cRet, nSecond := SECONDS()

DEFAULT cSep TO ":"
DEFAULT lZeroAsSpace TO .F.
DEFAULT nAddSeconds  TO 0

nSecond += nAddSeconds 
nSecond := MIN(nSecond,86400)
nSecond := Max(nSecond,0    )

cRet := ""
cRet += PADL(INT(nSecond%86400/3600), 2,"0")    +cSep
cRet += PADL(INT(nSecond%3600/60)   , 2,"0")    +cSep
cRet += PADL(INT(nSecond%60)        , 2,"0")

// se voglio il primo zero come "spazio"
// es: "09:00:00" -> " 9:00:00"
IF lZeroAsSpace .AND. LEFT(cRet, 1)=="0"
   cRet := " "+SUBSTR(cRet, 2)
ENDIF   
RETURN cRet


// come la TIME() ma usa il ":" fisso per separare
// invece che il settaggio di sistema
FUNCTION _dfTIME(nTimeZone)
   LOCAL aOld := {SetLocale(NLS_STIME, ":"), SET(_SET_TIME, "HH:MM:SS") }
   LOCAL cRet := TIME(nTimeZone)
   SET(_SET_TIME, aOld[2])
   SetLocale(NLS_STIME, aOld[1])
RETURN cRet
