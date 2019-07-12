/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/
#include "Common.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfGraph( cHeader, aArr, aArr1, aArr2, aArr3, nBar )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nMax := 0, nMaxGrf, nBarSpace

DEFAULT aArr  TO {"", {}}
DEFAULT aArr1 TO {"", {}}
DEFAULT aArr2 TO {"", {}}
DEFAULT aArr3 TO {"", {}}

nMax := dfAMax(aArr[2] )
nMax := dfAMax(aArr1[2])
nMax := dfAMax(aArr2[2])
nMax := dfAMax(aArr3[2])

nMax    := INT(nMax)
nMaxGrf := VAL("1" + REPLICATE("0", LEN(ALLTRIM(STR(nMax)))))

// Massimo valore grafico rappresentato
nMax := IF( nMaxGrf/5>nMax, nMaxGrf/5, IF(nMaxGrf/2>nMax, nMaxGrf/2, nMaxGrf) )

// Grandezza silgole barre
nBarSpace := 480/dfAMax( {LEN(aArr[2]),LEN(aArr1[2]),LEN(aArr2[2]),LEN(aArr3[2])} )

dfBackGraph( cHeader, nMax, 80 )

dfGrfLegend( 20, 419,  9, aArr[1] )
dfGrfLegend(340, 419, 15, aArr1[1])
dfGrfLegend( 20, 450, 10, aArr2[1])
dfGrfLegend(340, 450, 12, aArr3[1])

dfBarHor( aArr , nBarSpace, nMax, 150,  9, nBar )
dfBarHor( aArr1, nBarSpace, nMax, 130, 15, nBar )
dfBarHor( aArr2, nBarSpace, nMax, 110, 10, nBar )
dfBarHor( aArr3, nBarSpace, nMax,  90, 12, nBar )

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfBarHor( aArr, nBarSpace, nMax, nDif, nColor, nBar )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nCol, nColStart

FOR nCol := 1 TO LEN(aArr[2])
   nColStart := nDif +(nCol-1)*nBarSpace -30
   dfGrfBar( nColStart, 485-aArr[2][nCol]/nMax*250-nDif, nColStart+nBarSpace*.60, 485-nDif, nColor, nColor, nBar )
NEXT

RETURN
