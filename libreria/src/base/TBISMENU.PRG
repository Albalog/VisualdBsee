//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfWin.ch"
#include "dfMenu.ch"
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
FUNCTION tbIsMenu( oTbr ) //
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
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
