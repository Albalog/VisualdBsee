#include "xbp.ch"
#include "common.ch"
#include "dfStd.ch"
#include "dfWin.ch"
#include "dfOptFlt.ch"


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


// Mantiene i codeblock originali di spostamento di un browse
// ----------------------------------------------------------
STATIC CLASS browseCB
   PROTECTED
      VAR goTopBlock         // Salva il codeblock originale di oBrowser
      VAR skipBlock          // Salva il codeblock originale di oBrowser
      VAR goBottomBlock      // Salva il codeblock originale di oBrowser
      VAR phyPosBlock        // Salva il codeblock originale di oBrowser
      VAR phyPosSet          // Salva il codeblock originale di oBrowser
      VAR posBlock           // Salva il codeblock originale di oBrowser
      VAR goPosBlock         // Salva il codeblock originale di oBrowser
      VAR lastPosBlock       // Salva il codeblock originale di oBrowser
      VAR firstPosBlock      // Salva il codeblock originale di oBrowser

   EXPORTED 
      INLINE METHOD SaveCB(oBrowser)

         ::goTopBlock    := oBrowser:goTopBlock
         ::skipBlock     := oBrowser:skipBlock 
         ::goBottomBlock := oBrowser:goBottomBlock
         ::phyPosBlock   := oBrowser:phyPosBlock
         ::phyPosSet     := oBrowser:phyPosSet
         ::posBlock      := oBrowser:posBlock
         ::goPosBlock    := oBrowser:goPosBlock
         ::lastPosBlock  := oBrowser:lastPosBlock  
         ::firstPosBlock := oBrowser:firstPosBlock 
      RETURN

      INLINE METHOD ResetCB(oBrowser)

         oBrowser:goTopBlock    := ::goTopBlock
         oBrowser:skipBlock     := ::skipBlock 
         oBrowser:goBottomBlock := ::goBottomBlock
         oBrowser:phyPosBlock   := ::phyPosBlock
         oBrowser:phyPosSet     := ::phyPosSet
         oBrowser:posBlock      := ::posBlock
         oBrowser:goPosBlock    := ::goPosBlock
         oBrowser:lastPosBlock  := ::lastPosBlock  
         oBrowser:firstPosBlock := ::firstPosBlock 
      RETURN

ENDCLASS

// Classe BASE di ottimizzazione
CLASS tbBrowseOptimize
   PROTECTED 
      VAR oBrw               // Oggetto che contiene i W_ (derivato da S2Window)
      VAR oBrowser           // Oggetto che fa il browse (derivato da XbpBrowse)
      VAR oForm              // Oggetto che contiene le var. static (derivato da S2Form)
      VAR status
      VAR oBrowseCB          // Contiene i codeblock originali di oBrowser

   EXPORTED 
      INLINE METHOD Init(oBrw, oBrowser, oForm) 
         DEFAULT oBrowser TO oBrw
         DEFAULT oForm    TO oBrw

         ::status := XBP_STAT_INIT
         ::oBrw    := oBrw
         ::oBrowser:= oBrowser
         ::oForm   := oForm
         ::oBrowseCB:= browseCB():new()

      RETURN self

      INLINE METHOD Status(); RETURN ::status  // Ottimizzazione impostata?

      INLINE METHOD Create(oBrw, oBrowser, oForm)  // Imposta l'ottimizzazione
         DEFAULT oBrowser TO oBrw

         DEFAULT oBrw     TO ::oBrw
         DEFAULT oBrowser TO ::oBrowser
         DEFAULT oBrowser TO oBrw
         DEFAULT oForm    TO ::oForm

         ::oBrw    := oBrw
         ::oBrowser:= oBrowser
         ::oForm   := oForm

         ::SaveCB()

      RETURN self

      INLINE METHOD Destroy(oBrw)              // Toglie l'ottimizzazione
         ::ResetCB()

         ::status := XBP_STAT_INIT
         ::oBrw    := NIL
         ::oBrowser:= NIL
         ::oBrowseCB := NIL
      RETURN self


      INLINE METHOD SaveCB(oBrowser)
          DEFAULT oBrowser TO ::oBrowser
          IF oBrowser != NIL
             ::oBrowseCB:saveCB(oBrowser)
          ENDIF
      RETURN 

      INLINE METHOD ResetCB(oBrowser)
          DEFAULT oBrowser TO ::oBrowser
          IF oBrowser != NIL
             ::oBrowseCB:resetCB(oBrowser)
          ENDIF
      RETURN 

      // ottimizzazione in corso? (se si usano thread)
      INLINE METHOD Optimizing(); RETURN .F.

      // Pu• essere usato per reimpostare alcune variabili
      // Š chiamato dal tbBrwOptChk()
      INLINE METHOD Check(); RETURN .T.

      // Il filtro Š cambiato?
      DEFERRED METHOD Changed()

      // Imposta i codeblock di navigazione
      DEFERRED METHOD SetBrowseCB()

ENDCLASS


