/*******************************************************************************
Progetto       : dBsee 4.1
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
*******************************************************************************/

#include "common.ch"

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfMsgRolR( cMsg, nDelay, nRow )
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
DEFAULT nDelay TO 15
RETURN dfMsgRol( LEFT( cMsg + SPACE(MAXCOL()-1), MAXCOL()-2 ), nDelay, nRow )
