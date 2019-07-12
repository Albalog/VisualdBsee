#include "dll.ch"

//FUNCTION dfArgC(); RETURN 1
//FUNCTION dfArgV(n); RETURN IIF(n==0, dfExeName(), "")

STATIC aParam := NIL
//
// FUNCTION dfArgC()
//    LOCAL oErr := ErrorBlock({|o| break(o) })
//    LOCAL e
//    LOCAL nRet
//
//    BEGIN SEQUENCE
//       nRet := _ArgC()
//
//    RECOVER USING e
//       // Intercetto ERRORE: INTERNAL DATA STRUCTURES CORRUPTED
//       IF e:genCode == 41 .AND. e:subCode == 5 .AND. e:subSystem == "BASE"
//
//          nRet := 1
//       ELSE
//          EVAL(oErr, e)
//       ENDIF
//    END SEQUENCE
//    ErrorBlock(oErr)
//
// RETURN nRet
//
// FUNCTION dfArgV(nInd)
//    LOCAL oErr := ErrorBlock({|o| break(o) })
//    LOCAL e
//    LOCAL cRet
//
//    BEGIN SEQUENCE
//       cRet := _ArgV(nInd)
//
//    RECOVER USING e
//       // Intercetto ERRORE: INTERNAL DATA STRUCTURES CORRUPTED
//       IF e:genCode == 41 .AND. e:subCode == 5 .AND. e:subSystem == "BASE"
//          cRet := dfExeName()
//       ELSE
//          EVAL(oErr, e)
//       ENDIF
//    END SEQUENCE
//    ErrorBlock(oErr)
//
// RETURN cRet

FUNCTION dfArgC()
   InitParam()
RETURN LEN(aParam)

FUNCTION dfArgV( nInd )
   LOCAL cRet := ""

   InitParam()

   nInd++
   IF nInd >= 1 .AND. nInd <= LEN(aParam)
      cRet := aParam[nInd]
   ENDIF
RETURN cRet

STATIC PROCEDURE InitParam()
   LOCAL cCL

   IF aParam == NIL
      aParam := {}

      cCL := GetCommandLine()

      IF ! EMPTY(cCL)
         aParam := dfStr2Arr(ALLTRIM(cCL), " ")
      ENDIF

   ENDIF
RETURN

STATIC FUNCTION GetCommandLine()
   LOCAL nDll
   LOCAL cCall
   LOCAL nResult := NIL
   LOCAL cResult := NIL

   nDll := DllLoad( "KERNEL32.DLL" )

   IF nDll != 0
      cCall := DllPrepareCall( nDLL, DLL_STDCALL, "GetCommandLineA")

      IF LEN(cCall) != 0
         nResult := DLLExecuteCall( cCall, NIL )

         // Converte un puntatore a una stringa in una stringa xBase
         cResult := dfXbaseString(nResult)

      ENDIF

      DllUnLoad(nDll)
   ENDIF
RETURN cResult
