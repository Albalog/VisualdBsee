/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "dfMsg1.ch"
#include "Common.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfWin400( lMsg )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T.

DEFAULT lMsg TO .T.

// IF !DbeLoad( "FOXDBE", .T.)
//    IF lMsg
//       dfAlert( dfStdMsg1( MSG1_DFDBFCDX01 ) )
//    ENDIF
//    lRet := .F.
// ENDIF
//
// IF !DbeLoad( "CDXDBE",.T.)
//    IF lMsg
//       dfAlert( dfStdMsg1( MSG1_DFDBFCDX02 ) )
//    ENDIF
//    lRet := .F.
// ENDIF
//
// IF !DbeBuild( "DBFCDX", "FOXDBE", "CDXDBE" )
//    IF lMsg
//       dfAlert( dfStdMsg1( MSG1_DFDBFCDX03 ) )
//    ENDIF
//    lRet := .F.
// ENDIF

lRet := .F.

// IF lRet 
//    S2DbeLockSet("WIN400")
// ENDIF

RETURN lRet
