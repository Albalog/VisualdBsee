//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per ARRAY
//Programmatore  : Baccan Matteo
//*****************************************************************************
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
FUNCTION dfGetArr( aSource, nEle )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
LOCAL uVal
IF LEN(aSource)>=nEle .AND. nEle#0
   uVal := aSource[nEle]
ELSE
   uVal := ""
ENDIF
RETURN uVal
