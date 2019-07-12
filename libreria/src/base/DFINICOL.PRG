//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per COLORI
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "common.ch"
#INCLUDE "dfSet.ch"
#INCLUDE "dfMsg.ch"

//
// Ho tolto la messaggistica perche' e' inconsistente
// prima del set dei colori
//

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfIniCol() // Ritorna l'array colori dell' Applicazione
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aColor := {}
dfScanIni( "color", {|lMod|dfLoadCol(aColor,lMod)} )
RETURN aColor

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfLoadCol( aColor, lMod )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cStr, cToken, nPos

DEFAULT lMod TO .F.

WHILE !dfFEof()       // Trovata
   cStr := UPPER(ALLTRIM(dfFRead()))
   DO CASE
      CASE !lMod .AND. LEFT(cStr,1) == "["         // altra sezione
           EXIT

      CASE LEFT(cStr,2) == "ID"        // Id

      CASE LEFT(cStr,4) == "INFO"      // Info

      OTHERWISE
           cToken := dfLeft(cStr)
           nPos   := 0
           IF lMod
              nPos := ASCAN( aColor, {|aSub|aSub[1]==cToken} )
           ENDIF
           IF nPos == 0
              AADD( aColor, NIL ); nPos := LEN(aColor)
           ENDIF
           IF cStr = "PALETTE"            // Palette
              aColor[nPos] := { cToken, dfRight( cStr, RT_ARRAY ,RT_NUMBER ) }
           ELSE
              aColor[nPos] := { cToken, dfRight( cStr, RT_ARRAY ) }
           ENDIF

   ENDCASE
   dfFSkip()
END

RETURN
