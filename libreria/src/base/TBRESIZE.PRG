#include "dfwin.ch"
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE tbResize( oTbr ) //
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
oTbr:nTop    := oTbr:W_RP_TOP
oTbr:nLeft   := oTbr:W_RP_LEFT
oTbr:nBottom := oTbr:W_RP_BOTTOM
oTbr:nRight  := oTbr:W_RP_RIGHT
tbResSav( oTbr )
RETURN
