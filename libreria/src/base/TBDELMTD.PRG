//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "dfStd.ch"
#INCLUDE "dfWin.ch"
#INCLUDE "dfUsr.ch"
#INCLUDE "dfCTRL.ch"

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
PROCEDURE tbDelMtd( oTbr, cMtd )
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL nPos := ASCAN( oTbr:W_KEYBOARDMETHODS,;
                       {|aSub|UPPER(aSub[MTD_ACT])==UPPER(cMtd)})
IF nPos>0; DFAERASE( oTbr:W_KEYBOARDMETHODS, nPos ); ENDIF
RETURN
