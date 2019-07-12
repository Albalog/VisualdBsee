//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per ACT
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"
#INCLUDE "dfStd.ch"
#INCLUDE "dfReport.ch"
#INCLUDE "dfpdf.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfArrRep(lSet) // Ritorna l'array delle Action letto dall'ini
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC aAct := NIL
LOCAL nArr, nLen
DEFAULT lSet TO .F.

IF lSet
   aAct := NIL
   dfIniOpen()
ENDIF 

IF aAct == NIL
   IF dfIsIni()           // Ho l'INI aperto
      aAct := dfIniRep()     // Carico le azioni dall'INI
   ENDIF
   IF EMPTY aAct ASSIGN dfIntRep() // Prendo i valori interni
   nLen := LEN(aAct)
   FOR nArr := 1 TO nLen
      ASIZE( aAct[nArr][PRN_PRF_VALUE], PRN_PRF_LEN )
      DEFAULT aAct[nArr][PRN_PRF_USEUSER1] TO "0"
      DEFAULT aAct[nArr][PRN_PRF_USEUSER2] TO "0"
      DEFAULT aAct[nArr][PRN_PRF_USEUSER3] TO "0"
      DEFAULT aAct[nArr][PRN_PRF_NO_EJECT] TO "0"
      DEFAULT aAct[nArr][PRN_PRF_ALLPAGE ] TO "1"
      DEFAULT aAct[nArr][PRN_PRF_FROMPAGE] TO "0"
      DEFAULT aAct[nArr][PRN_PRF_TOPAGE  ] TO "9999"
      DEFAULT aAct[nArr][PRN_PRF_COPY    ] TO "1"
      DEFAULT aAct[nArr][PRN_PRF_PAGE           ] TO PDF_PAGE_A4
      DEFAULT aAct[nArr][PRN_PRF_ORIENTATION    ] TO PDF_VERTICAL
   NEXT
ENDIF

IF lSet
   dfIniClose()
ENDIF


RETURN aAct
