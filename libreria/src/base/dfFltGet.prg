//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Salva e azzera filtro e scope (solo xbase 1.7 o successivi)
//Programmatore  : Simone Degl'Innocenti
//*****************************************************************************
#include "common.ch"

// simone 25/10/04
// abilita il log..messe per verifica lentezza filtri a ricoh 
// da togliere successivamente
// #define _LOG_FILTER_

FUNCTION dfFilterGet(nFlt, nClear)
   LOCAL cFlt   := NIL
   LOCAL aScope := NIL

#ifdef _LOG_FILTER_
   LOCAL aLogData := {DATE(), TIME(), SECONDS(), DBFILTER()}
#endif

   DEFAULT nFlt   TO 3   // Salva filtro (1) e scope (2) o tutti (3)
   DEFAULT nClear TO 3   // azzera filtro (1) e scope (2) o tutti (3)

   IF dfAnd(nFlt, 1) != 0
      cFlt := _SaveFlt(nClear)
#ifdef _LOG_FILTER_
      LogFlt(0, IIF(dfAnd(nClear, 1)!=0, "<clear>", "<nochange>"), aLogData)
#endif
   ENDIF

 #ifdef _XBASE17_
   IF dfAnd(nFlt, 2) != 0
      aScope := _SaveScope(nClear)
   ENDIF
 #endif  
RETURN {cFlt, aScope} 

STATIC FUNCTION _SaveFlt(nClear)
   LOCAL cFlt   := NIL
      cFlt := DBFILTER()
      IF UPPER(ALLTRIM(cFlt)) == ".T."
         cFlt := NIL
      ENDIF
   IF ! EMPTY(cFlt) .AND. dfAnd(nClear, 1) != 0
         // Simone 1/3/2005 GERR 4283
         dfClearFilter( .F. )
      ENDIF
RETURN cFlt

 #ifdef _XBASE17_
STATIC FUNCTION _SaveScope(nClear)
   LOCAL aScope := NIL
   LOCAL nInd := 0
   LOCAL nOrd := 0
   LOCAL cKey   := ""

      nOrd := INDEXORD()
      aScope := {}
      DO WHILE ! EMPTY( (cKey := INDEXKEY(++nInd)))
         DBSETORDER(nInd)
         AADD(aScope,  {cKey, DBSCOPE(SCOPE_TOP), DBSCOPE(SCOPE_BOTTOM)})
         IF dfAnd(nClear, 2) != 0
            DBCLEARSCOPE(SCOPE_BOTH)
         ENDIF
      ENDDO
      DBSETORDER(nOrd)
RETURN aScope
 #endif  

FUNCTION dfFilterSet(aFlt, nFlt)
   LOCAL aScope := NIL

#ifdef _LOG_FILTER_
   LOCAL aLogData := {DATE(), TIME(), SECONDS(), DBFILTER()}
#endif

   IF EMPTY(aFlt) .OR. ! VALTYPE(aFlt) == "A" 
      RETURN NIL
   ENDIF


   DEFAULT nFlt TO 3

   IF dfAnd(nFlt, 1) != 0
      _ResetFlt(aFlt)
#ifdef _LOG_FILTER_
      LogFlt(1, IIF(EMPTY(cFlt), "<clear>", cFlt), aLogData)
#endif
   ENDIF

 #ifdef _XBASE17_
   IF dfAnd(nFlt, 2) != 0
      _ResetScope(aFlt)
   ENDIF
 #endif
RETURN NIL

STATIC FUNCTION _ResetFlt(aFlt)
   LOCAL cFlt   := NIL
   LOCAL cCurrFlt := NIL

   cFlt := DBFILTER()
   IF UPPER(ALLTRIM(cFlt)) == ".T."
      cFlt := NIL
   ENDIF
   cCurrFlt := cFlt

      cFlt := aFlt[1]

      // Simone 1/3/2005 GERR 4283
      IF EMPTY(cFlt)
         IF ! EMPTY(cCurrFlt) // se non è già azzerato
            dfClearFilter( .F. )
         ENDIF
      ELSE 
         dfSetFilter(NIL, cFlt, NIL, .F.)
      ENDIF
RETURN .T.

 #ifdef _XBASE17_
STATIC FUNCTION _ResetScope(aFlt)
   LOCAL nInd   := 0
   LOCAL nOrd   := 0
   LOCAL nPos   := 0
   LOCAL cKey   := ""
   LOCAL aScope := aFlt[2]

      nOrd := INDEXORD()

      DO WHILE ! EMPTY( (cKey := INDEXKEY(++nInd)) )
         DBSETORDER(nInd)
         IF aScope == NIL .OR. ((nPos := ASCAN(aScope, {|x|x[1]==cKey})) == 0)
            DBCLEARSCOPE()
         ELSE
        IF aScope[nPos][2] == NIL
              DBCLEARSCOPE(SCOPE_TOP)
           ELSE
           DBSETSCOPE(SCOPE_TOP, aScope[nPos][2])
           ENDIF

        IF aScope[nPos][3] == NIL
              DBCLEARSCOPE(SCOPE_BOTTOM)
           ELSE
           DBSETSCOPE(SCOPE_BOTTOM, aScope[nPos][3])
           ENDIF
         ENDIF
      ENDDO

      DBSETORDER(nOrd)
RETURN .T.
 #endif

#ifdef _LOG_FILTER_
  FUNCTION dfFilterLog(b)
     STATIC bLog 
     LOCAL bRet := bLog
     IF PCOUNT() >0 
        bLog := b
     ENDIF
  RETURN bRet

  STATIC FUNCTION LogFlt(nMode, cFltPost, aLogData)
  IF ! EMPTY(dfFilterLog())
     EVAL(dfFilterLog(), nMode, cFltPost, aLogData)
  ENDIF
  RETURN NIL
#endif