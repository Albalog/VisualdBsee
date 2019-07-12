//
//
//     IF ChkPrevApp("XbpDialog")
//       QUIT
//     ENDIF
//
//
// Then add this section to your code...
//
//
// DLLFUNCTION GetClassNameA( nHwnd, @cBuf, nBufLen ) USING STDCALL FROM USER32.DLL
// Thats how to use GetClassNameA (the return value is the lenght of the string
// returned in cClassName
//
// cClassName := SPACE(250)
// ? GetClassNameA( oWin:GetHWND(), @cClassName, 250 )
// ? cClassName

// ----------------------------------------------------------

//    ChkPrevApp, coded in Xbase++
//
//    The first and only parameter you have to pass is the ClassName of the
//    top level window of your app.
//
//    For a XbpDialog() window this is "XbpDialog", for a XbpCrt() object,
//    it is "XbpPmtClass".
//
//    If your app has no window...well, then you have to look for a different way,
//    or create an "invisible" main window.

// ----------------------------------------------------------

#include "dll.ch"

/*
 * ShowWindow() Commands, from WINUSER.H
 */
#define SW_HIDE             0
#define SW_SHOWNORMAL       1
#define SW_NORMAL           1
#define SW_SHOWMINIMIZED    2
#define SW_SHOWMAXIMIZED    3
#define SW_MAXIMIZE         3
#define SW_SHOWNOACTIVATE   4
#define SW_SHOW             5
#define SW_MINIMIZE         6
#define SW_SHOWMINNOACTIVE  7
#define SW_SHOWNA           8
#define SW_RESTORE          9
#define SW_SHOWDEFAULT      10
#define SW_MAX              10

//DLLFUNCTION FindWindowA( @ClassName, @WinName ) USING STDCALL FROM USER32.DLL
DLLFUNCTION FindWindowA( @ClassName, WinName )  USING STDCALL FROM USER32.DLL
DLLFUNCTION GetForegroundWindow()               USING STDCALL FROM USER32.DLL
DLLFUNCTION IsIconic( nHwnd )                   USING STDCALL FROM USER32.DLL
DLLFUNCTION GetLastActivePopup( nHwnd )         USING STDCALL FROM USER32.DLL
DLLFUNCTION ShowWindow( nHwnd, nCmdShow )       USING STDCALL FROM USER32.DLL
DLLFUNCTION BringWindowToTop( nHwnd )           USING STDCALL FROM USER32.DLL
DLLFUNCTION SetForegroundWindow( nHwnd )        USING STDCALL FROM USER32.DLL
DLLFUNCTION GetWindowThreadProcessId( nForgroundHwnd, @nRetProcId ) USING STDCALL FROM USER32.DLL

// FUNCTION GetClassName(hWnd, cName)
//    LOCAL xRet
//    LOCAL cBuff := SPACE(100)
//    LOCAL cFName := "GetClassName"
//    xRet := DllCall("USER32.DLL", DLL_STDCALL, cFName, hWnd, @cBuff, 100)
//    cName := cBuff
// RETURN xRet


FUNCTION S2PrevWindowFind( cClass, cWinTitle )
   LOCAL lRet := .F.
   LOCAL nHwndFind

   IF EMPTY(cWinTitle)
      cWinTitle := CHR(0)
   ENDIF

   // Until now I haven't figured out why the second Parameter of FindWindowA()
   // does not work as expected, maybe someone else can find it out...
   // (is this a known bug in the WIN32 API?)
   nHwndFind := FindWindowA( @cClass, 0) //cWinTitle )
RETURN nHWndFind

FUNCTION S2PrevWindowShow(nHWndFind)
   LOCAL lRet := .F.
   LOCAL nHwndForeground, nForegroundId
   LOCAL nFindId, nHwndLast

   nHwndForeground := GetForegroundWindow()
   nForeGroundId   := GetWindowThreadProcessId( nHwndForeground, 0 )
   nFindId         := GetWindowThreadProcessId( nHwndFind, 0 )
   IF nForeGroundId != nFindId .OR. IsIconic( nHwndFind ) # 0
      nHwndLast := GetLastActivePopup( nHwndFind )
      IF IsIconic( nHwndLast ) = 0
         ShowWindow( nHwndLast, SW_RESTORE )
      ENDIF
      BringWindowToTop( nHwndLast )
      SetForegroundWindow( nHwndLast )
      lRet := .T.
   ENDIF
RETURN lRet
