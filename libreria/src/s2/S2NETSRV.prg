#include "dll.ch"

#define CNLEN 15 // Computer name lenght da "lmcons.h"

//function dfwinis95(); return "WINDOWS 95" $ UPPER(oS())
//function dfwinis98(); return "WINDOWS 98" $ UPPER(oS())


// Wrapper per funzione NetServerGetInfo
// Torna: NIL = errore generico
//        valore numerico= codice di errore di NetServerGetInfo
//        array = valori cercati
// Funziona solo in win95

FUNCTION S2WAPINetServerGetInfo(xServer)
   LOCAL aRet
   LOCAL xRet
   LOCAL nDll

   IF dfOSFamily() == "WIN9X" //dfWinIs95() .OR. dfWinIs98()
      xRet := S2WAPINetServerGetInfo95(xServer)
   ELSE
      // Funzione in C
      aRet := S2WAPINetServerGetInfoNT(xServer)

      // Converto da struttura SERVER_INFO_101 a SERVER_INFO_50
      IF ! EMPTY(aRet) .AND. VALTYPE(aRet) == "A"
         xRet := ARRAY(4)
         xRet[1] := aRet[2]
         xRet[2] := aRet[3]
         xRet[3] := aRet[4]
         xRet[4] := aRet[5]
      ENDIF
   ENDIF
RETURN xRet

// FUNCTION S2WAPINetServerGetInfoNT(xServer)
//    LOCAL nDll:=DllLoad("DBWINNT.DLL", "_DLL_")
//    LOCAL aRet
// 
//    IF nDll > 0
//       aRet := DLLCall(nDll, NIL, "_DLL_S2WAPINetServerGetInfoNT", xServer)
//       DllUnload(nDll)
//    ENDIF
// RETURN aRet

FUNCTION S2WAPINetServerGetInfo95(xServer)
   LOCAL nDll
   LOCAL cCall
   LOCAL nResult := -1, xRet
   LOCAL nSize, nSize2

   LOCAL cBuf
   nDll := DllLoad( "SVRAPI.DLL" )

   IF nDll != 0
      cCall := DllPrepareCall( nDLL, DLL_STDCALL, "NetServerGetInfo")

      IF LEN(cCall) != 0

         IF EMPTY(xServer)
            xServer := 0  // NULL
         ENDIF

         nSize := 0
         nResult := DLLExecuteCall( cCall, xServer, 50, 0, 0, @nSize )
         IF nSize > 0
            cBuf := SPACE(nSize)
            nSize2 := nSize
            nResult := DLLExecuteCall( cCall, xServer, 50, @cBuf, nSize, @nSize2 )

            IF nResult == 0

               xRet := {}

               nSize := AT(CHR(0), LEFT(cBuf, CNLEN+1))
               IF nSize == 0
                  nSize := CNLEN+1
               ENDIF

               AADD(xRet, LEFT(cBuf, nSize-1))    // Nome risorsa
               AADD(xRet, BIN2I(SUBSTR(cBuf, CNLEN+1 +1, 1))) // OS major number
               AADD(xRet, BIN2I(SUBSTR(cBuf, CNLEN+1 +2, 1))) // OS minor number
               AADD(xRet, BIN2L(SUBSTR(cBuf, CNLEN+1 +3, 4))) // attributes
            ELSE
               xRet := nResult
            ENDIF
         ELSE
            xRet := nResult
         ENDIF

      ENDIF

      DllUnLoad(nDll)
   ENDIF
RETURN xRet

