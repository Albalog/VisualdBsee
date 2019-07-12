/*******************************************************************************
Progetto       : dBsee 4.1
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
*******************************************************************************/
#include "common.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfMsgRolC( cMsg, nDelay, nRow )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nSpace := ( MAXCOL() -2 -LEN( cMsg ) ) / 2
DEFAULT nDelay TO 15
RETURN dfMsgRol( SPACE( nSpace ) + cMsg + SPACE( nSpace ), nDelay, nRow )
