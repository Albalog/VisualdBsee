/*******************************************************************************
Project     : dBsee 4.4
Description : Supporto per funzioni dBsee 3.0
Programmer  : Baccan Matteo
*******************************************************************************/
#include "common.ch"
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfYearHi( dDate )
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
DEFAULT dDate TO DATE()
RETURN VAL(SUBSTR(STR(YEAR( dDate ),4),1,2))
