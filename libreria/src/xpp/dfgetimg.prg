#include "common.ch"
#include "gra.ch"

// trova le dimensioni di una immagine
// <xbmpid> pu• essere:
//   numero: id risorsa
//   array: {nomeDLL, numero id risorsa}
//   stringa: nomefile 
// <@oBitmap> -> se Š 0, per referenza ritorna l'oggetto bitmap in status CREATE()
// ritorna
//   NIL: errore
//   array: dimensione immagine
FUNCTION dfGetImgSize(xBmpID)
//   LOCAL aSize
//   LOCAL oBmp := XbpBitmap():new():create()
//   IF (VALTYPE(xBmpId) == "N" .AND. oBmp:load(NIL, xBmpId)) .OR. ;
//      (VALTYPE(xBmpId) == "A" .AND. oBmp:load(xBmpId[1], xBmpId[2])) .OR. ;
//      (VALTYPE(xBmpId) $  "CM" .AND. oBmp:loadFile(xBmpId))
//      aSize := {oBmp:xSize, oBmp:ySize}
//   ENDIF
   LOCAL aSize
   LOCAL lErr := .T.
   LOCAL oBmp := dfGetImgObject(xBmpId, @lErr)
   IF ! lErr
      aSize := {oBmp:xSize, oBmp:ySize}
   ENDIF
   oBmp:destroy()
   oBmp:=NIL
RETURN aSize

// ritorna l'oggetto bitmap in status CREATE()
// <xbmpid> pu• essere:
//   numero: id risorsa
//   array: {nomeDLL, numero id risorsa, cType }
//   stringa: nomefile 
//
// nTransparentClr= colore di trasparenza: default= 0x808080
//                  se non voglio trasparenza devo passare .F.

FUNCTION dfGetImgObject(xBmpID, lError, nTransparentClr, oBmp)
   LOCAL aSize

   // Simone 28/8/06
   // mantis 0001130: dare possibilità di impostare icone toolbar disabilitate/focused   
   IF xBmpID == NIL
      RETURN NIL
   ENDIF

   DEFAULT oBmp TO S2XbpBitmap():new():create()
   DEFAULT nTransparentClr TO GraMakeRGBColor({128, 128, 128})

   IF VALTYPE(xBmpID)=="A"
      xBmpID := ACLONE(xBmpID)
      ASIZE(xBmpID, 3)
   ENDIF

   IF (VALTYPE(xBmpId) == "N" .AND. oBmp:load(NIL, xBmpId)) .OR. ;
      (VALTYPE(xBmpId) == "A" .AND. oBmp:load(xBmpId[1], xBmpId[2], NIL, NIL, xBmpId[3])) .OR. ;
      (VALTYPE(xBmpId) $  "CM" .AND. oBmp:loadFile(xBmpId))
      lError := .F.
   ELSE
      lError := .T.
   ENDIF

   IF oBmp:transparentClr == GRA_CLR_INVALID  .AND. ; // se non ho gi… un valore di trasparenza
      VALTYPE(nTransparentClr) $ "N-A"                 // e voglio usare la trasparenza
      IF VALTYPE(nTransparentClr) == "A"
         nTransparentClr := GraMakeRGBColor(nTransparentClr)
      ENDIF
      oBmp:transparentClr := nTransparentClr
   ENDIF
RETURN oBmp
