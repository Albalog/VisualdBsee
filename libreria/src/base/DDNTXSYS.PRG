//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per FILE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
#include "dfStd.ch"
#include "dfSet.ch"
#include "dfMsg.ch"
#include "dfmsg1.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE ddIndexSys( nFile ) // ricostruzione indici file di sistema
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lOpen
LOCAL nStyle

DEFAULT nFile TO NTX_DBDD +NTX_DBHLP +NTX_DBTABD

nStyle := dfSet(AI_XBASEINDEXWAITSTYLE)

/////////////////////////////////////////////////////
//Mantis 2112
//Da runtime errore su Win98
IF dfWinIs98() .AND. nStyle == AI_INDEXWAITSTYLE_FANCY
   nStyle     :=  0
ENDIF 
/////////////////////////////////////////////////////

DO CASE
   CASE nStyle == AI_INDEXWAITSTYLE_NONE
     // niente!

   CASE nStyle == AI_INDEXWAITSTYLE_FANCY
     VDBWaitInit()
     VDBWaitOn("", dfStdMsg1(MSG1_DFWAIT01), NIL, .T.)

   OTHERWISE
     dbFrameOn( (MAXROW()/2-2), 15, (MAXROW()/2+2), 65, dfStdMsg(MSG_NTXSYS01) )
ENDCASE
 

IF dfAnd( nFile, NTX_DBDD )#0
   lOpen := DFISSELECT("DBDD")
   dbCfgClose("DBDD")

   DO CASE
      CASE nStyle == AI_INDEXWAITSTYLE_NONE
        // niente!

      CASE nStyle == AI_INDEXWAITSTYLE_FANCY
        VDBWaitUpd(dfStdMsg(MSG_NTXSYS03))
      OTHERWISE
        dbFrameDis( dfStdMsg(MSG_NTXSYS03) )
   ENDCASE

   dbCfgOpen("DBDD",.T.)
   IF !lOpen; dbCfgClose("DBDD"); ENDIF

   DO CASE
      CASE nStyle == AI_INDEXWAITSTYLE_NONE
        // niente!

      CASE nStyle == AI_INDEXWAITSTYLE_FANCY

      OTHERWISE
         dbFrameDis( "" )
   ENDCASE
ENDIF

IF dfAnd( nFile, NTX_DBHLP )#0
   lOpen := DFISSELECT("DBHLP")
   dbCfgClose("DBHLP")

   DO CASE
      CASE nStyle == AI_INDEXWAITSTYLE_NONE
        // niente!

      CASE nStyle == AI_INDEXWAITSTYLE_FANCY
        VDBWaitUpd(dfStdMsg(MSG_NTXSYS04))

      OTHERWISE
         dbFrameDis( dfStdMsg(MSG_NTXSYS04) )
   ENDCASE
   dbCfgOpen("DBHLP",.T.)
   IF !lOpen; dbCfgClose("DBHLP"); ENDIF
   DO CASE
      CASE nStyle == AI_INDEXWAITSTYLE_FANCY

      OTHERWISE
         dbFrameDis( "" )
   ENDCASE
ENDIF

IF dfAnd( nFile, NTX_DBTABD )#0
   IF dfRddFile( dfTabPath() +dfSet(AI_TABNAME) +dfTabExt(), dfTabRdd() )
      lOpen := DFISSELECT("DBTABD")
      dbCfgClose("DBTABD")
      DO CASE
         CASE nStyle == AI_INDEXWAITSTYLE_NONE
           // niente!

         CASE nStyle == AI_INDEXWAITSTYLE_FANCY

         OTHERWISE
            dbFrameDis( dfStdMsg(MSG_NTXSYS05) )
      ENDCASE
      dbCfgOpen("DBTABD",.T.)
      IF !lOpen; dbCfgClose("DBTABD"); ENDIF
      DO CASE
         CASE nStyle == AI_INDEXWAITSTYLE_NONE
           // niente!

         CASE nStyle == AI_INDEXWAITSTYLE_FANCY
            VDBWaitUpd(dfStdMsg(MSG_NTXSYS05))

         OTHERWISE
            dbFrameDis( "" )
      ENDCASE
   ENDIF
ENDIF

DO CASE
   CASE nStyle == AI_INDEXWAITSTYLE_NONE
     // niente!

   CASE nStyle == AI_INDEXWAITSTYLE_FANCY
      VDBWaitOff()

   OTHERWISE
      dbFrameOff()
ENDCASE


RETURN
