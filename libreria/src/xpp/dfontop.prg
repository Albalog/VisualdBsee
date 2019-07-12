#include "common.ch"
#include "appevent.ch"
#include "xbp.ch"

/*    from WINUSER.H            */
#define HWND_TOP            0
#define HWND_BOTTOM         1
#define HWND_TOPMOST        -1
#define HWND_NOTOPMOST      -2


#define SWP_NOSIZE          1
#define SWP_NOMOVE          2
#define SWP_NOZORDER        4
#define SWP_NOREDRAW        8
#define SWP_NOACTIVATE      10
#define SWP_FRAMECHANGED    20  /* The frame changed: send WM_NCCALCSIZE */
#define SWP_SHOWWINDOW      40
#define SWP_HIDEWINDOW      80
#define SWP_NOCOPYBITS      100
#define SWP_NOOWNERZORDER   200  /* Don't do owner Z ordering */
#define SWP_NOSENDCHANGING  400  /* Don't send WM_WINDOWPOSCHANGING */


// Imposta l'XBP passato (generalmente un XbpDialog) 
// come SEMPRE IN PRIMO PIANO
// Deve essere chiamata dopo il CREATE() dell'oggetto
FUNCTION dfSetXbpOnTop( oDlg )
//   LOCAL aSize := oDlg:currentSize()
//   LOCAL aPos  := oDlg:currentPos()
   LOCAL xRet
   xRet := SetWindowPos( oDlg:getHWND(), HWND_TOPMOST,;
                           0, 0, 0, 0,;
                           SWP_NOSIZE + SWP_NOMOVE + SWP_SHOWWINDOW        ;
                           )
   oDlg:invalidateRect()
RETURN xRet


STATIC FUNCTION SetWindowPos( hWND, nWhat, nX, nY, nWidth, nHeight, uFlag)
   LOCAL nDll := DllLoad( "USER32.DLL")
   LOCAL xRet := DllCall( nDll, 32, "SetWindowPos",                ;
                           hWND, nWhat, nX, nY, nWidth, nHeight, uFlag)
   DllUnLoad(nDll)
RETURN xRet
