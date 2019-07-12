#include "common.ch"
#include "dfMsg.ch"
#include "dfStd.ch"

// Torna Array del call stack
FUNCTION dfCallStackArr(i, lShowCaller, nThreadID)
   LOCAL aErr := {}

   DEFAULT lShowCaller TO .F.

   IF i == NIL .AND. ;
      ! lShowCaller // Non mostro la routine che chiama il callstack

      i := 2
   ENDIF

   DEFAULT i TO 1

   DO WHILE ( !EMPTY(PROCNAME(i, nThreadID)) )
      AADD( aErr, {PROCNAME(I, nThreadID) , PROCLINE(I, nThreadID)} )
      i++
   ENDDO
RETURN aErr

// Mostra window con array del call stack
FUNCTION dfErrStkShow(cTitle, aCS, nThreadID)
   LOCAL aErr := {}

   DEFAULT cTitle TO "Call Stack"

   IF ! VALTYPE(aCS) == "A"
      aCS := dfCallStackArr(NIL, NIL, nThreadID)
   ENDIF

   AEVAL(aCS, ;
         {|x| AADD(aErr, dfStdMsg(MSG_ERRSYS75) +" " +Trim(x[1])+ ;
                         "(" + ALLTRIM(STR(x[2])) + ")  " ) } )

   dfArrWin(,,,,aErr,cTitle)
RETURN NIL

