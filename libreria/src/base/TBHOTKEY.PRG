//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
#include "dfWin.ch"
#include "dfCTRL.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION tbHotKey( oTbr, cState )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos, aCtrl, cInside, nActual := oTbr:W_CURRENTGET, aActCTRL

DEFAULT cState TO DE_STATE_INK

DO CASE
   CASE "A_" $ M->Act
        aCtrl   := oTbr:W_CONTROL
        cInside := dfHot()+UPPER(RIGHT(M->Act,1))
        FOR nPos := 1 TO LEN(aCTRL)
           aActCTRL := aCTRL[nPos]
           IF aActCTRL[FORM_CTRL_PAGE]#oTbr:W_CURRENTPAGE .AND. ;
              aActCTRL[FORM_CTRL_PAGE]!=0
              LOOP  // Processo solo la pagina attuale
           ENDIF
           DO CASE
              CASE aActCTRL[FORM_CTRL_TYP] == CTRL_GET
                   IF cInside $ UPPER(aActCTRL[FORM_GET_PROMPT]) .AND.;
                      tbGetIsAct( oTbr, nPos, cState )
                      nActual := nPos
                      EXIT
                   ENDIF

              CASE aActCTRL[FORM_CTRL_TYP] == CTRL_CMB
                   IF cInside $ UPPER(aActCTRL[FORM_CMB_PROMPT]) .AND.;
                      tbGetIsAct( oTbr, nPos, cState )
                      nActual := nPos
                      EXIT
                   ENDIF

              CASE aActCTRL[FORM_CTRL_TYP] == CTRL_TEXT
                   IF cInside $ UPPER(aActCTRL[FORM_TXT_PROMPT]) .AND.;
                      tbGetIsAct( oTbr, nPos, cState )
                      nActual := nPos
                      EXIT
                   ENDIF

              CASE aActCTRL[FORM_CTRL_TYP] == CTRL_CHECK .OR. ;
                   aActCTRL[FORM_CTRL_TYP] == CTRL_RADIO
                   IF cInside $ UPPER(aActCTRL[FORM_CHK_PROMPT]) .AND.;
                      tbGetIsAct( oTbr, nPos, cState )
                      nActual := nPos
                      //dbAct2Kbd("mcr")
                      EXIT
                   ENDIF

              CASE aActCTRL[FORM_CTRL_TYP] == CTRL_SPIN
                   IF cInside $ UPPER(aActCTRL[FORM_SPN_PROMPT]) .AND.;
                      tbGetIsAct( oTbr, nPos, cState )
                      nActual := nPos
                      EXIT
                   ENDIF

              CASE aActCTRL[FORM_CTRL_TYP] == CTRL_BUTTON
                   IF cInside $ UPPER(aActCTRL[FORM_BUT_PROMPT]) .AND.;
                      tbGetIsAct( oTbr, nPos, cState )
                      nActual := nPos
                      dbAct2Kbd("ret")
                      EXIT
                   ENDIF

              CASE aActCTRL[FORM_CTRL_TYP] == CTRL_LISTBOX
                   IF cInside $ UPPER(aActCTRL[FORM_LIST_OBJECT]:W_TITLE ) .AND.;
                      tbGetIsAct( oTbr, nPos, cState )
                      nActual := nPos
                      EXIT
                   ENDIF

           ENDCASE
        NEXT
   CASE M->Act == "Atb"
        tbPgLoop( oTbr )
        nActual := tbMainCtrl( oTbr )
        M->Act:="tab"
ENDCASE
RETURN nActual
