// imposta una variabile di un file .rep di reportmanager
// es.             
// cTmpRep := dfFileRead("c:\pippo.rep")
// dfRepManSetVar(cTmpRep, "TRpReport.PreviewWindow", "spwMaximized")
// dfRepManSetVar(cTmpRep, { {"TRpReport.PreviewWindow", "spwMaximized"}, ;
//                               {"TRpReport.PrinterSelect", "pRpUserPrinter2"} )
//
// supporta solo variabili TRpReport.xxxxx

#include "dfStd.ch"

FUNCTION dfRepManSetVar(cRep, xVar, cVal)
   LOCAL aPath 
   LOCAL nIndent := 2
   LOCAL n
   LOCAL aLines := {}
   LOCAL cPrev
   LOCAL lAdd   := .T.
   LOCAL cVar
   LOCAL nVar

   IF EMPTY(cRep) .OR. EMPTY(xVar)
      RETURN .F.
   ENDIF

   aLines := dfStr2Arr(cRep, CRLF)
   IF VALTYPE(xVar) $ "CM" 
      xVar := { {xVar, cVal} }
   ENDIF

   FOR nVar := 1 TO LEN(xVar)
      cVar := xVar[nVar][1]
      cVal := xVar[nVar][2]

      aPath  := dfStr2Arr(ALLTRIM(cVar), ".")

      IF LEN(aPath) >= 2              .AND. ;
         UPPER(aPath[1])=="TRPREPORT" 

         lAdd := .T.
         FOR n := 1 TO LEN(aLines)
            IF UPPER(dfLeft(aLines[n])) == UPPER(aPath[2])
               cPrev := dfRight(aLines[n])
               IF VALTYPE(cVal) $ "CM"
                  aLines[n] := dfLeft(aLines[n])+ " = " + cVal
               ENDIF

               // by reference ritorna il val vecchio
               cVal := cPrev

               lAdd := .F.
               EXIT
            ENDIF
         NEXT

         IF lAdd
            IF VALTYPE(cVal) $ "CM"
               AADD(aLines, aPath[2]+" = "+cVal, 2)
            ENDIF

            // by reference ritorna il val vecchio
            cVal := NIL
         ENDIF
      ENDIF

      // by reference ritorna il val vecchio 
      xVar[nVar][2] := cVal
   NEXT
   cRep := dfArr2Str(aLines, CRLF)
RETURN cRep

