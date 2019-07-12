//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfWin.ch"
#include "dfMove.ch"

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE tbSize( oTbr, lKey ) //
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
LOCAL nVert  := oTbr:nBottom -oTbr:nTop
LOCAL nHoriz := oTbr:nRight  -oTbr:nLeft
LOCAL aPos := { TBREALTOP( oTbr )    ,;
                TBREALLEFT( oTbr )   ,;
                TBREALBOTTOM( oTbr ) ,;
                TBREALRIGHT( oTbr )   }

IF oTbr:WOBJ_TYPE#W_OBJ_FRM // Il size sul FORM NON deve funzionare
   dfSize( aPos, lKey, oTbr:W_SHADOW )

   oTbr:nBottom := aPos[POS_BOTTOM] -oTbr:W_BG_BOTTOM
   oTbr:nRight  := aPos[POS_RIGHT ] -oTbr:W_BG_RIGHT

   tbResSav( oTbr )
ELSE
   dbSouErr()
ENDIF

RETURN
