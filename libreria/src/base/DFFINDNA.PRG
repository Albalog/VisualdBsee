/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfFindName( cName )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos, nPos1

nPos  := RAT(".",cName)
nPos1 := MAX( RAT("\",cName), RAT(":",cName) )

IF nPos>0 .AND. nPos>nPos1
   cName := LEFT( cName, nPos-1 )
ENDIF

IF nPos1>0
   cName := SUBSTR( cName, nPos1+1 )
ENDIF

RETURN cName
