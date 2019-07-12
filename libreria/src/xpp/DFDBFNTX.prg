/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "dfMsg1.ch"
#include "Common.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDBFNTX( lMsg )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T.

DEFAULT lMsg TO .T.

IF !dfDbeLoad( "DBFDBE", .T.)
   IF lMsg
      dfAlert( dfStdMsg1( MSG1_DFDBFNTX01 ) )
   ENDIF
   lRet := .F.
ENDIF

IF !dfDbeLoad( "NTXDBE",.T.)
   IF lMsg
      dfAlert( dfStdMsg1( MSG1_DFDBFNTX02 ) )
   ENDIF
   lRet := .F.
ENDIF

IF !DbeBuild( "DBFNTX", "DBFDBE", "NTXDBE" )
   IF lMsg
      dfAlert( dfStdMsg1( MSG1_DFDBFNTX03 ) )
   ENDIF
   lRet := .F.
ENDIF

IF lRet
   S2DbeLockSet("DBFNTX")
ENDIF

RETURN lRet
