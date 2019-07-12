//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Funzioni di Utilita' VARIE
//Programmatore  : Baccan Matteo
//*****************************************************************************

#include <windows.h>
#include <xppdef.h>
#include <xpppar.h>
#include <xppcon.h>

XPPRET XPPENTRY DFHEX2DEC( XppParamList paramList ){

   LONG nPar1Len = _parclen( paramList, 1 );
   MomHandle hNew1 = _momAlloc( sizeof(char)*(nPar1Len+1) );
   char *cpString = _momLock( hNew1 );

   int iLen, iMax, iChar;
   unsigned int iVal=0,iExp=1;

   _parc( cpString, nPar1Len+1, paramList, 1 );

   iLen = iMax = nPar1Len;
   while( iLen-->0 ){
      iChar=cpString[iLen];
      if(iMax==iLen+1) iExp = 1;
      else iExp*=16;
      if(iChar>=97 && iChar<=102) iChar-=32;
      if(iChar>=65 && iChar<=70)  iChar-=7;
      if(iChar>=48 && iChar<=63)  iChar-=48;
      if(iChar>=0  && iChar<=16)  iVal +=(iChar*iExp);
   }
   _retnl( paramList, iVal );

   _momUnlock(hNew1);
   _momFree(hNew1);
}
