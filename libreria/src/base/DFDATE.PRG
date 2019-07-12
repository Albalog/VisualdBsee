//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' VARIE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfStd.ch" // Server per XPP
#include "Common.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDate( dDate ) // Ritorna la data
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cRet := ""

DEFAULT dDate TO DATE()

cRet += CDOW(dDate)              + ", "
cRet += ALLTRIM(STR(DAY(dDate))) + " "
cRet += CMONTH(dDate)            + " "
cRet += STR(YEAR(dDate),4)

RETURN cRet
