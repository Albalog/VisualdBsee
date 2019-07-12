// PROCEDURE MAIN()
// ? S2GetInetStatus()
// RETURN

#include "dll.ch"

#define INTERNET_CONNECTION_MODEM         0x01
#define INTERNET_CONNECTION_LAN           0x02
#define INTERNET_CONNECTION_PROXY         0x04
#define INTERNET_CONNECTION_MODEM_BUSY    0x08 // obsolete
#define INTERNET_RAS_INSTALLED            0x10
#define INTERNET_CONNECTION_OFFLINE       0x20
#define INTERNET_CONNECTION_CONFIGURED    0x40

DLLFUNCTION InternetGetConnectedState(@nStatus,nZero);
                USING STDCALL FROM WININET.DLL



// Controlla lo status della connessione ad internet
// Torna: 
//       {.F., -1}            errore in chiamata DLL 
//       {lConnesso, nStatus} 

FUNCTION S2GetInetStatus()
   LOCAL nStatus     := 0
   LOCAL lConnected  := .F. 
   LOCAL oErr        := ErrorBlock({|e| dfErrBreak(e) })

   BEGIN SEQUENCE

      lConnected := InternetGetConnectedState(@nStatus, 0) == 1

   RECOVER
      nStatus    := -1

   END SEQUENCE

   ErrorBlock(oErr)

RETURN {lConnected,nStatus}

// #define FUNCTIONNAME "InternetGetConnectedState"
// FUNCTION S2GetInetStatus()
//    LOCAL nStatus     := 0
//    LOCAL nConnected  := 0
//    LOCAL nDll        := 0
//    LOCAL aFuncs      := 0
//    LOCAL nRet        := -2
// 
//    BEGIN SEQUENCE
//       nDll := DllLoad("WININET.DLL")
// 
//       IF nDll == 0; BREAK; ENDIF
//       aFuncs := DllInfo(nDll, DLL_INFO_FUNCLIST)
// 
//       IF ASCAN(aFuncs, FUNCTIONNAME) == 0; BREAK; ENDIF
// 
//       nConnected := DllCall(nDll,DLL_STDCALL, FUNCTIONNAME, @nStatus, 0)
// 
//       nRet := IIF(nConnected > 0, nStatus, -1)
//    END SEQUENCE
// 
//    IF nDll > 0
//       DllUnLoad(nDll)
//    ENDIF
// 
//    // nConnected := InternetGetConnectedState(@nStatus,0)
// RETURN nRet

