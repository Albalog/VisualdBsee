//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
#include "dfWin.ch"
#include "dfCtrl.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION tbIs2Paint( oTbr, nPos, nType, cID, cRID )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aCTRL := oTbr:W_CONTROL, lRet := .T., aActCTRL

DEFAULT nType   TO 0          // Tipo 0 nessuno in particolare
DEFAULT cID     TO "#"        // tutti
DEFAULT cRID    TO "#"        // tutti

cID  := UPPER( cID  )
cRID := UPPER( cRID )

// RICORDARSI di allineare il tutto con i SYS
aActCTRL := aCTRL[nPos]
DO CASE
   CASE !(aActCTRL[FORM_CTRL_PAGE]==0 .OR.;
        oTbr:W_CURRENTPAGE==aActCTRL[FORM_CTRL_PAGE])
        lRet:=.F. // pagina 0 o NIL o pagina uguale alla corrente stampo

   CASE !(nType==0 .OR. nType==aActCTRL[FORM_CTRL_TYP]) // Se non voglio
        lRet:=.F.                                          // visualizzare
                                                           // un tipo
   CASE !(cID=="#" .OR. UPPER(aActCTRL[FORM_CTRL_ID])$cID)
        lRet:=.F.

   CASE !(cRID=="#" .OR. cRID+"-"$UPPER(aActCTRL[FORM_CTRL_RID]))
        lRet:=.F.
ENDCASE

RETURN lRet
