#include "dfSet.ch"

FUNCTION tbConfig( oWin )
   LOCAL b

   // simone 25/8/06 
   // mantis 0001128: aggiungere possibilità per l'utente di definire le classi base form/browse/ecc.
   b := dfSet({AI_XBASESTDFUNCTIONS,  AI_STDFUNC_TBCONFIG})
   IF VALTYPE(b)=="B"
      RETURN EVAL(b, oWin)
   ENDIF
RETURN oWin:tbConfig()
