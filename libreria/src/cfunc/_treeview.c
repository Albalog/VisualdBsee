#include <windows.h>
#include <shlobj.h>

#include <xppdef.h>
#include <xpppar.h>
#include <xppcon.h>

//XPPRET XPPENTRY TVGETSELTEXT( XppParamList paramList ){
//   HWND hWnd = ( HWND ) _parnl( paramList, 1 );
//   HTREEITEM hItem = TreeView_GetSelection( hWnd );
//   TV_ITEM tvi;
//   BYTE buffer[ 100 ];
//   if( hItem )
//   {
//      tvi.mask       = TVIF_TEXT;
//      tvi.hItem      = hItem;
//      tvi.pszText    = ( char *)buffer;
//      tvi.cchTextMax = 100;
//      TreeView_GetItem( hWnd, &tvi );
//      _retc( paramList, tvi.pszText );
//   }
//   else
//      _retc( paramList, "" );
//}

// torna la posizione dell'item correntemente selezionato nel treeview 
XPPRET XPPENTRY TVGETSELRECT( XppParamList paramList ){
   HWND hWnd = ( HWND ) _parnl( paramList, 1 );
   HTREEITEM hItem = TreeView_GetSelection( hWnd );
   RECT prc;
   BOOL lAll= _parl(paramList, 2);
   BOOL lRet=FALSE;

   if( hItem )
   {
      lRet = TreeView_GetItemRect( hWnd, hItem, &prc, lAll );
      _retclen( paramList, (CHAR*) &prc, sizeof(prc) );
   }
   else
      _retc( paramList, "");
}

