#include "xbp.ch"
#include "common.ch"
#include "dfStd.ch"
#include "dfWin.ch"
#include "dfOptFlt.ch"


#ifndef _XBASE18_

// Per problemi di gestione della classe browse (cast, ecc.)
// si pu• attivare l'ottimizzazione solo da Xbase 1.8 in poi

FUNCTION tbBrwOptSet(oBrw, oBrowser); RETURN .F.
FUNCTION tbBrwOptChk(oBrw, oBrowser); RETURN .F.
FUNCTION tbBrwOptDel(oBrw, oBrowser); RETURN .F.


#else


// Note simone 8/apr/03
//
// Problemi dell'ottimizzazione tipo SUBSET 
// - se dall'esterno si cambia il recno non viene riaggiornata 
//   la posizione del browse (che Š su array)
//   bisognerebbe agire sull'evento :notify
// - se si "preparano" meno righe di quelle visibili nel browse
//   allora premendo pag. giu possono rimanere delle righe "bianche"
//   bisognerebbe fare il :refresh delle righe via via che si aggiunge
//   un elemento al :arecno (si potrebbe impostando il :bOnfound)
// - probabili problemi con ADS e creazione subset in thread
//   bisognerebbe aprire la connessione con ADS nel nuovo thread
//   (sarebbe da modificare S2WorkSpaceGet/Set)
// 
// L'ottimizzazione di tipo INDEX
// - la creazione dell'indice in thread diverso non Š finita
// - probabili problemi con ADS e creazione dell'indice in thread
//   bisognerebbe aprire la connessione con ADS nel nuovo thread
//   (sarebbe da modificare S2WorkSpaceGet/Set)


// Imposta/cambia l'ottimizzatore per i browse
// -------------------------------------------
FUNCTION tbBrwOptSet(oBrw, oBrowser, oForm)
   LOCAL oOpt
   LOCAL nMtd := oBrw:W_OPTIMIZEMETHOD
   LOCAL nRecLimit 

   tbBrwOptDel(oBrw)

   IF EMPTY( oBrw:W_ALIAS )
      RETURN .F.
   ENDIF

   nRecLimit := dfSet("XbaseBrowseOptimizeRecLimit")

   DEFAULT nRecLimit TO "500"

   nRecLimit := VAL(nRecLimit)

   // Non applico l'ottimizzazione se ci sono meno di "n" record
   IF (oBrw:W_ALIAS)->(LASTREC()) < nRecLimit
     RETURN .F.
   ENDIF

   IF VALTYPE(nMtd) == "B"
      oOpt := EVAL(nMtd)

   ELSEIF ! VALTYPE(nMtd) == "N"
      // va avanti solo se Š un numero 

   //ELSEIF VALTYPE(nMtd) == "O"
   //   oOpt := nMtd

   ELSEIF nMtd == W_OPT_SUBSET
      oOpt := tbBrowseOptimizeSubSet():new()

   ELSEIF nMtd == W_OPT_INDEX
      oOpt := tbBrowseOptimizeIndex():new()

   ELSEIF nMtd == W_OPT_FILTER
      oOpt := tbBrowseOptimizeFilter():new()

   ENDIF

   IF oOpt != NIL
      oOpt:Create(oBrw, oBrowser, oForm)
      IF oOpt:status() == XBP_STAT_CREATE
         oBrw:W_OPTIMIZEOBJECT := oOpt
      ENDIF
   ENDIF
RETURN .T.

// Controlla se le condizioni di filtro sono cambiate
// --------------------------------------------------
FUNCTION tbBrwOptChk(oBrw, oBrowser, oForm)
   LOCAL lRet := .F.


   // Se non ho definito l'oggetto di optimize cerco di crearlo
   // altrimenti lo ricreo solo se sono cambiati i parametri di filtro
   IF oBrw:W_OPTIMIZEOBJECT == NIL .OR. ;
      oBrw:W_OPTIMIZEOBJECT:changed()

      lRet := .T.
      tbBrwOptSet(oBrw, oBrowser, oForm)

   ELSEIF oBrw:W_OPTIMIZEOBJECT != NIL

      // Assicura che l'ottimizzazione sia a posto
      oBrw:W_OPTIMIZEOBJECT:check()

   ENDIF

RETURN lRet

// Toglie l'ottimizzatore per i browse
// -------------------------------------------
FUNCTION tbBrwOptDel(oBrw)
   IF oBrw:W_OPTIMIZEOBJECT != NIL
      oBrw:W_OPTIMIZEOBJECT:destroy()
      oBrw:W_OPTIMIZEOBJECT := NIL
   ENDIF
RETURN .T.

FUNCTION tbBrwIsOptimized(oBrw)
RETURN oBrw:W_OPTIMIZEOBJECT != NIL
       
#endif

