//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfWin.ch"
#include "dfMove.ch"

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE tbMove( oTbr, lKey ) //
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
LOCAL nVert  := oTbr:nBottom -oTbr:nTop
LOCAL nHoriz := oTbr:nRight  -oTbr:nLeft
LOCAL aPos := { TBREALTOP( oTbr )    ,;
                TBREALLEFT( oTbr )   ,;
                TBREALBOTTOM( oTbr ) ,;
                TBREALRIGHT( oTbr )   }

dfMove( aPos, lKey, oTbr:W_SHADOW )

oTbr:nTop    := aPos[POS_TOP ]+ oTbr:W_BG_TOP
oTbr:nLeft   := aPos[POS_LEFT]+ oTbr:W_BG_LEFT
oTbr:nBottom := oTbr:nTop  +nVert
oTbr:nRight  := oTbr:nLeft +nHoriz

tbResSav( oTbr )

RETURN
