//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per BROWSE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfWin.ch"
#include "dfSet.ch"
#include "dfCtrl.ch"

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE tbCls( oTbr ) //
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
LOCAL nOfs := IF( TBISOPT( oTbr, W_MM_VSCROLLBAR ),1,0)
LOCAL nRow := IF( tbIsMenu( oTbr )                ,1,0)

DISPBOX( TBREALTOP( oTbr )+1+nRow   ,;
         TBREALLEFT( oTbr )+1       ,;
         TBREALBOTTOM( oTbr )-1     ,;
         TBREALRIGHT( oTbr )-1-nOfs ,;
         SPACE(9)                   ,; // On Fillato
         oTbr:W_COLORARRAY[AC_FRM_BACK] )

// Obbligo il refresh degli oggetti ListBox
// Non uso lo stable dell'oggetto perche' sporca a video
IF oTbr:WOBJ_TYPE == W_OBJ_FRM
   tbInvalid( oTbr )
ENDIF

RETURN
