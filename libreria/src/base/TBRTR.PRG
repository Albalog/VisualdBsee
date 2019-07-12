//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per BROWSE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfWin.ch"
#include "dfStd.ch"
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE tbRtr( oTbr, oMaster ) // Refresh the ROW
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
LOCAL uOldKey, nIndex, uNewKey

#ifdef __XPP__
IF oTbr:WOBJ_TYPE != W_OBJ_FRM
   oTbr:dehilite()
ENDIF
#endif

IF !EMPTY(oTbr:W_ALIAS)
   nIndex := (oTbr:W_ALIAS)->(ORDSETFOCUS())
   IF !EMPTY(nIndex)
      uOldKey := (oTbr:W_ALIAS)->(&((oTbr:W_ALIAS)->(ORDKEY(nIndex))))
   ELSE
      uOldKey := (oTbr:W_ALIAS)->(RECNO())
   ENDIF
   IF (oTbr:W_ALIAS)->(DELETED())  .OR. ; // Verifico che il record
      !EVAL(oTbr:W_FILTER)         .OR. ; // corrente sia valido
      EVAL(oTbr:W_BREAK)
      tbValidRec( oTbr )
   ENDIF
   tbRecCng( oTbr )
   IF !EMPTY(nIndex)
      uNewKey := (oTbr:W_ALIAS)->(&((oTbr:W_ALIAS)->(ORDKEY(nIndex))))
   ELSE
      uOldKey := (oTbr:W_ALIAS)->(RECNO())
   ENDIF
ENDIF

DFDISPBEGIN()
//oTbr:W_IS2TOTAL := .T. // Obbliga il ricalcolo del totale nei refresh
IF uOldKey#uNewKey
   oTbr:REFRESHALL()
ELSE
   oTbr:REFRESHCURRENT()
ENDIF
tbStab( oTbr, .T. )
DFDISPEND()
IF oMaster#NIL .AND. !(oMaster==oTbr)
   tbSys( oTbr, oMaster )
   tbSysFooter( oTbr ) // Modifica per CASPER
ENDIF

#ifdef __XPP__
IF oTbr:WOBJ_TYPE != W_OBJ_FRM
   oTbr:hilite()
ENDIF
#endif

RETURN
