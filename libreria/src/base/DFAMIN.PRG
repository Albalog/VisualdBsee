/*******************************************************************************
Progetto       : dBsee 4.3
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
*******************************************************************************/

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfAMin( aSource )
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL nMin := dfGetArr( aSource, 1 )
IF VALTYPE(nMin)=="C"
   nMin := 0
ENDIF
AEVAL( aSource, {|nVal| nMin := MIN(nMin,nVal) } )
RETURN nMin
