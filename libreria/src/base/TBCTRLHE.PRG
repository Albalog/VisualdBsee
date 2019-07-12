//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per dataentry
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "dfMsg.ch"
#INCLUDE "dfWin.ch"
#INCLUDE "dfCtrl.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION tbCtrlHelp( oTbr, cState )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos:=oTbr:W_CURRENTGET, aCTRL := oTbr:W_CONTROL, lRet:=.F., aMtd := {}
LOCAL aActCTRL

IF M->Act=="ush"
   lRet:=.T.
ENDIF
aActCTRL := aCTRL[nPos]
IF lRet .AND. nPos>0
   DO CASE
      CASE aActCTRL[FORM_CTRL_TYP] == CTRL_GET
           AEVAL( aActCTRL[FORM_GET_PFK], {|aSub|AADD( aMtd, aSub )} )
           IF aActCTRL[FORM_GET_COMBO]
              ADDKEY "Ada" TO aMtd MESSAGE dfStdMsg(MSG_TBGETKEY01)
              ADDKEY "Cda" TO aMtd MESSAGE dfStdMsg(MSG_TBGETKEY02)
              ADDKEY "Cla" TO aMtd MESSAGE dfStdMsg(MSG_TBGETKEY16)
              ADDKEY "Cra" TO aMtd MESSAGE dfStdMsg(MSG_TBGETKEY17)
              ADDKEY "Cho" TO aMtd MESSAGE dfStdMsg(MSG_TBGETKEY18)
              ADDKEY "Cen" TO aMtd MESSAGE dfStdMsg(MSG_TBGETKEY19)
           ENDIF
           DO CASE
              CASE VALTYPE(EVAL(aActCTRL[FORM_GET_VAR]))=="C"
                   ADDKEY "Cin" TO aMtd MESSAGE dfStdMsg(MSG_TBGETKEY14)
                   ADDKEY "Sin" TO aMtd MESSAGE dfStdMsg(MSG_TBGETKEY15)
              CASE VALTYPE(EVAL(aActCTRL[FORM_GET_VAR]))=="D"
                   ADDKEY "A02" TO aMtd MESSAGE dfStdMsg(MSG_TBGETKEY20)
                   ADDKEY "skn" TO aMtd MESSAGE dfStdMsg(MSG_TBGETKEY21)
                   ADDKEY "skp" TO aMtd MESSAGE dfStdMsg(MSG_TBGETKEY22)
           ENDCASE


      CASE aActCTRL[FORM_CTRL_TYP] == CTRL_CMB
           AEVAL( aActCTRL[FORM_CMB_PFK], {|aSub|AADD( aMtd, aSub )} )
           ADDKEY "Ada" TO aMtd MESSAGE dfStdMsg(MSG_TBGETKEY01)
           ADDKEY "Cin" TO aMtd MESSAGE dfStdMsg(MSG_TBGETKEY14)
           ADDKEY "Sin" TO aMtd MESSAGE dfStdMsg(MSG_TBGETKEY15)

      CASE aActCTRL[FORM_CTRL_TYP] == CTRL_TEXT
           AEVAL( aActCTRL[FORM_TXT_PFK], {|aSub|AADD( aMtd, aSub )} )
           ADDKEY "Cin" TO aMtd MESSAGE dfStdMsg(MSG_TBGETKEY14)
           ADDKEY "Sin" TO aMtd MESSAGE dfStdMsg(MSG_TBGETKEY15)
           ADDKEY "mcr" TO aMtd MESSAGE dfStdMsg(MSG_TBGETKEY04)

      CASE aActCTRL[FORM_CTRL_TYP] == CTRL_CHECK
           ADDKEY "mcr" TO aMtd MESSAGE dfStdMsg(MSG_TBGETKEY05)

      CASE aActCTRL[FORM_CTRL_TYP] == CTRL_RADIO
           ADDKEY "mcr" TO aMtd MESSAGE dfStdMsg(MSG_TBGETKEY06)

      CASE aActCTRL[FORM_CTRL_TYP] == CTRL_BUTTON
           ADDKEY "ret" TO aMtd MESSAGE dfStdMsg(MSG_TBGETKEY07)

      CASE aActCTRL[FORM_CTRL_TYP] == CTRL_LISTBOX
           aMtd:=ACLONE( aActCTRL[FORM_LIST_OBJECT]:W_KEYBOARDMETHODS )

      CASE aActCTRL[FORM_CTRL_TYP] == CTRL_SPIN
           ADDKEY "uar" TO aMtd MESSAGE dfStdMsg(MSG_TBGETKEY08)
           ADDKEY "dar" TO aMtd MESSAGE dfStdMsg(MSG_TBGETKEY09)
           ADDKEY "Cda" TO aMtd MESSAGE dfStdMsg(MSG_TBGETKEY10)
           ADDKEY "Cua" TO aMtd MESSAGE dfStdMsg(MSG_TBGETKEY11)
   ENDCASE
   ADDKEY "esc" TO aMtd MESSAGE dfStdMsg(MSG_DFGET01)
   IF cState#DE_STATE_INK // La funzione e' usata solo in get
                          // pertanto questo controllo potrebbe essere evitato
      ADDKEY "wri" TO aMtd MESSAGE dfStdMsg(MSG_DFGET02)
   ENDIF
   dfUsrHelp( aMtd, cState )
ENDIF
RETURN lRet
