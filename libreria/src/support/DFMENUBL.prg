#include "dfMenu.ch"

FUNCTION dfMenuBlock(aArr, cCho)
   LOCAL bRet := {|| .T.  }
   LOCAL aItem := dfMenuItm(aArr, cCho)

   IF ! EMPTY(aItem) .AND. dfMenuItemIsActive(aItem)
      bRet := aItem[MNI_BLOCK]
   ENDIF

   // LOCAL nAttivo
   //
   // IF ! EMPTY(aItem)
   //    nAttivo := EVAL( aItem[MNI_BSECURITY] )
   //    // (aItem[MNI_SECURITY] == MN_ON .OR. aItem[MNI_SECURITY] == MN_SECRET)
   //    IF nAttivo == MN_ON .OR. nAttivo == MN_SECRET
   //       bRet := aItem[MNI_BLOCK]
   //    ENDIF
   // ENDIF
RETURN bRet

FUNCTION dfMenuItemIsActive(aItem)
   LOCAL cLab
   //LOCAL nAttivo := EVAL( aItem[MNI_BSECURITY],aItem[MNI_CHILD],aItem[MNI_LABEL],aItem[MNI_ID]  )
   LOCAL nAttivo := 0

   cLAB   := aItem[MNI_LABEL]
   IF VALTYPE(cLAB) == "B"
      cLAB := EVAL(cLAB)
   ENDIF 

   //Nuova implementazione etichette dinamiche, mantis 2185, luca 05/09/2012 
   nAttivo := EVAL( aItem[MNI_BSECURITY],aItem[MNI_CHILD], cLab ,aItem[MNI_ID]  )


//Modificato Luca per gestire meglio personalizzazioni per attivazione label a runtime
//RETURN (nAttivo == MN_ON .OR. nAttivo == MN_SECRET) .AND. ;
//       (VALTYPE(aItem[MNI_BRUNTIME]) != "B" .OR. EVAL(aItem[MNI_BRUNTIME]))
//RETURN (nAttivo == MN_ON .OR. nAttivo == MN_SECRET) .AND. ;                                 
//       (VALTYPE(aItem[MNI_BRUNTIME]) != "B" .OR. EVAL(aItem[MNI_BRUNTIME],aItem[MNI_CHILD], aItem[MNI_LABEL],aItem[MNI_ID]))
RETURN (nAttivo == MN_ON .OR. nAttivo == MN_SECRET) .AND. ;                                 
       (VALTYPE(aItem[MNI_BRUNTIME]) != "B" .OR. EVAL(aItem[MNI_BRUNTIME],aItem[MNI_CHILD], cLAB ,aItem[MNI_ID]))

