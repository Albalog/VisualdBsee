#include "Common.ch"
#include "Xbp.ch"
#include "Gra.ch"
#include "Appevent.ch"
#include "dfXBase.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dbInk(  )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

   LOCAL nKey
   DO WHILE .T.
      nKey := dfInkey( 0 )

      DbActSet(nKey) // Imposto ACT, A, SA

      IF M->ACT=="A01"                .AND. ;
         ! TYPE("dfHotFun") == "U"    .AND. ;  // Se Š definita la variabile dfHotFun
         dfFun2Do(M->dfHotFun)                 // la eseguo
         LOOP
      ENDIF

      IF ! TYPE("BackFun") == "U"          // Se Š definita la variabile BackFun
         dfFun2Do(M->BackFun)              // la eseguo
      ENDIF

      IF M->ACT=="A04"
         S2QuitApplication()
      ENDIF

      EXIT
   ENDDO

   #ifdef _EVAL_
      // Controllo scadenza DEMO, il nome funzione 
      // non fa pensare al controllo demo
      // inoltre controllo che il valore di ritorno e il parametro
      // per referenza siano messi per bene cosi sono sicuro che la
      // funzione _dfStringExe() non sia stata modificata dall'utente

      IF (_dfStringExe(, , @nKey) + 5 < SECONDS()) .OR. ;
         (! nKey == CHR(107)+CHR(53)+LEFT("ert", 1)+"0"+"j"+UPPER(CHR(106))+CHR(106))
         S2RealTimeDelAll()
         CLOSE ALL
         QUIT
      ENDIF
   #endif


RETURN M->ACT

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfInkey(n)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL nEvent, mp1, mp2, oXbp
   LOCAL nEvent2, mp12, mp22, oXbp2
   LOCAL nKey := 0
   LOCAL nEnd, nChk

   IF n != NIL
      nEnd := SECONDS() + n
   ENDIF

   DO WHILE .T.
      // Simone 06/10/08
      // mantis 0001977: velocizzare le stampe 
      nEvent := dfAppEvent( @mp1, @mp2, @oXbp, 1)

      #ifdef _S2DEBUG_
         S2DebugOut(oXbp, nEvent, mp1, mp2)
      #endif

      IF (nEvent == xbeP_None .OR. oXbp == NIL)

      ELSEIF (nEvent == xbeP_User+EVENT_KEYBOARD) .OR. ;
         (nEvent == xbeP_Keyboard)

         IF nEvent == xbeP_Keyboard

	    // Simone 23/04/2004 GERR 3833
            // Toglie dalla coda dei messaggi i messaggi keyboard doppi
            dfIgnoreKbdEvent(mp1, mp2)
          /*
            // Toglie dalla coda dei messaggi i messaggi doppi
            DO WHILE .T.
               nEvent2 := dfNextAppEvent(@mp12, @mp22, @oXbp2)

               IF nEvent2 == nEvent .AND. mp12 == mp1 .AND. mp22 == mp2

                  AppEvent(@mp12, @mp22, @oXbp2)
               ELSE

                  EXIT
               ENDIF

            ENDDO
           */
         ELSE

            oXbp   := SetAppFocus()
            IF EMPTY(oXbp)
               oXbp := S2FormCurr()
            ENDIF

            nEvent := xbeP_Keyboard

         ENDIF

         nKey := mp1

         EXIT

      ELSEIF (nEvent == xbeM_LbDown) .OR. ;
             (nEvent == xbeM_MbDown) .OR. ;
             (nEvent == xbeM_RbDown)

         nKey := EVENT_MOUSE_DOWN
         EXIT
      ENDIF

      IF ! nEvent == xbeP_None .AND. oXbp != NIL
         oXbp:HandleEvent(nEvent, mp1, mp2)
      ENDIF

      IF n == NIL
         EXIT
      ENDIF

      IF n <> 0 .AND. SECONDS() > nEnd
         EXIT
      ENDIF
   ENDDO

RETURN nKey

