/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/
#include "dfSet.ch"
#include "dfWin.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE tbMinimize( oTbr )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nGap := IF( dfSet( AI_WIN95INTERFACE ) , 2, 0 )
IF oTbr:WOBJ_TYPE==W_OBJ_FRM
   tbResize( oTbr )
ELSE
   oTbr:nBottom := oTbr:nTop+3
   oTbr:nRight  := oTbr:nLeft+2+nGap
   tbResSav( oTbr )
ENDIF
RETURN
