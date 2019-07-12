//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per FILE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "FILEIO.CH"
#include "dfMsg.CH"
#include "dfset.ch"
#include "common.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddIndexFile( cFName, cPath ) // ricostruzione indici su file indicato
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cFile, cDriver, cNtxVar , cVarName, cExt, lRet := .T., nHnd
LOCAL lOpen := .F., cIndexExp, cIndexFile, lAscend, lUnique
LOCAL lCandidate

dbCfgOpen("DBDD")

IF !ddFilePos( cFName ) .OR.;  // Non riesco a posizionare
   ddFileIsTab()               // Sono su una tabella
   RETURN .F.
ENDIF

DEFAULT cPath   TO ddFilePath()

cFile   := cFName
cFName  := ddFileName()
cDriver := ddFileDriver()
cExt    := dfDbfExt(cDriver)

// Simone 18/12/2009
// per uso ADS e CDX con XbaseAxsAutoUse=YES
// altrimenti controlla con il driver del DBDD (es DBFNTX)
// e quindi controlla esistenza file .NTX invece di .CDX
IF dfAxsLoaded(cPath, cDriver)
   cDriver := dfAXSDriver()
ENDIF

IF !dfRddFile( cPath +cFName +cExt, cDriver )   // se non esiste il file su disco
   ddGenDbf( cFile, cPath+cFname+cExt )       // Lo creo
ENDIF                             // NB ddGenDbf() muove il dbdd

dbdd->(DBSEEK( UPPER( "NDX" +cFile ) ))
IF dbdd->(EOF())                  // Se il file non ha indici
   RETURN .T.
ENDIF

IF DFISSELECT( cFName )
   CLOSE (cFName)
   lOpen := .T.
ENDIF

// Simone 07/09/2007
// mantis 0001497: Disattivazione dell’accesso alla cartella dati mantenendo l’accesso da Extra.
// provo apertura esclusiva
IF ! IsInUse(cPath, cFName, cExt, cFname, cDriver)
//IF (lRet := ((nHnd := FOPEN( cPath +cFName +cExt,  FO_READ +FO_EXCLUSIVE ))>0))
   FCLOSE(nHnd)
   IF dfRddCanCompound( cDriver )
      FERASE( cPath+cFName +dfIndExt(cDriver) )
   ENDIF

  #ifdef __XPP__
   // Simone 28/11/03 GERR 4019
   IF (dfSet("XbaseADSFIXEmptyDbf") == "YES")
      dfADSFixEmptyDBF(cPath+cFName, cDriver)
   ENDIF
  #endif

   IF (lRet :=dfUseFile( cPath+cFName ,,, cDriver ))
      IF dfSet(AI_INDEXPACK)
         dfWaitOn( dfStdMsg(MSG_DDINDEXFL03) +cFName +dfStdMsg(MSG_DDINDEXFL04) )
         PACK
         dfWaitOff()
      ENDIF

      WHILE UPPER(dbdd->RecTyp+dbdd->File_Name)==UPPER("NDX"+PADR(cFile,8)) .AND.;
         !dbdd->(EOF())

         IF LEFT(dbdd->FILE_ALI,1) = "@"  // nome file variabile
            cVarName := SUBSTR(dbdd->file_ali,2)
            IF TYPE( cVarName ) # "C"
               dbMsgErr( dfStdMsg(MSG_DDINDEXFL01) +cFName  +"//"+;
                         dfStdMsg(MSG_DDINDEXFL02) +cVarName      )
               lRet := .F.
               EXIT
            ENDIF
            cNtxVar := UPPER(&cVarName)
         ELSE
            cNtxVar := ALLTRIM(dbdd->FILE_ALI)
         ENDIF

         dfUsrMsg( dfStdMsg(MSG_DBCFGOPE01) +" " +cPath+cNtxVar )

         cIndexExp  := ddIndexExp()
         cIndexFile := cPath+cNtxVar
         lAscend    := EMPTY(dbdd->File_typ) .OR. UPPER(dbdd->File_typ) == "A"
         lUnique    := ALLTRIM(UPPER(ddGetSlot(dbdd->Slot,"±",3)))=="U"

         // Simone 7/marzo/06
         // mantis 0000995: abilitare indici "candidati" di xbase 1.90 per indici primari/univoci
         lCandidate := NIL
         IF dfSet("XbaseCandidateIndexEnabled") == "YES" .AND. ;
            ! EMPTY(dbdd->File_Mode)                     .AND. ;
            UPPER(dbdd->File_Mode) $ "PU"  // indice primario/univoco
            lCandidate := .T.
         ENDIF

         IF dfRddCanCompound( cDriver )
            dfMakeInd( cIndexExp, cPath+cFName, lAscend, lUnique, cNtxVar, .F., lCandidate )
         ELSE
            dfMakeInd( cIndexExp,   cIndexFile, lAscend, lUnique, NIL    , NIL, lCandidate )
         ENDIF

         dbdd->(DBSKIP(1))               // passa al prossimo indice del file
      ENDDO
      CLOSE (cFName)
   ENDIF
ENDIF

IF lOpen
   DDUSE( cFName )
ENDIF

RETURN lRet

// Simone 07/09/2007
// mantis 0001497: Disattivazione dell’accesso alla cartella dati mantenendo l’accesso da Extra.
// verifica se una tabella Š in uso
// NOTA: QUESTA FUNZIONE E' PRESENTE IDENTICA ANCHE IN DDINDEX.PRG
//       SE SI MODIFICA QUESTA FUNZIONE MODIFICARLA ANCHE IN DDINDEX.PRG
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
      //IF cDriver == dfAXSDriver() .OR. dfAXSLoaded( cPath+cFName+cExt )
      IF cDriver == dfAXSDriver() .OR. dfAXSLoaded( cPath+cFName+cExt,cDriver  )
         IF dfUseFile( cPath+cFName+cExt, cAlias, .T., cDriver, .T., .T.)
            lRet := .F. // non Š in uso
            CLOSE(cFName)
         ENDIF
      ENDIF
   END SEQUENCE
   ERRORBLOCK(bErr)
   DBSELECTAREA(nPrev)
RETURN lRet
