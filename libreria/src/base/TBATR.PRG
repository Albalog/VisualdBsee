//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per BROWSE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfWin.ch"
#ifdef __XPP__
   // simone 5/11/04 per correzione problema DBGOTO(0)
   // vedi DBGOTO_XPP
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE tbAtr( oTbr ) // Append the ROW
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
LOCAL nRec, nSkipped

#ifdef __XPP__
IF oTbr:WOBJ_TYPE != W_OBJ_FRM
   oTbr:dehilite()
ENDIF
#endif

IF tbRecCng( oTbr )

   IF EMPTY(oTbr:W_ALIAS)
      oTbr:W_CURRENTREC++
      oTbr:W_AI_LENGHT++
      nRec := oTbr:W_CURRENTREC
   ENDIF
   nSkipped := oTbr:ROWPOS

   oTbr:ROWPOS := nSkipped - (EVAL( oTbr:SKIPBLOCK, -nSkipped ) +nSkipped) +1

   IF !EMPTY(oTbr:W_ALIAS)
      (oTbr:W_ALIAS)->(DBGOTO(oTbr:W_CURRENTREC))
   ELSE
      oTbr:W_CURRENTREC := nRec
   ENDIF
   //oTbr:W_IS2TOTAL := .T. // Obbliga il ricalcolo del totale nei refresh
   tbCONFIGURE(oTbr)       // configuro
   tbStab( oTbr, .T. )    // e Stabilize Forzato

ENDIF
// Fuori dall'ottimizer perche' con le list-box il record e' gia aggiornato
tbSysFooter( oTbr )       // Fatta per CASPER

#ifdef __XPP__
IF oTbr:WOBJ_TYPE != W_OBJ_FRM
   oTbr:hilite()
ENDIF
#endif

RETURN
