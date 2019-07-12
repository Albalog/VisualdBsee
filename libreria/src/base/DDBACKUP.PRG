//*****************************************************************************
//Progetto       : dBsee 4.3
//Descrizione    : Funzioni di utilita' per FILE
//Programmatore  : Baccan Matteo
//*****************************************************************************

// Mancano EXE, dbstart.ini, ini vari e
// file vari specificti dall'utente
// Parametri forse da aggiungere : file da aggiungere, file da levare
// check del path, autodetect del compressore

#include "Common.ch"
#include "FileIO.ch"
#include "dfBackup.ch"
#include "dfIndex.ch"
#include "dfSet.ch"
#include "dfStd.ch"

#define  DDBACKUP_NAME "DDBACKUP"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddBackup( nPacker, cPath, cBackupName ) // Nome del file da aprire
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aBackup := {}, lRet := .T., cFile, cDbf, cTemp, nHandle, cExt, cSwap

DEFAULT nPacker     TO DDBKP_PKZIP
DEFAULT cBackupName TO DDBACKUP_NAME
IF EMPTY cPath ASSIGN "A:\"

cPath := dfPathChk(cPath)

DBCOMMITALL()

IF !dbCfgOpen( "dbDD" )         // Open DBDD
   RETURN .F.
ENDIF

// File di sistema
cExt := dfDbfExt(RDDSETDEFAULT())
AADD( aBackup, dbCfgPath( "dbddPath"    ) +"dbdd"            +cExt )
AADD( aBackup, dbCfgPath( "HelpPath"    ) +"dbHlp"           +cExt )
AADD( aBackup, dbCfgPath( "TabPath"     ) +dfSet(AI_TABNAME) +cExt )
AADD( aBackup, dbCfgPath( "dbLoginPath" ) +"dbLogin"         +cExt )

DBDD->(DBSEEK("DBF"))
WHILE !DBDD->(EOF()) .AND. UPPER(DBDD->RECTYP)=="DBF"
   cDbf := ddFileName()
   IF !ddFileIsTab()
      IF FILE( (cFile := ddFilePath()+cDbf+dfDbfExt(ddFileDriver())) )
         AADD( aBackup, cFile )
      ENDIF
      IF FILE( (cFile := ddFilePath()+cDbf+dfMemoExt(ddFileDriver())) )
         AADD( aBackup, cFile )
      ENDIF
      IF !(dfMemoExt(ddFileDriver())==".DBT") .AND.;
         FILE( (cFile := ddFilePath()+cDbf+".DBT") )
         AADD( aBackup, cFile )
      ENDIF
   ENDIF
   DBDD->(DBSKIP())
ENDDO
CLOSE DATABASES

nHandle := dfFileTemp( @cTemp )
AEVAL( aBackup, {|cSub|FWRITE(nHandle,cSub+CRLF)} )
FCLOSE( nHandle )

cSwap := cPath +cBackupName
FERASE( cSwap+".*" )

DO CASE
   CASE nPacker==DDBKP_PKZIP
        FERASE( cSwap+".ZIP" )
        cSwap := "PKZIP -ex -& " +cSwap +" @" +cTemp

   CASE nPacker==DDBKP_ARJ
        FERASE( cSwap+".ARJ" )
        cSwap := "ARJ a -vva   " +cSwap +" !" +cTemp

   CASE nPacker==DDBKP_RAR
        FERASE( cSwap+".RAR" )
        cSwap := "RAR a -s -v  " +cSwap +" @" +cTemp
ENDCASE
dfSwap(cSwap)

FERASE( cTemp )

RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddRestore( nPacker, cPath, cBackupName ) // Nome del file da aprire
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T., cSwap

DEFAULT nPacker     TO DDBKP_PKZIP
IF EMPTY cPath ASSIGN "A:\"
DEFAULT cBackupName TO DDBACKUP_NAME

cPath := dfPathChk(cPath)

CLOSE DATABASES

cSwap := " " +cPath +cBackupName
DO CASE
   CASE nPacker==DDBKP_PKZIP ;cSwap := "PKUNZIP -o    " +cSwap
   CASE nPacker==DDBKP_ARJ   ;cSwap := "ARJ x -vva -y " +cSwap
   CASE nPacker==DDBKP_RAR   ;cSwap := "RAR x -v -o+  " +cSwap
ENDCASE
dfSwap(cSwap)

ddIndexSys( NTX_DBDD ) // Ricostruisce in DBDD
ddIndex( IDX_REINDEX ) // Ricostruisce tutti gli indici

RETURN lRet
