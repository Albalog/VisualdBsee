/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di compatibilita' fra dBsee 4.0d a 4.3
Programmatore  : Baccan Matteo
******************************************************************************/

#include "dfWin.ch"
#include "dfStd.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION tbIsOpt( oTbr, nOpt ) ;RETURN TBISOPT( oTbr, nOpt )
FUNCTION tbRealTop( oTbr )     ;RETURN TBREALTOP( oTbr )
FUNCTION tbRealLeft( oTbr )    ;RETURN TBREALLEFT( oTbr )
FUNCTION tbRealBottom( oTbr )  ;RETURN TBREALBOTTOM( oTbr )
FUNCTION tbRealRight( oTbr )   ;RETURN TBREALRIGHT( oTbr )
FUNCTION dfIsSelect( cFile )   ;RETURN DFISSELECT( cFile )
FUNCTION dfCompile( cString )  ;RETURN DFCOMPILE( cString )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
