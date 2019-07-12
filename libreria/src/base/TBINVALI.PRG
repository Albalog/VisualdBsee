#include "dfWin.ch"
#include "dfCtrl.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE tbInvalid( oTbr ) // Rende instabile l'oggetto sul quale sono
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
DO CASE
   CASE oTbr:WOBJ_TYPE == W_OBJ_BRW // Browse
        tbCONFIGURE(oTbr)

   CASE oTbr:WOBJ_TYPE == W_OBJ_FRM // Form
        AEVAL( oTbr:W_CONTROL, {|aSub|IF(aSub[FORM_CTRL_TYP] == CTRL_LISTBOX,;
                                         tbInvalid(aSub[FORM_LIST_OBJECT]),)})

   CASE oTbr:WOBJ_TYPE == W_OBJ_ARRWIN // dfArrWin
        tbCONFIGURE(oTbr)

   CASE oTbr:WOBJ_TYPE == W_OBJ_ARRAYBOX .OR. ;
        oTbr:WOBJ_TYPE == W_OBJ_BROWSEBOX
        oTbr:W_OBJREFRESH := .T.
        oTbr:W_BACKGROUND := .T.

ENDCASE
RETURN
