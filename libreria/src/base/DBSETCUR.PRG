//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Funzioni di Utilita' Varie
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "setcurs.ch"
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dbSetCur() //
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL nRet

IF Set(_SET_INSERT)
   nRet := SETCURSOR( SC_SPECIAL1 )
ELSE
   nRet := SETCURSOR( SC_NORMAL )
ENDIF

RETURN nRet
