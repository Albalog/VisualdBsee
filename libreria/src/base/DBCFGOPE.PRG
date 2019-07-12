//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per Configurazioni
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
#include "dfSet.ch"
#include "dfMsg.ch"
#include "dfStd.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dbCfgOpen( cFile, lCreate ) // apre i file di configurazione
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC lASInizialize := .F.
STATIC lFTInizialize := .F.
LOCAL cPath, cExp, cNtx0, cNtx1, cNtx2, cName, cInd, cExt, lMake
LOCAL lCompound
LOCAL cDriver := RDDSETDEFAULT()

DEFAULT lCreate TO .F.

cFile := UPPER( cFile )
IF !cFile $ "-DBDD-DBHLP-DBTABD-DBLOGIN-DBLKINF"
   dbMsgErr( dfStdMsg( MSG_DBCFGOPE02 ) +" " +cFile )
   RETURN .F.
ENDIF

IF dfSet( AI_AS400INIT )
   IF !lASInizialize
      dfASInizialize()
      lASInizialize := .T.
   ENDIF
ENDIF

IF dfSet( AI_FORTRESSINIT )
   IF !lFTInizialize
      dfFTInizialize()
      lFTInizialize := .T.
   ENDIF
ENDIF

DO CASE
   CASE DFISSELECT( cFile )
        SELECT (cFile)
        IF !(cFile=="DBLOGIN")
           SET ORDER TO 1
        ENDIF

   CASE cFile == "DBDD"
        cPath := dbCfgPath( "dbddPath" )

        // Simone 18/12/2009
        // per uso ADS e CDX con XbaseAxsAutoUse=YES
        // altrimenti controlla con il driver del DBDD (es DBFNTX)
        // e quindi controlla esistenza file .NTX invece di .CDX
        IF dfAxsLoaded(cPath, cDriver)
           cDriver := dfAXSDriver()
        ENDIF

        cExt      := dfDbfExt( cDriver )
        lCompound := dfRddCanCompound( cDriver )

        IF dfRddFile( cPath +"DBDD" +cExt, cDriver )
           cNtx0 := cPath +"DBDD"
           cNtx1 := cPath +"DBDD1"
           cNtx2 := cPath +"DBDD2"
           cInd  := dfIndExt(cDriver)

           lMake := .T.
           DO CASE
              CASE lCreate

              CASE lCompound
                   lMake := !dfRddFile( cNtx0 +cInd, cDriver )

              OTHERWISE
                   lMake := !dfRddFile( cNtx1 +cInd, cDriver ) .OR.;
                            !dfRddFile( cNtx2 +cInd, cDriver )
           ENDCASE

           IF lMake
              IF lCompound // Delete the file before the open
                 FERASE( cNtx0 +cInd )
              ENDIF

              IF !dfUseFile( cPath +cFile +cExt )
                 RETURN .F.
              ENDIF
              dfUsrMsg( dfStdMsg(MSG_DBCFGOPE01) +" DBDD1" +cInd )

              cExp := "UPPER(dbdd->RecTyp+dbdd->File_name)+" +;
                      "STR(dbdd->NdxIncN,3)"

              IF lCompound
                 dfMakeInd( cExp, cNtx0,,,"DBDD1", .F.)
              ELSE
                 dfMakeInd( cExp, cNtx1 )
              ENDIF

              dfUsrMsg( dfStdMsg(MSG_DBCFGOPE01) +" DBDD2" +cInd )

              cExp := "UPPER(dbdd->RecTyp+dbdd->file_name+dbdd->field_name)"

              IF lCompound
                 dfMakeInd( cExp, cNtx0,,,"DBDD2", .F.)
              ELSE
                 dfMakeInd( cExp, cNtx2 )
              ENDIF

              dfUsrMsg( "" )

              CLOSE (cFile)
           ENDIF
           IF dfUseFile( cPath +cFile +cExt,,!dfSet(AI_NET))
              IF lCompound
                 SET INDEX TO (cNtx0)
              ELSE
                 SET INDEX TO (cNtx1), (cNtx2)
              ENDIF
              // DBFMDX dont' set the index !!!!!!
              SET ORDER TO 1
           ENDIF
        ELSE
           dbMsgErr( dfStdMsg( MSG_DBCFGOPE02 ) +" " +cPath +"DBDD" +cExt )
        ENDIF

   CASE cFile == "DBHLP"

        cPath := dbCfgPath( "HelpPath" )

        // Simone 18/12/2009
        // per uso ADS e CDX con XbaseAxsAutoUse=YES
        // altrimenti controlla con il driver del DBDD (es DBFNTX)
        // e quindi controlla esistenza file .NTX invece di .CDX
        IF dfAxsLoaded(cPath, cDriver)
           cDriver := dfAXSDriver()
        ENDIF

        cExt      := dfDbfExt( cDriver )
        lCompound := dfRddCanCompound( cDriver )

        IF dfRddFile( cPath +"DBHLP" +cExt, cDriver )
           cNtx1 := cPath +"DBHLP1"
           cInd := dfIndExt(cDriver)

           IF !dfRddFile( cNtx1 +cInd, cDriver ) .OR. lCreate
              IF !dfUseFile( cPath +cFile +cExt )
                 RETURN .F.
              ENDIF

              dfUsrMsg( dfStdMsg(MSG_DBCFGOPE01) +" DBHLP1" +cInd )

              dfMakeInd( "UPPER(dbHlp->RecId+dbHlp->EnvId+dbHlp->SubId+dbHlp->FieId)" , cNtx1 )

              dfUsrMsg( "" )

              CLOSE (cFile)
           ENDIF

           IF dfUseFile( cPath +cFile +cExt,,!dfSet(AI_NET) )
              SET INDEX TO (cNtx1)
              // DBFMDX dont' set the index !!!!!!
              SET ORDER TO 1
           ENDIF
        ELSE
           dbMsgErr( dfStdMsg( MSG_DBCFGOPE02 ) +" " +cPath +"DBHLP" +cExt )
        ENDIF

   CASE cFile == "DBTABD"

        cPath := dfTabPath()
        cName := dfSet(AI_TABNAME)
        cExt  := dfTabExt()

        IF dfRddFile( cPath +cName +cExt, dfTabRdd() )
           cNtx1 := cPath +dfSet(AI_TABINDEX1)
           cInd  := dfIndExt( dfTabRdd() )

           IF !dfRddFile( cNtx1 +cInd, dfTabRdd() ) .OR. lCreate
              IF !dfUseFile( cPath +cName +cExt,"dbtabd", ,dfTabRdd() )
                 RETURN .F.
              ENDIF

              IF dfSet(AI_INDEXPACK)
                 dfWaitOn( dfStdMsg(MSG_DDINDEX11) +"dbtabd" +dfStdMsg(MSG_DDINDEX12) )
                 PACK
                 dfWaitOff()
              ENDIF

              dfUsrMsg( dfStdMsg(MSG_DBCFGOPE01) +" " +dfSet(AI_TABINDEX1) +cInd )

              dfMakeInd( "UPPER(dbTabD->TabId+dbTabD->TabPrk+dbTabD->TabCode)", cNtx1 )

              dfUsrMsg( "" )

              CLOSE
           ENDIF

           IF dfUseFile( cPath +cName +cExt, "dbtabd", !dfSet(AI_NET) ,dfTabRdd() )
              SET INDEX TO (cNtx1)
              // DBFMDX dont' set the index !!!!!!
              SET ORDER TO 1
           ENDIF
        ELSE
           dbMsgErr( dfStdMsg( MSG_DBCFGOPE02 ) +" " +cPath +cName +cExt )
        ENDIF

   CASE cFile == "DBLOGIN"

        cPath := dfLoginPath()
        cExt  := dfLoginExt()

        IF dfRddFile( cPath +"DBLOGIN" +cExt, dfLoginRdd() )
           dfUseFile( cPath +cFile +cExt, "dblogin", !dfSet(AI_NET), dfLoginRdd() )
        ENDIF

   CASE cFile == "DBLKINF"

        IF EMPTY(dbCfgPath( "DBLKINFPath" )) 
           dbCfgPath( "DBLKINFPath", dbCfgPath( "dbddPath" ))
        ENDIF 

        cPath := dfLockInfoPath()
        cExt  := dfLockInfoExt()

        IF !dfRddFile( cPath +"DBLKINF" +cExt, dfLockInfoRdd() )
              DBCREATE( dbCfgPath( "DBLKINFPath" ) +"dbLkInf"   ,{ {"RECTYPE"  , "C",  1 ,0} ,;
                                                                   {"USER"     , "C", 20 ,0} ,;
                                                                   {"USERPROG" , "C",  4 ,0} ,;
                                                                   {"AZI"      , "C", 20, 0} ,;
                                                                   {"DBF"      , "C", 20, 0} ,;
                                                                   {"NUMREC"   , "N",  9, 0} ,;
                                                                   {"LOGDATE"  , "D",  8, 0} ,;
                                                                   {"LOGTIME"  , "C",  5, 0} ,;
                                                                   {"FREELOG"  , "C",100, 0} })

        ENDIF 

        IF dfRddFile( cPath +"DBLKINF" +cExt, dfLockInfoRdd() )
           cNtx1 := cPath + "DBLKINF1" 
           cInd  := dfIndExt( dfTabRdd() )

           IF !dfRddFile( cNtx1 +cInd, dfLockInfoRdd() ) .OR. lCreate
              IF !dfUseFile( cPath +"DBLKINF" +cExt,"DBLKINF", ,dfLockInfoRdd() )
                 RETURN .F.
              ENDIF
              dfWaitOn( dfStdMsg(MSG_DDINDEX11) +"DBLKINF" +dfStdMsg(MSG_DDINDEX12) )
              IF FILE(cNtx1+cInd)
                 FErase(cNtx1+cInd)
                 //SET INDEX TO (cNtx1)
              ENDIF 
              ZAP
              dfWaitOff()

              //IF dfSet(AI_INDEXPACK)
              //ENDIF

              dfUsrMsg( dfStdMsg(MSG_DBCFGOPE01) +" DBLKINF1"  +cInd )

              dfMakeInd( "DBLKINF->RECTYPE+DBLKINF->AZI+DBLKINF->DBF+STR(DBLKINF->NUMREC,9,0)", cNtx1 )
              //dfMakeInd( "RECTYPE+AZI+DBF+STR(NUMREC,9,0)", cNtx1 )

              dfUsrMsg( "" )

              CLOSE
           ENDIF

           IF EMPTY(SELECT("DBLKINF"))
              IF dfUseFile( cPath +cFile +cExt, "DBLKINF", , dfLockInfoRdd() ) 
                 dfWaitOn( dfStdMsg(MSG_DDINDEX11) +"DBLKINF" +dfStdMsg(MSG_DDINDEX12) )
                 SET INDEX TO (cNtx1)
                 //IF FILE(cNtx1+cInd)
                 //   FErase(cNtx1+cInd)
                 //ENDIF 
                 ZAP
                 dfWaitOff()
                 CLOSE
              ENDIF 
              IF dfUseFile( cPath +cFile +cExt, "DBLKINF", !dfSet(AI_NET), dfLockInfoRdd() ) 
                 SET INDEX TO (cNtx1)
                 // DBFMDX dont' set the index !!!!!!
                 SET ORDER TO 1
              ENDIF
           ENDIF
        ELSE
           dbMsgErr( dfStdMsg( MSG_DBCFGOPE02 ) +" " +cPath +"DBLKINF" +cExt )
        ENDIF


ENDCASE

RETURN DFISSELECT( cFile )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfTabRdd( cRdd )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC cTabRdd := NIL
DEFAULT cTabRdd   TO RDDSETDEFAULT()
IF cRdd!=NIL
   cTabRdd := cRdd
ENDIF

// Simone 18/12/2009
// per uso ADS e CDX con XbaseAxsAutoUse=YES
// altrimenti controlla con il driver del DBDD (es DBFNTX)
// e quindi controlla esistenza file .NTX invece di .CDX
IF dfAxsLoaded(dbCfgPath( "TabPath" ), cTabRdd)
   cTabRdd := dfAXSDriver()
ENDIF
RETURN cTabRdd

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfTabPath()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cPath := dbCfgPath( "TabPath" )
IF dfASDriver( dfTabRdd() )
   cPath := LEFT( cPath, LEN(cPath)-1 )           // Rimuovo lo slash \ finale
   IF RIGHT(cPath,1)#":" .AND. LEN(cPath)>1       // Se ho un path
      cPath += ":"                                   // Aggiungo i : finali
   ENDIF
ENDIF
RETURN cPath

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfTabExt()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN dfDbfExt(dfTabRdd())

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfTabOnAS( lAS )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lDriver

DEFAULT lAS TO .F.

lDriver := dfASDriver( dfTabRdd() )
IF lAS
   dfTabRdd( "WIN400" )
ENDIF

RETURN lDriver


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfLoginRdd( cRdd )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC cLoginRdd := NIL
DEFAULT cLoginRdd TO RDDSETDEFAULT()
IF cRdd!=NIL
   cLoginRdd := cRdd
ENDIF
// Simone 18/12/2009
// per uso ADS e CDX con XbaseAxsAutoUse=YES
// altrimenti controlla con il driver del DBDD (es DBFNTX)
// e quindi controlla esistenza file .NTX invece di .CDX
IF dfAxsLoaded(dbCfgPath( "dbLoginPath" ), cLoginRdd)
   cLoginRdd := dfAXSDriver()
ENDIF
RETURN cLoginRdd

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfLoginPath()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cPath := dbCfgPath( "dbLoginPath" )
IF dfASDriver( dfLoginRdd() )
   cPath := LEFT( cPath, LEN(cPath)-1 )           // Rimuovo lo slash \ finale
   IF RIGHT(cPath,1)#":" .AND. LEN(cPath)>1       // Se ho un path
      cPath += ":"                                   // Aggiungo i : finali
   ENDIF
ENDIF
RETURN cPath

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfLoginExt()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN dfDbfExt(dfLoginRdd())

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfLoginOnAS( lAS )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lDriver

DEFAULT lAS TO .F.

lDriver := dfASDriver( dfLoginRdd() )
IF lAS
   dfLoginRdd( "WIN400" )
ENDIF

RETURN lDriver


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
EXIT PROCEDURE EXITCfg() // chiude i file di configurazione
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
dbCfgClose( "dbdd" )    // dizionario
dbCfgClose( "dbhlp" )   // Help
dbCfgClose( "dbtabd" )  // tabelle
dbCfgClose( "dbLogin" ) // PASSWORD
RETURN
