#include "common.ch"
#include "error.ch"
#include "dfStd.ch"

// crea un oggetto error
FUNCTION dfErrorCreate(cDex, aArgs, cOp, nGenCode, nSeverity, cSub)
   LOCAL oError := Error():new()

   DEFAULT nGenCode  TO 9999
   DEFAULT nSeverity TO XPP_ES_FATAL
   DEFAULT cSub      TO "VDBSEE"
   DEFAULT aArgs     TO {}
   DEFAULT cOp       TO ""

   oError:description := cDex
   oError:args        := aArgs
//   oError:canSubstitute := .T.
   oError:genCode     := nGenCode
   oError:operation   := cOp
   oError:severity    := nSeverity
   oError:subSystem   := cSub
   oError:thread      := threadID()
   oError:osCode      := DOSERROR()
RETURN oError

PROCEDURE dfErrorThrow(cDex, aArgs, cOp, nGenCode, nSeverity, cSub)
   LOCAL oError
   oError := dfErrorCreate(cDex, aArgs, cOp, nGenCode, nSeverity, cSub)
   EVAL( ERRORBLOCK(), oError)
RETURN 

// come break() ma aggiunge descrizione e callstack al :cargo 
// vedi anche VDBErrorMessage()
FUNCTION dfErrBreak(e, cSep, lHandleDefault)
   LOCAL i
   LOCAL cRet

   DEFAULT cSep TO CRLF
   DEFAULT lHandleDefault TO .F.

   IF VALTYPE(e)=="O" .AND. e:isDerivedFrom("Error")
      cRet := ""
      i    := 2
      cRet += cSep+"CallStack:"

      IF IsMethod( e, "getCallstack" )
         cRet += e:getCallstack( cSep )
      ELSE
      DO WHILE !EMPTY( PROCNAME(i) )
         cRet += cSep+ "- "+TRIM(PROCNAME(i)) + "(" + ALLTRIM(STR(PROCLINE(i))) + ")"
         i++
      ENDDO
      ENDIF
      e:cargo := SUBSTR(cRet, LEN(cSep)+1)
   ENDIF

   IF lHandleDefault
      // posso gestirla di default senza dare errore?
      cRet := dfErrHandleDefault(e, @lHandleDefault)
      IF lHandleDefault
         RETURN (cRet)
      ENDIF
   ENDIF
   break(e)
RETURN NIL

// crea stringa del callstack per un thread
FUNCTION dfCallStackGet(i, nID, cEol, aCallStack)
   LOCAL cRet := ""
   LOCAL cLine

   DEFAULT nID  TO ThreadID()
   DEFAULT i    TO IIF(nID == ThreadID(), 2, 0)
   DEFAULT cEol TO CRLF

   while ( !Empty(ProcName(i, nID)) )
       cLine := Trim(ProcName(i, nID)) + "(" + ALLTRIM(STR(ProcLine(i, nID))) + ")" 
       cRet += cEol+cLine

       IF aCallStack != NIL // by reference torna come array
          AADD(aCallStack, {ProcName(i, nID), ProcLine(i, nID), cLine})
       ENDIF

       i++
   end
RETURN SUBSTR(cRet, LEN(cEol)+1)

