//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per STAMPE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfStd.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfArrPor() // Array delle porte
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC aPrn := NIL
IF aPrn == NIL
   IF dfIsIni()           // Ho l'INI aperto
      aPrn := dfIniPor()      // Lo leggo
   ENDIF
   IF EMPTY aPrn ASSIGN dfIntPor() // Prendo i valori interni
ENDIF
RETURN aPrn
