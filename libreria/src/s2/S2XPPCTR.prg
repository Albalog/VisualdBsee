// Esegue un codeblock sugli oggetti Xbase
// Esempio: 
//   S2XppCtrlEval(oWin,"exp0010-exp0020", {|o,obj| obj:setColorBG(4) })

FUNCTION S2XppCtrlEval(oWin, cCtrls, bBlk)
   LOCAL aCtrls := dfStr2Arr(cCtrls,"-")
   LOCAL aCtrl
   LOCAL oObj
   LOCAL nInd


   FOR nInd := 1 TO LEN(aCtrls)
      IF ! EMPTY(aCtrls[nInd])
         aCtrl := oWin:searchObj(aCtrls[nInd])

         oObj := aCtrl[1]

         IF ! EMPTY(oObj) 

            IF ! EVAL(bBlk, oWin, aCtrl[1], aCtrl[2], aCtrls[nInd])
               EXIT
            ENDIF

         ENDIF
      ENDIF
   NEXT
RETURN NIL

