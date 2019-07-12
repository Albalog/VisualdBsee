//*****************************************************************************
//Progetto       : dBsee 4.3
//Descrizione    : Funzioni di utilita' per FILE
//Programmatore  : Baccan Matteo
//*****************************************************************************

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfASOpenFile( aFile )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
dbCfgOpen( "dbdd" )

dbdd->(DBSEEK("DBF"))
WHILE UPPER(dbdd->RecTyp) == "DBF" .and. !dbdd->(eof())
   IF dbdd->file_typ = "1"  // table file don't need dbf structur as they are
      dbdd->(DBSKIP(1))     // stored in dbdd file
      LOOP
   ENDIF
   dbdd->(dfPushArea())

   IF dfASDriver( ddFileDriver() )
      dfUse( UPPER(ALLTRIM(dbdd->File_name)), NIL, aFile )
   ENDIF

   dbdd->(dfPopArea())
   dbdd->(DBSKIP(1))
ENDDO

IF dfTabOnAS();   dbCfgOpen( "DBTABD" );  ENDIF
IF dfLoginOnAS(); dbCfgOpen( "DBLOGIN" ); ENDIF

RETURN
