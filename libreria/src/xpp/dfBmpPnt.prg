#include "Common.ch"
#include "gra.ch"
#include "xbp.ch"

#include "dfCtrl.ch"

// simone 1/6/05
// mantis 0000760: abilitare nuovi stili per i controls
// funzioni basi per disegno di un bordo, per avere meno refresh
// il disegno pu• essere effettuato all'interno di una bitmap
// che viene poi impostata in un oggetto

// Esegue il paint in una Bitmap
FUNCTION dfBMPPaint(aSz, bPaint)
   LOCAL oPS 
   LOCAL oBmp

   oPS:=XbpPresSpace():new():create()

   oBmp := S2XbpBitmap():new()
   oBmp:create()
   oBmp:presSpace(oPS)
   oBmp:make(aSz[1], aSz[2] ) 

   EVAL(bPaint, oPS, oBmp, aSz)

   oPS:destroy()
RETURN oBmp

// Esegue il paint in una bitmap di un BOX con bordo
FUNCTION dfBMPPaintBack(aSize, nPaintStyle, nLineWidth, xFG, xBG, aRound)
   LOCAL oBmp
   oBmp := dfBMPPaint(aSize, {|oPS, oBmp, aSize| dfPSPaintBorder(oPS, {0, 0}, aSize, nPaintStyle, nLineWidth, xFG, xBG, aRound )})
RETURN oBmp

// Disegna un bordo in un PresentationSpace
FUNCTION dfPSPaintBorder(oPS, aPos, aSize, nPaintStyle, nLineWidth, xFG, xBG, aRound)
   LOCAL aAttr

   DEFAULT aPos TO {0, 0}
   DEFAULT nPaintStyle TO PS_BORDER
   DEFAULT aRound TO IIF(nPaintStyle==PS_ROUNDBORDER, {10, 10}, {0, 0})

   aSize := ACLONE(aSize)
   aSize[1] += aPos[1]
   aSize[2] += aPos[2]

   IF xBG != NIL
      aAttr  := Array( GRA_AA_COUNT )     // create array for
      aAttr[ GRA_AA_COLOR ] := xBG
      GraSetAttrArea( oPS, aAttr )     // set area attributes

      aAttr  := Array( GRA_AL_COUNT )     // create array for
      aAttr[ GRA_AL_COLOR ] := xFG
      GraSetAttrLine( oPS, aAttr )     // set area attributes

      GraBox(oPS,aPos,aSize, GRA_FILL)
   ENDIF

   IF nPaintStyle == PS_BORDER .OR. nPaintStyle == PS_ROUNDBORDER // ha il bordo?
      aAttr  := Array( GRA_AL_COUNT )     // create array for
      aAttr[ GRA_AL_COLOR ] := xFG
      aAttr[ GRA_AL_WIDTH ] := nLineWidth
      GraSetAttrLine( oPS, aAttr )     // set area attributes

      GraBox(oPS,aPos,{aSize[1]-1, aSize[2]-1},IIF(xBG==NIL, GRA_OUTLINE, GRA_OUTLINEFILL),aRound[1],aRound[2])
   ENDIF
RETURN NIL

