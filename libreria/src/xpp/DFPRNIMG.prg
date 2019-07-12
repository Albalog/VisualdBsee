// Inserisce un'immagine
#include "dfWinRep.ch"
#include "dfReport.ch"
#include "common.ch"

// Stampa l'immagine
FUNCTION dfPrintImage(nRow, nCol, cFile, nWidth, nHeight, nImgRow, nImgCol, aBuf)
   LOCAL lOk := .F.
   LOCAL cStr, aSave

   // Se non Š una stampante windows disabilito la stampa
   IF ! CanPrint(aBuf)
      RETURN .T.
   ENDIF

   IF cFile != NIL .AND. ! EMPTY(cFile)
      cFile := dfAny2Str(cFile)
   ENDIF

   // Conversione da CM a centesimi di CM
   IF VALTYPE(nWidth ) == "N" .AND. ! EMPTY(nWidth ); nWidth  *= 100; ENDIF
   IF VALTYPE(nHeight) == "N" .AND. ! EMPTY(nHeight); nHeight *= 100; ENDIF
   IF VALTYPE(nImgRow) == "N" .AND. ! EMPTY(nImgRow); nImgRow *= 100; ENDIF
   IF VALTYPE(nImgCol) == "N" .AND. ! EMPTY(nImgCol); nImgCol *= 100; ENDIF

   cStr := dfPrintImageString(cFile, nImgRow, nImgCol, nWidth, nHeight, ;
                              NIL, NIL, nRow, nCol)

   IF ! EMPTY(cStr)
      //dfPrintAttr(nRow, nCol, "", NIL, {cStr, ""})
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
      lRet := aBuf[REP_XBASEPRINTDISP  ]:canSupportImg()
   ENDIF
RETURN lRet


// Costruisce la stringa per stampare l'immagine
FUNCTION dfPrintImageString(cFile, nImgRow, nImgCol, nWidth, nHeight, ;
                            nXRes, nYRes, nRow, nCol, aBuf)
   LOCAL cStr

   // Se non Š una stampante windows disabilito la stampa
   IF ! CanPrint(aBuf)
      RETURN ""
   ENDIF

   IF ! EMPTY(cFile) .AND. VALTYPE(cFile) == "C" .AND. FILE(cFile)

      cStr := DFWINREP_IMAGE+cFile

      cStr+="#"
      IF nImgCol != NIL; cStr += ALLTRIM(STR(nImgCol)); ENDIF

      cStr+="#"
      IF nImgRow != NIL; cStr += ALLTRIM(STR(nImgRow)); ENDIF

      cStr+="#"
      IF nWidth  != NIL; cStr += ALLTRIM(STR(nWidth )); ENDIF

      cStr+="#"
      IF nHeight != NIL; cStr += ALLTRIM(STR(nHeight)); ENDIF

      cStr+="#"
      IF nXRes   != NIL; cStr += ALLTRIM(STR(nXRes  )); ENDIF

      cStr+="#"
      IF nYRes   != NIL; cStr += ALLTRIM(STR(nYRes  )); ENDIF

      cStr+="#"
      IF nCol    != NIL; cStr += ALLTRIM(STR(nCol   )); ENDIF

      cStr+="#"
      IF nRow    != NIL; cStr += ALLTRIM(STR(nRow   )); ENDIF

      cStr += ";"

   ENDIF
RETURN cStr
