/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/

#include "dfWin.ch"
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION tbIsLock( oWin )
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL lRet := .T., nPos

IF !EMPTY(oWin:W_ALIAS)
   // Se trovo il RECNO() fra I Lokkati
   lRet := ASCAN((oWin:W_ALIAS)->(dfLockList()),(oWin:W_ALIAS)->(RECNO()))>0
ENDIF

RETURN lRet
