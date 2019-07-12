#include "dfStd.ch"
#include "dfXbase.ch"
#include "AppEvent.ch"

//////////////////////////////////////
//Inserito per Workourond Errore su Setinterval(0)
//Luca 18/7/04 GERR4216
//--> Inizio
// ATTENZIONE --> Rispetto al codice originario Š stato inserito 
// la funzione _SetTimerEvent(), dove Š utilizzata la funzione SetTimerEvent Š 
// stata sostiuita con _SetTimerEvent().
//////////////////////////////////////

#include "error.ch"
STATIC nInterval := 0
STATIC bCode
STATIC oThread
//////////////////////////////////////
//Inserito per Workourond Errore su Setinterval(0)
//Luca 18/7/04
//--> Fine
//////////////////////////////////////


STATIC aRealTime := {}
STATIC lStop := .F.
STATIC lAll := NIL

FUNCTION S2RealTimeStop(lNewStop)
   LOCAL lRet := lStop
   IF lNewStop != NIL
      lStop := lNewStop
   ENDIF
RETURN lRet

FUNCTION S2RealTimeAdd(oForm)

#ifndef _S2DEBUG_

   IF lAll == NIL

      lAll := .T. 
      // Caratteristica per effettuare il realtime solo per i control
      // della form attiva
      IF dfSet("XbaseRealTimeFast") == "YES"
         lAll := .F. 
      ENDIF
   ENDIF

   IF ASCAN(aRealTime, {|oF| oF == oForm}) == 0
      AADD(aRealTime, oForm)
   ENDIF

   IF LEN(aRealTime) > 0
      _SetTimerEvent( 15, {|| S2RealTimeUpd()} )
   ENDIF
#endif

RETURN NIL

FUNCTION S2RealTimeDel(oForm)

#ifndef _S2DEBUG_

   LOCAL nPos := ASCAN(aRealTime, {|oF| oF == oForm})

   IF nPos > 0
      DFAERASE(aRealTime, nPos)
   ENDIF

   IF LEN(aRealTime) == 0
      // Tolgo il timer
      _SetTimerEvent( 0 )
   ENDIF
#endif

RETURN NIL

FUNCTION S2RealTimeDelAll()

#ifndef _S2DEBUG_
   _SetTimerEvent(0)
   ASIZE(aRealTime, 0)
#endif

RETURN NIL

#ifndef _S2DEBUG_
FUNCTION S2RealTimeUpd()
   LOCAL oCurr
   IF ! lStop .AND. NEXTKEY() == 0
      oCurr := S2FormCurr()

      AEVAL(aRealTime, {|oForm| IIF(EMPTY(oCurr) .OR. lAll .OR. oForm == oCurr, ;
                                    PostAppEvent(xbeP_User+EVENT_REALTIME, ;
                                                 NIL, NIL, oForm), NIL )} )
   ENDIF
RETURN NIL
#endif

//////////////////////////////////////
//Inserito per Workourond Errore su Setinterval(0)
//Luca 18/7/04 GERR4216
//--> Inizio
//////////////////////////////////////

FUNCTION _SetTimerEvent( nNewInterval, bNewBlock )

   LOCAL aReturn := { nInterval, bCode }

   IF oThread == NIL
      // Inizio modifica
      IF EMPTY(nNewInterval)
         RETURN aReturn
      ENDIF
      // Inizio Fine
      oThread := Thread():new()
   ENDIF

   IF PCount() > 0
      // nNewInterval has to be a non negative numeric value 
      IF VALTYPE(nNewInterval) != "N"
         RETURN paramError( "setTimerEvent", {nNewInterval, bNewBlock}, XPP_ERR_ARG_TYPE )
      ENDIF
      IF nNewInterval < 0 
         RETURN paramError( "setTimerEvent", {nNewInterval, bNewBlock}, XPP_ERR_ARG_VALUE )
      ENDIF
      nInterval := nNewInterval
   ENDIF
         
   IF PCount() > 1
      IF VALTYPE( bNewBlock ) == "B"
         // stop old codeblock
         oThread:setInterval(NIL) 
         oThread:synchronize(0)
         bCode := bNewBlock
      ELSE
         // bNewBlock is not a codeblock:
         // generate error if nNewInterval != 0
         IF VALTYPE( nNewInterval ) != "N" .OR. nNewInterval != 0
            RETURN paramError( "setTimerEvent", {nNewInterval, bNewBlock}, XPP_ERR_ARG_TYPE )
         ENDIF
      ENDIF
   ENDIF

   IF nInterval > 0
      oThread:setInterval( nInterval )
      oThread:start( bCode )
   ELSEIF nInterval == 0 .AND. oThread:active
      oThread:setInterval( NIL )
   ENDIF

RETURN aReturn

// generate an runtime error
STATIC FUNCTION paramError( cFunction, aArgs, nError )
 
   LOCAL oError := Error():new()

   oError:args := aArgs
   oError:canSubstitute := .T.
   oError:description := errorString( nError )
   oError:genCode := nError
   oError:operation := cFunction
   oError:subSystem := "BASE"
   oError:thread := threadID()

RETURN EVAL( errorBlock(), oError )

FUNCTION GetTimerThread()
RETURN oThread
//////////////////////////////////////
//Inserito per Workourond Errore su Setinterval(0)
//Luca 18/7/04
//--> Fine
//////////////////////////////////////
