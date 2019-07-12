/*******************************************************************************
Progetto       : dBsee 4.3
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
*******************************************************************************/
#include "dfScr.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfUpdPoint( aPoint, nRow, nY, nY1, nX, nX1 )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPoint

FOR nPoint := 1 TO LEN(aPoint)
   IF aPoint[nPoint][POINT_UP]
      IF (aPoint[nPoint][POINT_ROW] -= nPoint )<nY+nRow
         aPoint[nPoint][POINT_UP] := !aPoint[nPoint][POINT_UP]
      ENDIF
   ELSE
      IF (aPoint[nPoint][POINT_ROW] += nPoint )>nY1-nRow
         aPoint[nPoint][POINT_UP] := !aPoint[nPoint][POINT_UP]
      ENDIF
   ENDIF

   IF aPoint[nPoint][POINT_LEFT]
      IF (aPoint[nPoint][POINT_COL] -= nPoint )<nX+nRow
         aPoint[nPoint][POINT_LEFT] := !aPoint[nPoint][POINT_LEFT]
      ENDIF
   ELSE
      IF (aPoint[nPoint][POINT_COL] += nPoint )>nX1-nRow
         aPoint[nPoint][POINT_LEFT] := !aPoint[nPoint][POINT_LEFT]
      ENDIF
   ENDIF
NEXT

RETURN
