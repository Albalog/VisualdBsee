//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Funzioni di Utilita' per APP
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfStd.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfArrApp() // Inizializzazione Applicazione
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC aApp := NIL
IF aApp == NIL            // Se NON e' inizializzato l'array
   IF dfIsIni()              // Ho un'INI aperto
      aApp := dfIniApp()        // Lo Uso
   ENDIF
   IF EMPTY aApp ASSIGN dfIntApp() // Prendo i valori interni
   dfSetApp(aApp)            // Uso i settaggi
ENDIF
RETURN aApp
