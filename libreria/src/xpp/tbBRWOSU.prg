#include "xbp.ch"
#include "common.ch"
#include "dfStd.ch"
#include "dfWin.ch"
#include "dfOptFlt.ch"



// Ottimizzazione di tipo SUBSET 
// il browse viene impostato su un array che contiene i RECNO
// che rientrano nel filtro, l'array viene riempito in un THREAD
// separato


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

CLASS tbBrowseOptimizeSubSet FROM tbBrowseOptimize
   PROTECTED 
      VAR cAlias, nOrd, bKey, bFilter, bBreak

   EXPORTED 
      VAR breakSubset
      VAR oSubSet
      METHOD Create()
      METHOD SetBrowseCB()

      INLINE METHOD Check(); RETURN .T.
      INLINE METHOD Optimizing(); RETURN ::oSubset != NIL  .AND. ::oSubset:active

      INLINE METHOD Changed()
      RETURN !( ::status()== XBP_STAT_CREATE .AND. ;
                ::cAlias  == ::oBrw:W_ALIAS  .AND. ;
                ::nOrd    == ::oBrw:W_ORDER  .AND. ;
                ::bKey    == ::oBrw:W_KEY    .AND. ;
                ::bFilter == ::oBrw:W_FILTER .AND. ;
                ::bBreak  == ::oBrw:W_BREAK  )

      //METHOD Destroy()
      INLINE METHOD Destroy(oBrw)              // Toglie l'ottimizzazione
         sleep(20)
         IF ::oSubset != NIL 
            IF ::Optimizing()
               // interrompo il render delle pagine
               ::breakSubset := .T.
               ::oSubset:synchronize(0)
            ENDIF
            ::oSubset:destroy()
         ENDIF
         sleep(20)

         ::tbBrowseOptimize:Destroy(oBrw)
      RETURN self
ENDCLASS

METHOD tbBrowseOptimizeSubSet:Create(oBrw, oBrowser)
   LOCAL cVal    := dfSet("XbaseBrowseOptimizeSubSetPrepare")
   LOCAL bBreak

   ::status := XBP_STAT_FAILURE

   ::tbBrowseOptimize:Create(oBrw, oBrowser)

   oBrw     := ::oBrw
   oBrowser := ::oBrowser

   ::cAlias   := oBrw:W_ALIAS
   ::nOrd     := oBrw:W_ORDER
   ::bKey     := oBrw:W_KEY
   ::bFilter  := oBrw:W_FILTER
   ::bBreak   := oBrw:W_BREAK

   // L'ottimizzazione Š valida solo se c'Š filtro, altrimenti 
   // Š praticamente inutile dato che si usa key/break che Š gi… performante
   IF ! EMPTY(::bFilter)

      IF ::bBreak == NIL
         bBreak := {|| ::breakSubset }
      ELSE
         bBreak := {|| ::breakSubset .OR. EVAL(oBrw:W_BREAK)}
      ENDIF

      ::breakSubset := .F.
      ::oSubSet := dfSubSet():new( ::cAlias, ::nOrd, ::bKey, ::bFilter, bBreak )
//::oSubSet:nprogress:=1

      // Nell'altro thread riapre tutti archivi e indici
      //::oSubSet:bStart  := {|| S2WorkSpaceSet(aWA)}
      //::oSubSet:bEnd    := {|| DBCLOSEALL() }

      //oSubSet:bStart  := {|| dfUse( "MATRICO" ,NIL ,aMyFile ) .AND. dfUse( "CONTRAD" ,NIL ,aMyFile )}
      //oSubSet:bEval := {||dfUsrMsg(ALLTRIM(STR( CONTRAD->(RECNO()) ))+cFound), .T.}
      //oSubSet:bEnd  := {||dfUsrMsg(""), dfClose(aMyfile)}
//::oSubset:bend:={||dfalert("end")}

      // sarebbe carino fare anche un postappevent con codeblock per
      // effettuare il refresh del browse, non posso mettere direttamente
      // obrowse:refrshall() perche sarebbe eseguito nell'altro thread
      // e darebbe errori dato che Š aperto solo il CONTRAD.
      //oSubSet:bOnFound  := {||cFound:= "-"+ALLTRIM(STR(CONTRAD->(RECNO())))+cFound}
      //oSubSet:bOnFound  := {||cFound:= "-"+ALLTRIM(STR(CONTRAD->(RECNO())))+cFound, oBrowse:refreshAll()}

//::oSubSet:bOnFound  := {||oBrowser:refreshAll()}

      IF cVal == NIL 
         // Default al numero di righe visibili nel browse
         IF VALTYPE(oBrowser:rowCount)=="N" .AND. oBrowser:rowCount > 0
            cVal := STR(oBrowser:rowCount+4)
         ENDIF
      ELSEIF VALTYPE(cVal) == "C"
         cVal := VAL(cVal)
      ENDIF

      ::oSubSet:prepare( cVal )
      IF ::oSubset:getError() == 0
         ::SaveCB()

         ::SetBrowseCB(oBrw, oBrowser)


         ::oSubSet:finish()

         ::status := XBP_STAT_CREATE
      ENDIF
   ENDIF
RETURN .T.

METHOD tbBrowseOptimizeSubSet:SetBrowseCB(oBrw, oBrowser)
   // Navigation code blocks for the browser using a DbSubSet object
   oBrowser:goTopBlock    := {| | (oBrw:W_ALIAS)->(::oSubSet:GoTop()   ) } 
   oBrowser:skipBlock     := {|n| (oBrw:W_ALIAS)->(::oSubSet:Skip(n)   ) } 
   oBrowser:goBottomBlock := {| | (oBrw:W_ALIAS)->(::oSubSet:GoBottom()) } 

   oBrowser:phyPosBlock   := {| | (oBrw:W_ALIAS)->(::oSubset:Recno()   ) } 
   oBrowser:phyPosSet     := {|n| (oBrw:W_ALIAS)->(::oSubSet:goTo(n)   ) }

   // Navigation code blocks for the vertical scroll bar 
   oBrowser:posBlock      := {| | (oBrw:W_ALIAS)->(::oSubSet:Recno()   ) } 
   oBrowser:goPosBlock    := {|n| (oBrw:W_ALIAS)->(::oSubSet:goTo(n)   ) } 
   oBrowser:lastPosBlock  := {| | (oBrw:W_ALIAS)->(::oSubSet:LastRec() ) } 
   oBrowser:firstPosBlock := {| | 1                  } 
RETURN self


