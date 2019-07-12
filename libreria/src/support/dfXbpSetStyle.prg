#include "dll.ch"

// define per pushbutton
#define BS_MULTILINE 0x2000
#define BS_LEFT      0x0100
#define BS_RIGHT     0x0200
#define BS_CENTER    0x0300
#define BS_TOP       0x0400
#define BS_BOTTOM    0x0800
#define BS_VCENTER   0x0C00
#define BS_FLAT      0x00008000
#define GWL_STYLE -16


/*
 * Static Control Constants
 */
#define SS_LEFT             0x00000000
#define SS_CENTER           0x00000001
#define SS_RIGHT            0x00000002
#define SS_ICON             0x00000003
#define SS_BLACKRECT        0x00000004
#define SS_GRAYRECT         0x00000005
#define SS_WHITERECT        0x00000006
#define SS_BLACKFRAME       0x00000007
#define SS_GRAYFRAME        0x00000008
#define SS_WHITEFRAME       0x00000009
#define SS_USERITEM         0x0000000A
#define SS_SIMPLE           0x0000000B
#define SS_LEFTNOWORDWRAP   0x0000000C

#define SS_OWNERDRAW        0x0000000D
#define SS_BITMAP           0x0000000E
#define SS_ENHMETAFILE      0x0000000F
#define SS_ETCHEDHORZ       0x00000010
#define SS_ETCHEDVERT       0x00000011
#define SS_ETCHEDFRAME      0x00000012
#define SS_TYPEMASK         0x0000001F

#define SS_NOPREFIX         0x00000080 /* Don't do "&" character translation */

#define SS_NOTIFY           0x00000100
#define SS_CENTERIMAGE      0x00000200
#define SS_RIGHTJUST        0x00000400
#define SS_REALSIZEIMAGE    0x00000800
#define SS_SUNKEN           0x00001000
#define SS_ENDELLIPSIS      0x00004000
#define SS_PATHELLIPSIS     0x00008000
#define SS_WORDELLIPSIS     0x0000C000
#define SS_ELLIPSISMASK     0x0000C000


#define WS_OVERLAPPED       0x00000000
#define WS_POPUP            0x80000000
#define WS_CHILD            0x40000000
#define WS_MINIMIZE         0x20000000
#define WS_VISIBLE          0x10000000
#define WS_DISABLED         0x08000000
#define WS_CLIPSIBLINGS     0x04000000
#define WS_CLIPCHILDREN     0x02000000
#define WS_MAXIMIZE         0x01000000
#define WS_CAPTION          0x00C00000     /* WS_BORDER | WS_DLGFRAME  */
#define WS_BORDER           0x00800000
#define WS_DLGFRAME         0x00400000
#define WS_VSCROLL          0x00200000
#define WS_HSCROLL          0x00100000
#define WS_SYSMENU          0x00080000
#define WS_THICKFRAME       0x00040000
#define WS_GROUP            0x00020000
#define WS_TABSTOP          0x00010000

#define WS_MINIMIZEBOX      0x00020000
#define WS_MAXIMIZEBOX      0x00010000


#define WS_TILED            WS_OVERLAPPED
#define WS_ICONIC           WS_MINIMIZE
#define WS_SIZEBOX          WS_THICKFRAME
#define WS_TILEDWINDOW      WS_OVERLAPPEDWINDOW

/*
 * Common Window Styles
#define WS_OVERLAPPEDWINDOW (WS_OVERLAPPED     | \
                             WS_CAPTION        | \
                             WS_SYSMENU        | \
                             WS_THICKFRAME     | \
                             WS_MINIMIZEBOX    | \
                             WS_MAXIMIZEBOX)

#define WS_POPUPWINDOW      (WS_POPUP          | \
                             WS_BORDER         | \
                             WS_SYSMENU)

#define WS_CHILDWINDOW      (WS_CHILD)

 */
/*
 * Extended Window Styles
 */
#define WS_EX_DLGMODALFRAME     0x00000001
#define WS_EX_NOPARENTNOTIFY    0x00000004
#define WS_EX_TOPMOST           0x00000008
#define WS_EX_ACCEPTFILES       0x00000010
#define WS_EX_TRANSPARENT       0x00000020
//#if(WINVER >= 0x0400)
#define WS_EX_MDICHILD          0x00000040
#define WS_EX_TOOLWINDOW        0x00000080
#define WS_EX_WINDOWEDGE        0x00000100
#define WS_EX_CLIENTEDGE        0x00000200
#define WS_EX_CONTEXTHELP       0x00000400

#define WS_EX_RIGHT             0x00001000
#define WS_EX_LEFT              0x00000000
#define WS_EX_RTLREADING        0x00002000
#define WS_EX_LTRREADING        0x00000000
#define WS_EX_LEFTSCROLLBAR     0x00004000
#define WS_EX_RIGHTSCROLLBAR    0x00000000

#define WS_EX_CONTROLPARENT     0x00010000
#define WS_EX_STATICEDGE        0x00020000
#define WS_EX_APPWINDOW         0x00040000


#define WS_EX_OVERLAPPEDWINDOW  (WS_EX_WINDOWEDGE + WS_EX_CLIENTEDGE)
#define WS_EX_PALETTEWINDOW     (WS_EX_WINDOWEDGE + WS_EX_TOOLWINDOW + WS_EX_TOPMOST)

//#endif /* WINVER >= 0x0400 */

DLLFUNCTION GetWindowLongA( nHwnd,nIndex )     USING STDCALL FROM USER32.DLL
DLLFUNCTION SetWindowLongA( nHwnd,nIndex,nNewIndex )    USING STDCALL FROM USER32.DLL

FUNCTION dfXBPSetStyle(oXbp, n, lSet)
   LOCAL nStyle:= 0

   IF VALTYPE(oXbp) != "O"
      RETURN .F.
   ENDIF

   // legge stile corrente del XBP
   nStyle := GetWindowLongA(oXbp:GetHwnd(), GWL_STYLE)

   IF lSet  // Imposta l'attributo
      nStyle := dfOR(nStyle, n)
   ELSE     // toglie l'attributo
      nStyle := dfAnd( nStyle, dfXOR(0xFFFFFFFF, n))
   ENDIF

   // imposta nuovo stile
   n := SetWindowLongA(oXbp:GetHwnd(), GWL_STYLE, nStyle)

RETURN n != 0
