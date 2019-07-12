// Classe per gestione indici temporanei
#include "common.ch"
#include "dfStd.ch"
#include "dmlb.ch"
#include "dbstruct.ch"
#include "dfMsg.ch"
#include "dfMsg1.ch"


// Classe per gestione indici temporanei eventualmente con k/b e filtrati
//
// Uso:
//
// oTmpIdx := dfTempIndex():new()
//
// nTmpIdx := (DOCMOVD)->(oTmpIdx:create(....))
//
// IF nIdx==NIL
//    ERRORE CREAZIONE
// ELSE
//    .. posso usare nTmpIdx ..
//
// ENDIF
// oTmpIdx:destroy()
 

CLASS dfTempIndex
   PROTECTED:
      VAR cAlias 
      VAR aInd   
      VAR cFile  
      VAR nInd   
      VAR cRealAlias
      VAR lCond
      VAR nRealIndex  
      VAR oThread
      VAR lIndexError
      VAR __cFName // nome del file

      // gestione del nome del file
      INLINE METHOD setFName(x)
         ::__cFName := x
      RETURN self

      INLINE METHOD GetFName()
         LOCAL cFile

         IF ! EMPTY(::__cFName)
            // se l'ho impostato uso il nome impostato
            RETURN ::__cFName
         ENDIF

         // Simone 25/3/03 GERR 3723
         // Se uso ADS creo il file temporaneo nella cartella
         // che contiene il DBF
         IF dfAxsIsLoaded( ALIAS() )
            // Servirebbe per impostare la cartella di rete 
            // che contiene indici temporanei
            cFile := dfSet("XbaseTempIndexAXSPath")

            IF cFile == NIL
               cFile := dfFNameSplit( DbInfo( DBO_FILENAME ) )
               cFile := cFile[1]+cFile[2]
            ENDIF

            //////////////////////////////////////////////////
            //XLS 4348
            //Luca 19/09/2014
            //////////////////////////////////////////////////
            IF !cFile == NIL
               dfMD(cFile) 
            ENDIF
            //////////////////////////////////////////////////

            cFile := dfNameUnique(cFile, dfIndExt(RDDNAME()))
         ELSE
            cFile := dfNameUnique(,dfIndExt(RDDNAME()))
         ENDIF
      RETURN cFile

   EXPORTED
      METHOD Init       // Crea un indice temporaneo
      METHOD Create     // Crea un indice temporaneo
      METHOD Destroy    // Chiude e cancella l'indice temp.
      METHOD mkIndex()  // Creazione del file indice
      INLINE METHOD isError(); RETURN ::lCond
      INLINE METHOD getIndex(); RETURN ::nRealIndex

      INLINE METHOD indexing() // Sto indicizzando?
      RETURN IIF(::oThread==NIL, .F., ::oThread:active)

      INLINE METHOD OpenIndex()
         (::cAlias)->(ORDLISTADD( ::cFile ))
         (::cAlias)->(ORDSETFOCUS(LEN(::aInd)+1))
         (::cAlias)->(DBGOTOP())
         ////////////////////////////////////////////////
         //Luca+Simone 19/01/2011
         //Inserito perchè si è notato con ADS 9.1 che se l'indice filtrato non aveva record allora 
         //la tabella rimaneva a BOF() = .T.  senza impostare il EOF() == .T.  .
         //La funzione DBGOTO_XPP(-1) forza la tabella ad andare a a EOF()
         ////////////////////////////////////////////////
         IF (::cAlias)->(BOF()) .AND. !(::cAlias)->(EOF())
            (::cAlias)->(DBGOTO_XPP(-1))
         ENDIF 
         ////////////////////////////////////////////////
         ////////////////////////////////////////////////
      RETURN self

      // Riapro indici standard
      INLINE METHOD openStdIndexes()
         ORDLISTCLEAR()

         IF dfRddCanCompound( RDDNAME() )
            // 13/12/2002 SIMONE GERR 3582
            IF ::cRealAlias == NIL
               ORDLISTADD( ::aInd[1] )
            ELSE
               ORDLISTADD( SUBSTR( ::aInd[1], 1, RAT( "\", ::aInd[1] ) ) +ALLTRIM(::cRealAlias) )
            ENDIF
         ELSE
            // Simone 26/10/2009 FIX per DIZIONARIO DATI ADS
            // apre "n" indici
            //AEVAL( ::aInd, {|cInd|ORDLISTADD(cInd)} )
            dfIndexesSet(::aInd)

         ENDIF
      RETURN self

ENDCLASS

METHOD dfTempIndex:Init()
   ::lCond  := .F.
   ::cAlias := NIL
   ::aInd   := NIL
   ::cFile  := NIL
   ::nInd   := NIL
   ::cRealAlias := NIL
   ::nRealIndex := NIL
   ::oThread := NIL
   ::lIndexError := .F.
RETURN self

// Crea e apre l'indice temporaneo
// - filtrato per cNewFilter/bNewFilter
// - ordinato per cNewKey o per l'indice nOrd o per l'indice corrente
// 
// nOrd: indice su cui scandire la tabella 
// bKey: chiave per scandire la tabella
// bFilter: INUTILE
// bBreak: break per scandire la tabella
// cNewFilter/bNewFilter: espressione di filtro dell'indice
//                        se tutte e 2 sono NIL non viene creato indice
//                        se cNewFilter=.T. crea indice senza filtro
//                        se una delle 2 diversa da NIL crea indice filtrato
// nProgress: tipo finestra di attesa
//            0= senza finestra attesa
//            1= progress bar
//            2= finestra messaggi
//            3= finestra di wait
// cNewKey: espressione di ordinamento nuova
// lThraad: crea indice in altro thread
// cRealAlias: serve ad esempio se fai USE PIPPO ALIAS PLUTO,  
//             allora in cRealAlias ci deve andare PIPPO
// cFile: nome file indice (default da :getFName())
// lOpenNewIdx: se aggiungere l'indice creato default=.T.
//
// Ritorna:
// se non crea indice torna NIL
// se crea indice torna il nø indice (nota se lOpenNewIdx=.F. NON)
//
//

METHOD dfTempIndex:Create(nOrd       ,; // Finestra sul file e indice corrente
                          bKey       ,;
                          bFilter    ,;
                          bBreak     ,;
                          cNewFilter ,;
                          bNewFilter ,;
                          nProgress  ,;
                          cNewKey    ,;
                          lThread    ,;
                          cRealAlias ,;
                          cFile      ,;
                          lOpenNewIdx)

   LOCAL cKey, nInd := INDEXORD(), nMaxInd, aInd := {}, nRec := RECNO()
   LOCAL cAlias := ALIAS(), lCond, nRealIndex
   LOCAL lKey := (bKey!=NIL .AND. EVAL(bKey)!=NIL) // Ho un filtro
   LOCAL aWS

   LOCAL cPath := ""

//   DEFAULT nProgress TO 1
#if XPPVER < 01900000
   DEFAULT nProgress TO 1   
#else
   DEFAULT nProgress TO 3   // con progress bar in 1.90 si pianta durante indicizzazione
#endif

   DEFAULT lThread   TO .F.
   DEFAULT lOpenNewIdx TO .T.

   IF dfWinIs98()
      nProgress := 1   
   ENDIF 

   //## In caso di indici filtrati bisogna prendere anche il filtro dell'indice
   //   Per creare il sottoindice

   // Se ho un filtro e NON ho disabilitato il sotto indice
   // abilito la creazione dell'indice ON THE FLY
   lCond := .T.
   DO CASE
      CASE VALTYPE(cNewFilter) == "L" .AND. cNewFilter .AND. EMPTY(bNewFilter)
         // SE PASSO cNewFilter=.T. FACCIO L'INDICE ANCHE SE NON E' FILTRATO!
         cNewFilter := NIL
         bNewFilter := NIL

      CASE cNewFilter == NIL .AND. bNewFilter == NIL
         // nessun filtro passato, non faccio niente!
         lCond := .F.   

      CASE VALTYPE(cNewFilter) == "L"
         // nessun filtro passato, non faccio niente!
         lCond := .F.   

      CASE cNewFilter == NIL 
         cNewFilter := dfCodeBlock2String(bNewFilter)

      CASE bNewFilter == NIL 
         bNewFilter := DFCOMPILE(cNewFilter)
   ENDCASE
     
   //lCond := (cNewFilter!=NIL) 

   // Non creo l'indice su File AS/400
   lCond := lCond                                  .AND.; // Se devo fare l'indice
            !dfAsDriver( RDDNAME() )               .AND.; // NON e' AS
            !(ALLTRIM(UPPER(RDDNAME()))=="DBFNDX")        // NON e' DBFNDX

   // Creo l'indice solo sui DBFNTX
   //lCond := lCond                                  .AND.; // Se devo fare l'indice
   //         ALLTRIM(UPPER(RDDNAME()))=="DBFNTX"           // E' DBFCDX

   IF lCond
      DEFAULT cFile TO ::GetFName()

      IF VALTYPE(cNewKey) $ "CM"
         cKey := cNewKey
      ELSEIF lKey
         cKey  := ORDKEY(nOrd)
      ELSE
         cKey  := ORDKEY(nInd)
      ENDIF

      aInd  := dfOrdList_XPP()

      ::cFile      := cFile
      ::cAlias     := cAlias
      ::aInd       := aInd
      ::cRealAlias := cRealAlias


      IF lThread
         // Creazione indice in thread separato
         aWS :=S2WorkSpaceGet()
         ::oThread := Thread():new()
         ::oThread:atStart := {||S2WorkSpaceSet(aWS)}
         ::oThread:atEnd   := {||S2WorkSpaceDel(aWS)}
         ::oThread:start({|| ::mkIndex(nOrd, bKey, bFilter, bBreak, cFile, ;
                              nProgress, lKey, cNewFilter, bNewFilter, cKey) })
         lCond := .F.
      ELSE
         ::mkIndex(nOrd, bKey, bFilter, bBreak, cFile, ;
                   nProgress, lKey, cNewFilter, bNewFilter, cKey)

      ENDIF

      // Riapro indici standard
      ::openStdIndexes()

      IF ::lIndexError
         // se c'Š stato errore in creazione indice
         // disabilito ottimizzazione
         lCond := .F.
      ELSEIF ! ::indexing() .AND. lOpenNewIdx
         ::OpenIndex()
      ENDIF
   ELSE
      IF lKey
         DBSETORDER( nOrd )
      ENDIF
   ENDIF

//   #ifndef __XPP__
//   IF dfAsDriver( RDDNAME() ) .AND.;
//      !EMPTY(cNewFilter)
//      //Win400 adds a new feature to filters, the skill of includeude a virtual
//      //ordering to the database file  and the filter expression altogether; the
//      //ordering expression is defined adding next to the filter expression the
//      //clause ‘.AND. ORDERBY(FieldList)’ where FieldList is the list of fields that
//      //define the ordering criteria all of them separated by ‘,’ (comma). The order
//      //yet generated is activated as the order 0 not affecting the behavior of all
//      //the other active indexes, in this way it is possible to search for records
//      //using the normal method (SEEK command or DBSEEK() function
//
//      cNewFilter := _dfASFilte( cNewFilter )
//
//      dbMsgOn( dfStdMsg(MSG_DDKEY12) )
//      DBSETFILTER( DFCOMPILE(cNewFilter), cNewFilter )
//      DBGOTOP()
//      dbMsgOff()
//      cNewFilter := ".T."
//   ENDIF
//   #endif

   // Se vuoto o NIL assogno qualcosa di valido
   //IF EMPTY cNewFilter ASSIGN ".T."
   //cNewFilter := DFCOMPILE( cNewFilter )

   // Se ho attiva una KEY NON posso spostare l'indice
//   IF lKey
//      nViewIndex := nOrd
//   ELSE
//      nViewIndex := nInd
//   ENDIF

   IF lCond
      nRealIndex := INDEXORD()
   ELSE
      nRealIndex := NIL
      ORDSETFOCUS(nInd)
      DBGOTO_XPP(nRec)
   ENDIF

   ::lCond  := lCond
   //::cAlias := cAlias
   //::aInd   := aInd
   //::cFile  := cFile
   ::nInd   := nInd
   //::cRealAlias := cRealAlias
   ::nRealIndex := nRealIndex

RETURN nRealIndex


//   DO CASE
//      CASE bFilter==NIL
//           IF bBreak!=NIL
//              ddWin( nViewIndex, bKey, cNewFilter ,;
//                                 {||EVAL(bBreak ) .OR.  dfChkNext()},,nRealIndex)
//           ELSE
//              ddWin( nViewIndex, bKey, cNewFilter, {||dfChkNext()},,nRealIndex)
//           ENDIF
//
//      CASE bBreak ==NIL
//           ddWin( nViewIndex, bKey, {||EVAL(bFilter) .AND. EVAL(cNewFilter)} ,;
//                              {||dfChkNext()},,nRealIndex)
//      OTHERWISE
//           ddWin( nViewIndex, bKey, {||EVAL(bFilter) .AND. EVAL(cNewFilter)} ,;
//                              {||EVAL(bBreak ) .OR. dfChkNext()},,nRealIndex)
//   ENDCASE

METHOD dfTempIndex:mkIndex(nOrd, bKey, bFilter, bBreak, cFile, ;
                           nProgress, lKey, cNewFilter, bNewFilter, cKey)
   LOCAL oErr
   LOCAL err
   LOCAL lRet := .T.

   ::lIndexError := .F.

   /////////////////////////////////////////////////////
   //Mantis 2112
   //Da runtime errore su Win98
   IF nProgress == 3 .AND. dfWinIs98()
      nProgress := 2
   ENDIF 
   /////////////////////////////////////////////////////

   IF nProgress == 1
      _dfMakeIndInit()
      _dfMakeIndCreate(cFile,RECCOUNT(), .5)
   ELSEIF nProgress == 2
      dbMsgOn( dfStdMsg(MSG_DDKEY12), .5 )
   ELSEIF nProgress == 3
      VDBWaitInit()  // assicura sia inizializzato
      VDBWaitOn(STRTRAN(dfStdMsg(MSG_DDKEY12), "//", CRLF), dfStdMsg1(MSG1_DFWAIT01), NIL, .T.)
   ENDIF

   IF dfAxsIsLoaded( ALIAS() )
      // Simone 23/8/04 GERR 4048
      // con ADS e indici CDX ho errore di runtime su creazione indice
      // se il file esiste gia', quindi lo cancello!
      FERASE(cFile)
   ENDIF

   // Questa piccola ottimizzazione in caso di Key e Break puo'
   // migliorare anche fino a 100 volte il tempo di elaborazione
   IF lKey 
      DBSETORDER(nOrd)
      DBSEEK( EVAL(bKey) )

      oErr := ErrorBlock( {|e| break(e)} )
      BEGIN SEQUENCE
         // Simone 09/12/02 GERR 3579
         // L'indice temporaneo non veniva usato in Xbase
         lRet := dfMakeIndSub( RDDNAME(),;
                               NIL,;
                               1,;
                               RECNO(),;
                               .T.,;
                               cFile,;
                               dfFindName( cFile ),;
                               cKey,;
                               IIF(nProgress==1, &( "{|| _dfMakeIndPB(), "+cKey+" }" ), DFCOMPILE(cKey)),;
                               .F., ;
                               {||!EVAL(bBreak)}, ;
                               bNewFilter, ; // &( "{|| _dfMakeIndPB(), dbMsgUpd(str(recno())), "+cNewFilter+" }" ),; 
                               cNewFilter, ;
                               NIL, NIL, NIL, ;
                               .T. ) // simone 16/12/09 fix per creazione indici temp con diz. dati ADS 
      RECOVER USING err
         err := err  // serve solo per vedere qual Š l'errore in fase di debug
         ::lIndexError := .T.
      END SEQUENCE
      ErrorBlock(oErr)
   ELSE
      ORDLISTCLEAR()
      oErr := ErrorBlock( {|e| break(e)} )
      BEGIN SEQUENCE
         // Simone 09/12/02 GERR 3579
         // L'indice temporaneo non veniva usato in Xbase
         lRet := dfMakeIndSub( RDDNAME(),;
                               NIL,;
                               1,;
                               RECNO(),;
                               .T.,;
                               cFile,;
                               dfFindName( cFile ),;
                               cKey,;
                               IIF(nProgress==1, &( "{|| _dfMakeIndPB(), "+cKey+" }" ), DFCOMPILE(cKey)),;
                               .F. , ;
                               NIL, ;
                               bNewFilter, ;
                               cNewFilter, ;
                               NIL, NIL, NIL, ;
                               .T. ) // simone 16/12/09 fix per creazione indici temp con diz. dati ADS 

      RECOVER USING err
         err := err  // serve solo per vedere qual Š l'errore in fase di debug
        ::lIndexError := .T.
      END SEQUENCE
      ErrorBlock(oErr)
   ENDIF

   ////////////////////////////////////////////
   IF !lRet 
      ::lIndexError := .T.
   ENDIF 
   ////////////////////////////////////////////


   IF ::lIndexError
      // se c'Š stato errore in creazione indice cancello il file 
      FERASE( cFile )
   ENDIF

   IF nProgress == 1
      _dfMakeIndDestroy()
   ELSEIF nProgress == 2
      dbMsgOff()
   ELSEIF nProgress == 3
      VDBWaitOff()
   ENDIF

RETURN self

// Chiude e cancella l'indice temporaneo creato
// --------------------------------------------

METHOD dfTempIndex:Destroy(lEraseFile)
   LOCAL nRec   := 0
   LOCAL cAlias := ::cAlias
   LOCAL lCond  := ::lCond
   LOCAL aInd   := ::aInd
   LOCAL cFile  := ::cFile
   LOCAL nInd   := ::nInd
   LOCAL cRealAlias := ::cRealAlias

   DEFAULT lEraseFile TO .T.

   // se sto indicizzando attendo la fine!
   IF ::oThread != NIL
      ::oThread:synchronize(0)
      DO WHILE ::oThread:active
         sleep(10)
      ENDDO
      ::oThread := NIL
   ENDIF

   DBSELECTAREA( cAlias )
   IF lCond
      nRec := RECNO()
      ::openStdIndexes()
/*
      ORDLISTCLEAR()
      IF dfRddCanCompound( RDDNAME() )
         // 13/12/2002 SIMONE GERR 3582
         IF cRealAlias == NIL
            ORDLISTADD( aInd[1] )
         ELSE
            ORDLISTADD( SUBSTR( aInd[1], 1, RAT( "\", aInd[1] ) ) +ALLTRIM(cRealAlias) )
         ENDIF
      ELSE
         AEVAL( aInd, {|cInd|ORDLISTADD(cInd)} )
      ENDIF
*/
      SET ORDER TO nInd
      DBGOTO_XPP( nRec )

      IF lEraseFile
         FERASE( cFile )
      ENDIF
   ENDIF

   IF dfAsDriver( RDDNAME() )
      SET FILTER TO
   ENDIF
RETURN




