//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfwin.ch"
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE tbSav( oTbr ) //
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
IF oTbr:W_SAVESCREENID # NIL
   dbScrSav( oTbr:W_SAVESCREENID ,;
             TBREALTOP( oTbr )     ,;
             TBREALLEFT( oTbr )    ,;
             TBREALBOTTOM( oTbr )  +IF(oTbr:W_SHADOW,1,0) ,;
             TBREALRIGHT( oTbr )   +IF(oTbr:W_SHADOW,2,0)  )
ENDIF
RETURN

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE tbRes( oTbr ) //
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
IF oTbr:W_SAVESCREENID # NIL
   dbScrRes( oTbr:W_SAVESCREENID )
ENDIF
RETURN
