/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function for Alaska Xbase++
Programmer  : Baccan Matteo
******************************************************************************/

#include <windows.h>
#include <xppdef.h>
#include <xpppar.h>
#include <xppcon.h>

XPPRET XPPENTRY DFGETFILEATR( XppParamList paramList ){
   LONG iLen = _parclen( paramList, 1 );
   MomHandle hNew1 = _momAlloc( sizeof(char)*(iLen+1) );
   char *fpString = _momLock( hNew1 );

   DWORD iRet;

   _parc( fpString, iLen+1, paramList, 1 );

   iRet = GetFileAttributes( fpString );

   _retnl( paramList, iRet );

   _momUnlock(hNew1);
   _momFree(hNew1);
}

XPPRET XPPENTRY DFSETFILEATR( XppParamList paramList ){
   LONG iLen = _parclen( paramList, 1 );
   MomHandle hNew1 = _momAlloc( sizeof(char)*(iLen+1) );
   char *fpString = _momLock( hNew1 );

   DWORD nAtr = _parnl( paramList, 2 );

   _parc( fpString, iLen+1, paramList, 1 );

   SetFileAttributes( fpString, nAtr );

   _momUnlock(hNew1);
   _momFree(hNew1);
}
