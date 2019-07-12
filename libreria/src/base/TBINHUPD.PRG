/*******************************************************************************
Progetto       : dBsee 4.4
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
*******************************************************************************/
#include "Common.ch"
#include "dfWin.ch"
#include "dfNet.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE tbInhUpd( oTbr, aInh, oParent )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
// ## Modifica per vedere la contestualita' di pagina
// ## non visualizzare se in pagina diversa dalla corrente
// No stabilize se siamo in pagina diversa da quella corrente
DEFAULT aInh TO oTbr:W_INHARRAY
tbEval( oTbr, {|| _tbInhUpd( oTbr, aInh ) } )
tbStab( oTbr, .T. )
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE _tbInhUpd( oTbr, aInh )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF (oTbr:W_ALIAS)->(dfNet( NET_RECORDLOCK, 0 ))
   tbInh( oTbr, aInh, INH_WRI )
   (oTbr:W_ALIAS)->(dfNet( NET_RECORDUNLOCK ))
ENDIF
RETURN
