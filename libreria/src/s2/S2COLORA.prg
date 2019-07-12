FUNCTION S2ColorArray(n)
   STATIC aColorObj := NIL

   IF aColorObj == NIL
      aColorObj := { dfColor( "Browse"      ) ,;
                     dfColor( "Form"        ) ,;
                     dfColor( "ArrayWindow" ) ,;
                     dfColor( "ArrayBox"    ) ,;
                     dfColor( "BrowseBox"   )  }
   ENDIF
RETURN ACLONE( aColorObj[n] )

//FUNCTION S2ColorPalette()
//   STATIC aColorPal := NIL
//   LOCAL nInd
//   LOCAL aRGB
//
//   IF aColorPal == NIL
//      aColorPal := ARRAY(16)
//      FOR nInd := 0 TO 15
//         aRGB := dfColor( "PALETTE"+STRZERO(nInd,2,0) )
//         aColorPal[nInd+1] := {aRGB[1]*4,aRGB[2]*4,aRGB[3]*4}
//      NEXT
//   ENDIF
//RETURN aColorPal

