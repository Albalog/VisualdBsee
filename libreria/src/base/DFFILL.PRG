//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Funzioni di Utilita' per Video
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfFill( nTop, nLeft, nBottom, nRight, cFill, cColor ) // filler
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nWidth := nRight -nLeft +1
LOCAL cStr   := PADR(REPLICATE( cFill, ROUND(nWidth/LEN(cFill)+1,0) ), nWidth )
LOCAL nRow

DEFAULT cColor TO SetColor()

FOR nRow := 0 TO (nBottom -nTop)
   @ nTop +nRow, nLeft SAY cStr COLOR cColor
NEXT

RETURN
