//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per COLORI
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
#include "dfStd.ch"

#ifndef __XPP__
REQUEST InitdBsee
#endif
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfArrCol( lLoadIni ) // Ritorna l'array colori dell' Applicazione
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC aColor := NIL

DEFAULT lLoadIni TO .T.

IF aColor == NIL
   IF dfIsIni() .AND. lLoadIni  // L'ini e' aperto
      aColor := dfIniCol()      // Carico i colori dall'INI
   ENDIF
   IF EMPTY aColor ASSIGN dfIntCol() // Prendo i valori interni
   dfSavePal()    // Salvataggio Palette
   dfSetPal()     // Settaggio Nuove palette
ENDIF
RETURN aColor
