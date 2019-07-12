/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/
#include "Common.ch"
#include "dfnet.ch"
#include "dfset.ch"
#include "dfstd.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfUserLog( cMsg )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC lRecourse := .F.
LOCAL cPath, cFile, cAlias

IF !lRecourse .AND. (dfSet(AI_ENABLEUSERTRACE) .OR. dfSet(AI_LOGUSEDFORM))
   lRecourse := .T.
   DEFAULT cMsg TO ""

   cAlias := ALIAS()

   cFile := dbCfgPath("dbddpath") +"DBLOG"

   IF !dfRddFile( cFile +dfDbfExt( RDDSETDEFAULT() ) )

      // SD 22/05/2002 
      // modificato altrimenti il file DBLOG
      // viene creato nella cartella sbagliata 
      // (cartella che contiene EXE)
      // ma poi viene aperto nella cartella che contiene il DBDD
      // quindi il DBLOG non esiste e da errore!

      // DBCREATE( "DBLOG", {;
      DBCREATE( cFile, {;
                         {"DbaDt"  , "D",  8, 0 },;
                         {"DbaOra" , "C",  8, 0 },;
                         {"DbaUser", "C", 30, 0 },;
                         {"DbaOp"  , "C", 80, 0 },;
                         {"DbaWs"  , "C", 20, 0 } ;
                         })
   ENDIF
   IF DFISSELECT( "DBLOG" )            .OR. ;
      dfUseFile( cFile, "DBLOG", .F. )
      IF DBLOG->(dfNet( NET_APPEND ))

         DBLOG->DbaDt   := DATE()
         DBLOG->DbaOra  := TIME()
         DBLOG->DbaUser := dfUserName()
         DBLOG->DbaOp   := cMsg
         DBLOG->DbaWs   := dfStationID()

         DBLOG->(DBCOMMIT())
         DBLOG->(dfNet( NET_RECORDUNLOCK ))
      ENDIF
   ENDIF

   IF !EMPTY( cAlias )
      SELECT (cAlias)
   ENDIF

   lRecourse := .F.
ENDIF

RETURN
