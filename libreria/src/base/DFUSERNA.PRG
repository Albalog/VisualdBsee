//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per PASSWORD
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfSet.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfUserName( cName )
 Local cOut

 //MANTIS 2190
 IF cName == NIL .AND. EMPTY(dfSet( AI_USERNAME))
    cOut  := GETENV("USERNAME")
 ELSE 
    cOut  := dfSet( AI_USERNAME, cName )
 ENDIF 
RETURN cOut 
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
