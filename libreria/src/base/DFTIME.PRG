//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' VARIE
//Programmatore  : Baccan Matteo
//*****************************************************************************
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfTime()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cRet, cSep, nSecond := SECONDS()

IF ROUND(nSecond,0) != INT(nSecond)
   cSep := " "
ELSE
   cSep := ":"
ENDIF

cRet := ""
cRet += STR( INT(nSecond%86400/3600), 2)        +cSep
cRet += PADL(INT(nSecond%3600/60)   , 2,"0")    +cSep
cRet += PADL(INT(nSecond%60)        , 2,"0")

RETURN cRet
