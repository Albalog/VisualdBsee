///******************************************************************************
//Progetto       : dBsee 4.1
//Descrizione    : Funzioni di utilita' per BROWSE
//Programmatore  : Baccan Matteo
//******************************************************************************/

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
PROCEDURE tbFreeze( oTbr ) //
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
IF EMPTY(oTbr:Freeze)
   oTbr:Freeze := oTbr:colpos
ELSE
   oTbr:Freeze := 0
ENDIF
tbConfigure(oTbr)
tbStab(oTbr)
RETURN
