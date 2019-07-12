//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per FILE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "fileio.CH"
#include "set.ch"
#include "inkey.ch"
#include "dfstd.ch"
#include "dfset.ch"
#include "dfindex.ch"
#include "dfmsg.ch"
#include "dfmsg1.ch"
#include "dfCtrl.ch"
#include "common.ch"

#ifdef __XPP__
   // simone 5/11/04 per correzione problema DBGOTO(0)
   // vedi DBGOTO_XPP
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddIndex( nMode, bFlt ) // Ricostruzione indici
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cFileOpen, cFileDes, cIndexName, cIndexExp
LOCAL nIndex        := 0              // Variabile per cicli
LOCAL aNtxLst := {} ,; // Array con lista indici per selezione
      aNtxDat := {} ,; // Array con dati  per ricostruzione indici
      aNtxTag := {}    // Array con gli indici da ricostruire
LOCAL nHnd, cAscend, lJump, lBatch
LOCAL cMsgNtx, cDriver, cTag, lUnique, lOldDeleted
LOCAL aDatabase := {}, nFile, aNewTag := {}, cAlias, lPack
LOCAL lCandidate
LOCAL nStyle

MEMVAR Act

IF !dbCfgOpen("DBDD")        // Apro come altri file di configurazione
   RETURN .F.
ENDIF

DEFAULT bFlt TO {|| .T. }

DO CASE
   CASE VALTYPE( nMode )=="N"
        IF nMode==IDX_SYSTEM
           ddIndexSys()
           RETURN .T.
        ENDIF

        IF nMode == IDX_CHECK .AND. dfSet(AI_CHECKMODE) == AI_CHECKMODE_ONUSE
           RETURN .T.
        ENDIF
   OTHERWISE
        nMode := ddIndexForm()

        DO CASE
           CASE nMode==-1          // Ho premuto ESC
                RETURN .F.

           CASE nMode==IDX_SYSTEM
                ddIndexSys()
                RETURN .T.
        ENDCASE
ENDCASE

ddIndexArr(nMode,aNtxLst,aNtxDat, bFlt) // CARICA L'ARRAY DEI TAG CON INDICI DA RICOSTRUIRE

IF EMPTY(aNtxDat)
   RETURN .F.
ENDIF

// Se l'elemento 8 e "L" il file e' lokkato da qualcuno
AEVAL( aNtxDat, {|aSub,nArr| IF(EMPTY(aSub[8]),AADD(aNtxTag,nArr),NIL) } )

cMsgNtx := dfStdMsg(MSG_DDINDEX06)
IF dfSet(AI_INDEXPACK) .AND. nMode==IDX_REINDEX
   cMsgNtx += dfStdMsg(MSG_DDINDEX07)
ENDIF

IF nMode = IDX_CHOICE   // Ricostruzione indici PARZIALE

   dfUsrMsg( dfStdMsg(MSG_DDINDEX08) )
   dfArrWin( NIL, NIL, NIL, NIL ,; // Finestra su array centrata
                        aNtxLst ,; // Array righe
                        cMsgNtx ,; // Intestazione finestra
        dfStdMsg(MSG_DDINDEX05) ,; // Intestazione campi
                        aNtxTag  ) // Array tag

   IF Act = [esc]                  // OPERAZIONE ANNULLATA
      RETURN .F.
   ENDIF

   FOR nIndex := 1 TO LEN(aNtxTag)
      IF dfRddCanCompound( aNtxDat[aNtxTag[nIndex]][03] )
         FOR nFile := 1 TO LEN(aNtxDat)
            IF aNtxDat[aNtxTag[nIndex]][02]==;
               aNtxDat[        nFile  ][02]
               IF ASCAN( aNewTag, nFile )==0
                  AADD( aNewTag, nFile )
               ENDIF
            ENDIF
         NEXT
      ELSE
         AADD( aNewTag, aNtxTag[nIndex] )
      ENDIF
   NEXT
   aNtxTag := aNewTag
ENDIF


nStyle := dfSet(AI_XBASEINDEXWAITSTYLE)

DO CASE
   CASE nStyle == AI_INDEXWAITSTYLE_NONE
     // niente!

   CASE nStyle == AI_INDEXWAITSTYLE_FANCY
     dfPIOn(dfStdMsg1(MSG1_DFWAIT01), cMsgNtx, .F., AI_PROGRESSSTYLE_FANCY)

   OTHERWISE
     dbFrameOn( (MAXROW()-15)/2, 05, (MAXROW()-15)/2+15,  75, cMsgNtx )
ENDCASE

dfUsrMsg( dfStdMsg(MSG_DDINDEX10) )

//
// Per velocizzare le operazioni
// apro il file ignorando i deleted, in modo che CLIPPER
// non vada a cercare il primo record vuoto
//
lOldDeleted := SET( _SET_DELETED, .F. )

FOR nIndex := 1 TO LEN(aNtxTag)
// simone 10/4/08 commentato perchŠ non serve
   //IF dfINKEY()==K_SPACE    // Tasto barra pausa //FW
   //   TONE(300,1)
   //   dfUsrMsg( dfStdMsg(MSG_DDINDEX09) )
   //   dfINKEY(0)                                 //FW
   //   dfUsrMsg( dfStdMsg(MSG_DDINDEX10) )
   //   TONE(1300,1)
   //ENDIF

   cFileOpen  := aNtxDat[aNtxTag[nIndex]][02]
   cDriver    := aNtxDat[aNtxTag[nIndex]][03]
   cFileDes   := aNtxDat[aNtxTag[nIndex]][04]
   cIndexName := aNtxDat[aNtxTag[nIndex]][05]
   cTag       := aNtxDat[aNtxTag[nIndex]][06]
   cIndexExp  := aNtxDat[aNtxTag[nIndex]][07]
   cAscend    := aNtxDat[aNtxTag[nIndex]][09]
   IF EMPTY(cAscend); cAscend:="A"; ENDIF
   //cName      := aNtxDat[aNtxTag[nIndex]][10]
   lUnique    := aNtxDat[aNtxTag[nIndex]][11]
   lBatch     := aNtxDat[aNtxTag[nIndex]][12]
   cAlias     := dfFindName(cFileOpen)
   lPack      := aNtxDat[aNtxTag[nIndex]][14]

   // Simone 7/marzo/06
   // mantis 0000995: abilitare indici "candidati" di xbase 1.90 per indici primari/univoci
   lCandidate := NIL
   IF dfSet("XbaseCandidateIndexEnabled") == "YES"  .AND. ;
      ! EMPTY(aNtxDat[aNtxTag[nIndex]][15])         .AND. ;
      UPPER(aNtxDat[aNtxTag[nIndex]][15]) $ "PU"     // indice primario/univoco
      lCandidate := .T.
   ENDIF


   DO CASE
      CASE nStyle == AI_INDEXWAITSTYLE_FANCY
        dfPIStep(nIndex, LEN(aNtxTag))

      OTHERWISE

   ENDCASE
   
   IF ASCAN(aDatabase,{|aSub|aSub[1]==UPPER(ALLTRIM(cFileOpen))})==0
      IF DFISSELECT( cAlias )
         CLOSE (cAlias)

         // Simone 24/10/2001 correzione per errore runtime se
         // esistono 2 files che hanno stesso ALIAS ma path diversi
         IF (nHnd:=ASCAN(aDatabase,{|aSub|aSub[2]==UPPER(ALLTRIM(cAlias))})) > 0
            DFAERASE( aDatabase, nHnd )
         ENDIF
      ENDIF
      IF !dfAsDriver( cDriver ) .AND. !dfFTDriver( cDriver )

         // Simone 07/09/2007
         // mantis 0001497: Disattivazione dell’accesso alla cartella dati mantenendo l’accesso da Extra.
         // Se non riesco ad aprire il file passo al prossimo
         IF IsInUse(dfFNameSplit(cFileOpen, 1+2), dfFNameSplit(cFileOpen, 4), dfDbfExt(cDriver), cAlias, cDriver)
            LOOP
         ENDIF

         // Se non riesco ad aprire il file passo al prossimo
         //IF (nHnd := FOPEN( cFileOpen +dfDbfExt(cDriver), FO_READ +FO_EXCLUSIVE )) < 0
         //   LOOP
         //ENDIF
         //FCLOSE(nHnd)

      ENDIF

      // Cancello l'indice
      IF dfRddCanCompound( cDriver )
         FERASE( cFileOpen +dfIndExt(cDriver) )
      ENDIF

      // Apro il file
      IF !dfUseFile( cFileOpen,,, cDriver )
         // simone 15/06/2009
         // risolto possibile errore runtime in indicizzazione 
         // se si usava stile NONE o FANCY
         DO CASE
            CASE nStyle == AI_INDEXWAITSTYLE_NONE
              // niente!

            CASE nStyle == AI_INDEXWAITSTYLE_FANCY
              dfPIUpdMsg(dfStdMsg(MSG_DDUSE08) +" " +PADR(cFileDes,30))

            OTHERWISE
         dbFrameDis( dfStdMsg(MSG_DDUSE08) +" " +PADR(cFileDes,30) )
         ENDCASE
         LOOP
      ENDIF

      // Aggiungo alla lista
      AADD( aDatabase, {UPPER(ALLTRIM(cFileOpen)),ALIAS()} )

      // Tolgo l'ultimo indicizzato
      IF LEN(aDatabase)>1
         dbCfgClose( aDatabase[1][2] )
         DFAERASE( aDatabase, 1 )
      ENDIF

      // Pack solo una volta
      IF lPack
         IF EVAL( dfSet(AI_PACKCODEBLOCK), cAlias )
            DO CASE
               CASE nStyle == AI_INDEXWAITSTYLE_NONE
                 // niente!

               CASE nStyle == AI_INDEXWAITSTYLE_FANCY
                 dfPIUpdMsg(dfStdMsg(MSG_DDINDEX11) +cFileOpen +dfStdMsg(MSG_DDINDEX12))

               OTHERWISE
                 dbFrameBox( dfStdMsg(MSG_DDINDEX11) +cFileOpen +dfStdMsg(MSG_DDINDEX12))
            ENDCASE

            PACK
         ENDIF
      ENDIF
   ENDIF

   DO CASE
      CASE nStyle == AI_INDEXWAITSTYLE_NONE
        // niente!

      CASE nStyle == AI_INDEXWAITSTYLE_FANCY
        dfPIUpdMsg(PADR(cFileDes,30)+ " " +STR(RECCOUNT(), 9))

      OTHERWISE
        dbFrameDis( PADR(cFileDes,30)+ " " +STR(RECCOUNT(), 9)+ " " + cIndexExp )
   ENDCASE


   lJump := .F.
   IF lBatch           // In check qualcuno potrebbe essere gia' passato
      IF dfAsDriver( cDriver )
         lJump   := dfAsFile( cIndexName )              // Gia' creato
         cIndexName := cTag
      ELSE
         IF !dfRddCanCompound( cDriver ) // Disattivato per i Compound
                                         // In futuro poteri ripensarci
            lJump := dfRddFile( cIndexName +dfIndExt(cDriver), cDriver ) // Gia' creato
         ENDIF
      ENDIF
   ENDIF

   IF !lJump
      IF dfRddCanCompound( cDriver )
         dfMakeInd( cIndexExp,  cFileOpen, cAscend=="A", lUnique, cTag, .F., lCandidate )
      ELSE
         dfMakeInd( cIndexExp, cIndexName, cAscend=="A", lUnique, NIL , NIL, lCandidate )
      ENDIF
   ENDIF

   IF nMode==IDX_CHECK                // Aggiornamento batch INDICI
      dbdd->(DBGOTO(aNtxDat[aNtxTag[nIndex]][1]))
      IF !EMPTY(dbdd->FlgCodNdx)      // Azzero il flag su dbdd
         IF dbdd->(DBRLOCK(RECNO()))
            dbdd->FlgCodNdx := ""
            dbdd->(DBCOMMIT())
            dbdd->(DBRUNLOCK(RECNO()))
         ENDIF
      ENDIF
   ENDIF
NEXT

dfUsrMsg("")

//
// Reimposto i deleted come in partenza
//
SET( _SET_DELETED, lOldDeleted )


AEVAL( aDatabase, {|aSub|dbCfgClose(aSub[2])} )

DO CASE
   CASE nStyle == AI_INDEXWAITSTYLE_NONE
     // niente!

   CASE nStyle == AI_INDEXWAITSTYLE_FANCY
     dfPIOff()

   OTHERWISE
     dbFrameOff()
ENDCASE

RETURN .T.

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE ddIndexArr( nMode, aNtxLst, aNtxDat, bFlt ) // Scandisce DBDD per ottenere la lista degli indici
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nRecno, cName, cFileName, cPath, cFileOpen, cDriver, lOldDeleted
LOCAL nRecNum, cOpen, nHnd, cIndexName, cFileDes, cNdxVar, lBatch, nLenNtx
LOCAL lToReindex, nPos, lCheck, lAll
LOCAL lSkipOpen := .F., lGenDBF := .F.
LOCAL lAdsFix := dfSet("XbaseADSFIXEmptyDbf") == "YES"

dbdd->(DBSEEK( "DBF" ))
WHILE UPPER(dbdd->recTyp)=="DBF" .AND. !dbdd->(EOF())
   IF ddFileIsTab()                  // Se e' una tabella
      dbdd->(DBSKIP(1))              // lo salto
      LOOP
   ENDIF

   cFileName := ddFileName()
   IF EMPTY(cFileName)
      dbdd->(DBSKIP(1))              // lo salto
      LOOP
   ENDIF

   IF ! EVAL(bFlt)                   // Filtro utente
      dbdd->(DBSKIP(1))              // lo salto
      LOOP
   ENDIF

   nRecno    := dbdd->(RECNO())      // Memorizzo il dbf in dbdd
   cName     := dbdd->FILE_NAME      // salvo il nome del file ID per dbdd
   cPath     := ddFilePath()         // Path del file.
   cFileOpen := cPath +cFileName     // Nome file fisico da aprire con PATH
   cDriver   := ddFileDriver()       // Driver del file
   cFileDes  := dbdd->field_des      // Descrizione del file

   IF !dfSet( AI_DISABLEUSEMESSAGE ) .AND. !dfAsDriver( cDriver )
      dfUsrInfo( STRTRAN( dfStdMsg(MSG_AS40004), "%FILE%", cFileOpen +dfDbfExt(cDriver) ) )
   ENDIF

   // Simone 17/12/2009
   // per uso ADS e CDX con XbaseAxsAutoUse=YES
   // altrimenti controlla con il driver del DBDD (es DBFNTX)
   // e quindi controlla esistenza file .NTX invece di .CDX
   IF dfAxsLoaded(cPath,cDriver )
      cDriver := dfAXSDriver()
   ENDIF

   lGenDBF := .F.
   IF dfAsDriver( cDriver )
      IF !dfAsFile( cFileOpen )
         ddGenDbf( cName )
         lGenDBF := .T.
         dfASAddFile( cFileOpen )
      ENDIF
   ELSE
      IF !dfRddFile( cFileOpen +dfDbfExt(cDriver), cDriver ) // se non esiste il file su disco
         ddGenDbf( cName )           // Lo creo
         lGenDBF := .T.
      ENDIF    // ddGenDbf() sposta il dbdd
   ENDIF

   lCheck := .F.

   // Simone 28/11/03 GERR 4019
   // fix per errore esistente con Xbase++ aprendo un DBF con campi memo 
   // e senza record con ADS 
   IF lAdsFix     .AND. ;
      ! lSkipOpen .AND. ;
      dfADSFixEmptyDBF(cFileOpen, cDriver, "_TMPADS_")

      lGenDBF := .T.
      IF nMode==IDX_CHECK
         lCheck := .T. // forzo ricostruzione indici
      ENDIF
   ENDIF

   IF nMode==IDX_CHECK
      IF dfChkPar("/DOCTOR")
         IF !dfChkDbf( cName, cDriver )
            lCheck := .T.
         ENDIF
      ENDIF
   ENDIF

   dbdd->(DBSEEK( "NDX" +UPPER(cName) ))
   IF dbdd->(EOF())                  // Se il file non ha indici
      dbdd->(DBGOTO(nRecno))         // passo al file successivo
      dbdd->(DBSKIP(1))
      LOOP
   ENDIF

   nRecNum := 0     // default Nørecord
   cOpen   := " "   // blank = aperto / L = Lock gi… in USO in rete

   IF DFISSELECT( dfFindName(cFileName) )
      nRecNum := (dfFindName(cFileName))->(RECCOUNT()) // conto i records
   ELSE
      IF dfAsDriver( cDriver )
         nRecNum := 0
      ELSE
         // Se ho generato il DBF probabilmente non ci sono gli indici
         IF lSkipOpen .AND. ! lGenDBF
            cOpen := "L"
         ELSE

            // Simone 07/09/2007
            // mantis 0001497: Disattivazione dell’accesso alla cartella dati mantenendo l’accesso da Extra.
            // Se non riesco ad aprire il file passo al prossimo
            IF IsInUse(cPath, cFileName, dfDbfExt(cDriver), ;
                       dfFindName(cFileName), cDriver) .AND. !dfFtDriver( cDriver )


            //nHnd := FOPEN( cFileOpen +dfDbfExt(cDriver), FO_READ +FO_EXCLUSIVE )
            //IF nHnd<0 .AND. !dfFtDriver( cDriver )
               cOpen := "L"            // blank = aperto / U = Gi… in USO in rete
               IF nMode == IDX_CHECK .AND. ;
                  dfSet(AI_CHECKMODE) == AI_CHECKMODE_SKIP
                  // Al momento che ne trovo uno aperto evito
                  // di aprire tutti gli altri perchŠ su windows NT
                  // Š un'operazione LENTA!
                  lSkipOpen := .T.
               ENDIF
            ELSE
               // FCLOSE(nHnd)

               //
               // Per velocizzare le operazioni
               // apro il file ignorando i deleted, in modo che CLIPPER
               // non vada a cercare il primo record vuoto
               //
               lOldDeleted := SET( _SET_DELETED, .F. )
               IF dfUseFile( cFileOpen,,, cDriver )          // Apro
                  nRecNum := RECCOUNT()                      // conto i records
                  CLOSE                                      // Chiudo
               ENDIF
               //
               // Reimposto i deleted come in partenza
               //
               SET( _SET_DELETED, lOldDeleted )
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   lAll    := .T.
   nLenNtx := LEN( aNtxDat )
   WHILE UPPER(dBdd->RecTyp+dBdd->file_name)=="NDX" +UPPER(cName) .AND. !DBDD->(EOF())
      lToReindex := .F.
      lBatch     := .F.
      cNdxVar    := ddIndexName( cFileName )
      cIndexName := cPath +cNdxVar                // Nome file Indice con path

      IF !dfSet( AI_DISABLEUSEMESSAGE ) .AND. !dfAsDriver( cDriver )
         dfUsrInfo( STRTRAN( dfStdMsg(MSG_AS40004), "%FILE%", cFileOpen +dfIndExt(cDriver) ) )
      ENDIF

      IF nMode==IDX_CHECK                         // Aggiornamento batch INDICI
         DO CASE
            CASE lCheck

            CASE dfAsDriver( cDriver )            // AS/400
                 IF dfAsFile( cIndexName )        // LOOP if exist
                    DBDD->(DBSKIP(1))
                    LOOP
                 ENDIF
                 lBatch := .T.

            CASE dfRddCanCompound( cDriver )      // Compound index
                 IF !dfRddFile( cFileOpen +dfIndExt(cDriver), cDriver )
                    lBatch     := .T.             // Must be updated
                    lToReindex := .T.             // Must be updated
                 ENDIF
                 IF !EMPTY(dbdd->FlgCodNdx)       // E' da aggiornare
                    lToReindex := .T.
                 ENDIF

            CASE !dfRddFile( cIndexName +dfIndExt(cDriver), cDriver ) // Normal Index
                 lBatch := .T.

            CASE EMPTY(dbdd->FlgCodNdx)           // Non e' da aggiornare
                 DBDD->(DBSKIP(1))   // il flag sul dbdd e' alzato da dBsee
                 lAll := .F.
                 LOOP
         ENDCASE

      ENDIF

      AADD( aNtxDat, { dBdd->(RECNO())       ,; //  1 Nørecord dbdd
                       cFileOpen             ,; //  2 Nome file   con Path
                       cDriver               ,; //  3 Driver di generazione
                       cFileDes              ,; //  4 Descrizione del file
                       cIndexName            ,; //  5 Nome indice con Path
                       cNdxVar               ,; //  6 Nome TAG
                       ddIndexExp()          ,; //  7 Espressione
                       cOpen                 ,; //  8 Per la rete L = file Lock
              UPPER(ALLTRIM(dbdd->File_typ)) ,; //  9 Tipo di indice Ascend/Descend
                       dbdd->Field_des       ,; // 10 Descrizione indice
 ALLTRIM(UPPER(ddGetSlot(dbdd->Slot,"±",3)))=="U" ,;  // 11 Indice di tipo UNIQUE
                       lBatch                ,; // 12 Ricostruzione batch
                       lToReindex            ,; // 13 Se .T. e' da reindicizzare
                       dfSet(AI_INDEXPACK)   ,; // 14 Se .T. e' da packare
                       dbdd->File_Mode       }) // 15 Indice Primario/Univoco

      IF nMode==IDX_CHOICE    // Ricostruzione parziale con selezione
         AADD( aNtxLst, cOpen  +" "                 +; // 1 in rete Lock
                        PADR(dBdd->FILE_ALI,9) +" " +; // 2 Nome indice
                        STR(nRecNum,6)         +" " +; // 3 Nø Records del file
                        ddIndexExp()                 ) // 4 Espressione
      ENDIF
      dbdd->(DBSKIP(1))
   ENDDO

   // Compound mode is activated
   IF nMode==IDX_CHECK     .AND.;
      dfRddCanCompound( cDriver ) // Se tutti sono lToReindex==.F.
                                  // Deve essere tolto il database
                                  // A meno che non manchi effettivamente
                                  // il compound index
      lToReindex := .F.
      FOR nPos := nLenNtx+1 TO LEN( aNtxDat )
         IF aNtxDat[nPos][13]
            lToReindex := .T.
         ENDIF
      NEXT

      // If there is one index to rebuild, MUST rebuld all
      IF lToReindex
         FOR nPos := nLenNtx+1 TO LEN( aNtxDat )
            aNtxDat[nPos][13] := .T.
            aNtxDat[nPos][12] := .T.
         NEXT
      ELSE
         ASIZE( aNtxDat, nLenNtx ) // Nothing to do
         lAll := .F.
      ENDIF
   ENDIF

   // Siamo in modalita' check
   IF nMode==IDX_CHECK
      // Questo file non ha tutti gli indici da reindicizzare
      IF !lAll
         // Metto il flag di PACK a false
         FOR nPos := nLenNtx+1 TO LEN( aNtxDat )
            aNtxDat[nPos][14] := .F.
         NEXT
      ENDIF
   ENDIF

   dbdd->(DBGOTO(nRecno))
   dbdd->(DBSKIP(1))
ENDDO

dfUsrInfo( "" ) // Fix per alaska. Rimaneva un messaggio attivo

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION ddIndexForm()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aForm := {}, nMode := 1

ATTACH "00" TO aForm GET AS RADIOBUTTON nMode ;
                     PROMPT dfStdMsg(MSG_DDINDEX15) AT 1, 1 SIZE { 50,  2}  VALUE 0 GAP 1   

ATTACH "01" TO aForm GET AS RADIOBUTTON nMode ;
                     PROMPT dfStdMsg(MSG_DDINDEX02) AT 2, 1 SIZE { 50,  2} VALUE 1 GAP 1  

ATTACH "02" TO aForm GET AS RADIOBUTTON nMode ;
                     PROMPT dfStdMsg(MSG_DDINDEX03) AT 3, 1 SIZE { 50,  2} VALUE 2 GAP 1   
                                                                            
ATTACH "03" TO aForm GET AS RADIOBUTTON nMode ;
                     PROMPT dfStdMsg(MSG_DDINDEX04) AT 4, 1 SIZE { 50,  2} VALUE 3 GAP 1  

IF !dfAutoForm( NIL, NIL, aForm, dfStdMsg(MSG_DDINDEX01)+"         ", NIL, "__WRI" )
   nMode := -1
ENDIF

RETURN nMode

// Simone 07/09/2007
// mantis 0001497: Disattivazione dell’accesso alla cartella dati mantenendo l’accesso da Extra.
// verifica se una tabella Š in uso
// NOTA: QUESTA FUNZIONE E' PRESENTE IDENTICA ANCHE IN DDINDEXF.PRG
//       SE SI MODIFICA QUESTA FUNZIONE MODIFICARLA ANCHE IN DDINDEXF.PRG
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION IsInUse(cPath, cFname, cExt, cAlias, cDriver)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL lRet := .T. // default Š in uso
   LOCAL nHnd
   LOCAL nPrev
   LOCAL bErr

   DEFAULT cAlias TO cFname

   IF DFISSELECT(cAlias) 
      RETURN .T. // Š in uso
   ENDIF

   //Mantis 1817
   // simone 9/4/08
   // workaround per VISTA: 
   // prima provo apertura condivisa, dopo provo la esclusiva
   // altrimenti quella esclusiva e' lenta!
   nHnd := FOPEN( cPath +cFName +cExt,  FO_READ +FO_SHARED )
   IF nHnd > 0
      FCLOSE(nHnd)
   ENDIF

   // provo apertura esclusiva
   nHnd := FOPEN( cPath +cFName +cExt,  FO_READ +FO_EXCLUSIVE )
   IF nHnd > 0
      FCLOSE(nHnd)
      RETURN .F. // non Š in uso
   ENDIF

   // se non riesco provo apertura esclusiva tramite RDD, dato che potrei 
   // non avere accessi alla cartella ma con ADS potrebbe andare
   nPrev := SELECT()
   bErr  := ERRORBLOCK( {|e|break(e)} )
   BEGIN SEQUENCE
      IF cDriver == dfAXSDriver() .OR. dfAXSLoaded( cPath+cFName+cExt )
         IF dfUseFile( cPath+cFName+cExt, cAlias, .T., cDriver, .T., .T.)
            lRet := .F. // non Š in uso
            CLOSE(cFName)
         ENDIF
      ENDIF
   END SEQUENCE
   ERRORBLOCK(bErr)
   DBSELECTAREA(nPrev)
RETURN lRet

// Simone 28/11/03 GERR 4019
// fix per errore esistente con Xbase++ aprendo un DBF con campi memo 
// e senza record con ADS 
// se apro con ADS e uso DBFNTX e ho caricato anche il Database engine
// DBFNTX allora controllo se il DBF Š vuoto e ha campi memo
// ne creo uno vuoto al volo usando ADS
//
// NOTA: non Š STATIC FUNCTION perche cosi si pu• utilizzare
// anche in altre funzioni tipo s2ddIndex()


#ifndef __XPP__
   FUNCTION dfADSFixEmptyDbf(); RETURN .F.
#else

#include "dbstruct.ch"
#include "dfAdsDbe.ch"

#define  DBE_DBFNTX   "DBFNTX"

FUNCTION dfADSFixEmptyDbf(cFName, cDriver, cAlias)
   LOCAL lRet := .F.
   LOCAL oErr
   LOCAL aStru
   LOCAL nPrev 
   
   //DEFAULT cAlias TO "_TMPFIX_"
   IF EMPTY(cAlias)                       // Alias default
      cAlias := dfFindName( cFName )
   ENDIF


   // If the AXS is loaded change the RDD to the default RDD of the AXS
   //Spostato qui
   IF dfAXSLoaded( cFName, cDriver )
      cDriver := dfAXSDriver()
   ENDIF

   IF dfASDriver( cDriver )
      cAlias := SUBSTR( cAlias, RAT(":",cAlias)+1 )
   ENDIF

// Spostato sopra perche in caso di ADS cDriver Š un oggetto e da runtime errore quando si cerca di di fare un <Alltrim()>
//   IF dfAXSLoaded( cFName )
//      cDriver := dfAXSDriver()
   //ENDIF

   // Now is possible to use cript database. Link dBsee4cr.obj
   IF dBsee4CR() .AND. !("-"+UPPER(cAlias)+"-"$"-DBDD-DBHLP-DBLOGIN-")
      cDriver := dfCRRDD()
      cFName  := "[" +dfSet( AI_CRIPTKEY ) +"]" +cFName
   ENDIF


   IF UPPER(ALLTRIM(cDriver)) == dfAXSDriver() .AND. ;
      S2DbeInfo(cDriver, COMPONENT_DATA, ADSDBE_TBL_MODE) == ADSDBE_NTX .AND. ;
      ASCAN(RDDLIST(), DBE_DBFNTX) > 0

      nPrev := SELECT()
      aStru := NIL

      oErr := ERRORBLOCK({|e|break(e)})
      BEGIN SEQUENCE

         // Provo ad aprire con DBFNTX
         DBUSEAREA( .T., DBE_DBFNTX, cFName, cAlias, .F., .T. ) 

         // se ho aperto
         IF DFISSELECT(cAlias) 
            // se non ho record salvo la struttura
            IF (cAlias)->(LASTREC()) == 0 
               aStru := (cAlias)->(DBSTRUCT())
            ENDIF
            (cAlias)->(DBCLOSEAREA())
         ENDIF

         // a questo punto il DBF Š chiuso, se ha zero record e
         // contiene un campo MEMO allora ricreo un DBF vuoto
         IF aStru != NIL .AND. ASCAN(aStru, {|a| a[DBS_TYPE]=="M"}) > 0
            DBCREATE(cFName, aStru, cDriver)

            // simone 28/11/08
            // supporto DBF criptati con ADS o ALS
            IF dfADSGetPwd(cFName) != NIL
               dfADSTableEncrypt(cFName, .T.)
            ENDIF

            lRet := .T.
         ENDIF
      END SEQUENCE

      // mi assicuro che sia chiuso
      BEGIN SEQUENCE
         // se ho aperto
         IF DFISSELECT(cAlias) 
            (cAlias)->(DBCLOSEAREA())
         ENDIF
      END SEQUENCE

      ERRORBLOCK(oErr)
      DBSELECTAREA(nPrev)
   ENDIF
RETURN lRet
#endif

