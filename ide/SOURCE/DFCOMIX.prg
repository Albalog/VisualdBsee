/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "dfMsg1.ch"
#include "Common.ch"
#include "dmlb.ch"
#include "cdxdbe.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfCOMIX( lMsg, lComp )
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

#ifdef _XBASE18_
DEFAULT lComp TO .F.
IF lComp
   // Imposta compatibilita COMIX (solo Xbase 1.8+)
   dbeInfo( COMPONENT_ORDER, CDXDBE_MODE, CDXDBE_COMIX )
ENDIF
#endif
 

IF !DbeBuild( "COMIX", "FOXDBE", "CDXDBE" )
   IF lMsg
      dfAlert( dfStdMsg1( MSG1_DFDBFCDX03 ) )
   ENDIF
   lRet := .F.
ENDIF

IF lRet
   S2DbeLockSet("COMIX")
ENDIF

RETURN lRet

//
// Use this if you have DBF+DBT and CDX index
//
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfComixDBT( lMsg, lComp )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T.

DEFAULT lMsg TO .T.

IF !dfDbeLoad( "DBFDBE", .T.)
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

#ifdef _XBASE18_
DEFAULT lComp TO .F.
IF lComp
   // Imposta compatibilita COMIX (solo Xbase 1.8+)
   dbeInfo( COMPONENT_ORDER, CDXDBE_MODE, CDXDBE_COMIX )
ENDIF
#endif

IF !DbeBuild( "COMIX", "DBFDBE", "CDXDBE" )
   IF lMsg
      dfAlert( dfStdMsg1( MSG1_DFDBFCDX03 ) )
   ENDIF
   lRet := .F.
ENDIF

IF lRet
   S2DbeLockSet("COMIX")
ENDIF
RETURN lRet
