//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "COMMON.CH"
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE dfHorBar( nActual, nTot, nRow, nLeft, nRight, cColor )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
STATIC aFont := {,,,}
LOCAL cRet, nLen, nWidth, nPos

IF aFont[1]==NIL
   aFont[1] := dfFontStr( "scrollleftarrow" )
   aFont[2] := dfFontStr( "horizontalscrollbar" )
   aFont[3] := dfFontStr( "scrollrightarrow" )
   aFont[4] := dfFontStr( "horizontalcursor" )
ENDIF

nActual := MAX( MIN( nActual, nTot ), 0)

nLen := nRight-3-nLeft                    // spazio a video

nWidth := MAX( MIN( ROUND(nLen/nTot+0.49999999,0), nLen), 1) // grandezza barra

nPos := INT((nActual-1) * nLen/nTot)              // posizione barra

cRet := aFont[1] +REPLICATE(aFont[2], nPos )
cRet += REPLICATE( aFont[4], nWidth )
cRet := PADR( cRet, nLen+2, aFont[2]) +aFont[3]

@ nRow, nLeft SAY cRet COLOR cColor

RETURN
