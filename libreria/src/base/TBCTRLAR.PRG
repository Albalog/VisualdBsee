//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "dfWin.ch"
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION tbCTRLArr( oTbr, cId )
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL nPos := tbCTRLPos( oTbr, cId ), aRet := {}
IF nPos>0
   aRet := oTbr:W_CONTROL[nPos]
ENDIF
RETURN aRet
