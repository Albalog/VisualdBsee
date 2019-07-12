#include "Dll.ch"
#include "common.ch"


// cMode validi "open", "print",  "explore"
// 
//returns a value greater than 32 if successful, or an error value that is less than or equal to 32 otherwise.
// The following table lists the error values. 
//0	The operating system is out of memory or resources.
//ERROR_FILE_NOT_FOUND	The specified file was not found.
//ERROR_PATH_NOT_FOUND	The specified path was not found.
//ERROR_BAD_FORMAT	The .exe file is invalid (non-Microsoft Win32 .exe or error in .exe image).
//SE_ERR_ACCESSDENIED	The operating system denied access to the specified file.
//SE_ERR_ASSOCINCOMPLETE	The file name association is incomplete or invalid.
//SE_ERR_DDEBUSY	The Dynamic Data Exchange (DDE) transaction could not be completed because other DDE transactions were being processed.
//SE_ERR_DDEFAIL	The DDE transaction failed.
//SE_ERR_DDETIMEOUT	The DDE transaction could not be completed because the request timed out.
//SE_ERR_DLLNOTFOUND	The specified DLL was not found.
//SE_ERR_FNF	The specified file was not found.
//SE_ERR_NOASSOC	There is no application associated with the given file name extension. This error will also be returned if you attempt to print a file that is not printable.
//SE_ERR_OOM	There was not enough memory to complete the operation.
//SE_ERR_PNF	The specified path was not found.
//SE_ERR_SHARE	A sharing violation occurred.

FUNCTION S2OpenRegisteredFile( cFile, cParam, cPath, cMode, nShowMode )
   LOCAL nHWND := AppDeskTop():getHWND()
   LOCAL nRet,oErr

   DEFAULT cMode     TO "open"
   DEFAULT cParam    TO ""
   DEFAULT cPath     TO  "C:\"
   DEFAULT nShowMode TO 1


   oErr := ERRORBLOCK({|e| dfErrBreak(e, NIL, .T.)})
   BEGIN SEQUENCE
      nRet := DllCall( "SHELL32.DLL", DLL_STDCALL, "ShellExecuteA", ;
                nHWND, cMode, cFile, cParam, cPath, nShowMode )
   RECOVER 
       nRet := 0
   END SEQUENCE
   ERRORBLOCK(oErr)

RETURN nRet


// Torna il nome di un exe associato ad un file
// es. S2FindExecutable("c:\pippo.html")
// o NIL su errore
FUNCTION S2FindExecutable(cFile, cPath)
   LOCAL cExe
   LOCAL oErr

   cExe := SPACE(1024)
   oErr := ERRORBLOCK({|e| dfErrBreak(e, NIL, .T.)})
   BEGIN SEQUENCE
   IF DllCall( "SHELL32.DLL", DLL_STDCALL, "FindExecutableA", ;
               cFile, cPath, @cEXE) > 32
      IF CHR(0) $ cExe
         cExe := LEFT(cExe, AT(CHR(0), cExe)-1)
      ENDIF
      IF EMPTY(cExe)
         cExe := NIL
      ENDIF
  ELSE
     cExe := NIL
  ENDIF
   RECOVER 
     cExe := NIL
   END SEQUENCE
   ERRORBLOCK(oErr)

RETURN cExe

// trova nome eseguibile dal registro sistema
// è diverso dalla s2findexecutable() ad esempio per i files JPG
// la s2findexecutable() torna c:\windows\system32\shimgvw.dll
// mentre questa torna rundll32.exe C:\WINDOWS\system32\shimgvw.dll,ImageView_Fullscreen %1
FUNCTION S2FindExecutableFromRegistry(cExt, cMode)
   LOCAL cRet := ""

   DEFAULT cMode TO "open"  // open, print, ecc

   IF EMPTY(cExt) .OR. ! VALTYPE(cExt) $ "CM"
      RETURN NIL
   ENDIF

   IF ! LEFT(cExt, 1)=="."
      cExt := "."+cExt
   ENDIF
   cExt := UPPER(ALLTRIM(cExt))

   cRet := dfQueryRegistry("HKCR", cExt)
   IF EMPTY(cRet) .OR. ! VALTYPE(cRet) $ "CM"
      RETURN NIL
   ENDIF

   cRet := dfQueryRegistry("HKCR", cRet+"\shell\"+cMode+"\command")
RETURN cRet

