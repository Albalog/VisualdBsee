#include "xbp.ch"
#include "common.ch"
#include "dfStd.ch"
#include "dfWin.ch"
#include "dfOptFlt.ch"


// Ottimizzazione di tipo INDEX
// viene creato un indice filtrato al volo e il browse usa 
// l'indice filtrato

// Note simone 8/apr/03
//
// L'ottimizzazione di tipo INDEX
// - la creazione dell'indice in thread diverso non ä finita
// - probabili problemi con ADS e creazione dell'indice in thread
//   bisognerebbe aprire la connessione con ADS nel nuovo thread
//   (sarebbe da modificare S2WorkSpaceGet/Set)
CLASS tbBrowseOptimizeIndex FROM tbBrowseOptimizeFilter
   PROTECTED:
      METHOD OptimizeFilter
      VAR oTmpIdx

   //  Controlla se il filtro ä corretto
   EXPORTED:
      METHOD Create()
      METHOD Destroy()

      INLINE METHOD Check()
         IF ! EMPTY(::_cAlias) .AND. ! EMPTY(::getIndex())
            (::_cAlias)->(ORDSETFOCUS_XPP(::getIndex()))
         ENDIF
      RETURN .T.

      INLINE METHOD Optimizing()
      RETURN ::oTmpIdx:indexing()

      INLINE METHOD getIndex(); RETURN ::oTmpIdx:getIndex()

      INLINE METHOD GoTop()
         (::_cAlias)->(ORDSETFOCUS_XPP(::getIndex()))

         ::tbBrowseOptimizeFilter:goTop()
//         IF ::bNotOptFlt == NIL
//            (::_cAlias)->(DBGOTOP())
//         ELSE
//            (::_cAlias)->(dfTop( ::oBrw:W_KEY, ::bNotOptFlt, ::oBrw:W_BREAK))
//         ENDIF
      RETURN NIL

//      INLINE METHOD skip(n)
//         LOCAL xRet 
//         IF ::bNotOptFlt == NIL
//            xRet := (::_cAlias)->(::DBSKIPPER(n, .F.))
//         ELSE
//            xRet := (::_cAlias)->(dfSkip( n, ::bNotOptFlt, ::oBrw:W_BREAK))
//         ENDIF
//      RETURN xRet

      INLINE METHOD GoBottom()
         (::_cAlias)->(ORDSETFOCUS_XPP(::getIndex()))
         ::tbBrowseOptimizeFilter:goBottom()
//
//         IF ::bNotOptFlt == NIL
//            (::_cAlias)->(DBGOBOTTOM())
//         ELSE
//            (::_cAlias)->(dfBottom( ::oBrw:W_KEY, ::bNotOptFlt, ::oBrw:W_BREAK))
//         ENDIF
      RETURN NIL
ENDCLASS

METHOD tbBrowseOptimizeIndex:Create(oBrw, oBrowser, oForm)
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

   ::oTmpIdx := dfTempIndex():new()

   IF ! dbCfgOpen( "dbDD" )         // Apro il dizionario
      RETURN 
   ENDIF

   dbdd->(ORDSETFOCUS_XPP(1))                       // posiziono dbdd
   dbdd->(DBSEEK( "DBF"+cAlias))

   DBSELECTAREA(cAlias)
   ORDSETFOCUS_XPP(nOrd)

   IF dbdd->(EOF()) .OR. ;
      !("DBF"+cAlias == UPPER(dbDD->rectyp+dbDD->file_name))
      
      // Se non ci sono chiavi,
      // 2' tentativo  ALIAS sul generato == FILE (In dBsee)
      // accade quando apro il file con un alias diverso, in questo caso provo
      // comunque a far andare le ricerche
      cRealAlias := UPPER(PADR( dfAlias2Name( ALIAS() ), 8))
   ENDIF

   xFilter := ::calcFilter(oBrw, oForm, NIL, cStrFilter, cStrBreak, ;
                           bKey, bFilter, bBreak)


   // Salvo per confronto succ. in ::changed()
   ::aNewFilter := xFilter //{xFilter[1], VAR2CHAR(xFilter[2])}
   cNewFilter := xFilter[1]
   ::bNotOptFlt := xFilter[2]

   IF (! EMPTY(cNewFilter) .OR. ! EMPTY(bNewFilter) ) .AND. ;
      ! cNewFilter == ".T." .AND. ;
      ::oTmpIdx:Create(nOrd, bKey, bFilter, bBreak, ;
                       cNewFilter, bNewFilter, NIL, NIL, NIL, cRealAlias) != NIL

      ::SetBrowseCB(oBrw, oBrowser)
      ::status := XBP_STAT_CREATE
   ENDIF
RETURN self

METHOD tbBrowseOptimizeIndex:Destroy(oBrw, oBrowser)

   IF ::status() == XBP_STAT_CREATE
      ::oTmpIdx:destroy()
   ENDIF

   ::tbBrowseOptimize:Destroy()
RETURN self


METHOD tbBrowseOptimizeIndex:OptimizeFilter(cNewFilter, bFilter, oBrw, oForm)
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

   // La lunghezza max. di stringa di filtro possibile per indice NTX ä
   // 256 (nei CDX ä 512). La imposto = 240 perchä il filtro potrebbe
   // tornare una stringa un po piu lunga di 240 car. perche 
   // ci sono le parentesi ")" da chiudere
   dfOptFltOptimize(xFilter, NIL, 240)

   IF dfOptFltGetErrNum(xFilter) != 0 .AND. dfSet("XbaseBrowseOptimizeShowErrors")=="YES"
      dfAlert(  dfOptFltGetErrMsg(xFilter)  )
   ENDIF
RETURN xFilter
