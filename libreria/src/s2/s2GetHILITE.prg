#include "dfCtrl.ch"
#include "Xbp.ch"
#include "dfMenu.ch"
#include "Common.ch"

STATIC lHILITE
STATIC lHILITE_SPN
STATIC lHILITE_RBN

FUNCTION S2CTRGET_HILITEON(lSet, lisSPN, lIsRbn )
  LOCAL lRET := .F.

  DEFAULT lisSPN TO .F.
  DEFAULT lIsRbn TO .F.
  

  IF lHILITE == NIL
     lHILITE := dfSet("XbaseS2CTRGET_HILITEON") == "YES"
  ENDIF 
  //Mantis 2258
  IF lHILITE_SPN == NIL
     lHILITE_SPN := !dfSet("XbaseS2CTRGET_HILITEON_SPN") == "NO"
  ENDIF 
  //Mantis 2258
  IF lHILITE_RBN == NIL
     lHILITE_RBN := !dfSet("XbaseS2CTRGET_HILITEON_RBN") == "NO"
  ENDIF 

  IF lSet <>NIL .AND. VALTYPE(lSET) == "L"
     lHILITE := lSet
  ENDIF 

  IF lisSPN .AND. !lHILITE_SPN
     RETURN .F.
  ENDIF 
  IF lIsRbn .AND. !lHILITE_RBN
     RETURN .F.
  ENDIF 


  lRET := lHILITE
RETURN lRet 