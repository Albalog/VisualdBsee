//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfWin.ch"
#include "dfMenu.ch"
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION tbIsMenu( oTbr ) //
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL lRet := .F.
IF !oTbr:W_MENUHIDDEN
   IF !EMPTY( oTbr:W_MENUARRAY )                     // Non e' vuoto
      IF oTbr:W_MENUARRAY[1][MNI_TYPE] == MN_SYSTEM .AND. ;
         LEN( oTbr:W_MENUARRAY ) > 2
         lRet := .T.
      ENDIF
   ENDIF
ENDIF
RETURN lRet
