//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "dfWin.ch"
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE tbArrLen( oTbr, nLen )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
oTbr:W_AI_LENGHT  := MAX( nLen, oTbr:W_AI_LENGHT )
oTbr:W_CURRENTREC := 1
RETURN
