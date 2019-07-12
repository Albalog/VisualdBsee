//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Ritorna l'array colori dell'oggetto associato
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
#include "dfMsg.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfColor( cStr, aNewColor ) // Ritorna l'array colori
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC aColor := NIL, aStr := {}
LOCAL nPos
LOCAL uRet := {}

IF cStr#NIL  // Controllo che sia diverso da NIL, perche' a volte
             // Dai CTRL arriva un cStr uguale a NIL
   DEFAULT aColor TO dfArrCol()

   cStr := UPPER( ALLTRIM( cStr ) )
   nPos := ASCAN( aColor, {|aSub| aSub[1]==cStr } )

   IF nPos > 0
      uRet := aColor[nPos][2]
      IF aNewColor!=NIL
         ACOPY( aNewColor, aColor[nPos][2] )
      ENDIF
   ELSE                                      // Label colore non trovata
      IF ASCAN( aStr, cStr )==0   // Evito l'errore in ricorsione nel caso
         AADD( aStr, cStr )       // in cui il colore e' quello dei messaggi
         dbMsgErr( dfStdMsg(MSG_DFCOLOR01) +" " +dfAny2Str(cStr) +;
                   " " +dfStdMsg(MSG_DFCOLOR02) )
         ASIZE( aStr, LEN(aStr)-1 )
      ENDIF
   ENDIF
ENDIF

RETURN uRet
