//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Funzioni di Utilita' VARIE
//Programmatore  : Baccan Matteo
//*****************************************************************************

#include <windows.h>
#include <xppdef.h>
#include <xpppar.h>
#include <xppcon.h>

XPPRET XPPENTRY DFBIN2NUM( XppParamList paramList ){
   LONG nPar1Len = _parclen( paramList, 1 );

   MomHandle hNew1 = _momAlloc( sizeof(char)*(nPar1Len+1) );
   char *fpStr = _momLock( hNew1 );

   int iMax=min(16,nPar1Len);
   long iCount=1;
   long iBin=0;

   _parc( fpStr, nPar1Len+1, paramList, 1 );

   while( iMax-->0 ){
      if( fpStr[iMax]=='1' ) iBin += iCount;
      iCount *= 2;
   }

   _retnl(paramList,iBin);

   _momUnlock(hNew1);
   _momFree(hNew1);
}
