// Inserisce un codeblock qualsiasi durante la stampa
#include "dfWinRep.ch"
#include "dfReport.ch"
#include "common.ch"

// Include il codeblock nel report
FUNCTION dfPrintCBlock(nRow, nCol, bCB, aBuf)
   LOCAL lOk := .F.
   LOCAL cStr, aSave

   // Se non Š una stampante windows disabilito la stampa
   IF ! CanPrint(aBuf)
      RETURN .T.
   ENDIF

   cStr := dfPrintCBlockString(bCB)

   IF ! EMPTY(cStr)
      _dfPrint(nRow, nCol, "", NIL, {cStr, ""})
      lOk := .T.
   ENDIF
RETURN lOk

STATIC FUNCTION CanPrint(aBuf)
   LOCAL lRet
   DEFAULT aBuf TO dfPrnArr()
   IF EMPTY( aBuf[REP_XBASEPRINTDISP  ] )
      lRet := aBuf[REP_PRINTERPORT]=="VIDEO" .OR. dfIsWinPrinter(aBuf)
   ELSE
      lRet := .T. //aBuf[REP_XBASEPRINTDISP  ]:canSupportImg()
   ENDIF
RETURN lRet


// Costruisce la stringa
FUNCTION dfPrintCBlockString(bCB)
   LOCAL cStr

   IF VALTYPE(bCB) == "B"
      cStr := VAR2BIN(bCB)
   ELSEIF  VALTYPE(bCB) == "C"
      cStr := bCB
   ELSE
      RETURN ""
   ENDIF
   cStr := DFWINREP_CODEBLOCK+ALLTRIM(STR(LEN(cStr)))+";"+cStr
RETURN cStr
