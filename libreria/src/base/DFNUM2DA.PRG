//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per DATE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfNum2Day( nNum )
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
DEFAULT nNum TO 1
nNum:=MIN(MAX(1,nNum),7)
RETURN dfDay()[nNum]
