/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "dfMsg1.ch"
#include "Common.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDBFCDX( lMsg )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T.

DEFAULT lMsg TO .T.

IF !dfDbeLoad( "FOXDBE", .T.)
   IF lMsg
      dfAlert( dfStdMsg1( MSG1_DFDBFCDX01 ) )
   ENDIF
   lRet := .F.
ENDIF

IF !dfDbeLoad( "CDXDBE",.T.)
   IF lMsg
      dfAlert( dfStdMsg1( MSG1_DFDBFCDX02 ) )
   ENDIF
   lRet := .F.
ENDIF

IF !DbeBuild( "DBFCDX", "FOXDBE", "CDXDBE" )
   IF lMsg
      dfAlert( dfStdMsg1( MSG1_DFDBFCDX03 ) )
   ENDIF
   lRet := .F.
ENDIF

IF lRet
   S2DbeLockSet("DBFCDX")
ENDIF
RETURN lRet
