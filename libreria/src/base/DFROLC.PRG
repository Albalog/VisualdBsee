/*******************************************************************************
Progetto       : dBsee 4.1
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
*******************************************************************************/
#include "common.ch"

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfMsgRolC( cMsg, nDelay, nRow )
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL nSpace := ( MAXCOL() -2 -LEN( cMsg ) ) / 2
DEFAULT nDelay TO 15
RETURN dfMsgRol( SPACE( nSpace ) + cMsg + SPACE( nSpace ), nDelay, nRow )
