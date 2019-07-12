//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Utility per le configurazioni
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"
#INCLUDE "dfSet.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfRight( cStr, nType, nSubType ) // Torna la destra di un'egualianza
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos := AT( "=", cStr )+1, uRet := "", nTok, aDmm, uSub

IF nPos > 0
   uRet := ALLTRIM(SUBSTR( cStr, nPos ))
ENDIF

DO CASE
   CASE nType == NIL .OR. nType == RT_CHARACTER

   CASE nType == RT_ARRAY
        nTok := dfNumToken( uRet, ",")
        aDmm := {}
        IF nTok>0
           FOR nPos := 1 TO nTok
              uSub := dfToken( uRet, ",", nPos)
              IF nSubType == NIL .OR. nSubType == RT_CHARACTER
                 AADD( aDmm, ALLTRIM( uSub ) )
              ELSE
                 AADD( aDmm, dfRight( "=" +uSub, nSubType ) )
              ENDIF
           NEXT
        ENDIF
        uRet := aDmm

   CASE nType == RT_LOGICAL
        uRet :=  !( EMPTY(uRet) .OR. UPPER(uRet) == "NO" )

   CASE nType == RT_NUMBER
        uRet := VAL( uRet )

ENDCASE

RETURN uRet
