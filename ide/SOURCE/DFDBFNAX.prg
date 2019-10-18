/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "dfMsg1.ch"
#include "Common.ch"
#include "dfAdsDbe.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDBFNTXAX( lMsg )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T.

DEFAULT lMsg TO .T.

IF !dfDbeLoad( ADSRDD, .F.)
   IF lMsg
      dfAlert( dfStdMsg1( MSG1_DFDBFNTX01 ) )
   ENDIF
   lRet := .F.
ENDIF

// IF !dfDbeLoad( "NTXDBE",.T.)
//    IF lMsg
//       dfAlert( dfStdMsg1( MSG1_DFDBFNTX02 ) )
//    ENDIF
//    lRet := .F.
// ENDIF
//
// IF !DbeBuild( "DBFNTX", "DBFDBE", "NTXDBE" )
//    IF lMsg
//       dfAlert( dfStdMsg1( MSG1_DFDBFNTX03 ) )
//    ENDIF
//    lRet := .F.
// ENDIF
//
// IF lRet
//    S2DbeLockSet("DBFNTXAX")
// ENDIF

RETURN lRet
