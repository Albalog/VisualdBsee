//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "dfWin.ch"
#INCLUDE "dfCtrl.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION tbGetVar( oTbr, cID, uVal )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nActual, uRet, aCTRL
LOCAL aUserData, nPos

IF VALTYPE(cId)=="C"
   nActual := tbCtrlPos( oTbr, cID )
   IF nActual == 0 // simone 19/01/2009 se non trovo l'ID cerco nel VARNAME
      nActual := __tbCtrlVarName( oTbr, cID )
   ENDIF
ELSE
   nActual := cId
ENDIF

IF nActual>0
   aCTRL := oTbr:W_CONTROL[nActual]
   DO CASE
      CASE aCTRL[FORM_CTRL_TYP]==CTRL_SAY      ; uRet :=      aCTRL[FORM_SAY_VAR]
      CASE aCTRL[FORM_CTRL_TYP]==CTRL_BOX      ; uRet :=      aCTRL[FORM_BOX_TYPE]
      CASE aCTRL[FORM_CTRL_TYP]==CTRL_FUNCTION ; uRet := EVAL(aCTRL[FORM_FUN_VAR])
      CASE aCTRL[FORM_CTRL_TYP]==CTRL_GET      ; uRet := EVAL(aCTRL[FORM_GET_VAR],uVal)
      CASE aCTRL[FORM_CTRL_TYP]==CTRL_CMB      ; uRet := EVAL(aCTRL[FORM_CMB_VAR],uVal)
      CASE aCTRL[FORM_CTRL_TYP]==CTRL_TEXT     ; uRet := EVAL(aCTRL[FORM_TXT_VAR],uVal)
      CASE aCTRL[FORM_CTRL_TYP]==CTRL_CHECK    ; uRet := EVAL(aCTRL[FORM_CHK_VAR],uVal)
      CASE aCTRL[FORM_CTRL_TYP]==CTRL_RADIO    ; uRet := EVAL(aCTRL[FORM_RAD_VAR],uVal)
      CASE aCTRL[FORM_CTRL_TYP]==CTRL_BUTTON   ; uRet :=      aCTRL[FORM_BUT_PROMPT]
      CASE aCTRL[FORM_CTRL_TYP]==CTRL_LISTBOX  ; uRet :=      aCTRL[FORM_LIST_OBJECT]:W_TITLE
      CASE aCTRL[FORM_CTRL_TYP]==CTRL_SPIN     ; uRet := EVAL(aCTRL[FORM_SPN_VAR],uVal)

      CASE aCTRL[FORM_CTRL_TYP]==CTRL_USERCB   // simone 19/01/2009 supporto controls utente
            aUserData := aCTRL[FORM_UCB_USERDATA]
            nPos := ASCAN(aUserData, {|x|UPPER(ALLTRIM(x[1]))=="DATALINK"})
            IF nPos > 0 .AND. VALTYPE(aUserData[nPos][2]) == "B"
               uRet := EVAL(aUserData[nPos][2],uVal)
            ENDIF
   ENDCASE
ENDIF
RETURN uRet

// cerca nel varname 
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION __tbCtrlVarName( oTbr, cId )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL nPos
   cId  := UPPER(cId)
   nPos := ASCAN( oTbr:W_CONTROL, {|aSub|_isVarName(aSub, cId)} )
RETURN nPos

STATIC FUNCTION _isVarName(aCtrl, cId)
   LOCAL uRet := .F.
   DO CASE
//      CASE aCTRL[FORM_CTRL_TYP]==CTRL_SAY      ; uRet :=      aCTRL[FORM_SAY_VAR]
//      CASE aCTRL[FORM_CTRL_TYP]==CTRL_BOX      ; uRet :=      aCTRL[FORM_BOX_TYPE]
//      CASE aCTRL[FORM_CTRL_TYP]==CTRL_FUNCTION ; uRet := EVAL(aCTRL[FORM_FUN_VAR])
      CASE aCTRL[FORM_CTRL_TYP]==CTRL_GET      ; uRet := _IsId(aCTRL[FORM_GET_CVAR], cId)
      CASE aCTRL[FORM_CTRL_TYP]==CTRL_CMB      ; uRet := _IsId(aCTRL[FORM_CMB_CVAR], cId)
      CASE aCTRL[FORM_CTRL_TYP]==CTRL_TEXT     ; uRet := _IsId(aCTRL[FORM_TXT_CVAR], cId)
      CASE aCTRL[FORM_CTRL_TYP]==CTRL_CHECK    ; uRet := _IsId(aCTRL[FORM_CHK_CVAR], cId)
      CASE aCTRL[FORM_CTRL_TYP]==CTRL_RADIO    ; uRet := _IsId(aCTRL[FORM_RAD_CVAR], cId)
//      CASE aCTRL[FORM_CTRL_TYP]==CTRL_BUTTON   ; uRet :=      aCTRL[FORM_BUT_PROMPT]
//      CASE aCTRL[FORM_CTRL_TYP]==CTRL_LISTBOX  ; uRet :=      aCTRL[FORM_LIST_OBJECT]:W_TITLE
      CASE aCTRL[FORM_CTRL_TYP]==CTRL_SPIN     ; uRet := _IsId(aCTRL[FORM_SPN_CVAR], cId)

      CASE aCTRL[FORM_CTRL_TYP]==CTRL_USERCB   // simone 19/01/2009 supporto controls utente
           uRet := _isUserCB(aCtrl, cID)
   ENDCASE
RETURN uRet

STATIC FUNCTION _isID(x, cID)
RETURN VALTYPE(x) $"CM" .AND. UPPER(x)==cID


// simone 19/01/2009 supporto controls utente
STATIC FUNCTION _IsUserCB(aSub, cID)
   LOCAL lRet := .F.
   LOCAL nPos, aUserData

   IF aSub[FORM_CTRL_TYP]==CTRL_USERCB   
      aUserData := aSub[FORM_UCB_USERDATA]
      IF VALTYPE(aUserData)=="A" .AND. ! EMPTY(aUserData)
         nPos := ASCAN(aUserData, {|x|UPPER(ALLTRIM(x[1]))=="VARNAME"})
         IF nPos > 0 .AND. _IsId(aUserData[nPos][2], cID)
            lRet := .T.
         ENDIF
      ENDIF
   ENDIF
RETURN lRet