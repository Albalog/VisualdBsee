#include "dfStd.ch"
#include "common.ch"
#include "dfAdsDbe.ch"
#include "dmlb.ch"
#include "dfSet.ch"

#include "directry.ch"
#include "dfNet.ch"

/*
// Simone 1/3/2005 GERR 4283

// Come workaround ai blocchi di GIOIA/SAT su CITRIX di RICOH
// copia un indice e lo apre, in modo che il blocco venga effettuato
// sull'indice copiato e non blocchi gli altri utenti
//
// funziona solo su ADS, senza ADS c'Š errore runtime.. vedi sotto

// modo d'uso

// crea oggetto, gli indici verranno creati nella cartella
// passata (se Š su ADS)
oIdx := dfIndexDup():new( S2TmpDir() )	

// crea indice, nOrd=numero indice da usare
nOrd := 2
oIdx:create( @nOrd, "DOCMOVD" )

docmovd->(dfS(nOrd, xxxx)

do while ! docmovd->(eof())
.. elaborazione
   docmovd->(dbSkip())
enddo

// cancella indice e ripristina indice corrente
oIdx:destroy()

*/


CLASS dfIndexDup
PROTECTED:
   VAR cAlias      // alias
   VAR nIdx        // indice originale
   VAR aIdxOrig    // elenco indici originali
   VAR aFiles      // files indice creati

   VAR tempPath

   INLINE METHOD clearVar()
      ::cAlias     := NIL
      ::nIdx       := NIL
      ::aIdxOrig   := NIL
      ::aFiles     := NIL
   RETURN self

EXPORTED:

   INLINE METHOD init(cPath)
      DEFAULT cPath TO dfSet("XbaseTempIndexPath")
      DEFAULT cPath TO dfTemp()
      ::clearVar()
      ::setTempPath(cPath)
   RETURN self

   INLINE METHOD setTempPath(x)
      LOCAL cRet := ::tempPath
      IF VALTYPE(x)=="C"
         ::tempPath := x
      ENDIF
   RETURN cRet

   INLINE METHOD create(nIdx, cAlias)
      LOCAL aOut := NIL
      LOCAL n    := NIL
      LOCAL lRet := .F.

      DEFAULT cAlias TO ALIAS()
      ::cAlias     := cAlias
      ::nIdx       := (cAlias)->(INDEXORD())
      ::aIdxOrig   := ACLONE( (cAlias)->(dfOrdList_XPP()) )
      ::aFiles     := NIL

      IF ! EMPTY(nIdx) 
         aOut := (cAlias)->(dfOpenIdx({nIdx}, ::setTempPath() ))
      ENDIF

      IF EMPTY(aOut)
         ::clearVar()
      ELSE
         // BY REFERENCE ritorna numero indice creato
         nIdx := LEN((cAlias)->(dfOrdList_XPP()))
         ::aFiles     := aOut
         lRet := .T.
      ENDIF
   RETURN lRet

   INLINE METHOD destroy()
      LOCAL nSel
      LOCAL nRec

      IF ! EMPTY(::cAlias)
         nSel := SELECT()
         DBSELECTAREA( ::cAlias )
         nRec := RECNO()

         // riapre indici originali
         //ORDLISTCLEAR()
         //AEVAL( ::aIdxOrig, {|cInd|ORDLISTADD(cInd)} )
         // Simone 26/10/2009 FIX per DIZIONARIO DATI ADS
         // apre "n" indici
         dfIndexesSet(::aIdxOrig)

         // cancella indici nuovi creati ad hoc
         AEVAL( ::aFiles, {|aOut| IIF(aOut[2], FERASE( aOut[1] ), NIL)} )

         SET ORDER TO ::nIdx
         DBGOTO( nRec )
         DBSELECTAREA(nSel)
      ENDIF

      ::clearVar()
   RETURN self
ENDCLASS

// Apre gli indici con una modalit… diversa come workaround
// ai blocchi di GIOIA/SAT su CITRIX di RICOH
//
// Lavora sul file e indici attualmente aperti
//
// xParam pu• essere:
//   .T. = esegue copia di tutti gli indici 
//         e riapre la copia al posto degli originali di rete
//   numero = esegue copia dell'indice numero xParam
//         e riapre la copia al posto dell'indice originale di rete
//   stringa=espressione chiave dell'indice da creare (da implementare)
//
//   array vuoto = copia tutti gli indici 
//           e riapre gli originali pi— la copia 
//           es. se una tabella ha 3 indici, alla fine
//           risulta avere 6 indici (3 originali + 3 copia)
//   array non vuoto = copia (o crea da nuovo) gli indici indicati nell'array
//           e riapre gli originali pi— le copia 
//           se l'elemento Š un numero copia l'indice 
//           se l'elemento Š una stringa crea un nuovo indice con espressione chiave (da implementare)
//           se l'elemento Š un array crea un nuovo indice con espressione chiave elemento[1]
//           filtrato per elemento[2] (da implementare)
//           es. se una tabella ha 3 indici, e si passa {1, 3}
//           alla fine risulta avere 5 indici (3 originali + 2 copia)
//   
// Ritorna aRet
//    vuoto se non ha modificato niente
//  oppure
//    array con i dati degli indici creati
//      {lNuovoIndice, nome file creato } 
//   
// esempi:
//   ? dfOpenIdx(2) 
STATIC FUNCTION dfOpenIdx(xParam, cPath)
    LOCAL aInd
    LOCAL aOut := {}
    LOCAL aRet := {}
    LOCAL aTmp := {}
    LOCAL lSaveFlt
    LOCAL n

    // funziona solo con ADS!
    // senza ADS da errore runtime
    // "Error BASE/8071  Alias already in use: OrdListAdd"
    // quando arriva ad aprire l'indice temporaneo copiato
    // probabilmente funzionerebbe bene creando un nuovo indice
    IF ! dfAxsIsLoaded( ALIAS() )
       RETURN aOut
    ENDIF

    // attualmente gli indici compound non sono supportati
    IF dfRddCanCompound( RDDNAME() )
       RETURN aOut
    ENDIF

    // per fare prima disabilita salvataggio filtro su push area
    lSaveFlt := dfSet(AI_SAVEFILTERONPUSHAREA, .F.)
    dfPushArea()

    // elenco indici aperti 
    aInd := dfOrdList_XPP()

    // creazione nuovi indici
    DO CASE
       CASE VALTYPE(xParam) == "N" 
          // indice da sostituire
          AADD(aOut, {xParam, dfCreateIdx(xParam, cPath)})

       CASE VALTYPE(xParam) == "L" .AND. xParam
          // indici da sostituire
          AEVAL(aInd, {|cInd, n| AADD(aOut, {n, dfCreateIdx(n, cPath)})})

       CASE VALTYPE(xParam) == "A"
          // indice/i da aprire in aggiunta
          IF EMPTY(xParam)
             AEVAL(aInd, {|cInd, n| AADD(aOut, {.T., dfCreateIdx(n, cPath)})} )
          ELSE
             AEVAL(xParam, {|xIdx| AADD(aOut, {.T., dfCreateIdx(xIdx, cPath)})} )
          ENDIF
   ENDCASE

   // tolgo ventuali indici che non Š stato possibile creare
   n:=0
   DO WHILE ++n <= LEN(aOut)
      IF aOut[n][2] == NIL
         DFAERASE(aOut, n)
         n--
      ENDIF
   ENDDO

   // se ci sono nuovi indici da aprire
   IF ! EMPTY(aOut)
      AEVAL(aInd, {|x| AADD(aRet, {x, .F.}) })

      // creo array con elenco di tutti gli indici da aprire
      FOR n := 1 TO LEN(aOut)
         IF VALTYPE(aOut[n][1]) == "N"
            // indice da sostituire
            aRet[n][1] := aOut[n][2]
            aRet[n][2] := .T. // indice da cancellare alla fine
         ELSE
            // indice da aprire in aggiunta
            AADD(aRet, {aOut[n][2], .T.}) // indice da cancellare alla fine
         ENDIF
      NEXT

      // apertura indici
      //ORDLISTCLEAR()
      //AEVAL( aRet, {|aIndex| ORDLISTADD(aIndex[1]) } )
      // Simone 26/10/2009 FIX per DIZIONARIO DATI ADS
      // apre "n" indici
      aTmp := ARRAY(LEN(aRet)) //Costruisco array con solo i nomi dei files
      AEVAL( aRet, {|x,i| aTmp[i] := x[1] } ) 
      dfIndexesSet(aTmp)


//      IF dfRddCanCompound( RDDNAME() )
//         // 13/12/2002 SIMONE GERR 3582
//         IF cRealAlias == NIL
//            ORDLISTADD( aInd[1] )
//         ELSE
//            ORDLISTADD( SUBSTR( aInd[1], 1, RAT( "\", aInd[1] ) ) +ALLTRIM(cRealAlias) )
//         ENDIF
//      ELSE
//         AEVAL( aInd, {|cInd|ORDLISTADD(cInd)} )
//      ENDIF
   ENDIF

   // ripristino situazione iniziale
   dfPopArea()
   dfSet(AI_SAVEFILTERONPUSHAREA, lSaveFlt)
RETURN aRet

// Crea un nuovo indice
//   xIdx pu• essere
//   - numero = copia indice numero xIdx
//   - stringa = crea nuovo indice con espressione xIdx
//   - array di 2 elementi = crea nuovo indice con espressione xIdx[1] filtrato per xIdx[2]
// Torna nome file creato o NIL se errore
STATIC FUNCTION dfCreateIdx(xIdx, cPath)
   LOCAL lOk   := .F.
   LOCAL cFlt  := NIL
   LOCAL cName := NIL
   LOCAL nOk

   cName := _CreateFileName(cPath)

   IF EMPTY(cName)
      RETURN NIL
   ENDIF

   IF VALTYPE(xIdx) == "N"
      nOk := _CopyIdx(xIdx, cName)

      // Simone 07/09/2007
      // mantis 0001497: Disattivazione dell’accesso alla cartella dati mantenendo l’accesso da Extra.
      lOk := nOk == 0
      IF nOk == -20
         // errore in copia file, provo a creare un indice temporaneo
         lOk   := _CreateIdx(ORDKEY(xIdx), ORDFOR(xIdx), cName)
      ENDIF
   ELSE
      IF VALTYPE(xIdx) == "A" 
         cFlt := xIdx[2]
         xIdx := xIdx[1]
      ENDIF
      lOk   := _CreateIdx(xIdx, cFlt, cName)
   ENDIF

   IF ! lOk
      FERASE(cName)
      cName := NIL
   ENDIF
RETURN cName

// Simone 07/09/2007
// mantis 0001497: Disattivazione dell’accesso alla cartella dati mantenendo l’accesso da Extra.
STATIC FUNCTION _CreateIdx(cExp, cFlt, cName)
   LOCAL oTmpIdx 
   LOCAL nIdx
/*
   // Simone 23/8/04 GERR 4048
   // con ADS e indici CDX ho errore di runtime su creazione indice
   // se il file esiste gia', quindi lo cancello!
   IF FILE(cName) .AND. ;
      dfAxsIsLoaded( ALIAS() ) .AND. ;
      S2DbeInfo( ADSRDD, COMPONENT_ORDER, ADSDBE_TBL_MODE) == ADSDBE_CDX 

      FERASE(cName)
   ENDIF

   // da implementare craeazione indice
   // per un esempio vedi ddKey.prg

*/
   IF EMPTY(cFlt)
      cFlt := .T. // forzo creazione indice anche senza FILTRO
   ENDIF

   oTmpIdx := dfTempIndex():new()

   // crea il file senza aprirlo
   nIdx := oTmpIdx:Create(NIL, NIL, NIL, {||.F.}, ;
                          cFlt, NIL, NIL, cExp, .F., ;
                          NIL, cName, .F.) 
/*
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
                          lOpenNewIdx )
*/
//   oTmpIdx:destroy()

RETURN nIdx != NIL


// simone 25/02/2005
// copia l'indice di rete cercando di assicurarsi
// che sia uguale all'indice iniziale
// (ci potrebbero essere aggiornamenti dell'indice di rete durante la copia)
// se l'indice Š stato aggiornato riprova a copiarlo fino a 10 volte
// poi se non ci riesce.. pazienza si spera che non dia problemi
// in teoria si potrebbe anche fare un LOCK del file intero (FLOCK())
// ma mi sembra troppo restrittivo
STATIC FUNCTION _CopyIdx(nIdx, cName)
   LOCAL cIdxName 
   LOCAL aInd
   LOCAL lOk := .F.
   LOCAL aDir1 := {}
   LOCAL aDir2 := {}
   LOCAL nRetry := 10 // numero volte per provare a copiare indice
   LOCAL nRet  := 0

   aInd  := dfOrdList_XPP()
   IF nIdx >= 1 .AND. nIdx <= LEN(aInd)
      cIdxName := aInd[nIdx]

      // non posso usare ddFileLock(): genera un loop!
      // impedisco APPEND durante la copia
      //ddFileLock(DD_LOCK , ALIAS() )              // Blocco dbdd (file semaforo)

      DO WHILE .T.
         aDir1 := DIRECTORY(cIdxName)

         lOk := dfFileCopy(cIdxName, cName, NIL, .T.)

         aDir2 := DIRECTORY(cIdxName)

         IF ! lOk // se non l'ho copiato esco
            // Simone 07/09/2007
            // mantis 0001497: Disattivazione dell’accesso alla cartella dati mantenendo l’accesso da Extra.
            nRet := -20 // errore copia file indice
            EXIT
         ENDIF

         // non sono riuscito a prendere i dati.. 
         // esco e dico ok... o la va o la spacca!
         IF LEN(aDir1) != 1 .OR. LEN(aDir2) != 1
            //lOk := .F.
            nRet := 0
            EXIT
         ENDIF

         // verifico che l'indice originale non sia cambiato
         IF aDir1[1][F_WRITE_DATE] == aDir2[1][F_WRITE_DATE] .AND. ;
            aDir1[1][F_WRITE_TIME] == aDir2[1][F_WRITE_TIME] .AND. ;
            aDir1[1][F_SIZE]       == aDir2[1][F_SIZE] 

            // se non Š cambiato OK!
            EXIT
         ENDIF

         // se Š cambiato riprovo a copiarlo max 10 volte
         // alla fine esco e dico ok... o la va o la spacca!
         IF --nRetry <= 0
            //lOk := .F.
            EXIT
         ENDIF
      ENDDO

      // riabilito APPEND
      //ddFileLock(DD_UNLOCK , ALIAS() )              // sblocco dbdd (file semaforo)
   ELSE
      nRet := -10 // indice fuori range
   ENDIF
RETURN nRet

STATIC FUNCTION _CreateFileName(cPath)
   LOCAL cFile
   LOCAL aFn

   DEFAULT cPath TO dfTemp()

   // Simone 25/3/03 GERR 3723
   // Se uso ADS creo il file temporaneo nella cartella
   // che contiene il DBF
   IF dfAxsIsLoaded( ALIAS() )

      aFn:= dfFNameSplit(cPath)
      IF EMPTY(aFn[1])
         // simone 29/11/06
         // mantis 0001175: supportare percorsi UNC
         aFN[1]:=dfPathRoot() //CURDRIVE()+":"
      ENDIF

      // se il path temporaneo non Š su un server ADS
      // crea l'indice nel path del file .DBF
      IF ! dfAXSOnDrives( UPPER(ALLTRIM(aFN[1])) ) .OR. ! dfChkDir(cPath)
         cPath := dfFNameSplit( DbInfo( DBO_FILENAME ) )
         cPath := cPath[1]+cPath[2]
      ENDIF
   ENDIF

   cFile := dfNameUnique(cPath, dfIndExt(RDDNAME()))
RETURN cFile
