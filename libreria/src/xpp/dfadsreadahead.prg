// Gestione del ReadAhead di ADS per velocizzare le operazioni di SKIP
// serve per leggere "n" record in una volta sola
// da usare nei REPORT e nei BROWSE. 
// Dove ci sono le scritture pu• dare problemi perchŠ NON 
// si vedono i dati reali del DB

// Modo d'uso
// LOCAL aAhead := {}
// DOCMOVD->(dfADSReadAheadSet(aAhead, "REPORT"))
// .. elaborazione su DOCMOVD
// S2AdsReadAheadDel(aAhead)
//
// oppure

// LOCAL aAhead := {}
// DOCMOVD->(dfADSReadAheadSet(aAhead, 50))
// .. elaborazione su DOCMOVD
// S2AdsReadAheadDel(aAhead)

#include "dfAdsDbe.ch"

// Imposta 
FUNCTION dfADSReadAheadSet(aAhead, xMode, xAlias)
   LOCAL cAlias 
   LOCAL cSet
   LOCAL nVal
   LOCAL nOld

   IF VALTYPE(xMode)=="N"
      nVal := xMode

   ELSEIF UPPER(xMode)=="REPORT"
      cSet := dfSet("XbaseADSReadAheadReport")
      IF EMPTY(cSet)
         cSet := "0" // default 0 (disabilitato)
      ENDIF
      nVal := VAL(cSet)

// simone 17/12/09
// per ora disabilitato
//   ELSEIF UPPER(xMode)=="BROWSE" 
//      cSet := dfSet("XbaseADSReadAheadBrowse")
//      IF EMPTY(cSet)
//         cSet := "0" // default 0 (disabilitato)
//      ENDIF
//      nVal := VAL(cSet)

   ELSE
      nVal := 0
   ENDIF

   IF nVal <= 1
      RETURN .F.  // disabilitato
   ENDIF
   IF EMPTY(xAlias) .OR. VALTYPE(xAlias)=="A"
      // imposto su tutte le workareas
      WorkSpaceEval({||_SetRA(aAhead, nVal, ALIAS(), xAlias)})
   ELSE
      // imposto solo sull'area indicata'
      (xAlias)->(_SetRA(aAhead, nVal, ALIAS()))
   ENDIF
RETURN .T.

STATIC FUNCTION _SetRA(aAhead, nVal, cAlias, xAlias)
   LOCAL nOld

   IF ! dfAxsIsLoaded( cAlias ) // se non c'Š ADS esce
      RETURN .F.
   ENDIF
   nOld:=(cAlias)->(DBInfo(ADSDBO_READAHEAD))

   IF nOld > 1
      RETURN .F. // gi… impostato esce
   ENDIF

   cAlias := UPPER(cAlias)
   IF ! EMPTY(xAlias) .AND. ASCAN(xAlias, {|c| UPPER(c) == cAlias}) == 0
      // non Š nell'array passato
      RETURN .F.
   ENDIF

   AADD(aAhead, {cAlias, nOld})
   (cAlias)->(DBInfo(ADSDBO_READAHEAD    , nVal))
//   (cAlias)->(DBInfo(ADSDBO_REFRESHRECORD, .F. ))
RETURN .T.

// ripristina il read ahead   
FUNCTION dfADSReadAheadDel(aAhead)
   LOCAL n, cAlias, nVal
   FOR n := 1 TO LEN(aAhead)
      cAlias := aAhead[n][1]
      nVal   := aAhead[n][2]
      (cAlias)->(DBInfo(ADSDBO_READAHEAD    , nVal))
//      (cAlias)->(DBInfo(ADSDBO_REFRESHRECORD, .T. ))
      (cAlias)->(DbSkip(0)) // refresh record corrente
   NEXT
RETURN .T.
