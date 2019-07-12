//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per BROWSE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
#include "dfwin.ch"
#include "dfMenu.ch"
#include "dfusr.ch"
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
FUNCTION tbMenu( oTbr, cLabel ) //
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
LOCAL cCho    := ""
LOCAL nTop    := TBREALTOP( oTbr )    +1
LOCAL nLeft   := TBREALLEFT( oTbr )
LOCAL nBottom := dfArrUsr()[USR_TOP]
LOCAL nRight  := TBREALRIGHT( oTbr )
LOCAL lSystem := .F.
LOCAL lActive := .F.
LOCAL nPos

IF tbIsMenu( oTbr )
   DEFAULT cLabel TO ""
   IF EMPTY(cLabel)
      nPos   := MIN( LEN(oTbr:W_MENUARRAY), 3 )
      IF nPos>0
         cLabel := oTbr:W_MENUARRAY[nPos][MNI_CHILD]
      ENDIF
   ENDIF
   lActive := .T.
ELSE
   IF !EMPTY( oTbr:W_MENUARRAY ) .AND. ; // Non e' vuoto
      oTbr:W_MENUARRAY[1][MNI_TYPE] == MN_SYSTEM // e menu di sistema
      lSystem := .T.
      lActive := .T.
   ENDIF
ENDIF
IF lActive
   cCho := dfMenu( oTbr:W_MENUARRAY, nTop    ,; // Prima  Riga
                                     nLeft   ,; // Prima  Col.
                                     nBottom ,; // Ultima Riga
                                     nRight  ,; // Ultima Col.
                                     NIL     ,; // Action
                                     cLabel  ,; // Position
                                     lSystem  ) // System
ENDIF
RETURN cCho
