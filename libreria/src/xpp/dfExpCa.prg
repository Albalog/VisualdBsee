// come dfExpCast ma se Š un codeblock ritorna
// il cast dell'evaluation
//
// Esempio considerando la variabile STATIC TIPART := "A"
//
// con la il dfExpCast() il codeblock {|| TIPART} tornerebbe "{||TIPART}" 
// e se si va valutare non si ha accesso alla variabile 
// e quindi non va bene
//
// con la dfExpCastEval() invece torna la stringa "'A'" e quando si
// va a valutare con macro Š ok

FUNCTION dfExpCastEval(xVal)
   IF VALTYPE(xVal)=="B"
      // ricorsione
      xVal := dfExpCastEval( EVAL(xVal) )
   ELSE
      xVal := dfExpCast(xVal)
   ENDIF
RETURN xVal


// Converte un valore qualsiasi in una stringa di cui si pu• fare il MACRO
// es:
// dfExpCast(1)-> "1"
// dfExpCast('ciao')-> "ciao"
// dfExpCast(date())-> "STOD('20070107')"
// dfExpCast({|| dfAlert('ciao')})-> "{|| dfAlert('ciao')}"

FUNCTION dfExpCast(xVal, cDefault)
   LOCAL cDel
   LOCAL cTip := VALTYPE(xVal)
   LOCAL cRet
   LOCAL nPos

   DO CASE
      CASE cTip == "U"
         cRet := "NIL"

      CASE cTip == "N"
         cRet := ALLTRIM(VAR2CHAR(xVal)) //ALLTRIM( STR(xVal, 25, 10) )

      CASE cTip $ "CM"
         cDel:='"'       // ritorna "xxx"
         IF cDel $ xVal
            cDel := "'"  // ritorna 'xxx'

            // simone 13/2/08 
            // correzione per stringhe che contengono sia " che '
            // es la frase
            //    cerca l'oro di "priamo"
            // le trasforma in 'cerca l'+chr(39)+'oro di "priamo"'
            // dato che il CHR(39) Š il carattere apostrofo (')
            IF "'" $ xVal 
               xVal := STRTRAN(xVal, "'", "'+chr(39)+'")
            ENDIF
         ENDIF
         cRet := cDel+xVal+cDel

      CASE cTip == "D"
         cRet := 'STOD("'+DTOS(xVal)+'")'

      CASE cTip == "L"
         cRet := IIF(xVal, ".T.", ".F." )

      CASE cTip == "A"
         cRet := "{"
         FOR nPos := 1 TO LEN( xVal )
            cRet += dfExpCast( xVal[nPos] )
            IF nPos<LEN( xVal )
               cRet += ","
            ENDIF
         NEXT
         cRet += "}"

      CASE cTip == "B"
         cRet := ALLTRIM(VAR2CHAR(xVal))

      CASE cTip == "O"
         cRet := ALLTRIM(VAR2CHAR(xVal))

      OTHERWISE
         cRet := cDefault
   ENDCASE
RETURN cRet
