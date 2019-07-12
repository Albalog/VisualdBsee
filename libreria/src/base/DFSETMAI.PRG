//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"

STATIC cMasterMain
STATIC cApplicationName
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
FUNCTION dfSetMain( cMain ) //
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
DEFAULT cMasterMain TO cMain
RETURN cMasterMain

FUNCTION dfSetApplicationName( cAppName ) //
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
DEFAULT cApplicationName TO "Menu"
   IF !EMPTY(cAppName)
      cApplicationName := ALLTRIM(cAppName)
   ENDIF
RETURN cApplicationName

