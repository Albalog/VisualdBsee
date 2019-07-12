#INCLUDE "common.ch"
#INCLUDE "dfReport.ch"
#INCLUDE "dfNet.ch"
#include "dfMsg.ch"

#ifdef _TEST_
func crystalexe()
local a := {}
dfuse("clienti", , a)
   dfCRWRunReport("clipr1.rpt", "clienti", nil, nil, NIL, NIL, {|a|cliqryexe(a)})

//   dfCRWRunReport("docpr3.rpt", {"docven", "docvend"})

dfclose(a)
return .t.

#endif

FUNCTION dfCRWRunReport(cRpt, aTables, cTitle, cFilter, lCopy, bSetup, bQry, oFlag, ;
                        nUserMenu, cIdPrinter, cIdPort)
   LOCAL aBuffer
   LOCAL aQuery   := {}                               //  Array dei dati in query
   LOCAL lQry 
   LOCAL oRepType
   LOCAL oOutput

   // parametri obbligatori
   IF EMPTY(cRpt) 
      RETURN .F.
   ENDIF

   IF EMPTY(aTables)
      aTables := _GetDbDDTables(cRpt)
   ENDIF

   IF EMPTY(aTables)
      RETURN .F.
   ENDIF

   IF VALTYPE(aTables) $ "CM"
      aTables := {aTables}
   ENDIF

   // trasforma da nome query in funzione
   IF VALTYPE(bQry) $ "CM" .AND. ! EMPTY(bQry) 
      bQry := ALLTRIM(bQry)
      IF IsFunction(bQry+"Exe") // se esiste la funzione
         bQry := &("{|aQry| "+bQry+"Exe(aQry) }")
      ENDIF
   ENDIF

   DEFAULT cTitle TO ""
   DEFAULT lCopy TO .T.


   lQry := VALTYPE(bQry)=="B"

   aBuffer := dfPrnCfg()                              //  Inizializzazione array statico ( vedere Norton Guide )

   DO WHILE .T.
      IF lQry

         EVAL(bQry, aQuery)

         IF m->Act == "esc"
            EXIT
         ENDIF

         aBuffer[REP_QRY_DES] := aQuery[QRY_OPT_DESC]    // Espressione letterale della query
         aBuffer[REP_QRY_EXP] := aQuery[QRY_OPT_FLTGET]  // Espressione di filtro

         // forza la conversione della sintassi Xbase++ 
         // in sintassi Crystal nella funzione PESetSelectionFormula
         cFilter := "XPP:"+aBuffer[REP_QRY_EXP] 
      ENDIF

      aBuffer[ REP_NAME ]          := cTitle
      aBuffer[ REP_VREC ]          := {}

      // Crystal Reports
      dfCRWReportSet(aBuffer, cRpt)

      oOutput := _CRWGesFast():new()
      oOutput:setTables( aTables )

      // se copio i files allora li devo cancellare alla fine
      oOutput:setTableCopy( lCopy )

      oRepType := aBuffer[ REP_XBASEREPORTTYPE  ]
      oRepType:setOutput( oOutput )

      IF ! EMPTY(cFilter)
         oRepType:setFormula( cFilter )
      ENDIF

      IF ! EMPTY(oFlag )
         oRepType:setFlag( oFlag )
      ENDIF

      // eventuali impostazioni utente
      IF VALTYPE(bSetup) == "B"
         EVAL(bSetup, aBuffer)
      ENDIF

      IF dfPrnMenu( aBuffer, nUserMenu, cIdPrinter, cIdPort )  //  Configurazione con parametri di layout
         // crea files temporanei
         oOutput:create()

         _dfXPrnOut(aBuffer)
      ENDIF

      IF !lQry; EXIT; ENDIF

      aBuffer := dfPrnCfg()                        //  Reinizializzazione array statico
   ENDDO
RETURN .T.


STATIC FUNCTION _GetDbDDTables(cRepName)
   LOCAL aTables := _GetRepTables(cRepName)
   LOCAL aRet := {}
   LOCAL n

   // ritorna solo le tabelle definite nel RPT 
   // che esistono nel DBDD
   FOR n := 1 TO LEN(aTables)
      IF ddFilePos(aTables[n], .F.)
         AADD(aRet, aTables[n])
      ENDIF
   NEXT
RETURN aRet

STATIC FUNCTION _GetRepTables(cRepName)
   LOCAL aTables := {}
   LOCAL lOpenEngine := .F.
   LOCAL lOpenJob    := .F.
   LOCAL cDir
   LOCAL nJob

   IF EMPTY(cRepName); RETURN {}; ENDIF
   IF ! FILE(cRepName); RETURN {}; ENDIF

   // Gerr. 3606 29/10/03
   // Avvolte l'aplicazione perde il path corrente
   // Salvo path e Directory corrente
   cDir   := dfPathGet()

   // Azzero errori
//   ::setError()

   BEGIN SEQUENCE

      IF PEOpenEngine() < 1; BREAK; ENDIF
      lOpenEngine := .T.

      nJob := PEOpenPrintJob(cRepName)
      IF nJob < 1; BREAK; ENDIF

      lOpenJob := .T.

      aTables := __PEGetTableList(nJob)

   RECOVER
      // C'Š stato un errore
//      ::setError(nJob)

   END SEQUENCE

   IF lOpenJob
      PEClosePrintJob( nJob)
      lOpenJob := .F.
   ENDIF

   IF lOpenEngine
      PECloseEngine()
      lOpenEngine := .F.
   ENDIF

   // Gerr. 3606 29/10/03
   // Avvolte l'aplicazione perde il path corrente
   // Ripristino path e Directory corrente
   dfPathSet( cDir )
RETURN aTables


STATIC CLASS _CRWGesFast
PROTECTED:
   VAR aTables
   VAR aFnames
   VAR lCopy
   VAR aFilesToDel

   INLINE METHOD copyTable(aF, cTo)
      LOCAL aFName := dfFNameSplit(aF[1])
      LOCAL n, cFile
      LOCAL cRet := NIL

      // nome file temporaneo
      cRet := dfFNameSplit(cTo)[1]+dfFNameSplit(cTo)[2]+aFname[3]+aFname[4]

      // effettua la copia effettiva
      dfUsrMsg( dfStdMsg( MSG_DFFILE2PRN02) )

      FOR n := 1 TO LEN(aF)

         cFile := cTo
         IF ! dfFileCopy(aF[n], @cFile)
            // errore durante la copia: return NIL
            cRet := NIL
            EXIT
         ENDIF

         AADD(::aFilesToDel, cFile)
      NEXT
   RETURN cRet

EXPORTED:
   INLINE METHOD init()
      ::aTables := {}
      ::aFNames := {}
      ::aFilesToDel := {}
      ::lCopy   := .T.
   RETURN self

   INLINE METHOD Ferase()
      AEVAL(::aFilesToDel, {|x|FERASE(x)} )
      ASIZE(::aFilesToDel, 0)
   RETURN self

   INLINE METHOD create()
      LOCAL aTab , cFile, nInd
      LOCAL aFiles := {}
      LOCAL cTo := dfReportTemp()
      LOCAL aFName

      aTab := ::aTables
      FOR nInd := 1 TO LEN(aTab)
        aFiles := dfAlias2Files(aTab[nInd])

        IF ! EMPTY(aFiles)
           cFile:= aFiles[1]

           IF ::lCopy
              cFile := ::copyTable(aFiles, cTo)
           ENDIF

           IF ! EMPTY(cFile)
              AADD(::aFnames, cFile)
           ENDIF
        ENDIF
      NEXT
   RETURN self

   INLINE METHOD close; RETURN self

   INLINE METHOD destroy()
     ::aTables := {}
     ::aFNames := {}
     ::aFilesToDel := {}
     ::lCopy   := .T.
   RETURN self

   INLINE METHOD getFName(); RETURN ACLONE(::aFnames)

   INLINE METHOD setTableCopy(l); ::lCopy := l; RETURN ::lCopy
   INLINE METHOD setTables(a); ::aTables:= ACLONE(a); RETURN ::lCopy
ENDCLASS

