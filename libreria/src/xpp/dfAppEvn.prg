#include "AppEvent.ch"
#include "dfXbase.ch"
#include "Common.ch"
#include "dfSet.ch"

// simone 15/2/08
// gestisco una coda di eventi di CODEBLOCK
// perchŠ con la PostAppEvent() potrebbe non essere sempre eseguito
// ad esempio se faccio  PostAppEvent(xbeP_User+EVENT_CODEBLOCK , bCB, par1, par2)
// e l'evento Š letto da un ciclo standard tipo:
//   DO WHILE nLoop == 0
//      nEvent := AppEvent( @mp1, @mp2, @oXbp )
//      oXbp:handleEvent( nEvent, mp1, mp2 )
//   ENDDO
// allora l'evento viene perso perchŠ non Š gestito.
// gestendo invece una coda separata, l'evento rimane in coda finchŠ
// non viene letto dalla dfAppEvent() (e prima o poi capiter…)

STATIC aCBQueue := {}

STATIC bCBLog

STATIC nStartSec

// imposta un Codeblock chiamato per log eventi
// se bLog = .F. disattiva log
FUNCTION dfAppEventLog(bLog)
   LOCAL bRet := bCBLog 

   IF VALTYPE(bLog)=="B"
      bCBLog := bLog

   ELSEIF VALTYPE(bLog)=="L"
      bCBLog := NIL 
   ENDIF
RETURN bRet

  

// SD 27/02/03 GERR 3339

// Simile alla AppEvent, con gestione eventi speciali
// (dfChkEvent())
FUNCTION dfAppEvent(mp1, mp2, oXbp, nTimeOut, oDlg)
   LOCAL nEvent 
   LOCAL nEndSec := -1
   LOCAL nChk
   LOCAL nStart

   DEFAULT nTimeOut TO 0
   DEFAULT oDlg     TO S2FormCurr()

   IF nTimeOut > 0
      IF nStartSec == NIL
         nStartSec := 0//SECONDS()
      ENDIF 
      // Simone 06/10/08
      // mantis 0001977: velocizzare le stampe 
      // la moltipl. per 100 era sbagliata deve dividere!!!
      //nEndSec := SECONDS() + (nTimeOut*100)
      //Il timeout è in centesimi di secondi 1 sec. -> 100 cent.sec
      IF nStartSec > 0
         nTimeOut -=  nStartSec *100
         nTimeOut := INT(nTimeOut)
         IF nTimeOut <= 0
            nTimeOut := 1
         ENDIF 
      ENDIF
      nStart  := SECONDS()
      nEndSec := nStart + (nTimeOut/100)
   ENDIF

   // Scarico gli eventi di tastiera in coda
   dbAct2KbdSetQueue()

   DO WHILE .T.
#ifdef __XPP_PROFILE__
      // con il profiler tengo in una funzione separata la gestione eventi
      // nel profiler posso considerare la __APPEVENT come neutra perchŠ
      // sta solo in attesa di eventi
      nEvent := __AppEvent(@mp1, @mp2, @oXbp, nTimeOut)
#else
      nEvent := AppEvent(@mp1, @mp2, @oXbp, nTimeOut)
#endif

      // simone 13/11/09
      // mantis 0002109: abilitare step recorder tipo Windows 7 
      IF nEvent != NIL .AND. nEvent != xbeP_None .AND. ! EMPTY(oXbp) 
         dfStepRecorderLog(nEvent, mp1, mp2, oXbp)
      ENDIF

      IF bCBLog != NIL
         // log evento
         EVAL(bCBLog, 0, NIL, @nEvent, @mp1, @mp2, @oXbp, oDlg)
      ENDIF

      nChk   := dfChkEvent(@nEvent, @mp1, @mp2, @oXbp, @oDlg)

      IF bCBLog != NIL
         // log evento
         EVAL(bCBLog, 1, NIL, @nEvent, @mp1, @mp2, @oXbp, oDlg, nChk)
      ENDIF

      IF nEndSec > 0 .AND. nEvent == xbeP_None
         EXIT  // TimeOut da AppEvent()
      ENDIF
      
      IF nEndSec > SECONDS() 
         EXIT  // TimeOut 
      ENDIF


      DO CASE
         CASE nChk == XBASE_APPEVENT_NONE
            EXIT

         CASE nChk == XBASE_APPEVENT_IGNORE

         CASE nChk == XBASE_APPEVENT_EXIT_OK
            dbAct2Kbd("wri")

         CASE nChk == XBASE_APPEVENT_EXIT_ABORT
            dbAct2Kbd("esc")
      ENDCASE
   ENDDO

   IF nTimeOut > 0
      IF !nEvent == xbeM_Motion  
         nStartSec := 0
      ELSE 
         nStartSec := SECONDS() -nStart
      ENDIF 
   ENDIF 

RETURN nEvent

STATIC FUNCTION dfChkEvent(nEvent, mp1, mp2, oXbp, oDlg)
   LOCAL nChk
   LOCAL bEval 
   LOCAL _nEvent, _mp1, _mp2, _oXbp
   LOCAL lExec := .F.

   IF LEN(aCBQueue) > 0
      // simone 15/2/08
      // gestisco una coda di eventi di CODEBLOCK

      bEval := aCBQueue[1][1]
      // non uso variabili mp1, mp2, ecc per non incasinare
      // visto che sono ritornate by reference
      _nEvent := xbeP_User+EVENT_CODEBLOCK
      _mp1    := bEval
      _mp2    := aCBQueue[1][2]
      _oXbp   := aCBQueue[1][3]
      AREMOVE(aCBQueue, 1)

      IF bCBLog != NIL
         // log evento
         EVAL(bCBLog, 10, bEval, @_nEvent, @_mp1, @_mp2, @_oXbp, oDlg)
      ENDIF

      nChk := EVAL(bEval, @_nEvent, @_mp1, @_mp2, @_oXbp, oDlg)

      IF bCBLog != NIL
         // log evento
         EVAL(bCBLog, 11, bEval, @_nEvent, @_mp1, @_mp2, @_oXbp, oDlg, nChk)
      ENDIF
      lExec := .T.

   ELSEIF nEvent == xbeP_User+EVENT_CODEBLOCK .AND. VALTYPE(mp1) =="B"
      bEval:= mp1

      IF bCBLog != NIL
         // log evento
         EVAL(bCBLog, 20, bEval, @nEvent, @mp1, @mp2, @oXbp, oDlg)
      ENDIF

      nChk := EVAL(bEval, @nEvent, @mp1, @mp2, @oXbp, oDlg)
      IF bCBLog != NIL
         // log evento
         EVAL(bCBLog, 21, bEval, @nEvent, @mp1, @mp2, @oXbp, oDlg, nChk)
      ENDIF
      lExec := .T.
   ENDIF

   IF ! lExec
      bEval := dfEventCB() 

      IF VALTYPE(bEval)=="B" 
         IF bCBLog != NIL
            // log evento
            EVAL(bCBLog, 30, bEval, @nEvent, @mp1, @mp2, @oXbp, oDlg)
         ENDIF

         nChk := EVAL(bEval, @nEvent, @mp1, @mp2, @oXbp, oDlg)

         IF bCBLog != NIL
            // log evento
            EVAL(bCBLog, 31, bEval, @nEvent, @mp1, @mp2, @oXbp, oDlg, nChk)
         ENDIF
      ENDIF
   ENDIF

   IF VALTYPE(nChk) != "N"
      nChk := XBASE_APPEVENT_NONE
   ENDIF
RETURN nChk

FUNCTION dfPostAppEventCB(bCB, par1, par2)
   IF ! VALTYPE(bCB)=="B"
      RETURN .F.
   ENDIF

   // simone 15/02/08
   // aggiungo l'evento a un array aCBQueue e
   // invio un evento "nullo" per interrompere immediatamente
   // il ciclo degli eventi.
   // in caso questo evento venga perso, l'evento rimane comunque in aCBQueue
   // e verrà quindi eseguito.
   // Prima invece l'evento si perdeva e basta.
   AADD(aCBQueue, {bCB, par1, par2})
RETURN PostAppEvent(xbeP_User+EVENT_CODEBLOCK, {|| XBASE_APPEVENT_NONE})
// RETURN PostAppEvent(xbeP_User+EVENT_CODEBLOCK , bCB, par1, par2)

#ifdef __XPP_PROFILE__
STATIC FUNCTION __AppEvent(mp1, mp2, oXbp, nTimeOut)
RETURN AppEvent(@mp1, @mp2, @oXbp, nTimeOut)
#endif