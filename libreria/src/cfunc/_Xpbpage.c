
/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function for Alaska Xbase++
Programmer  : Baccan Matteo
******************************************************************************/

#include <windows.h>
#include <xppdef.h>
#include <xpppar.h>
#include <xppcon.h>

XPPRET XPPENTRY DFXPPPAGESETUP( XppParamList paramList ){

   // Initialize the PAGESETUPDLG structure.
   HWND hWnd=0;
   PAGESETUPDLG psDlg;
   //int wMode = IDM_STANDARD;
   psDlg.lStructSize = sizeof (PAGESETUPDLG);

   if( PCOUNT(paramList)>=1 && XPP_IS_NUM(_partype(paramList,1)) )
      hWnd = (HWND)_parnl( paramList, 1 );
   psDlg.hwndOwner = hWnd;

   psDlg.hDevMode = (HANDLE)NULL;
   psDlg.hDevNames = (HANDLE)NULL;
   //psDlg.hInstance = (HANDLE)hInst;
   psDlg.hInstance = (HANDLE)NULL;
   psDlg.lCustData = (LPARAM)NULL;
   psDlg.hPageSetupTemplate = (HGLOBAL)NULL;
   psDlg.Flags = PSD_DEFAULTMINMARGINS|
                 PSD_INHUNDREDTHSOFMILLIMETERS;

   //switch (wMode)
   //{
      //case IDM_STANDARD:
         psDlg.lpfnPageSetupHook       = (LPPAGESETUPHOOK)(FARPROC)NULL;
         psDlg.lpPageSetupTemplateName = (LPTSTR)NULL;
         psDlg.lpfnPagePaintHook       = (LPPAGEPAINTHOOK)(FARPROC)NULL;
      //break;

      //case IDM_HOOK:
         //psDlg.Flags                  |= PSD_ENABLEPAGESETUPHOOK;
         //psDlg.lpfnPageSetupHook       = (LPPAGESETUPHOOK)(FARPROC)PageSetupHook;
         //psDlg.lpPageSetupTemplateName = (LPTSTR)NULL;
         //psDlg.lpfnPagePaintHook       = (LPPAGEPAINTHOOK)(FARPROC)NULL;
      //break;

      //case IDM_CUSTOM:
         //psDlg.Flags |= PSD_ENABLEPAGESETUPHOOK |
                        //PSD_ENABLEPAGESETUPTEMPLATE;
         //psDlg.lpfnPageSetupHook       = (LPPAGESETUPHOOK)(FARPROC)PageSetupHook;
         //psDlg.lpPageSetupTemplateName = (LPTSTR)PRNSETUPDLGORD95;
         //psDlg.lpfnPagePaintHook       = (LPPAGEPAINTHOOK)(FARPROC)NULL;
      //break;
   //}

   // Call the Page Setup common dialog procedure.
   //if( PageSetupDlg(&psDlg) == FALSE)
      //ProcessCDError(CommDlgExtendedError(), hWnd);

   if( PageSetupDlg(&psDlg) ) _retclen(paramList,(char*)&psDlg, sizeof(PAGESETUPDLG) );
   else                       _retc(paramList,"");

}
