//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' VARIE
//Programmatore  : Baccan Matteo
//*****************************************************************************

#include "common.ch"
#include "nls.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDirectoryStd(cDirectory, cAttribute)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN _dfDirectory(cDirectory, cAttribute)

// come la DIRECTORY() ma usa il ":" fisso per separare
// invece che il settaggio di sistema
FUNCTION _dfDIRECTORY(cDirectory, cAttribute)
   LOCAL aOld := {SetLocale(NLS_STIME, ":"), SET(_SET_TIME, "HH:MM:SS") }
   LOCAL cRet := DIRECTORY(cDirectory, cAttribute)
   SET(_SET_TIME, aOld[2])
   SetLocale(NLS_STIME, aOld[1])
RETURN cRet

