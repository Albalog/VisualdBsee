#include <windows.h>
//#include <commdlg.h>
#include <xppdef.h>
#include <xpppar.h>
#include <xppcon.h>

#define MAX_FILENAMELEN 2000

XPPRET XPPENTRY DFFILEDLG( XppParamList paramList ){

   HWND hWnd=0;
   LONG nParLen = 0;
   DWORD nFlags = 0;
   MomHandle hNew1 = NULL, hNew2 = NULL,
             hNew3 = NULL, hNew4 = NULL, hNew5 = NULL;
   OPENFILENAME psDlg;
   BOOL lSave = FALSE;
   char *cTitle = NULL;
   char *cPath = NULL;
   char *cFilter = NULL;
   char *cFile = NULL;

// FUNCTION _dfFileDlg(hWnd, cTitle, cPath, cFile, cFilter, nFlags, lSave)

   if( XPP_IS_NUM(_partype(paramList,1)) )
    hWnd = (HWND)_parnl( paramList, 1 );

   if( XPP_IS_CHAR(_partype(paramList,2)) ) {
    nParLen = _parclen( paramList, 2 ) + 1;
    hNew1 = _momAlloc( sizeof(char)* nParLen );
    cTitle = _momLock( hNew1 );
    _parc( cTitle, nParLen, paramList, 2 );
   }

   if( XPP_IS_CHAR(_partype(paramList,3)) ) {
    nParLen = _parclen( paramList, 3 ) + 1;
    hNew2 = _momAlloc( sizeof(char)* nParLen );
    cPath = _momLock( hNew2 );
    _parc( cPath, nParLen, paramList, 3 );
   }

   hNew3 = _momAlloc( sizeof(char)* MAX_FILENAMELEN );
   cFile = _momLock( hNew3 );
   *cFile = '\0';

   if( XPP_IS_CHAR(_partype(paramList,4)) ) {
    nParLen = _parclen( paramList, 4 ) + 1;
    if (nParLen < MAX_FILENAMELEN)
       _parc( cFile, nParLen, paramList, 4 );
   }

   if( XPP_IS_CHAR(_partype(paramList,5)) ) {
    nParLen = _parclen( paramList, 5 ) + 1;
    hNew4 = _momAlloc( sizeof(char)* nParLen );
    cFilter = _momLock( hNew4 );
    _parc( cFilter, nParLen, paramList, 5 );
   }

   if( XPP_IS_NUM(_partype(paramList,6)) )
    nFlags = (DWORD) _parnl( paramList, 6 );

   if( XPP_IS_LOGIC(_partype(paramList,7)) )
    lSave = _parl(paramList, 7);


   // hNew5 = _momAlloc( sizeof(char)*MAX_FILENAMELEN );
   // cFile = _momLock( hNew5 );
   // *cFile = '\0';

   psDlg.lStructSize       = sizeof(OPENFILENAME);
   psDlg.hwndOwner         = hWnd;
   psDlg.hInstance         = NULL;
   psDlg.lpstrFilter       = cFilter;
   psDlg.lpstrCustomFilter = NULL;
   psDlg.nMaxCustFilter    = 0;
   psDlg.nFilterIndex      = 1;
   psDlg.lpstrFile         = cFile;
   psDlg.nMaxFile          = MAX_FILENAMELEN;
   psDlg.lpstrFileTitle    = NULL;
   psDlg.nMaxFileTitle     = 0;
   psDlg.lpstrInitialDir   = cPath;
   psDlg.lpstrTitle        = cTitle;
   psDlg.Flags             = nFlags;
   psDlg.nFileOffset       = 0;
   psDlg.nFileExtension    = 0;
   psDlg.lpstrDefExt       = NULL;
   psDlg.lCustData         = 0;
   psDlg.lpfnHook          = NULL;
   psDlg.lpTemplateName    = NULL;

   if (lSave)
   {
      if( GetSaveFileName(&psDlg) )
         _retc(paramList, psDlg.lpstrFile );
      else
         _ret(paramList);
   }
   else
   {
      if( GetOpenFileName(&psDlg) )
         _retc(paramList, psDlg.lpstrFile );
      else
         _ret(paramList);
   }

   if (hNew1 != NULL) {
      _momUnlock(hNew1);
      _momFree(hNew1);
   }

   if (hNew2 != NULL) {
    _momUnlock(hNew2);
    _momFree(hNew2);
   }

   if (hNew3 != NULL) {
    _momUnlock(hNew3);
    _momFree(hNew3);
   }

   if (hNew4 != NULL) {
    _momUnlock(hNew4);
    _momFree(hNew4);
   }

   if (hNew5 != NULL) {
    _momUnlock(hNew5);
    _momFree(hNew5);
   }

}
