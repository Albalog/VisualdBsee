/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfPagGG( dOldDate, nGG )
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL nMese := MONTH(dOldDate)
IF !EMPTY(dOldDate)
   WHILE MONTH(dOldDate)==nMese; dOldDate++         ; END
   IF nGG#0                    ; dOldDate += (nGG-1); END
ENDIF

RETURN dOldDate
