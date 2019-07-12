//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per FILE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"
#INCLUDE "dfFile.ch"
#INCLUDE "fileio.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfFLocate( cStr, lContinue )       // Trova una stringa
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lFound := .F.
LOCAL nPos
LOCAL nActual := dfFActual()

DEFAULT lContinue TO .F.

IF lContinue
   dfFSkip()
ELSE
   dfFTop()                      // Go TOP
ENDIF

cStr := ALLtRIM(UPPER(cStr))     // Normalizzo la stringa

DO WHILE !dfFEof()
   IF AT( cStr, UPPER(dfFRead()) ) # 0  // Found
      lFound := .T.
      EXIT
   ENDIF
   IF AT( cStr, UPPER(nActual[FL_BUFFER]) ) == 0
      nPos := RAT( nActual[FL_SEPCHAR], nActual[FL_BUFFER] )
      nActual[FL_LINE]   := ""
      nActual[FL_BUFFER] := SUBSTR( nActual[FL_BUFFER], nPos+nActual[FL_SEPLEN] )
   ENDIF
   dfFSkip()
ENDDO

RETURN lFound
