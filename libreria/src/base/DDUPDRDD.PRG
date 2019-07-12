/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/
#include "common.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddUpdRdd( cRdd, aNoChg )                     // Setta Rdd
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aFile:={}

DEFAULT aNoChg TO {}

IF dbCfgOpen( "dbdd" )
   dbdd->(DFS(1,"DBF",.T.))
   WHILE !dbdd->(EOF())
      IF UPPER(ALLTRIM(DbDD->RecTyp)) != "DBF"
         EXIT
      ENDIF
      IF !ddFileIsTab() .AND. ;
         ASCAN(aNoChg,{|x|ALLTRIM(UPPER(x))==ALLTRIM(UPPER(Dbdd->File_name))})==0

         IF !(cRdd==NIL) .AND. UPPER(ALLTRIM(cRdd))!=UPPER(ALLTRIM(ddFileDriver()))
            AADD(aFile, DbDD->File_name)
            IF Dbdd->(DBRLOCK(RECNO()))
               dbDD->Field_name := cRdd
               Dbdd->(DBCOMMIT())
               Dbdd->(DBRUNLOCK(RECNO()))
            ENDIF
         ENDIF

      ENDIF
      DBDD->(DbSkip())
   ENDDO
ENDIF

RETURN aFile
