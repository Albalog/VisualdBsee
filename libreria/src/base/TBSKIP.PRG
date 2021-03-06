//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per BROWSE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "dfWin.ch"
#INCLUDE "dfmsg.ch"

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
FUNCTION _TbFSkip( oTbr, n2Skip ) // dbSkip
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
LOCAL nSkip := (oTbr:W_ALIAS)->(dfSkip( n2Skip, oTbr:W_FILTER, oTbr:W_BREAK ))
IF nSkip == 0
   DO CASE
      CASE oTbr:WOBJ_TYPE # W_OBJ_FRM

      CASE (oTbr:W_ALIAS)->(RECCOUNT())==0
           dbMsgErr( dfAliasDesc(oTbr:W_ALIAS) +dfStdMsg( MSG_TBSKIP01 ))

      CASE (oTbr:W_ALIAS)->(DELETED()) .OR. (oTbr:W_ALIAS)->(EOF())
           * Evito i messaggi in caso di file vuoto con record cancellati

      CASE n2Skip<0
           dbMsgErr( dfStdMsg( MSG_TBSKIP02 ) +dfAliasDesc(oTbr:W_ALIAS))

      CASE n2Skip>0
           dbMsgErr( dfStdMsg( MSG_TBSKIP03 ) +dfAliasDesc(oTbr:W_ALIAS))
   ENDCASE
ENDIF
RETURN nSkip

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE _TbBTop( oTbr ) // GoTop
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
// Simone 28/10/09 
// non uso ORDSETFOCUS_XPP perch� controllo prima (� pi� veloce)
IF (oTbr:W_ALIAS)->(ORDNUMBER()) != oTbr:W_ORDER
(oTbr:W_ALIAS)->(ORDSETFOCUS(oTbr:W_ORDER))
ENDIF
(oTbr:W_ALIAS)->(dfTop( oTbr:W_KEY, oTbr:W_FILTER, oTbr:W_BREAK ))
RETURN

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE _TbBBottom( oTbr ) // GoBottom
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
// Simone 28/10/09 
// non uso ORDSETFOCUS_XPP perch� controllo prima (� pi� veloce)
IF (oTbr:W_ALIAS)->(ORDNUMBER()) != oTbr:W_ORDER
(oTbr:W_ALIAS)->(ORDSETFOCUS(oTbr:W_ORDER))
ENDIF
(oTbr:W_ALIAS)->(dfBottom( oTbr:W_KEY, oTbr:W_FILTER, oTbr:W_BREAK ))
RETURN

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
STATIC FUNCTION dfAliasDesc( cAlias )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
LOCAL cName := cAlias
IF ddFilePos( cAlias )
   cName := ddFileDesc()
ENDIF
RETURN cName
