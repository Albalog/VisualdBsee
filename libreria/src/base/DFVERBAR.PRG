//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE dfVerBar( nActual, nTot, nCol, nTop, nBottom, cColor )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
STATIC aFont := {,,,}
LOCAL cRet, nLen, nWidth, nPos

IF aFont[1]==NIL
   aFont[1] := dfFontStr( "scrolluparrow" )
   aFont[2] := dfFontStr( "verticalscrollbar" )
   aFont[3] := dfFontStr( "verticalcursor" )
   aFont[4] := dfFontStr( "scrolldownarrow" )
ENDIF

nActual := MAX( MIN( nActual, nTot ), 0)

nLen := nBottom-1-nTop                       // spazio a video

nWidth := MAX( MIN( ROUND(nLen/nTot+0.49999999,0), nLen), 1) // grandezza barra

nPos := INT((nActual-1) * nLen/nTot)              // posizione barra

cRet := aFont[1] +REPLICATE(aFont[2], nPos )
cRet += REPLICATE( aFont[3], nWidth ) +REPLICATE( aFont[2], (nLen-nPos-nWidth)*2+2)
cRet := PADR( cRet, nLen*2+2) +aFont[4]

FOR nPos := 1 TO LEN(cRet) STEP 2
   @ nTop+ INT((nPos-1)/2), nCol SAY SUBSTR(cRet, nPos, 2) COLOR cColor
NEXT

RETURN
