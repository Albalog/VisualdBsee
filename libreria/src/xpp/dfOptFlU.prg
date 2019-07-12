#include "common.ch"

// Funzioni di utilit… per ottimizzazione filtro 
//
// Ottimizzazione per funzione ASCAN()
// es.1 se il codeblock di filtro era
//   bFlt := {|| ASCAN(aTipDoc, DOCMOVT->TIPDOC) != 0}
//
// deve diventare
//   cTipDoc := dfOptFltScan(aTipDoc, LEN(DOCMOVT->TIPDOC))
//   bFlt := {|| AT("-"+DOCMOVT->TIPDOC+"-", cTipDoc) != 0 } che Š ottimizzabile
//
// Nota: cTipDoc contiene -> "-ORDC--FVE1--FVE2--FVEN--BOLV-"
//
// es.2 se il codeblock di filtro era
//   bFlt := {|| ASCAN(aTipDoc, {|x|x[2]==DOCMOVT->TIPDOC}) != 0}
//
// deve diventare
//   cTipDoc := dfOptFltScan(aTipDoc, LEN(DOCMOVT->TIPDOC), {|x|x[2]})
//   bFlt := {|| AT("-"+DOCMOVT->TIPDOC+"-", cTipDoc) != 0 } che Š ottimizzabile


FUNCTION dfOptFltScan(aArr, nLen, bBlk, aDelim)
   LOCAL cRet := ""
   LOCAL nInd := 0
   LOCAL xVal 

   IF EMPTY(aArr)
      RETURN cRet
   ENDIF

   DEFAULT aDelim TO {"-"}

   IF VALTYPE(bBlk) != "B"
      bBlk := NIL
   ENDIF
   
   IF VALTYPE(aDelim) $ "CM" 
      aDelim := {aDelim, aDelim}
   ENDIF

   IF LEN(aDelim) < 1
      aDelim := {"-"}
   ENDIF

   IF LEN(aDelim) < 2
      ASIZE(aDelim, 2)
      aDelim[2] := aDelim[1]
   ENDIF

   IF nLen != NIL 
      // Se nLen viene passato MI ASSICURO che sia un numero
      // altimenti do un RUNTIME ERROR!!!!!
      xVal := nLen > 0
      xVal := NIL
   ENDIF

//   IF nLen != NIL .AND. VALTYPE(nLen) != "N"
//      nLen := NIL
//   ENDIF

   FOR nInd := 1 TO LEN(aArr)
      IF bBlk == NIL
         xVal := aArr[nInd]
      ELSE 
         xVal := EVAL(bBlk, aArr[nInd])
      ENDIF

      // Simone 16/05/08
      // correzione per errore runtime quando 
      // lunghezza elemento cercato <> lunghezza stringa
      IF nLen != NIL .AND. LEN(xVal) != nLen .AND. bBlk == NIL
         // se non ho un codeblock allora posso troncare la stringa
         // perche la ASCAN() senza codeblock confronta solo i primi caratteri
         IF LEN(xVal) > nLen 
            xVal := PAD(xVal, nLen) // tronco la stringa a "nLen" caratteri
         ELSE
            xVal := NIL     // in questo caso non Š mai possibile trovarlo!
         ENDIF
      ENDIF
      IF xVal != NIL
         xVal := aDelim[1] + xVal + aDelim[2]
         cRet += xVal
      ENDIF
   NEXT
RETURN cRet