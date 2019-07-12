#include "Appevent.ch"
#include "dfXBase.ch"
#include "common.ch"

// simone 20/11/09 
// gestione multithread per ora disabilitato
//#define _MULTITHREAD_

// STATIC oKbd
// 
// FUNCTION dbAct2KbdQueueInit()
// 
//    oKbd:=S2KbdQueue():new()
//    oKbd:producerID := ThreadId()
//    oKbd:start()
// 
// RETURN NIL
// 
// CLASS S2KbdQueue FROM Thread
// 
//   EXPORTED:
//   VAR producerID
//   VAR aQueue
// 
//   EXPORTED:
//      INLINE METHOD init()
//         ::thread:init()
//         ::aQueue := {}
//      RETURN
// 
//      METHOD addEvent()
//      METHOD execute()
// ENDCLASS
// 
// METHOD S2KbdQueue:addEvent(xAct)
//    IF !VALTYPE(xAct)=="A"
//       xAct := {xAct}
//    ENDIF
// 
//    ::aQueue := xAct
//    //AEVAL(xAct, {|cAct| AADD(::aQueue, cAct) })
// 
// RETURN NIL
// 
// METHOD S2KbdQueue:Execute()
//   LOCAL nEvent, mp1:=0, mp2:=0, oXbp:=NIL
//   LOCAL nEventB, mp1B:=0, mp2B:=0, oXbpB:=NIL
//   LOCAL nLastMotionTime := 0
// 
// 
//   DO WHILE .T.
// 
//      /*
//       * Because our entire Event sniffer pools events, we have
//       * to go sleep after each iteration otherwise we would
//       * consume to much CPU resources for nothing!
//       */
//      Sleep( 10 )
// 
//      nEvent := dfNextAppEvent(@mp1,@mp2,@oXbp) //,::producerID)
// 
//      IF LEN(::aQueue) > 0 .AND. ;
//         nEvent == nEventB .AND. mp1 == mp1B .AND. mp2 == mp2B .AND. ;
//         oXbp == oXbpB
// 
//         PostKey(::aQueue[1])
// 
//         ADEL(::aQueue, 1)
//         ASIZE(::aQueue, LEN(::aQueue)-1)
//      ENDIF
// 
//      nEventB := nEvent
//      mp1B    := mp1
//      mp2B    := mp2
//      oXbpB   := oXbp
//   ENDDO
// RETURN self

STATIC aQueue := {} // funge da buffer di tastiera


// SD 3/3/03 per GERR 3674
// mette l'array nel ciclo eventi
FUNCTION dbAct2KbdSetQueue()
   AEVAL(aQueue, {|a| PostAppEvent(a[1], a[2], a[3], a[4])})
   ASIZE(aQueue, 0)
RETURN NIL

// SD 3/3/03 per GERR 3674
// Aggiunto parametro nPostMode
// che pu• essere: 
//   0= azzera buffer e mette i tasti nel buffer
//   1= aggiunge i tasti nel buffer senza azzerare il buffer
//   2= post immediato del tasto (come in vers. dBsee 1.80 e precedenti)

FUNCTION dbAct2Kbd( xAct, nPostMode, oXbp )
   STATIC nPost

   // IF S2FormCurr() != NIL .AND. S2FormCurr():isEnabled()
   //    PostAppEvent(xbeP_User+EVENT_KEYBOARD, xAct, NIL, S2FormCurr())
   // ENDIF

   // oKbd:addEvent(xAct)
   IF nPost == NIL
      nPost := dfSet("XbaseAct2KbdPostMode")
      IF EMPTY(nPost)
         nPost := 0               // default = 0
      ELSE
         nPost := VAL(nPost)
      ENDIF
   ENDIF

   DEFAULT nPostMode TO nPost

   IF nPostMode == 0
      // SD 3/3/03 per GERR 3674
      // Per default azzera il "buffer"

      ASIZE(aQueue, 0)
   ENDIF

   IF VALTYPE(xAct) == "A"
      AEVAL(xAct, {|cAct| PostKey(cAct, nPostMode, oXbp) })
   ELSE
      PostKey(xAct, nPostMode, oXbp)
   ENDIF

RETURN NIL

STATIC FUNCTION PostKey( cAct, nPostMode, oXbp )
   LOCAL nKsc, oDlg
   IF cAct == "tab"
      // SD 27/02/03 GERR 3672
      oDlg := S2FormCurr()
      IF VALTYPE(oDlg) == "O" .AND. oDlg:isDerivedFrom("S2Form") .AND. S2XbpIsValid(oDlg)
         //dfPostAppEventCB({|nEv, mp1, mp2, oXbp, oDlg| oDlg:skipFocus(1), XBASE_APPEVENT_IGNORE})

         nKsc:= dbAct2Ksc(cAct)
         IF nKsc > 0
            _PostAppEvent(nPostMode, xbeP_User+EVENT_KEYBOARD, nKsc, NIL, oXbp)
         ENDIF

      ELSE
         // Trattamento particolare per il TAB: lancio killInputFocus
         _PostAppEvent(nPostMode, xbeP_KillInputFocus, NIL, NIL, oXbp)
      ENDIF
   ELSE
      IF cAct == "smp"  // Trattamento particolare per apertura menu

         _PostAppEvent(nPostMode, xbeP_User+EVENT_OPENMENU, 1, NIL, oXbp)

      ELSE
         nKsc:= dbAct2Ksc(cAct)
         IF nKsc > 0
            _PostAppEvent(nPostMode, xbeP_User+EVENT_KEYBOARD, nKsc, NIL, oXbp)
         ENDIF
      ENDIF
   ENDIF
RETURN nKsc

STATIC FUNCTION _PostAppEvent(nPostMode, nEv, mp1, mp2, oXbp)

#ifdef _MULTITHREAD_
   IF !dfThreadIsMain()
      DEFAULT oXbp TO S2FormCurr()
   ENDIF
#endif
/* simone 14/6/05 implementazione per FORM mdi (multithread)
   IF dfSet("XbaseMDIEnabled") == "YES"
      DEFAULT oXbp TO FixSetAppFocus()
   ENDIF
   DEFAULT oXbp TO SetAppWindow()
*/

   IF nPostMode == 2
      PostAppEvent(nEv, mp1, mp2, oXbp)
   ELSE
      AADD(aQueue, {nEv, mp1, mp2, oXbp})
   ENDIF
RETURN NIL