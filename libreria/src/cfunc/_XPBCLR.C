
/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function for Alaska Xbase++
Programmer  : Baccan Matteo
******************************************************************************/

#include <windows.h>
#include <xppdef.h>
#include <xpppar.h>
#include <xppcon.h>

XPPRET XPPENTRY DFXPPCHOOSECOLOR( XppParamList paramList ){
//BOOL ChooseNewColor (HWND hWnd)

   HWND hWnd=NULL;
   DWORD dwColor;
   DWORD dwCustClrs[16];
   BOOL fSetColor = FALSE;
   BYTE r=0, g=0, b=0;
   int i, nFlags=0;

   CHOOSECOLOR chsclr;

   if( PCOUNT(paramList)>=1 && XPP_IS_NUM(_partype(paramList,1)) )
      hWnd = (HWND)_parnl( paramList, 1 );

   if( PCOUNT(paramList)>=2 && XPP_IS_NUM(_partype(paramList,2)) )
      r=(BYTE)_parnl( paramList, 2 );

   if( PCOUNT(paramList)>=3 && XPP_IS_NUM(_partype(paramList,3)) )
      g=(BYTE)_parnl( paramList, 3 );

   if( PCOUNT(paramList)>=4 && XPP_IS_NUM(_partype(paramList,4)) )
      b=(BYTE)_parnl( paramList, 4 );

   if( PCOUNT(paramList)>=5 && XPP_IS_NUM(_partype(paramList,5)) )
      nFlags=_parnl( paramList, 5 );

   for (i = 0; i <= 15; i++)
      dwCustClrs[i] = RGB(255, 255, 255);

   chsclr.lStructSize = sizeof(CHOOSECOLOR);


   chsclr.hwndOwner = hWnd;
   dwColor = RGB (r, g, b);

   //chsclr.hInstance = (HANDLE)hInst;
   chsclr.hInstance = (HANDLE)NULL;
   chsclr.rgbResult = dwColor;
   chsclr.lpCustColors = (LPDWORD)dwCustClrs;
   chsclr.lCustData = 0L;

   //switch(wMode) {

      //case IDM_HOOK:
         //chsclr.Flags            = CC_ENABLEHOOK;
         //chsclr.lpfnHook         = (LPCCHOOKPROC)ChooseColorHookProc;
         //chsclr.lpTemplateName   = (LPTSTR)NULL;
      //break;


      //case IDM_CUSTOM:
         //chsclr.Flags = CC_PREVENTFULLOPEN | CC_ENABLEHOOK | CC_ENABLETEMPLATE;
         //chsclr.lpfnHook       = (LPCCHOOKPROC)ChooseColorHookProc;
         //chsclr.lpTemplateName = "CHOOSECOLOR";
      //break;


      //case IDM_STANDARD:
         //chsclr.Flags            = CC_PREVENTFULLOPEN;
         chsclr.Flags            = nFlags ; //CC_FULLOPEN | CC_RGBINIT;
         chsclr.lpfnHook         = (LPCCHOOKPROC)(FARPROC)NULL;
         chsclr.lpTemplateName   = (LPTSTR)NULL;
      //break;

   //}

   //if (fSetColor = ChooseColor (&chsclr)) {
      //crColor = chsclr.rgbResult;
      //return TRUE;
   //} else {
      //ProcessCDError (CommDlgExtendedError (), hWnd);
      //return FALSE;
   //}

   if (ChooseColor(&chsclr)==TRUE) {
     _retclen( paramList, (char *)chsclr.rgbResult, sizeof(chsclr.rgbResult) );  // array colori

   } else {
     _retnl( paramList, CommDlgExtendedError() );      // codice errore 
   }

}
