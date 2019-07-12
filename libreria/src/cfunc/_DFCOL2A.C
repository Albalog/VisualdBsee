//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Funzioni di Utilita' VARIE
//Programmatore  : Baccan Matteo
//*****************************************************************************

#include <windows.h>
#include <xppdef.h>
#include <xpppar.h>
#include <xppcon.h>
#include "dBsee4x.h"

XPPRET XPPENTRY DFCOL2NUMA( XppParamList paramList ){
   static char fpColorF[][4] = { "W+", "N" , "B+", "R+" , "RB+", "G+", "BG+", "GR+",
                                 "N+", "B" , "R" , "RB" , "G"  , "BG", "GR" , "W"  };

   static char fpColorB[][4] = { "W*", "N" , "B*", "R*" , "RB*", "G*", "BG*", "GR*",
                                 "N*", "B" , "R" , "RB" , "G"  , "BG", "GR" , "W"  };

   LONG nPar1Len = _parclen( paramList, 1 );
   MomHandle hNew1 = _momAlloc( sizeof(char)*(nPar1Len+1) );
   char *fpColor = _momLock( hNew1 );

   int iSlash=-1;
   char i;
   unsigned char iBios=0;

   _parc( fpColor, nPar1Len+1, paramList, 1 );

   _dfUpper( fpColor );

   i=0;
   while( fpColor[i] && fpColor[i] != '/' ) i++;
   if( fpColor[i] != '\0'){
      iSlash=i;
      fpColor[i]='\0';
   }

   i=0;
   while( i<16 && _dfstrcmp(fpColor,fpColorF[i]) ) i++;
   if(iSlash != -1) fpColor[iSlash] = '/';

   if(i<16){
      iBios=i;
      fpColor += _dfstrlen(fpColorF[i]);
      if(fpColor){
         fpColor++;
         i=0;
         while( i<16 && _dfstrcmp(fpColor,fpColorB[i]) ) i++;
         if(i<16)iBios += (i*16);
      }
   }

   _retnl( paramList, iBios );

   _momUnlock(hNew1);
   _momFree(hNew1);
}
