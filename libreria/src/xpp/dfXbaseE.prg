// Exit procedure per Ambiente XBase
// -------------------------------------------

// Esegue tutti i codeblock (es. per cancellare files temporanei)
// Esempio d'uso:
//
// - all'uscita del programma cancello il file pippo.tmp
//   dfXbaseExitProcAdd( dfExecuteActionDelFile():new("C:\pippo.tmp") )
//
// - all'uscita del programma do un msg
//   dfXbaseExitProcAdd( dfExecuteAction():new({||MsgBox("ciao")}) )
//
// - all'uscita del programma do un msg (preso da parametro)
//   dfXbaseExitProcAdd( dfExecuteAction():new({|x|MsgBox(x)}), "messaggio" )


STATIC aExitProc := {}

EXIT PROCEDURE _XbaseExit
   dfXbaseExit()
RETURN

PROCEDURE dfXBaseExit()
   AEVAL(aExitProc, {|o| o:execute() } )
RETURN

FUNCTION dfXbaseExitProcAdd(b)
   LOCAL nID := -1
   IF VALTYPE(b) == "O" .AND. b:isDerivedFrom("dfExecuteAction")
      AADD(aExitProc, b)
      nID := LEN(aExitProc)
   ENDIF
RETURN nID

CLASS dfExecuteAction
PROTECTED
   VAR bExe, xPar

EXPORTED
   INLINE METHOD init(bExe, xPar)
      ::bExe := bExe
      ::xPar := xPar
   RETURN self

   INLINE METHOD execute
      IF VALTYPE(::bExe) == "B"
         ::eval(::bExe, ::xPar)
      ENDIF
   RETURN self
ENDCLASS

CLASS dfExecuteActionDelFile FROM dfExecuteAction
EXPORTED
   INLINE METHOD init(cFile)
      ::xPar := cFile
      ::bExe := {|x| FERASE(x) }
   RETURN self
ENDCLASS
