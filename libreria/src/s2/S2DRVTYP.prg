#include "dfXBase.ch"
#include "dll.ch"

// Wrapper per funzione GetDriveType
FUNCTION S2WAPIGetDriveType(cVolRoot)
   LOCAL nDll, cCall
   LOCAL nResult := S2WAPIGDT_ERROR

   nDll := DllLoad( "KERNEL32.DLL")
   IF nDll != 0
      cCall := DllPrepareCall( nDLL, DLL_STDCALL, "GetDriveTypeA")
      IF LEN( cCall) != 0
         nResult := DLLExecuteCall( cCall, cVolRoot )
      ENDIF
   ENDIF
RETURN nResult

