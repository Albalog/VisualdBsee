#include "dfStd.ch"

// esegue un macro eventualmente su un oggetto
FUNCTION dfMacro(oErr, cMacro, oObj, aPar)
   LOCAL bErr
   LOCAL xRet
   LOCAL err

   oErr := NIL
   bErr := ERRORBLOCK({|e| dfErrBreak(e, CRLF, .T., .T.)})
   BEGIN SEQUENCE
       IF aPar != NIL
          IF EMPTY(oObj)
             xRet := &(cMacro)(aPar)
          ELSE
             xRet := &(oObj:cMacro)(aPar)
          ENDIF
       ELSE
          IF EMPTY(oObj)
             xRet := &(cMacro)
          ELSE
             xRet := &(oObj:cMacro)
          ENDIF
       ENDIF
   RECOVER USING err
      oErr := err
   END SEQUENCE
   ERRORBLOCK(bErr)
RETURN xRet 

//STATIC FUNCTION BuildErrMsg(oErr)
//   LOCAL cRet := ""
//   LOCAL i
//
//   cRet := S2ErrMsgStd(oErr, .T., CRLF)
//   i := 2
//   cRet+=CRLF+"CallStack:"
//   while ( !Empty(ProcName(i)) )
//           cRet += CRLF + "- "+Trim(ProcName(i)) + ;
//                          "(" + ALLTRIM(STR(ProcLine(i))) + ")"
//           i++
//   end
//   oErr:cargo := cRet
//RETURN NIL
