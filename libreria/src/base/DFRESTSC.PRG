/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/
#include "common.ch"
#include "dfStd.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfRestScre( nTop, nLeft, nBottom, nRight, cScr, cColor )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cPixel := "úù+ö*ð*ö+ùú "
LOCAL nRow := nBottom-nTop+1, nCol := nRight-nLeft+1
LOCAL nCount, nCount2, cScrTop, cScrBottom, nPos, nPix

DEFAULT cColor TO "W+/G"

nCount  :=  0
nCount2 :=  1
WHILE nTop+nCount-1<nBottom-nCount2
   DFDISPBEGIN()
   cScrTop := SUBSTR( cScr, nCol*nCount*2+1, nCol*2 )
   RESTSCREEN( nTop+nCount, nLeft, nTop+nCount, nRight, cScrTop )
   DISPBOX( nTop+nCount+1    , nLeft, nTop+nCount+1    , nRight, 1, cColor )
   nCount++

   cScrBottom := SUBSTR( cScr, LEN(cScr)-nCol*nCount2*2+1, nCol*2 )
   RESTSCREEN( nBottom-nCount2+1, nLeft, nBottom-nCount2+1, nRight, cScrBottom )
   DISPBOX( nBottom-nCount2  , nLeft, nBottom-nCount2  , nRight, 1, cColor )
   nCount2++
   DFDISPEND()
   dfINKEY(0.01) //FW
END
nCount2--

FOR nPos := 0 TO nCol/2
   DFDISPBEGIN()
   cScrBottom := SUBSTR( cScr, LEN(cScr)-nCol*(nCount2+1)*2+1, nCol*2 )
   RESTSCREEN( nBottom-nCount2, nLeft, nBottom-nCount2, nRight, cScrBottom )
   @ nBottom-nCount2, nLeft+nPos SAY REPLICATE("Ä", nCol-(nPos*2) ) COLOR cColor
   DFDISPEND()
NEXT

FOR nPos := 1 TO LEN(cPixel)
   DFDISPBEGIN()
   FOR nPix := 1 TO 50
      @ nBottom-nCount2, nLeft+(nCol/2) SAY SUBSTR( cPixel, nPos, 1 ) COLOR cColor
   NEXT
   DFDISPEND()
NEXT
M_CurOff()
RESTSCREEN( nTop, nLeft, nBottom, nRight, cScr )
M_CurOn()

RETURN
