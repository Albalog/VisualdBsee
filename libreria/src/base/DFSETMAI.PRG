//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"

STATIC cMasterMain
STATIC cApplicationName
* ����������������������������������������������������������������������������
FUNCTION dfSetMain( cMain ) //
* ����������������������������������������������������������������������������
DEFAULT cMasterMain TO cMain
RETURN cMasterMain

FUNCTION dfSetApplicationName( cAppName ) //
* ����������������������������������������������������������������������������
DEFAULT cApplicationName TO "Menu"
   IF !EMPTY(cAppName)
      cApplicationName := ALLTRIM(cAppName)
   ENDIF
RETURN cApplicationName
