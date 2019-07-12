//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Funzioni di supporto ai Font
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfStd.ch"

#ifndef __XPP__
REQUEST  InitdBsee
#endif
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfArrFont() // Array con le definizioni dei Font
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC aFont := NIL
IF aFont == NIL
   IF dfIsIni()              // Se ho un'INI
      aFont := dfIniFont()      // Lo utilizzo
   ENDIF
   IF EMPTY aFont ASSIGN dfIntFont() // Prendo i valori interni
   dfSetFont( aFont )        // Setto i FONT
ENDIF
RETURN aFont
