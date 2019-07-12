#include "dll.ch"
#include "common.ch"

STATIC aDllLoaded := {}

// simone 31/8/04
// abilita il log delle chiamate alla dfDllCall
// normalmente disabilitato, serve in caso si debba
// effettuare il log delle chiamate magari per debug
//#define _LOG_CALL_

#ifdef _LOG_CALL_
STATIC bLog

FUNCTION dfDllCallSetLog(bNew)
   LOCAL bRet := bLog

   IF VALTYPE(bNew)=="B"
      bLog := bNew
   ENDIF
RETURN bRet
#endif

// Queste funzioni sono modificate per un errore in Xbase
// SE c'Š il cFunc e la DLL Š gi… caricata da un runtime error
// se non ci fosse questo errore (che dovrebbe essere corretto
// nella prossima release) le funzioni sarebbero OK cos.
// -----------------------------------------------------------
//
// FUNCTION dfDllLoad(cDll, cFunc)
//    LOCAL nLoad
//    IF cFunc == NIL
//       nLoad := DllLoad(cDll)
//    ELSE
//       nLoad := DllLoad(cDll, cFunc)
//    ENDIF
//
//    IF nLoad != 0
//       AADD(aDllLoaded, nLoad)
//    ENDIF
// RETURN nLoad
//
// FUNCTION dfDllPrepareCall(cFunc)
//    LOCAL nInd
//    LOCAL cCall := ""
//
//    FOR nInd := 1 TO LEN(aDLLLoaded)
//       cCall := DLLPrepareCall(aDLLLoaded[nInd], NIL, cFunc)
//       IF ! EMPTY(cCall)
//          EXIT
//       ENDIF
//    NEXT
// RETURN cCall

FUNCTION dfDllLoad(cDll, cFunc)
   LOCAL nLoad

   cDll := UPPER(cDll)

   nLoad := ASCAN(aDllLoaded, {|x| x[2] == cDll })

   IF nLoad == 0

      IF cFunc == NIL
         nLoad := DllLoad(cDll)
      ELSE
         nLoad := DllLoad(cDll, cFunc)
      ENDIF

      IF nLoad != 0
         AADD(aDllLoaded, {nLoad, cDll, cFunc})
      ENDIF

   ELSE

   #ifndef _XBASE15_
      // La DLL Š gi… caricata con un prefisso diverso...
      // genero un runtime error
      IF ! cFunc == aDllLoaded[nLoad][3]
         DLLLoad(cDll, "xx") // Questo genera un runtime error con 1.30.210
      ENDIF
   #endif

      nLoad := aDllLoaded[nLoad][1]

   ENDIF

RETURN nLoad

FUNCTION dfDllUnLoad(xDll)
   LOCAL nLoad, lRet := .F.
   lRet := DllUnload(xDll)
   IF lRet 
      IF VALTYPE(xDll)=="N"
         nLoad := ASCAN(aDllLoaded, {|x| x[1] == xDll })
      ELSE
         xDll := UPPER(xDll)
         nLoad := ASCAN(aDllLoaded, {|x| x[2] == xDll })
      ENDIF
      IF nLoad > 0
         AREMOVE(aDllLoaded, nLoad)
      ENDIF
   ENDIF
RETURN lRet

FUNCTION dfDLLArr()
RETURN aDLLLoaded


FUNCTION dfDllPrepareCall(cFunc)
   LOCAL nInd
   LOCAL cCall := ""

   FOR nInd := 1 TO LEN(aDLLLoaded)
      #ifdef _XBASE15_
         cCall := _DLLPrepareCall(aDLLLoaded[nInd][1], NIL, cFunc)
      #else
         cCall := DLLPrepareCall(aDLLLoaded[nInd][1], NIL, cFunc)
      #endif

      IF ! EMPTY(cCall)
//         dfAlert({cFunc,"YES",aDLLLOaded[nInd]})
         EXIT
      ENDIF
//         dfAlert({cFunc,"NO",aDLLLOaded[nInd]})
   NEXT
RETURN cCall


// FUNCTION dfDllCall(cDll, cName, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, ;
//                    p11, p12, p13, p14, p15, p16, p17, p18, p19, p20)
//   LOCAL nLoad
//   LOCAL xRet
//
//   IF isFunction("_dbs_"+cName)
//      cName := "_dbs_"+cName
//      nLoad := 1
//   ELSE
//      nLoad := DllLoad(cDll)
//   ENDIF
//
//   IF nLoad > 0
//      xRet := &(cName)(@p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, ;
//                       @p11, @p12, @p13, @p14, @p15, @p16, @p17, @p18, ;
//                       @p19, @p20)
//   ELSE
//      dfAlert('Error loading DLL '+cDll+"//Error: "+ALLTRIM(STR(DOSERROR())))
//   ENDIF
// RETURN xRet

// FUNCTION dfDllCall(cDll, cName, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, ;
//                    p11, p12, p13, p14, p15, p16, p17, p18, p19, p20)
//
//    LOCAL nLoad
//    LOCAL xRet
//    LOCAL cPref
//
//    IF .T. //dfSet(AI_XBASEDLLLOADWITHPREFIX)
//       cPref := cDll+"_"
//       cPref := STRTRAN(cPref, ":", "_")
//       cPref := STRTRAN(cPref, "\", "_")
//       cPref := STRTRAN(cPref, ".", "_")
//
//       cName := cPref+cName
//
//       nLoad := DllLoad(cDll, cPref)
//
//    ELSE
//       nLoad := DllLoad(cDll)
//    ENDIF
//
//
//    IF nLoad > 0
//       xRet := &(cName)(@p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, ;
//                        @p11, @p12, @p13, @p14, @p15, @p16, @p17, @p18, ;
//                        @p19, @p20)
//    ELSE
//       dfAlert('Error loading DLL '+cDll+"//Error: "+ALLTRIM(STR(DOSERROR())))
//    ENDIF
// RETURN xRet


FUNCTION dfDllCall(cDll, cName, ;
                   p00, p01, p02, p03, p04, p05, p06, p07, p08, p09, ;
                   p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, ;
                   p20, p21, p22, p23, p24, p25, p26, p27, p28, p29, ;
                   p30, p31, p32, p33, p34, p35, p36, p37, p38, p39, ;
                   p40, p41, p42, p43, p44, p45, p46, p47, p48, p49  )

  LOCAL nLoad := DllLoad(cDll)
  LOCAL xRet
  LOCAL n
  IF nLoad > 0
     IF PCOUNT() > 52
        dfAlert("dfDllCall()//"+;
                "Attenzione, non tutti i parametri sono stati passati//"+;
                "DLL: "+cDll+" Funzione: "+cName+" Num. parametri: "+;
                ALLTRIM(STR(PCOUNT()-2)) )
     ENDIF

#ifdef _LOG_CALL_
     IF bLog != NIL
        EVAL(bLog, "I", cDll, @cName, @p00, @p01, @p02, @p03, @p04, @p05, @p06, @p07, @p08, @p09, ;
                      @p10, @p11, @p12, @p13, @p14, @p15, @p16, @p17, @p18, @p19, ;
                      @p20, @p21, @p22, @p23, @p24, @p25, @p26, @p27, @p28, @p29, ;
                      @p30, @p31, @p32, @p33, @p34, @p35, @p36, @p37, @p38, @p39, ;
                      @p40, @p41, @p42, @p43, @p44, @p45, @p46, @p47, @p48, @p49  )
     ENDIF
     IF EMPTY(cName)
        RETURN xRet
     ENDIF
#endif
     xRet := &(cName)(@p00, @p01, @p02, @p03, @p04, @p05, @p06, @p07, @p08, @p09, ;
                      @p10, @p11, @p12, @p13, @p14, @p15, @p16, @p17, @p18, @p19, ;
                      @p20, @p21, @p22, @p23, @p24, @p25, @p26, @p27, @p28, @p29, ;
                      @p30, @p31, @p32, @p33, @p34, @p35, @p36, @p37, @p38, @p39, ;
                      @p40, @p41, @p42, @p43, @p44, @p45, @p46, @p47, @p48, @p49  )

#ifdef _LOG_CALL_
     IF bLog != NIL
        EVAL(bLog, "O", cDll, cName, @xRet)
     ENDIF
#endif
  ELSE
     dfAlert('Error loading DLL '+cDll+"//Error: "+ALLTRIM(STR(DOSERROR())))
  ENDIF
RETURN xRet

FUNCTION dfDllHasFunction(xDll, cFunc)

#ifdef _XBASE15_
      LOCAL aArr := DllInfo(xDll,DLL_INFO_FUNCLIST)
      LOCAL cPref := UPPER(ALLTRIM(DllInfo(xDll,DLL_INFO_PREFIX)))
      cFunc := UPPER(ALLTRIM(cFunc))
   RETURN ASCAN(aArr, {|x|cPref+UPPER(ALLTRIM(x))==cFunc }) > 0

#else

   RETURN LEN(dllPrepareCall(xDll, DLL_STDCALL, cFunc)) != 0

#endif

#ifdef _XBASE15_

// Funzione di compatibilit… con Xbase 1.3 che non dava un runtime
// error se la funzione non esisteva

// FUNCTION _dllPrepareCall(xDll, xCall, cFunc)
//    LOCAL cRet := ""
//    IF dfDLLHasFunction(xDll,cFunc)
//       cRet := dllPrepareCall(xDll, xCall, cFunc)
//    ENDIF
// RETURN cRet

FUNCTION _dllPrepareCall(xDll, xCall, cFunc, lToUpper)
   LOCAL cRet := ""
   LOCAL oEH := ErrorBlock({|e| dfErrBreak(e) })
   LOCAL e
   LOCAL cPref := DllInfo(xDll,DLL_INFO_PREFIX)

   DEFAULT lToUpper TO .T.

   IF lToUpper
      cPref := UPPER(ALLTRIM(cPref))
   ENDIF

   BEGIN SEQUENCE
      IF lToUpper
         cFunc := UPPER(ALLTRIM(cFunc))
      ENDIF

      // Differenza sul prefisso della funzione da Xbase 1.3 che lo voleva
      // mentre con la 1.5 va tolto!

      IF ! EMPTY(cPref) .AND. ;
         UPPER(LEFT(ALLTRIM(cFunc), LEN(cPref)))==UPPER(ALLTRIM(cPref))
         cFunc := SUBSTR(cFunc,LEN(cPref)+1)
      ENDIF
      cRet := dllPrepareCall(xDll, xCall, cFunc)

   RECOVER USING e
      IF e:genCode == 21 .AND. e:subCode == 2002 .AND. ;
         VALTYPE(e:subSystem)=="C" .AND.e:subSystem=="BASE" .AND. ;
         VALTYPE(e:operation)=="C" .AND. UPPER(e:operation)=="DLLPREPARECALL"

         e:=NIL
      ENDIF

   END SEQUENCE
   ErrorBlock(oEH)

   IF e != NIL
      EVAL(oEH,e)
   ENDIF
RETURN cRet

#endif


