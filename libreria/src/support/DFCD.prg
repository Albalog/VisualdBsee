// Gestione directory

#include "Dll.ch"

//Modifica del 30/11/2006 Luca
FUNCTION dfMd(cDir)

   cDir := dfPathChk(cDir)                      // Normalizza il PATH
                                                // (con "\" finale)

   IF LEN(cDir) > 3                             // Se non e' la dir. radice
      cDir := LEFT(cDir, LEN(cDir) - 1)         // Toglie "\" finale
   ENDIF

RETURN _dfMd(cDir)


FUNCTION _dfMD(cDir)

   LOCAL nRet := -1
   LOCAL nDll
   LOCAL cCall
   LOCAL lErr
   LOCAL nInd
   LOCAL cDirectory
   LOCAL aPath
   LOCAL nAt
   LOCAL nPos

   BEGIN SEQUENCE

      IF EMPTY(cDir); BREAK; ENDIF

      // simone 29/11/06
      // mantis 0001175: supportare percorsi UNC
      // Gestione percorsi UNC
      cDir   := dfPathChk(cDir)
      aPath  := dfFNameSplit(cDir)

      nDll   := DllLoad( "KERNEL32.DLL" )

      IF nDll == 0; BREAK; ENDIF

      cCall := DllPrepareCall( nDll, DLL_STDCALL, "CreateDirectoryA")

      IF LEN(cCall) == 0; BREAK; ENDIF

      // Cerca di creare tutto l'albero delle directory

      // simone 29/11/06
      // mantis 0001175: supportare percorsi UNC
      nInd := 0
      lErr := .F.
      cDirectory := aPath[1]

      nPos := 1 
      nAt  := 0
      DO WHILE ! lErr  .AND. nAt <= LEN(aPath[2])

         nAt := AT("\", aPath[2], nPos)
         IF nAt == 0
            cDirectory += SUBSTR(aPath[2], nPos)
            nAT := LEN(aPath[2])+1
         ELSE
            nAt++
            cDirectory += SUBSTR(aPath[2], nPos, nAt-nPos)
            nPos := nAt
         ENDIF

         IF ! dfChkDir(cDirectory)
            lErr := (DLLExecuteCall( cCall, cDirectory, 0 ) == 0)
         ENDIF
      ENDDO

      IF lErr

         // Errore, non Š riuscito a creare tutto l'albero
         nRet := SysGetLastError()
         BREAK

      ENDIF

      nRet := 0

   END SEQUENCE

   IF ! EMPTY(nDll)
      DllUnLoad(nDll)
   ENDIF

RETURN nRet

// STATIC FUNCTION __MD(cDir)
//    LOCAL nDll
//    LOCAL cCall
//    LOCAL nResult := -1
//
//    nDll := DllLoad( "KERNEL32.DLL" )
//
//    IF nDll != 0
//       cCall := DllPrepareCall( nDLL, DLL_STDCALL, "CreateDirectoryA")
//
//       IF LEN(cCall) != 0
//          nResult := DLLExecuteCall( cCall, cDir, NIL )
//
//          // nResult := DLLCall( nDll, DLL_STDCALL, "CreateDirectoryA", cDir, NIL )
//
//          IF nResult == 0
//             // Errore
//             nResult := SysGetLastError()
//          ELSE
//             // OK
//             nResult := 0
//          ENDIF
//       ENDIF
//
//       DllUnLoad(nDll)
//    ENDIF
// RETURN nResult

FUNCTION dfRD(cDir)
   LOCAL nDll
   LOCAL cCall
   LOCAL nResult := -1

   nDll := DllLoad( "KERNEL32.DLL" )

   IF nDll != 0
      cCall := DllPrepareCall( nDLL, DLL_STDCALL, "RemoveDirectoryA")

      IF LEN(cCall) != 0
         nResult := DLLExecuteCall( cCall, cDir )

         // nResult := DLLCall( nDll, DLL_STDCALL, "RemoveDirectoryA", cDir )

         IF nResult == 0
            // Errore
            nResult := SysGetLastError()
         ELSE
            // OK
            nResult := 0
         ENDIF
      ENDIF

      DllUnLoad(nDll)
   ENDIF
RETURN nResult

FUNCTION dfCD(cDir)
   LOCAL nDll
   LOCAL cCall
   LOCAL nResult := -1

   nDll := DllLoad( "KERNEL32.DLL" )

   IF nDll != 0
      cCall := DllPrepareCall( nDLL, DLL_STDCALL, "SetCurrentDirectoryA")

      IF LEN(cCall) != 0
         nResult := DLLExecuteCall( cCall, cDir )

         // nResult := DLLCall( nDll, DLL_STDCALL, "SetCurrentDirectoryA", cDir )

         IF nResult == 0
            // Errore
            nResult := SysGetLastError()
         ELSE
            // OK
            nResult := 0
         ENDIF
      ENDIF

      DllUnLoad(nDll)
   ENDIF
RETURN nResult

/*
 * SysGetLastError() => nError
 * retrieve the last code of the last occured system error
 */
STATIC FUNCTION SysGetLastError()
/*
 * the shortest notation is helpful if you just want to rename a function
 * but keep the interface
 */

RETURN DLLCall("KERNEL32.DLL", DLL_STDCALL, "GetLastError")


