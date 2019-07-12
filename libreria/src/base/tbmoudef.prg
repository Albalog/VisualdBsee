//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"
#INCLUDE "dfWin.ch"
#INCLUDE "dfset.ch"
#INCLUDE "dfmenu.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION tbMouDef( nObjType )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nRet := 0
DO CASE
   CASE nObjType == W_OBJ_BRW
        nRet := W_MM_ESCAPE     +W_MM_MOVE       +W_MM_MINIMIZE  ;
               +W_MM_MAXIMIZE   +W_MM_VSCROLLBAR +W_MM_SIZE      ;
               +W_MM_HSCROLLBAR +W_MM_EDIT
   CASE nObjType == W_OBJ_ARRAYBOX  .OR. ;
        nObjType == W_OBJ_BROWSEBOX
        nRet := 0

   CASE nObjType == W_OBJ_ARRWIN
        nRet := W_MM_ESCAPE      +W_MM_MOVE       +W_MM_MINIMIZE ;
               +W_MM_MAXIMIZE    +W_MM_VSCROLLBAR +W_MM_SIZE     ;
               +W_MM_EDIT
   OTHERWISE
        nRet := W_MM_ESCAPE      +W_MM_MOVE                      ;
               +W_MM_HSCROLLBAR  +W_MM_EDIT +W_MM_PAGE
ENDCASE

RETURN nRet
