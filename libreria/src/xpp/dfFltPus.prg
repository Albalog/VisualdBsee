#include "common.ch"
#include "dfMsg.ch"


STATIC aFilt := {}

// Salva il filtro corrente
FUNCTION dfFilterPush(lClearFilter, lGoTop)
   LOCAL cAlias := ALIAS() 
   LOCAL cFlt := (cAlias)->(DBFILTER())
   LOCAL nPos := ASCAN(aFilt, {|x|x[1]==cAlias})
   LOCAL aArr
   LOCAL xPar

   DEFAULT lClearFilter TO .F.

   IF nPos == 0
      AADD(aFilt, {cAlias, {cFlt}})
   ELSE
      AADD(aFilt[nPos][2], cFlt)
   ENDIF

   IF lClearFilter
      // Simone 1/3/2005 GERR 4283
      (cAlias)->(dfClearFilter(lGoTop))
   ENDIF

RETURN .T.

// Imposta il filtro salvato
FUNCTION dfFilterPop(lSetFilter, nProgress, lGoTop)
   LOCAL cAlias := ALIAS()
   LOCAL nPos := ASCAN(aFilt, {|x|x[1]==cAlias})
   LOCAL aArr
   LOCAL cFlt
   LOCAL oThread
   LOCAL xPar

   DEFAULT lSetFilter TO .T.

   IF nPos != 0
      aArr := aFilt[nPos][2]
      IF ! EMPTY(aArr)
         cFlt := ATAIL(aArr)
         ASIZE( aArr, Len(aArr)-1 )
         IF lSetFilter
            // Simone 1/3/2005 GERR 4283
            (cAlias)->(dfSetFilter(NIL, cFlt, nProgress, lGoTop))
         ENDIF
      ENDIF
   ENDIF
RETURN nPos != 0


// Simone 1/3/2005 GERR 4283
// Gestisce un filtro con possibilit… di ripristinare
CLASS dfFilterSave
PROTECTED:
   VAR aOldFilter
   VAR cAlias
   VAR lFilterError

   INLINE METHOD Reset()
      (::cAlias)->(dfFilterSet(::aOldFilter))
   RETURN self

EXPORTED:
   INLINE METHOD Create(cNewFilter, bNewFilter,nProgress)
      LOCAL lCond := .F.
      LOCAL xRet  := NIL
      LOCAL cShow

      ::lFilterError := .F.
      ::cAlias     := ALIAS()
      ::aOldFilter := dfFilterGet()
      // Se ho un filtro e NON ho disabilitato il sotto indice
      // abilito la creazione dell'indice ON THE FLY
      lCond := .T.
      DO CASE
         CASE cNewFilter == NIL .AND. bNewFilter == NIL
            // nessun filtro passato, non faccio niente!
            lCond := .F.   

         CASE cNewFilter == NIL 
            cNewFilter := dfCodeBlock2String(bNewFilter)

         CASE bNewFilter == NIL 
            bNewFilter := DFCOMPILE(cNewFilter)
      ENDCASE
      IF lCond
   //Maudp 23/07/2013 XL 4010 Disattivo (default del settaggio) al cliente questo messaggio che si intreccia con altri dfwaiton e schianta
   ***************************************************************************************************************
         cShow := dfSet("XbaseBrowseOptimizeShow")

         DEFAULT cShow TO ""


         IF nProgress == NIL
            IF "SHOWMSG" $ cShow
               nProgress := 2 // messaggio di attesa
            ELSE
               nProgress := 0 // nessun messaggio di attesa
            ENDIF
         ENDIF
//         ::setFilter(bNewFilter, cNewFilter, 2)
         ::setFilter(bNewFilter, cNewFilter, nProgress)
   ***************************************************************************************************************
         IF ! ::lFilterError
            xRet := 0 // ritorna diverso da NIL
         ENDIF
      ENDIF
   RETURN xRet

   INLINE METHOD Destroy()
      ::reset()
   RETURN self

   // Prova ad impostare il filtro
   INLINE METHOD setFilter(bNewFilter, cNewFilter, nProgress)
      LOCAL nRec := RECNO()
      ::lFilterError := .F.

      IF ! dfSetFilter(bNewFilter, cNewFilter, nProgress)
         ::lFilterError := .T.
         ::reset()
         DBGOTO_XPP(nRec)
      ENDIF
   RETURN self
ENDCLASS
