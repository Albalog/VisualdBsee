/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function for Alaska Xbase++
Programmer  : Baccan Matteo
******************************************************************************/

#include <windows.h>
#include <xppdef.h>
#include <xpppar.h>
#include <xppcon.h>


XPPRET XPPENTRY DFSETFILETIME( XppParamList paramList ){
   LONG iLen = _parclen( paramList, 1 );
   int iRet;
   FILETIME ft, ft1;
   LPFILETIME lct=NULL, lwt=NULL, lmt=NULL;
   LONG nSet;
   HANDLE hFile;
   MomHandle hNew1 = _momAlloc( sizeof(char)*(iLen+1) );
   char * fpString = _momLock( hNew1 );

   hFile = (HANDLE) _parnl( paramList, 2 );
   nSet  = _parnl( paramList, 3 );

   _parc( fpString, iLen+1, paramList, 1 );

   SystemTimeToFileTime((LPSYSTEMTIME) fpString, &ft);  // converts to file time format
   LocalFileTimeToFileTime(&ft, &ft1);


   if (nSet & 1) lct = &ft1;
   if (nSet & 2) lwt = &ft1;
   if (nSet & 4) lmt = &ft1;

   iRet = SetFileTime(hFile, lct, lwt, lmt);          // sets last-write time for file

   _retnl(paramList, iRet);

   _momUnlock(hNew1);
   _momFree(hNew1);
}
