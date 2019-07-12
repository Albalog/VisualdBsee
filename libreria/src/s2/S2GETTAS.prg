#include "Dll.ch"
#include "Common.ch"

#define GW_HWNDFIRST        0
#define GW_HWNDLAST         1
#define GW_HWNDNEXT         2
#define GW_HWNDPREV         3
#define GW_OWNER            4
#define GW_CHILD            5
#define GW_MAX              5

// Torna un array con l'elenco delle finestre visibili
// L'array Š formato da Titolo finestra e handle della finestra
//
// cType : "A" (all) tutte le finestre
//         "V" (visible) solo le finestre visibili (DEFAULT)
//         "I" (invisible) solo le finestre non visibili

*******************************************************************************
FUNCTION S2GetTasklist(cType, hWnd)
*******************************************************************************
LOCAL aList:={}
LOCAL cWindowName
LOCAL nVisible
LOCAL nDll
LOCAL cGetWindowTextA
LOCAL cIsWindowVisible
LOCAL cGetWindow
LOCAL nLen := 0

DEFAULT hWnd TO 0
DEFAULT cType TO "V"

BEGIN SEQUENCE
   nDll := DllLoad("USER32.DLL")
   IF nDll == 0; BREAK; ENDIF

   hWnd := DllCall(nDll,DLL_STDCALL,"GetTopWindow", hWnd )
   IF hWnd == 0; BREAK; ENDIF

   cGetWindowTextA := DllPrepareCall(nDll, DLL_STDCALL, "GetWindowTextA")
   IF LEN(cGetWindowTextA) == 0; BREAK; ENDIF

   IF cType != "A"

      cIsWindowVisible := DllPrepareCall(nDll, DLL_STDCALL, "IsWindowVisible")
      IF LEN(cIsWindowVisible) == 0; BREAK; ENDIF

   ENDIF

   cGetWindow := DllPrepareCall(nDll, DLL_STDCALL, "GetWindow")
   IF LEN(cGetWindow) == 0; BREAK; ENDIF

   DO WHILE hWnd != 0
      cWindowname := SPACE(100)

      IF (nLen := DllExecuteCall(cGetWindowTextA, hWnd, @cWindowName, LEN(cWindowName))) != 0
         IF cType == "A"
            AADD(aList, {LEFT(cWindowname, nLen), hWnd})
         ELSE
            nVisible := DllExecuteCall(cIsWindowVisible, hWnd)
            IF (nVisible == 1 .AND. cType == "V") .OR. ;
               (nVisible != 1 .AND. cType == "I")

               AADD(aList, {LEFT(cWindowname, nLen), hWnd})
            ENDIF
         ENDIF
      ENDIF
      hWnd := DllExecuteCall(cGetWindow, hWnd, GW_HWNDNEXT )
   ENDDO
   DllUnLoad(nDll)

END SEQUENCE

RETURN aList

