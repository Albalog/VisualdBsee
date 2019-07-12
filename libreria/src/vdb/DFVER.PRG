//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' VARIE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfMsg.ch"
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
FUNCTION dfVer()    // Versione della libreria
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
RETURN _LibType()                                           +;
       IF( dBsee4AXS()," ADS ", "" )                        +;
       IF( dfRealMode(), " Real ", " Protected " ) +"mode " +;
       dfStdMsg(MSG_LANGUAGE)                               +;
       " " +dfNumVer()                                      +;
       " - Date " +dfLibDate()                              +;
       IF( dfIsDebug(), " (DEBUG)", "" )

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
FUNCTION dfNumVer() // Versione della libreria
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
RETURN "5.0 "  // SIMONE 13/05/2004 IN VISUAL DBSEE DEVE TORNARE 5.0!!
