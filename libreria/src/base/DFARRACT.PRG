//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per ACT
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "dfStd.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfArrAct() // Ritorna l'array delle Action letto dall'ini
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC aAct := NIL
IF aAct == NIL
   IF dfIsIni()           // Ho l'INI aperto
      aAct := dfIniAct()     // Carico le azioni dall'INI
   ENDIF
   IF EMPTY aAct ASSIGN dfIntAct() // Prendo i valori interni

   // Carico lo stack interno in C
   AEVAL( aAct, {|aSub| dfActAdd( aSub[1], aSub[2], aSub[3]) } )
ENDIF
RETURN aAct
