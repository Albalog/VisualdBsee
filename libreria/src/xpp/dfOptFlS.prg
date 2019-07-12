#include "common.ch"
#include "dfOptFlt.ch"
#include "dfMsg.ch"


// Imposta il filtro
FUNCTION dfOptFltSet(aOpt, bBlk, nMax, nProgress, lGoTop)
   LOCAL aArr := {}
   LOCAL bFlt := {||.T.}
   LOCAL cFlt := ""
   LOCAL cAlias := UPPER(ALLTRIM(aOpt[OPTFLT_ALIAS]))
   LOCAL oThread
   LOCAL xPar

   // Salvo il filtro corrente
   (cAlias)->(dfFilterPush())

   IF EMPTY(aOpt)
      RETURN bFlt
   ENDIF

   // Disabilita globalmente ottimizzazione browse
   IF dfSet("XbaseFilterOptimizeDisabled") == "YES"
      RETURN aOpt[OPTFLT_CBEXP]
   ENDIF

   dfOptFltOptimize(aOpt, bBlk, nMax)

   IF dfOptFltGetErrNum(aOpt) == 0 

      IF ! aOpt[OPTFLT_STRNOTOPTEXP ] == ".T." .AND. ;
         dfSet("XbaseFilterOptimizeShowErrors")=="YES"

         dfAlert("Filtro non completamente ottimizzabile//"+aOpt[OPTFLT_STREXP])
      ENDIF

   ELSE
      IF dfSet("XbaseFilterOptimizeShowErrors")=="YES"
         dfAlert(  dfOptFltGetErrMsg(aOpt)  )
      ENDIF
   ENDIF

   cFlt := dfOptFltGetString(aOpt)

   // Simone 1/3/2005 GERR 4283
   // Imposta/toglie filtro con goTop
   (aOpt[OPTFLT_ALIAS])->(dfSetFilter(dfOptFltGetCB(aOpt), cFlt, nProgress, lGoTop))
   
   bFlt := aOpt[OPTFLT_CBNOTOPTEXP]
RETURN bFlt

// Toglie il filtro
FUNCTION dfOptFltDel(aOpt)
   LOCAL cAlias := UPPER(ALLTRIM(aOpt[OPTFLT_ALIAS]))
RETURN (cAlias)->(dfFilterPop())

