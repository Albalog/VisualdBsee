#include "nls.ch"
#include "dfSet.ch"

// Abilita EURO
// funziona con Xbase >= 1.6

FUNCTION dfSetEuro(lSet)
   LOCAL lPrev, cSet

   IF lSet != NIL
      IF VALTYPE(lSet) == "L" 
         cSet := IIF(lSet, "1", "0")
      ENDIF
   ENDIF

   lPrev := SetLocale(NLS_ICURRENCYEURO) == "1"

   IF cSet != NIL
      SetLocale(NLS_ICURRENCYEURO, cSet)
   ENDIF

   IF lSet != NIL .AND. lSet
      SetLocale(NLS_SCURRENCY, CHR(213))
   ENDIF
RETURN lPrev

FUNCTION dfEuroChar(); RETURN CHR( dfSet(AI_EUROCHAR) )