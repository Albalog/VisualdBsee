/*******************************************************************************
Progetto       : dBsee 4.3
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
*******************************************************************************/
#include <windows.h>
#include <xppdef.h>
#include <xpppar.h>
#include <xppcon.h>
#include "dBsee4x.h"

unsigned int _dfRleCmp( char * fpNew,
                        unsigned int uiDup,
                        char cLast,
                        unsigned int uiPosNew );

XPPRET XPPENTRY DFRLCMP( XppParamList paramList ){
   unsigned int uiLen = _parclen( paramList, 1 );
   MomHandle hNew1 = _momAlloc( sizeof(char)*(uiLen+1) );
   char *fpStr = _momLock( hNew1 );

   MomHandle hNew2 = _momAlloc( sizeof(char)*(0x4101) );
   char *fpNew = _momLock( hNew2 );

   unsigned int uiPos=0;
   unsigned int uiPosNew=0;

   unsigned int uiDup=0;
   char cLast=0;

   _parc( fpStr, uiLen+1, paramList, 1 );

   while( uiPos<uiLen ){
      if(uiPos==0) {
         uiDup=1;
      } else if( uiPos>0 && fpStr[uiPos]==cLast ) {
         uiDup++;
      } else {
         uiPosNew=_dfRleCmp( fpNew, uiDup, cLast, uiPosNew );
         uiDup=1;
      }
      cLast=fpStr[uiPos++];
      if( uiPosNew>uiLen ) {
         uiPos=uiPosNew;
      }
   }

   uiPosNew=_dfRleCmp( fpNew, uiDup, cLast, uiPosNew );

   if(uiPosNew>=uiLen) _retclen(paramList,fpStr,uiLen   );
   else                _retclen(paramList,fpNew,uiPosNew);


   _momUnlock(hNew2);
   _momFree(hNew2);
   _momUnlock(hNew1);
   _momFree(hNew1);
}

unsigned int _dfRleCmp( char * fpNew,
                        unsigned int uiDup,
                        char cLast,
                        unsigned int uiPosNew ){
   if(uiDup>3){
      while( uiDup>255 ){
         fpNew[uiPosNew++] = '\xff';
         fpNew[uiPosNew++] = '\xff';
         fpNew[uiPosNew++] = cLast;
         uiDup-=255;
      }
      fpNew[uiPosNew++] = '\xff';
      fpNew[uiPosNew++] = (char)uiDup;
      fpNew[uiPosNew++] = cLast;
   } else if(cLast=='\xff') {
      fpNew[uiPosNew++] = '\xff';
      fpNew[uiPosNew++] = (char)uiDup;
      fpNew[uiPosNew++] = cLast;
   } else {
     while( uiDup-->0 ) fpNew[uiPosNew++]=cLast;
   }

   return uiPosNew;
}

XPPRET XPPENTRY DFRLDECMP( XppParamList paramList ){
   unsigned int uiLen = _parclen( paramList, 1 );
   MomHandle hNew1 = _momAlloc( sizeof(char)*(uiLen+1) );
   char *fpStr = _momLock( hNew1 );

   MomHandle hNew2 = _momAlloc( sizeof(char)*(0x4101) );
   char *fpNew = _momLock( hNew2 );
   unsigned int uiPos=0;
   unsigned int uiPosNew=0;

   unsigned char uiDup=0;
   char  cLast;

   _parc( fpStr, uiLen+1, paramList, 1 );

   while( uiPos<uiLen ){
      if( fpStr[uiPos]=='\xff' ) {

         uiDup=fpStr[++uiPos];
         cLast=fpStr[++uiPos];

         while( uiDup-->0 ) fpNew[uiPosNew++]=cLast;

      } else fpNew[uiPosNew++]=fpStr[uiPos];
      uiPos++;
   }

   _retclen(paramList,fpNew,uiPosNew);

   _momUnlock(hNew2);
   _momFree(hNew2);
   _momUnlock(hNew1);
   _momFree(hNew1);
}
