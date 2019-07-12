// dfBMPDisable - create bitmap for disabled status
// syntax:  dfBMPDisable(oBitmap) --> oDisabledBitmap
#include "gra.ch"

FUNCTION dfBMPDisable(oBmpOrg)
   LOCAL nOldClr
   LOCAL oPs
   LOCAL oBmpNew

   IF VALTYPE(oBmpOrg) != "O"
      RETURN NIL
   ENDIF

   IF ! oBmpOrg:isDerivedFrom("XbpBitmap") 
      RETURN NIL
   ENDIF

   nOldClr := oBmpOrg:transparentClr           // save current transparancy colour
   oPs     := XbpPresSpace():new():create()
   oBmpNew := S2XbpBitmap():new():create()       // create the bitmap
   oBmpNew:make(oBmpOrg:xSize, oBmpOrg:ySize)
   oBmpNew:presSpace(oPs)

   GraSetColor(oPs, GRA_CLR_WHITE, GRA_CLR_WHITE)
   GraBox(oPs, {0,0}, {oBmpOrg:xSize-1, oBmpOrg:ySize-1}, GRA_FILL)

   IF oBmpOrg:transparentClr == GRA_CLR_INVALID  // check transparency of bitmap
     oBmpOrg:transparentClr := oBmpOrg:getDefaultBGColor()
   ENDIF
   oBmpOrg:draw(oPs, {0,0})                    // draw bitmap on new presSpace
   oBmpOrg:transparentClr := nOldClr           // reset transparancy
   oPS:destroy()
RETURN oBmpNew
