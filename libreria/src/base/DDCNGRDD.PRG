//*****************************************************************************
//Progetto       : dBsee 4.3
//Descrizione    : Funzioni di utilita' per FILE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddCngRdd( cFile, cRdd )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cDriver := ""
IF dbCfgOpen( "dbdd" )
   dbdd->(DFS(1,"DBF"+ALLTRIM(UPPER(cFile))))
   IF !dbdd->(eof()) .AND. (UPPER(ALLTRIM(cFile))==UPPER(ALLTRIM(dbdd->File_name)))
      cDriver := ddFileDriver()    // RDD
      IF !(cRdd==NIL)
         IF dbdd->(DBRLOCK( RECNO() ))
            dbdd->Field_Name := cRdd
            dbdd->(DBCOMMIT())
            dbdd->(DBRUNLOCK( RECNO() ))
         ENDIF
      ENDIF
   ENDIF
ENDIF

RETURN cDriver
