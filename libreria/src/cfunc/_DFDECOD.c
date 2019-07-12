/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function for Alaska Xbase++
Programmer  : Baccan Matteo
******************************************************************************/

#include <windows.h>
#include <xppdef.h>
#include <xpppar.h>
#include <xppcon.h>

XPPRET XPPENTRY DFDECODE( XppParamList paramList ){

   LONG nPar1Len = _parclen( paramList, 1 );
   MomHandle hNew1 = _momAlloc( sizeof(char)*(nPar1Len+1) );
   char *nPar1 = _momLock( hNew1 );

   long nPar2 = _parnl( paramList, 2 );

   LONG nPar3Len = _parclen( paramList, 3 );
   MomHandle hNew3 = _momAlloc( sizeof(char)*(nPar3Len+1) );
   char *nPar3 = _momLock( hNew3 );

   long nPar4 = _parnl( paramList, 4 );

   _parc( nPar1, nPar1Len+1, paramList, 1 );
   _parc( nPar3, nPar3Len+1, paramList, 3 );

   _retnl( paramList, (nPar1[nPar2-1]) ^ (nPar3[nPar4-1]) );

   _momUnlock(hNew1);
   _momFree(hNew1);
   _momUnlock(hNew3);
   _momFree(hNew3);
}
