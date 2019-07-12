/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "dfwin.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE tbMaximize( oTbr ) //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
oTbr:nTop    := oTbr:W_BG_TOP
oTbr:nLeft   := oTbr:W_BG_LEFT
oTbr:nBottom := MAXROW() -IF(oTbr:W_SHADOW,3,2)
//oTbr:nRight  := MAXCOL() -IF(oTbr:W_SHADOW,4,2)
oTbr:nRight  := MAXCOL() -2
tbResSav( oTbr )
RETURN
