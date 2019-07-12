#include "common.ch"

#define DAY_SECONDS 86400 
// Gestione di un timeout con controllo passaggio mezzanotte
// esempio d'uso
//  oTimeOut := S2TimeOut():new( 120 ) // imposto un timeout a 120 sec
//  DO WHILE .T.
//     ..
//     IF oTimeOut:isTimeOut()
//        EXIT
//     ENDDO
//  ENDDO
//  ..
//  oTimeOut:start() // aggiorno il secondo di inizio conteggio
//  DO WHILE .T.
//     ..
//     IF oTimeOut:isTimeOut()
//        EXIT
//     ENDDO
//  ENDDO

CLASS S2TimeOut
PROTECTED:
   VAR nTimeOut
   VAR nStart
  
EXPORTED:
   METHOD init
   METHOD setTimeOut
   METHOD getTimeOut
   METHOD start
   METHOD isTimeOut
   METHOD getStartTime
   METHOD getTimeOutTime
   METHOD getElapsedTime
   METHOD getPercElapsed
ENDCLASS
  
METHOD S2TimeOut:init(nTimeout)
   DEFAULT nTimeOut TO 30 // secondi
   ::setTimeOut(nTimeOut)
   ::start()
RETURN self

METHOD S2TimeOut:setTimeOut(nTimeout)
   IF VALTYPE(nTimeOut) != "N"
      RETURN .F.
   ENDIF
   IF nTimeOut > DAY_SECONDS
      nTimeOut := DAY_SECONDS
   ENDIF
   ::nTimeOut := nTimeOut
RETURN .T.

METHOD S2TimeOut:getTimeOut()
RETURN ::nTimeOut

METHOD S2TimeOut:start( n )
   DEFAULT n TO SECONDS()
   ::nStart := n
RETURN self

METHOD S2TimeOut:getStartTime()
RETURN ::nStart

METHOD S2TimeOut:getTimeOutTime()
RETURN ::nStart + ::nTimeOut

METHOD S2TimeOut:isTimeOut()
   LOCAL n
   n := SECONDS()
   IF n < ::nStart  // passata mezzanotte?
      n += DAY_SECONDS
   ENDIF
RETURN n > ::getTimeOutTime() 

METHOD S2TimeOut:getElapsedTime()
   LOCAL n
   n := SECONDS()
   IF n < ::nStart  // passata mezzanotte?
      n += DAY_SECONDS
   ENDIF
RETURN n - ::nStart

METHOD S2TimeOut:getPercElapsed()
   LOCAL nMax := ::getTimeOut()
RETURN ::getElapsedTime() * 100  / nMax 



