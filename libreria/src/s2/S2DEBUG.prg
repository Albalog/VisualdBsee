
#ifdef _S2DEBUGTIME_
   #define _S2DEBUG_
#endif

#ifdef _S2DEBUG_

#include "dfXBase.ch"
#include "Appevent.ch"
#include "Xbp.ch"
#include "Common.ch"
#INCLUDE "DLL.CH"

STATIC saDbgCall
STATIC lTryLoad := .F.

STATIC aTime := {}

PROC S2DebugTimePush()
   AADD(aTime, SECONDS())
RETURN

FUNC S2DebugTimePop()
   LOCAL n := ATAIL(aTime)
   ASIZE(aTime, LEN(aTime)-1)
RETURN SECONDS()-n

FUNCTION S2DebugOut(oObj, nEve, mp1, mp2)
   IF ! lTryLoad .AND. EMPTY(saDbgCall)
      PrepareDebugWin()
   ENDIF

   IF ! EMPTY(saDbgCall[1])
      DLLExecuteCall(saDbgCall[1], oObj, nEve, mp1, mp2)
   ENDIF
RETURN NIL

FUNCTION S2DebugOutString(cMsg, lForce, oObj)

   IF ! lTryLoad .AND. EMPTY(saDbgCall)
      PrepareDebugWin()
   ENDIF

   IF ! EMPTY(saDbgCall[2])
      DLLExecuteCall(saDbgCall[2], cMsg, lForce, oObj )
   ENDIF
RETURN NIL

STATIC PROC PrepareDebugWin()
   LOCAL nDLL

   saDbgCall := {NIL,NIL}

   nDll := DllLoad( "_DEBUG.DLL")
   IF nDll != 0
      saDbgCall[1] := DllPrepareCall( nDLL, NIL, "_DebugOut")
      saDbgCall[2] := DllPrepareCall( nDLL, NIL, "_DebugOutString")
   ENDIF

   lTryLoad := .T.
RETURN

#else

FUNCTION S2DebugOut(oXbp, nEvent, mp1, mp2)
RETURN NIL

FUNCTION S2DebugOutString(cStr)
RETURN NIL

#endif
