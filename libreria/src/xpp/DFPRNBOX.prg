// Inserisce un box
#include "dfWinRep.ch"
#include "common.ch"
#include "dfReport.ch"

// cType non e' supportato al momento
//
// nRow, nCol, nWidth,  nHeight: coordinate relative alla riga corrente
// lChar: se .T. le coord. sono in caratteri
//        se .F. sono in centesimi di centimetro: 100 = 1 CM
//

// Stampa la stringa
FUNCTION dfPrintBox(nRow, nCol, nWidth, nHeight, lChar, cType)
   LOCAL lOk := .F.
   LOCAL cStr := dfPrintBoxString(nRow, nCol, nWidth, nHeight, lChar, cType)

   IF ! EMPTY(cStr)
      _dfPrint(nRow, nCol, "", NIL, {cStr, ""})
      //dfPrint(0, 0, cStr)
      lOk := .T.
   ENDIF
RETURN lOk

// Costruisce la stringa
FUNCTION dfPrintBoxString(nRow, nCol, nWidth, nHeight, lChar, cType)
   LOCAL cStr

   // Se non Š una stampante windows disabilito la stampa
   IF ! CanPrint()
      RETURN ""
   ENDIF

   DEFAULT cType TO "0"
   DEFAULT lChar TO .T.

   IF ! EMPTY(cType) .AND. cType $ "012345"

      cStr := DFWINREP_BOX+cType
      IF lChar
         cStr += "CHAR"
      ENDIF

      cStr+="#"
      IF nCol != NIL
         cStr += ALLTRIM(STR(nCol))
      ENDIF

      cStr+="#"
      IF nRow != NIL
         cStr += ALLTRIM(STR(nRow))
      ENDIF

      cStr+="#"
      IF nWidth != NIL
         cStr += ALLTRIM(STR(nWidth))
      ENDIF

      cStr+="#"
      IF nHeight != NIL
         cStr += ALLTRIM(STR(nHeight))
      ENDIF

      cStr += ";"

   ENDIF
RETURN cStr

STATIC FUNCTION CanPrint()
   LOCAL lRet
   LOCAL aBuf := dfPrnArr()
   IF EMPTY( aBuf[REP_XBASEPRINTDISP  ] )
      lRet := aBuf[REP_PRINTERPORT]=="VIDEO" .OR. dfIsWinPrinter(aBuf)
   ELSE
      lRet := aBuf[REP_XBASEPRINTDISP  ]:canSupportBox()
   ENDIF
RETURN lRet
