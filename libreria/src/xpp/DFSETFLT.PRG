#include "dfMsg.ch"
#include "common.ch"

// Simone 1/3/2005 
// funzioni dfSetFilter() e dfClearFilter()
// analoghe a DBSETFILTER() e DBCLEARFILTER()
// ma con in più progress bar e possibilità di fare GOTOP
// viene usato un metodo di FIX (vedi dfFilterFixSet())
// 
// Comunque è implementata questa logica:
// - sul clear Filter non esegue FIX
//
// - quando NON si deve fare il GOTOP
//   viene usato sempre il METODO 1 (ordine naturale) dato 
//   che non influisce in niente
// - quando si deve fare il GOTOP viene usato il FIX metodo definito
//   da dfFilterFixMtd() (cioè letto da apps.ini), ma per default
//   non abilita il FIX 

// Imposta/toglie filtro su una tabella
// con finestra attesa e gotop
FUNCTION dfClearFilter(lGoTop)
RETURN dfSetFilter("", "", 0, lGoTop)

FUNCTION dfSetFilter(bFlt, cFlt, nProgress, lGoTop)
   LOCAL oThread
   LOCAL cAlias := ALIAS()
   LOCAL xPar
   LOCAL oErr
   LOCAL err
   LOCAL nRec 
   LOCAL lRet := .T.

   DEFAULT cFlt      TO ""
   DEFAULT bFlt      TO IIF(EMPTY(cFlt), NIL, DFCOMPILE(cFlt))
   DEFAULT nProgress TO 0
   DEFAULT lGoTop    TO .T.

   nRec := (cAlias)->(RECNO())

   IF EMPTY(cFlt) .OR. UPPER(ALLTRIM(cFlt)) == ".T."
      // se non ho filtro disabilito la progress bar
      nProgress := 0

      (cAlias)->(DBCLEARFILTER())

      IF lGoTop
         (cAlias)->(DBGOTOP())
      ENDIF

   ELSE
      IF nProgress == 1
         // Thread separato per progress bar durante il filtro
         _dfMakeIndInit()
         _dfMakeIndCreate("",10, .5)
         oThread:= Thread():new()
         oThread:setInterval(50)
         oThread:start("_dfMakeIndPB")
      ELSEIF nProgress == 2
         dbMsgOn( dfStdMsg(MSG_DDKEY12), .5 )
      ENDIF

      // Simone 24/02/2005
      // imposta ordine naturale prima di impostare il filtro 
      // per evitare problemi blocchi su citrix
      //
      // Se devo andare TOP, uso FIX con metodo default
      // altrimenti uso metodo SET ORDER TO 0
      xPar := (cAlias)->(dfFilterFixSet( IIF(lGoTop, NIL, 1) ))


      oErr := ErrorBlock( {|e| break(e)} )
      BEGIN SEQUENCE
         (cAlias)->(DBSETFILTER(bFlt, cFlt))
         IF lGoTop
            (cAlias)->(DBGOTOP())
         ENDIF
      RECOVER USING err
         err := err  // serve solo per vedere qual Š l'errore in fase di debug
         lRet := .F.
      END SEQUENCE
      ErrorBlock(oErr)
   ENDIF

   IF xPar != NIL
      (cAlias)->(dfFilterFixDel( xPar ))
   ENDIF

   IF ! lRet 
      (cAlias)->(DBGOTO_XPP(nRec))
   ENDIF

   IF nProgress == 1
      oThread:setInterval(NIL)
      DO WHILE oThread:active
         sleep(10)
      ENDDO
      _dfMakeIndDestroy()
      oThread := NIL
   ELSEIF nProgress == 2
      dbMsgOff()
   ENDIF
RETURN lRet


