//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per BROWSE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfWin.ch"
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE tbEtr( oTbr ) // Erase the ROW
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
LOCAL nRec

#ifdef __XPP__
IF oTbr:WOBJ_TYPE != W_OBJ_FRM
   oTbr:dehilite()
ENDIF
#endif

IF EMPTY(oTbr:W_ALIAS) .OR. (oTbr:W_ALIAS)->(DELETED())

   IF EMPTY(oTbr:W_ALIAS)
      oTbr:W_AI_LENGHT--
   ENDIF
   IF EVAL( oTbr:SkipBlock, 1 ) == 0        // Se il Record NON c'e' Avanti
      IF EVAL( oTbr:SkipBlock, -1 ) == 0    // Se il Record NON c'e' Indietro
         EVAL( oTbr:GoTopBlock )               // GoToppo
      ELSE
         IF oTbr:WOBJ_TYPE != W_OBJ_FRM
            // VOLUTO PER ALASKA NON MODIFICARE
            oTbr:RowPos := oTbr:RowPos -1
         ENDIF
      ENDIF
   ENDIF
   tbRecCng( oTbr )
   IF oTbr:WOBJ_TYPE != W_OBJ_FRM
      //oTbr:W_IS2TOTAL := .T. // Obbliga il ricalcolo del totale nei refresh
      tbConfigure(oTbr)
      tbStab( oTbr, .T. )
      tbSysFooter( oTbr ) // Fatta per CASPER
   ENDIF

ELSE
   IF !EMPTY(oTbr:W_ALIAS) .AND. dfASDriver( (oTbr:W_ALIAS)->(RDDNAME()) )
      tbTop( oTbr )
   ENDIF
ENDIF

#ifdef __XPP__
IF oTbr:WOBJ_TYPE != W_OBJ_FRM
   oTbr:hilite()
ENDIF
#endif

RETURN
