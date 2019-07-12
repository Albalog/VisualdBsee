/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/

#include "Common.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfNameUnique( cPath, cExt )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cRet, nPos := 0, nHandle, nFill := 8
LOCAL nCheck := 2000
LOCAL lOK := .F.

DEFAULT cPath TO dfTemp()
DEFAULT cExt  TO ""

IF LEN(cPath)>0
   nFill := 8-(LEN(cPath)-RAT("\",cPath))
ENDIF
// Simone 24/10/07
// mantis 0001621: la funzione dfNameUnique pu• andare in loop se non ci sono diritti di scrittura sulla cartella
WHILE nCheck-- > 0 // al massimo 2000 volte
   WHILE FILE( cRet:=(cPath +PADL(++nPos,nFill,"0") +cExt) ); END
   IF (nHandle:=FCREATE(cRet))>0
      FCLOSE(nHandle)
      lOK := .T.
      EXIT
   ENDIF
ENDDO

RETURN cRet //torno comunque un nome di file IIF(lOK, cRet, NIL)
