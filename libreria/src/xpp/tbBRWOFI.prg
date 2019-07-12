#include "xbp.ch"
#include "common.ch"
#include "dfStd.ch"
#include "dfWin.ch"
#include "dfOptFlt.ch"
#include "dfMsg.ch"

// Ottimizzazione di tipo FILTER
// viene impostato un SET FILTER sull'arhivio base del browse

CLASS tbBrowseOptimizeFilter FROM tbBrowseOptimize
   PROTECTED:
      METHOD CalcFilter()
      METHOD OptimizeFilter()

      VAR _cAlias, nOrd, bKey, bFilter, bBreak, cStrKey, cStrFilter, cStrBreak
      VAR bNotOptFlt, aNewFilter

      VAR oTmpFlt

   //  Controlla se il filtro Š corretto
   EXPORTED:
      METHOD SetBrowseCB()
      METHOD Create()
      METHOD Destroy()
      METHOD Changed()
      METHOD DbSkipper // copiato dalla funzione standard Xbase 
                       // altrimenti ho problemi in LINK (funz. GetActive)


      INLINE METHOD GoTop()
         IF ::bNotOptFlt == NIL
            (::_cAlias)->(DBGOTOP())
         ELSE
            (::_cAlias)->(dfTop( ::oBrw:W_KEY, ::bNotOptFlt, ::oBrw:W_BREAK))
         ENDIF
      RETURN NIL

      INLINE METHOD skip(n)
         LOCAL xRet 
         IF ::bNotOptFlt == NIL
            xRet := (::_cAlias)->(::DBSKIPPER(n, .F.))
         ELSE
            xRet := (::_cAlias)->(dfSkip( n, ::bNotOptFlt, ::oBrw:W_BREAK))
         ENDIF
      RETURN xRet

      INLINE METHOD GoBottom()
         IF ::bNotOptFlt == NIL
            (::_cAlias)->(DBGOBOTTOM())
         ELSE
            (::_cAlias)->(dfBottom( ::oBrw:W_KEY, ::bNotOptFlt, ::oBrw:W_BREAK))
         ENDIF
      RETURN NIL

ENDCLASS

METHOD tbBrowseOptimizeFilter:Create(oBrw, oBrowser, oForm)
   LOCAL cAlias     
   LOCAL nOrd       
   LOCAL bKey       
   LOCAL bFilter    
   LOCAL bBreak     
   LOCAL cStrFilter 
   LOCAL cStrBreak  
   LOCAL cRealAlias
   LOCAL cNewFilter
   LOCAL bNewFilter
   LOCAL xFilter
   LOCAL nProgress

   ::tbBrowseOptimize:Create(oBrw, oBrowser, oForm)
   oBrw     := ::oBrw
   oBrowser := ::oBrowser
   oForm    := ::oForm

   cAlias     := UPPER(PADR( oBrw:W_ALIAS, 8))
   nOrd       := oBrw:W_ORDER
   bKey       := oBrw:W_KEY
   bFilter    := oBrw:W_FILTER
   bBreak     := oBrw:W_BREAK
   cStrFilter := oBrw:W_STRFILTER
   cStrBreak  := oBrw:W_STRBREAK

   ::_cAlias    := oBrw:W_ALIAS
   ::nOrd       := oBrw:W_ORDER
   ::bKey       := oBrw:W_KEY
   ::bFilter    := oBrw:W_FILTER
   ::bBreak     := oBrw:W_BREAK
   ::cStrKey    := oBrw:W_STRKEY
   ::cStrFilter := oBrw:W_STRFILTER
   ::cStrBreak  := oBrw:W_STRBREAK

   ::status := XBP_STAT_FAILURE
   ::bNotOptFlt  := NIL


   DBSELECTAREA(cAlias)
   ORDSETFOCUS_XPP(nOrd)

   // Simone 1/3/2005 GERR 4283
   ::oTmpFlt := dfFilterSave():new()

   xFilter := ::calcFilter(oBrw, oForm, NIL, cStrFilter, cStrBreak, ;
                           bKey, bFilter, bBreak)


   // Salvo per confronto succ. in ::changed()
   ::aNewFilter := xFilter //{xFilter[1], VAR2CHAR(xFilter[2])}
   cNewFilter := xFilter[1]
   ::bNotOptFlt := xFilter[2]

   IF (! EMPTY(cNewFilter) .OR. ! EMPTY(bNewFilter) ) .AND. ;
      ! cNewFilter == ".T." .AND. ;
      ::oTmpFlt:Create(cNewFilter, bNewFilter) != NIL

      ::SetBrowseCB(oBrw, oBrowser)
      ::status := XBP_STAT_CREATE
   ENDIF
RETURN self

// Controlla se Š cambiato un il filtro
METHOD tbBrowseOptimizeFilter:Changed()
    LOCAL xFilter
    LOCAL lRet := .F.

    IF ::status()   == XBP_STAT_CREATE    .AND. ;
       ::_cAlias    == ::oBrw:W_ALIAS     .AND. ;
       ::nOrd       == ::oBrw:W_ORDER     .AND. ;
       ::bKey       == ::oBrw:W_KEY       .AND. ;
       ::bFilter    == ::oBrw:W_FILTER    .AND. ;
       ::bBreak     == ::oBrw:W_BREAK     .AND. ;
       ::cStrKey    == ::oBrw:W_STRKEY    .AND. ;
       ::cStrFilter == ::oBrw:W_STRFILTER .AND. ;
       ::cStrBreak  == ::oBrw:W_STRBREAK  

        // non Š cambiato nessun codeblock, 
        // controllo se la stringa ottimizzata cambia
        xFilter := ::calcFilter(::oBrw, ::oForm, NIL, ::cStrFilter, ::cStrBreak, ;
                                ::bKey, ::bFilter, ::bBreak)

        lRet := ::aNewFilter[1] == xFilter[1] .AND. ;
                ::aNewFilter[2] == ::bNotOptFlt //VAR2CHAR(::bNotOptFlt) 
     ENDIF
RETURN ! lRet

// Calcola un filtro ottimizzato 
// torna array[2], il primo Š stringa di ottimizz. completa
// il secondo Š cb per ottim. parziale
METHOD tbBrowseOptimizeFilter:calcFilter(oBrw, oForm, cStrKey, cStrFilter, cStrBreak, bKey, bFilter, bBreak)
   LOCAL cNewFilter
   LOCAL xFilter
   LOCAL aRet := {NIL, NIL}

   //DEFAULT cStrKey    TO dfCodeBlock2String(bKey   )
   //DEFAULT cStrFilter TO dfCodeBlock2String(bFilter)
   //DEFAULT cStrBreak  TO dfCodeBlock2String(bBreak )
   cStrFilter := dfCodeBlock2String(bFilter)
   cStrBreak  := dfCodeBlock2String(bBreak )

   // L'ottimizzazione Š valida solo se c'Š filtro, altrimenti 
   // Š praticamente inutile dato che si usa key/break che Š gi… performante
   IF cStrFilter != NIL .AND. ! UPPER(ALLTRIM(cStrFilter)) == ".T."
      cNewFilter := cStrFilter 

    /* NON includo anche il break perche il bFilter deve essere passato
       alla :OptimizeFilter,  altrimenti bFilter e cNewFilter non corrispondono
       il bFilter DEVE essere passato altrimenti se contiene funzioni statiche
       non sono visibili nel codeblock di filtro creato in automatico da cNewFilter
       
      IF cStrBreak != NIL .AND. ! UPPER(ALLTRIM(cStrBreak)) == ".F."

         // valutare prima il break potrebbe essere pi— veloce 
         //cNewFilter := "("+cStrFilter + ") .AND. .NOT. (" + cStrBreak+")"
         cNewFilter := "( .NOT. ("+cStrBreak + ")) .AND. (" + cStrFilter +")"
      ELSE
         cNewFilter := cStrFilter 
      ENDIF
    */
   ENDIF

//   // non ho il filtro come stringa, cerco di ricavarlo dai codeblock
//   cStrFilter := dfCodeBlock2String(bFilter)
//   IF cStrFilter != NIL .AND. ! UPPER(ALLTRIM(cStrFilter)) == ".T."
//      cStrBreak := dfCodeBlock2String(bBreak)
//      IF cStrBreak != NIL .AND. ! UPPER(ALLTRIM(cStrBreak)) == ".F."
//         bNewFilter := {|| EVAL(bFilter) .AND. ! EVAL(bBreak)}
//      ELSE
//         bNewFilter := bFilter
//      ENDIF
//   ENDIF

   // Ottimizza la stringa
   xFilter := ::OptimizeFilter(cNewFilter, bFilter, oBrw, oForm)

   IF ! EMPTY(xFilter)
      aRet[1]    := xFilter[OPTFLT_STROPTEXP]
   ENDIF

   IF ! EMPTY(aRet[1]) .AND. ! xFilter[OPTFLT_STRNOTOPTEXP] == ".T."
      // Ottimizz. parziale del filtro
      aRet[2] := xFilter[OPTFLT_CBNOTOPTEXP]
   ENDIF


   IF EMPTY(aRet[2]) 
      // guardo se devo usare key/break, in questo caso
      // bNotOptFlt NON pu• essere NIL perche devo usare dftop/dfSkip/dfBottom

      aRet[2] := {|| .T. }

      IF EMPTY(oBrw:W_KEY) .OR. ;
         (VALTYPE(oBrw:W_KEY) == "B" .AND. EMPTY(EVAL(oBrw:W_KEY))) 

         // la chiave Š vuota,  controllo il break
         IF EMPTY(cStrBreak) .OR. (UPPER(ALLTRIM(cStrBreak)) == ".F.")
            // anche il break Š vuoto,  posso impostare
            aRet[2] := NIL
         ENDIF
      ENDIF
   ENDIF


RETURN aRet

METHOD tbBrowseOptimizeFilter:OptimizeFilter(cNewFilter, bFilter, oBrw, oForm)
   LOCAL xFilter
   //LOCAL aArr := {}
   LOCAL bVarAcc := {|cVar, xVal| tbGetVar(oForm, cVar, xVal)}

   IF EMPTY(cNewFilter)
      RETURN NIL
   ENDIF

   // Disabilita globalmente ottimizzazione browse
   IF dfSet("XbaseBrowseOptimizeDisabled") == "YES"
      RETURN NIL
   ENDIF

   xFilter := dfOptFltNew(oBrw:W_ALIAS, cNewFilter, bFilter, bVarAcc)

   //AEVAL(oBrw:W_OPTIMIZEVAR, {|x| AADD(aArr, {UPPER(x[1]), IIF(x[3]==NIL, x[2], x[3])} ) })
   //xFilter[OPTFLT_VAR_ARR] := aArr

   dfOptFltOptimize(xFilter)

   IF dfOptFltGetErrNum(xFilter) != 0 .AND. dfSet("XbaseBrowseOptimizeShowErrors")=="YES"
      dfAlert(  dfOptFltGetErrMsg(xFilter)  )
   ENDIF
RETURN xFilter


METHOD tbBrowseOptimizeFilter:SetBrowseCB(oBrw, oBrowser)
//   oBrowser:GoTopBlock    := {|    | (oBrw:W_ALIAS)->(ORDSETFOCUS(oBrw:W_OPTIMIZEOBJECT:getIndex())), ;
//                                     (oBrw:W_ALIAS)->(dfTop( oBrw:W_KEY, oBrw:W_FILTER, oBrw:W_BREAK )) }
//
//   oBrowser:GoBottomBlock := {|    | (oBrw:W_ALIAS)->(ORDSETFOCUS(oBrw:W_OPTIMIZEOBJECT:getIndex())), ;
//                                     (oBrw:W_ALIAS)->(dfBottom( oBrw:W_KEY, oBrw:W_FILTER, oBrw:W_BREAK )) }

   // Navigation code blocks for the browser using a DbSubSet object
   oBrowser:goTopBlock    := {| | oBrw:W_OPTIMIZEOBJECT:goTop() } 
   oBrowser:skipBlock     := {|n| oBrw:W_OPTIMIZEOBJECT:skip(n) }
   oBrowser:goBottomBlock := {| | oBrw:W_OPTIMIZEOBJECT:goBottom() }

RETURN self

METHOD tbBrowseOptimizeFilter:Destroy(oBrw, oBrowser)

   IF ::status() == XBP_STAT_CREATE
      ::oTmpFlt:destroy()
   ENDIF

   ::tbBrowseOptimize:Destroy()
RETURN self


METHOD tbBrowseOptimizeFilter:DbSkipper( nWantSkip, lAppend )
   LOCAL nDidSkip := 0

   DO CASE
   CASE LastRec() == 0 
   CASE nWantSkip == 0 
      DbSkip(0)

   CASE nWantSkip > 0 .AND. !Eof()

      /* Skip down */
      DO WHILE nDidSkip < nWantSkip
         DbSkip(1)
         IF Eof()
            IF lAppend
               /* Append Mode: Ghost record */
               nDidSkip ++
            ELSE
               DbSkip(-1)
            ENDIF
            EXIT
         ENDIF
         nDidSkip ++
      ENDDO

   CASE nWantSkip < 0

      /* Skip up */
      DO WHILE nDidSkip > nWantSkip
         DbSkip(-1)
         IF Bof()
            EXIT
         ENDIF
         nDidSkip --
      ENDDO

   ENDCASE
RETURN  nDidSkip


