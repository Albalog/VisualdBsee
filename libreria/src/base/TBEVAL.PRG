//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per BROWSE
//Programmatore  : Baccan Matteo
//*****************************************************************************

#include "dfWin.ch"

#ifdef __XPP__
   // simone 5/11/04 per correzione problema DBGOTO(0)
   // vedi DBGOTO_XPP
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE tbEval( oTbr, b2Eval ) //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
tbGenScan( oTbr, b2Eval, .F. )
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION tbScan( oTbr, b2Eval ) //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN tbGenScan( oTbr, b2Eval, .T. )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION tbGenScan( oTbr, b2Eval, lScan )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nSkipped := 1, nRec, lRet := .F., lEval

IF !EMPTY(oTbr:W_ALIAS)
   nRec := (oTbr:W_ALIAS)->(RECNO())

   EVAL( oTbr:GOTOPBLOCK )
   WHILE nSkipped # 0 .AND. !(oTbr:W_ALIAS)->(EOF())
      lEval := EVAL( b2Eval )
      IF (lScan .AND. lEval)
         lRet := .T.
         EXIT
      ENDIF
      nSkipped := EVAL( oTbr:SKIPBLOCK, 1 )
   ENDDO

   IF !lScan; (oTbr:W_ALIAS)->(DBGOTO( nRec )); ENDIF
ELSE // Skip su ARRAY
   nRec:=oTbr:W_CURRENTREC
   EVAL( oTbr:GOTOPBLOCK )
   IF oTbr:W_AI_LENGHT>0
      lEval := EVAL( b2Eval )
      IF !lScan .OR. (lScan .AND. !lEval)
         WHILE EVAL( oTbr:SKIPBLOCK, 1 )#0
            lEval := EVAL( b2Eval )
            IF (lScan .AND. lEval)
               lRet := .T.
               EXIT
            ENDIF
         ENDDO
      ELSE
         lRet := .T.
      ENDIF
   ENDIF
   IF !lScan; oTbr:W_CURRENTREC:=nRec; ENDIF
ENDIF
RETURN lRet
