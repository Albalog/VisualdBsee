//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "dfStd.ch"
#INCLUDE "dfWin.ch"
#INCLUDE "dfUsr.ch"
#INCLUDE "dfCTRL.ch"

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE tbDelMtd( oTbr, cMtd )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
LOCAL nPos := ASCAN( oTbr:W_KEYBOARDMETHODS,;
                       {|aSub|UPPER(aSub[MTD_ACT])==UPPER(cMtd)})
IF nPos>0; DFAERASE( oTbr:W_KEYBOARDMETHODS, nPos ); ENDIF
RETURN
