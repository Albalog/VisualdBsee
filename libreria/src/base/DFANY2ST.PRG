//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per Stringhe
//Programmatore  : Baccan Matteo
//*****************************************************************************
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfAny2Str( uPar, cPic )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cRet := uPar
LOCAL cTip := VALTYPE( uPar )
LOCAL nPos

DO CASE
   CASE cTip == "U"; cRet := ""
   CASE VALTYPE( cPic ) == "C" .AND. !EMPTY(cPic)
        cRet := TRANSFORM( uPar, cPic )
   CASE cTip $ "CM"
   CASE cTip == "N"; cRet := STR( uPar )
   CASE cTip == "D"; cRet := DTOC( uPar )
   CASE cTip == "L"; cRet := IF( uPar, ".T.", ".F." )
   CASE cTip == "A"
        cRet := "{"
        FOR nPos := 1 TO LEN( uPar )
           IF VALTYPE(uPar[nPos])$"CM"
              cRet += ["]
           ENDIF
           cRet += dfAny2Str( uPar[nPos], cPic )
           IF VALTYPE(uPar[nPos])$"CM"
              cRet += ["]
           ENDIF
           IF nPos<LEN( uPar )
              cRet += ","
           ENDIF
        NEXT
        cRet += "}"
   CASE cTip == "B"; cRet := dfAny2Str(EVAL( uPar ),cPic)
   CASE cTip == "O"
        #ifdef __XPP__
        cRet := "(" +uPar:CLASSNAME() +")"
        #else
        cRet := "!Object!"
        #endif
ENDCASE

RETURN cRet
