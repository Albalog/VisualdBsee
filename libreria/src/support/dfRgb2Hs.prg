//** convert HSB to RGB (aHSL should be {HUE,SATURATION,BRIGHTNESS})
FUNCTION dfHSBToRGB(aHSL)
  LOCAL R,G,B,H,S,L,nH,nS,nL,nF,nP,nQ,nT,lH

  IF EMPTY(aHSL)
     RETURN NIL
  ENDIF

  H := aHSL[1]
  S := aHSL[2]
  L := aHSL[3]

  IF S > 0

    nH := H / 60
    nL := L / 100
    nS := S / 100

    lH := Int(nH)
    nF := nH - lH
    nP := nL * (1 - nS)
    nQ := nL * (1 - nS * nF)
    nT := nL * (1 - nS * (1 - nF))

    DO CASE
      CASE lH == 0
        R := nL * 255
        G := nT * 255
        B := nP * 255
      CASE lH == 1
        R := nQ * 255
        G := nL * 255
        B := nP * 255
      CASE lH == 2
        R := nP * 255
        G := nL * 255
        B := nT * 255
      CASE lH == 3
        R := nP * 255
        G := nQ * 255
        B := nL * 255
      CASE lH == 4
        R := nT * 255
        G := nP * 255
        B := nL * 255
      CASE lH == 5
        R := nL * 255
        G := nP * 255
        B := nQ * 255
    ENDCASE
  ELSE
    R := (L * 255) / 100
    G := R
    B := R
  ENDIF

RETURN {r,g,b}

//** convert from RGB Color to HSB (aRGB should be {RED,GREEN,BLUE})
FUNCTION dfRGBToHSB(aRGB)
  LOCAL nTemp, lMin, lMax, lDelta, R, G, B, H, S, L

  IF EMPTY(aRGB)
     RETURN NIL
  ENDIF

  R := aRGB[1]
  G := aRGB[2]
  B := aRGB[3]

  lMax := IIf(R > G, IIf(R > B, R, B), IIf(G > B, G, B))
  lMin := IIf(R < G, IIf(R < B, R, B), IIf(G < B, G, B))

  lDelta := lMax - lMin

  L := (lMax * 100) / 255

  IF lMax > 0
    S := (lDelta / lMax) * 100

    IF lDelta > 0
      IF lMax == R
        nTemp := (G - B) / lDelta
      ELSEIF lMax == G
        nTemp := 2 + (B - R) / lDelta
      ELSE
        nTemp := 4 + (R - G) / lDelta
      ENDIF

      H := nTemp * 60

      IF H < 0
        H := H + 360
      ENDIF
    ENDIF
  ENDIF

RETURN {H,S,L}