/*******************************************************************************
Progetto       : dBsee 4.3
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
*******************************************************************************/

//#include <extend.api>
//#include <fm.api>
//#include <string.h>
#include <windows.h>
#include <xppdef.h>
#include <xpppar.h>
#include <xppcon.h>
#include "dBsee4x.h"

static unsigned char fpPair[][3]={ "  ",
                                   "\xd\xa",
                                   " *",
                                   " A",
                                   " C",
                                   " D",
                                   " I",
                                   " O",
                                   " T",
                                   "= ",
                                   "AR",
                                   "AT",
                                   "CO",
                                   "E ",
                                   "EL",
                                   "EN",
                                   "ER",
                                   "FI",
                                   "HE",
                                   "IN",
                                   "LA",
                                   "LE",
                                   "N ",
                                   "ND",
                                   "OR",
                                   "RE",
                                   "S ",
                                   "SE",
                                   "ST",
                                   "TH",
                                   "TI",
                                   "AN"};/*32*/

XPPRET XPPENTRY DFPAIRCMP( XppParamList paramList ){
   //unsigned char *fpStr=_parc(1);
   //unsigned int uiLen=_parclen(1);
   //unsigned char *fpNew=_xgrab(0x4100);
   unsigned int uiLen = _parclen( paramList, 1 );
   MomHandle hNew1 = _momAlloc( sizeof(char)*(uiLen+1) );
   char *fpStr = _momLock( hNew1 );

   MomHandle hNew2 = _momAlloc( sizeof(char)*(0x4101) );
   char *fpNew = _momLock( hNew2 );
   unsigned int  uiPos=0;
   unsigned char uiSearch=0;
   unsigned int  uiPosNew=0;

   _parc( fpStr, uiLen+1, paramList, 1 );

   while( uiPos<uiLen && fpStr[uiPos]<=223 ) uiPos++;

   if( uiPos==uiLen ){
      uiPos=0;
      while( uiPos<(uiLen-1) ){
         uiSearch=0;
         while( uiSearch<32 ){
            if( fpPair[uiSearch][0]==fpStr[uiPos  ] &&
                fpPair[uiSearch][1]==fpStr[uiPos+1]  ) break;

            uiSearch++;
         }
         if( uiSearch==32 ) fpNew[uiPosNew++]=fpStr[uiPos];
         else {fpNew[uiPosNew++]=(unsigned char)(224+uiSearch); uiPos++;}
         uiPos++;
      }
      if( uiPos==(uiLen-1) ) fpNew[uiPosNew++]=fpStr[uiPos];
      _retclen(paramList,fpNew,uiPosNew);
   }else{
      _retclen(paramList,fpStr,uiLen+1);
   }

   _momUnlock(hNew2);
   _momFree(hNew2);
   _momUnlock(hNew1);
   _momFree(hNew1);
}

XPPRET XPPENTRY DFPAIRDECMP( XppParamList paramList ){
   //unsigned char *fpStr=_parc(1);
   //unsigned int uiLen=_parclen(1);
   //unsigned char *fpNew=_xgrab(0x4100);
   unsigned int uiLen = _parclen( paramList, 1 );
   MomHandle hNew1 = _momAlloc( sizeof(char)*(uiLen+1) );
   char *fpStr = _momLock( hNew1 );

   MomHandle hNew2 = _momAlloc( sizeof(char)*(0x4101) );
   char *fpNew = _momLock( hNew2 );
   unsigned int uiPos=0;
   unsigned int uiPosNew=0;

   while( uiPos<uiLen ){
      if( fpStr[uiPos]>223 ) {

         fpNew[uiPosNew++]=fpPair[fpStr[uiPos]-224][0];
         fpNew[uiPosNew++]=fpPair[fpStr[uiPos]-224][1];

      } else fpNew[uiPosNew++]=fpStr[uiPos];
      uiPos++;
   }

   _retclen(paramList,fpNew,uiPosNew);
   //_xfree(fpNew);
   _momUnlock(hNew2);
   _momFree(hNew2);
   _momUnlock(hNew1);
   _momFree(hNew1);
}
