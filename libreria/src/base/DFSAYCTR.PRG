//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per Video
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北 Stampa la
PROCEDURE dfSayCtr( nTop, nLeft, nRight, cStr, cColor ) // Stringa centrata
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北
LOCAL nSpace

DEFAULT cColor TO SETCOLOR()

nSpace := (nRight-nLeft)+1
IF LEN(cStr) > nSpace
   cStr := PADL(cStr, nSpace)
ENDIF

dfSetPos( nTop, nLeft+ INT((nSpace -len(cStr)) /2) )
DEVOUT( cStr, cColor )

RETURN
