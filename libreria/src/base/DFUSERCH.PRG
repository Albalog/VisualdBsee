//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per PASSWORD
//Programmatore  : Baccan Matteo
//*****************************************************************************
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfUserCheck( cValid )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lValid:=.F.
IF "-" +ALLTRIM(STR(dfUserLev())) +"-" $ cValid
   lValid:=.T.
ENDIF
RETURN lValid
