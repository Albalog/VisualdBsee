//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per ARRAY
//Programmatore  : Baccan Matteo
//*****************************************************************************
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfGetArr( aSource, nEle )
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL uVal
IF LEN(aSource)>=nEle .AND. nEle#0
   uVal := aSource[nEle]
ELSE
   uVal := ""
ENDIF
RETURN uVal
