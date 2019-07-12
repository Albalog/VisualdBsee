//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per Stringhe
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"

// simone 09/01/07 by reference ritorna se errore
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dbMMrg( cTxt, lNoSpace, lErr ) // Esegue MailMerge
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cRet, nStart, nStop, cTxtFun
LOCAL lErr1

lErr := .F.

DEFAULT lNoSpace TO .F.

IF cTXT != NIL

   DO WHILE .T.
      nStart := AT("<<",cTxt)        // posizione primo minore
      nStop  := AT(">>",cTxt)        // posizione primo maggiore

      // se non trovo tutti e 2 o la partenza e' minore dell'arrivo : esco
      IF nStart == 0 .OR. nStop == 0 .OR. nStart>nStop
         EXIT
      ENDIF

      cTxtFun := SUBSTR(cTxt,nStart+2,nStop-nStart-2)
      cRet    := dfRetChr( cTxtFun, @lErr1 )

      IF ! EMPTY(lErr1)
         lErr := .T.
      ENDIF

      IF lNoSpace
         cRet := ALLTRIM(cRet)
      ENDIF

      cTxt := STRTRAN(cTxt,[<<]+cTxtFun+[>>],cRet)

   ENDDO
ENDIF

RETURN cTxt
