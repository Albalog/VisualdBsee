//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
#include "dfWin.ch"
#include "dfCTRL.ch"
#include "dfSet.ch"
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
FUNCTION _tbEnd( oTbr, cClose ) //
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
LOCAL nPos, aCtrl, aActCTRL
LOCAL lDestroyLsb := .F.

IF VALTYPE(oTbr)=="O"
   DEFAULT cClose TO W_OC_RESTORE

   IF ! EMPTY( dfSet( AI_MAXMEM ) )
      cClose += W_OC_DESTROY
      lDestroyLsb := VALTYPE(dfSet(AI_MAXMEM))=="N" .AND. dfSet(AI_MAXMEM) >= 2
   ENDIF

   cClose:= LOWER(cClose)

   aCtrl := oTbr:W_CONTROL

   FOR nPos := 1 TO LEN(aCTRL)
      aActCTRL := aCTRL[nPos]
      IF aActCTRL[FORM_CTRL_TYP] == CTRL_LISTBOX
         // Il rientro nella maschera obbliga il GOTOP
         // e il refresh delle List-BOX
         aActCTRL[FORM_LIST_OBJECT]:W_OBJGOTOP   := .T.
         aActCTRL[FORM_LIST_OBJECT]:W_OBJREFRESH := .T.
         aActCTRL[FORM_LIST_OBJECT]:W_BACKGROUND := .T.
         aActCTRL[FORM_LIST_OBJECT]:W_IS2TOTAL   := .T.

         // imposta NIL nella variabile della listbox per rilasciare memoria
         IF lDestroyLsb .AND. LEN(aActCTRL) >= FORM_LIST_OBJECTVAR
            EVAL(aActCTRL[FORM_LIST_OBJECTVAR], NIL)
         ENDIF

      ENDIF
   NEXT

   oTbr:W_BACKGROUND := .T.
   oTbr:W_IS2TOTAL   := .T.
   oTbr:W_OBJ2ADD    := .T.

   #ifndef __XPP__
   IF W_OC_RESTORE $ cClose
      tbRes( oTbr )
   ENDIF

   IF oTbr:W_SAVESCREENID # NIL         // Per evitare strani RESTORE-SCREEN
      dbScrDel( oTbr:W_SAVESCREENID )   // Distruggo la label dell'oggetto
      oTbr:W_SAVESCREENID := NIL
   ENDIF

   tbDelObj( oTbr )
   #endif
ENDIF

RETURN IF(W_OC_DESTROY$cClose,NIL,oTbr)
