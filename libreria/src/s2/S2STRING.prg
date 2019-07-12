#include "Common.ch"
#include "dfStd.ch"

FUNCTION S2StringDim(oXbp, cMsg, cSep)
RETURN IIF( cSep == NIL, ;
            LineDim(oXbp, cMsg), ;
            MultiLineDim(oXbp, cMsg, cSep) )


STATIC FUNCTION LineDim(oXbp, cMsg)
   LOCAL oPS := oXbp:lockPS()
   LOCAL aDim := GraQueryTextBox(oPS, cMsg)
   LOCAL nMaxWidth  := MAX(aDim[3][1], aDim[4][1]) - MIN(aDim[1][1], aDim[2][1])
   LOCAL nMaxHeight := MAX(aDim[3][2], aDim[4][2]) - MIN(aDim[1][2], aDim[2][2])
   oXbp:unlockPS(oPS)
RETURN {nMaxWidth, nMaxHeight}

STATIC FUNCTION MultiLineDim(oXbp, cMsg, cSep)
   LOCAL oPS := oXbp:lockPS()
   LOCAL aDim
   LOCAL nMaxWidth := 0
   LOCAL nMaxHeight:= 0
   LOCAL aStr
   LOCAL nInd
   LOCAL nWidth
   LOCAL nHeight

   // Ora Š Inutile
   // DEFAULT cSep TO CRLF

   // ----------------
   // Testo multilinea
   // ----------------

   aStr := dfStr2Arr(cMsg, cSep)

   FOR nInd := 1 TO LEN(aStr)
      aDim := GraQueryTextBox(oPS, IIF(aStr[nInd] == "", " ", aStr[nInd]))

      nWidth  := MAX(aDim[3][1], aDim[4][1]) - MIN(aDim[1][1], aDim[2][1])
      nHeight := MAX(aDim[3][2], aDim[4][2]) - MIN(aDim[1][2], aDim[2][2])

      nMaxWidth  := MAX(nMaxWidth, nWidth)
      nMaxHeight += nHeight

   NEXT
   oXbp:unlockPS(oPS)
RETURN {nMaxWidth, nMaxHeight}

