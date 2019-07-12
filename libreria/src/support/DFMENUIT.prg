#include "dfMenu.ch"
#include "Common.ch"


FUNCTION dfMenuItm( aFather, cID, nCh )
   LOCAL nInd := 0, aRet := {}
   LOCAL lExt := .F.
   DEFAULT nCh TO 1

///////////////////////////////////////////////////////////////
//Ger 4624
//   DO WHILE ++nInd <= LEN(aFather) .AND. ;
//      ! LEFT(aFather[nInd][MNI_CHILD], nCh) == LEFT(cId, nCh)
//   ENDDO
   DO WHILE !lExt .AND. ++nInd <= LEN(aFather) 
      IF EMPTY(aFather[nInd]) .OR. EMPTY(aFather[nInd][MNI_CHILD]) .OR. EMPTY(cId)
         lExt := .T.
      ENDIF
      IF LEFT(aFather[nInd][MNI_CHILD], nCh) == LEFT(cId, nCh)
         lExt := .T.
      ENDIF
   ENDDO
///////////////////////////////////////////////////////////////

   IF nInd <= LEN(aFather)
      IF nCh < LEN(cID)
         aRet := dfMenuItm( aFather[nInd][MNI_ARRAY], cID, nCh+1)
      ELSE
         aRet := aFather[nInd]
      ENDIF
   ENDIF
RETURN aRet
