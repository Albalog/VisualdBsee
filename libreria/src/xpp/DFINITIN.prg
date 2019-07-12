#include "dfXRes.ch"

FUNCTION dfInitScreenInfo()
   LOCAL aSz, nBmp :=  DFINITSCREEN_BITMAP

   aSz := dfGetImgSize(nBmp)
   IF VALTYPE(aSz) != "A" .OR. ;
      EMPTY(aSz) .OR.;
      LEN(aSz) < 2 

      aSz := {DFINITSCREEN_BITMAP_WIDTH, DFINITSCREEN_BITMAP_HEIGHT}
   ENDIF
RETURN { nBmp, aSz[1], aSz[2]}
