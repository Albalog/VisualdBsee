/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "dfMsg1.ch"
#include "Common.ch"

#include "dfAdsDbe.ch"


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDBFCDXAX( lMsg )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T.

DEFAULT lMsg TO .T.

IF !dfDbeLoad( ADSRDD, .F.)
   IF lMsg
      dfAlert( dfStdMsg1( MSG1_DFDBFNTX01 ) )
   ENDIF
   lRet := .F.
ENDIF

// Imposta FPT e CDX
S2DbeInfo( ADSRDD, COMPONENT_DATA , ADSDBE_TBL_MODE, ADSDBE_CDX )
S2DbeInfo( ADSRDD, COMPONENT_ORDER, ADSDBE_TBL_MODE, ADSDBE_CDX )

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
