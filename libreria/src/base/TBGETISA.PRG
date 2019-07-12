//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"
#INCLUDE "dfCtrl.ch"
#INCLUDE "dfWin.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION tbGetIsAct( oTbr, nPos, cState ) // Controllo attivazione GET
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet:=.F., aCTRL := oTbr:W_CONTROL, aActCTRL

DEFAULT cState TO DE_STATE_INK

aActCTRL := aCTRL[nPos]

DO CASE
   CASE nPos==0

   CASE !EVAL( aActCTRL[FORM_CTRL_DISPLAYIF] )  // Non visibile

   CASE aActCTRL[FORM_CTRL_TYP] == CTRL_SAY      .OR. ; // NON attive
        aActCTRL[FORM_CTRL_TYP] == CTRL_BOX      .OR. ;
        aActCTRL[FORM_CTRL_TYP] == CTRL_FUNCTION

   CASE aActCTRL[FORM_CTRL_TYP] == CTRL_GET               .AND. ;
        cState # DE_STATE_INK                             .AND. ;
        EVAL(aActCTRL[FORM_GET_ACTIVE])                   .AND. ;
        EVAL( aActCTRL[FORM_GET_CONDITION], FORM_PREGET )

        lRet := .T.

   CASE aActCTRL[FORM_CTRL_TYP] == CTRL_CMB               .AND. ;
        cState # DE_STATE_INK                             .AND. ;
        EVAL(aActCTRL[FORM_CMB_ACTIVE])                   .AND. ;
        EVAL( aActCTRL[FORM_CMB_CONDITION], FORM_PREGET )

        lRet := .T.

   CASE aActCTRL[FORM_CTRL_TYP] == CTRL_TEXT              .AND. ;
        cState # DE_STATE_INK                             .AND. ;
        EVAL(aActCTRL[FORM_TXT_ACTIVE])                   .AND. ;
        EVAL( aActCTRL[FORM_TXT_CONDITION], FORM_PREGET )

        lRet := .T.

   CASE (aActCTRL[FORM_CTRL_TYP] == CTRL_CHECK .OR. ;
         aActCTRL[FORM_CTRL_TYP] == CTRL_RADIO)           .AND. ;
        cState # DE_STATE_INK                             .AND. ;
        EVAL(aActCTRL[FORM_CHK_ACTIVE])

        lRet := .T.

   CASE aActCTRL[FORM_CTRL_TYP] == CTRL_BUTTON            .AND. ;
        EVAL(aActCTRL[FORM_BUT_ACTIVE])

        lRet := .T.

   CASE aActCTRL[FORM_CTRL_TYP] == CTRL_LISTBOX           .AND. ;
        EVAL(aActCTRL[FORM_LIST_ACTIVE])

        lRet := .T.

   CASE aActCTRL[FORM_CTRL_TYP] == CTRL_SPIN              .AND. ;
        cState # DE_STATE_INK                             .AND. ;
        EVAL( aActCTRL[FORM_SPN_ACTIVE])

        lRet := .T.

ENDCASE

RETURN lRet
