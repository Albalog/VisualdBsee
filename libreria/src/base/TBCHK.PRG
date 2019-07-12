//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"
#INCLUDE "dfWin.ch"
#INCLUDE "dfset.ch"
#INCLUDE "dfmenu.ch"
#INCLUDE "dfMsg.ch"
#INCLUDE "dfMsg1.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION tbChkLab( oTbr, cPar )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

// simone 13/12/10 XL 2319
// poter mettere controllo accessi per utente su stampa tabella/stampa etichette
LOCAL b := dfSet(AI_TBPRNLAB_CB)

RETURN !EMPTY(oTbr:W_ALIAS)                                                    .AND.;
       !dfSet( AI_DISABLELABELPRINT )                                          .AND.;
       !("-"+UPPER(ALLTRIM(oTbr:W_ALIAS))+"-" $ "-DBDD-DBHLP-DBTABD-DBLOGIN-") .AND.;
       !dfIsCaller("dfPrnMenu")                                                .AND.;
       !(dfSet("XbaseDisablePrintDatabase") == "YES")                          .AND.;
       (EMPTY(b) .OR. EVAL(b, oTbr, cPar))


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION tbChkPrn( oTbr, cPar )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

// simone 13/12/10 XL 2319
// poter mettere controllo accessi per utente su stampa tabella/stampa etichette
LOCAL b := dfSet(AI_TBPRNWIN_CB)

RETURN !EMPTY(oTbr:W_ALIAS)                                                    .AND.;
       !(dfSet("XbaseDisablePrintDatabase") == "YES")                          .AND.;
       (EMPTY(b) .OR. EVAL(b, oTbr, cPar))


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION tbChkSta( oTbr, cPar )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

// simone 13/12/10 XL 2319
// poter mettere controllo accessi per utente su stampa tabella/stampa etichette
LOCAL b := dfSet(AI_TBFILESTAT_CB)

RETURN !EMPTY(oTbr:W_ALIAS)                                                    .AND.;
       !dfSet( AI_DISABLESTATISTIC )                                           .AND.;
       !("-"+UPPER(ALLTRIM(oTbr:W_ALIAS))+"-" $ "-DBDD-DBHLP-DBTABD-DBLOGIN-") .AND.;
       !dfIsCaller("dfPrnMenu")                                                .AND.;
       (EMPTY(b) .OR. EVAL(b, oTbr, cPar))

