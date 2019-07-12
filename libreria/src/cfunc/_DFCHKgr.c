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

// Funzione interna di controllo gruppi di refresh

XPPRET XPPENTRY DFCHKGRP( XppParamList paramList ){
//CLIPPER dfChkGrp(){
   //char * fpStr;
   //char * fpDes;
   int iStrLen, iActual, iPos;

   LONG nPar1Len = _parclen( paramList, 1 );

   MomHandle hNew1 = _momAlloc( sizeof(char)*(nPar1Len+1) );
   char *fpStr = _momLock( hNew1 );

   MomHandle hNew2 = _momAlloc( sizeof(char)*(nPar1Len+1) );
   char *fpDes = _momLock( hNew2 );

   _parc( fpStr, nPar1Len+1, paramList, 1 );

   //fpStr = _parc(1);
   if( fpStr != NULL ){
       //iStrLen = _parclen(1);
       iStrLen = nPar1Len;
       iActual = iPos = 0;

       //fpDes = _xgrab(iStrLen+1);

       while( iActual<iStrLen && (fpStr[iActual]=='-'||fpStr[iActual]==' ') )
          iActual++;

       fpStr += iActual;

       _dfstrcpy( fpDes, fpStr );

       iStrLen = _dfstrlen(fpDes);

       while( iStrLen>0 && (fpDes[iStrLen-1]=='-'||fpDes[iStrLen-1]==' ') )
          fpDes[--iStrLen]=0;

      _retc(paramList, fpDes);

      //_xfree(fpDes);
   }else{

      _retc(paramList, "");
   }

   _momUnlock(hNew2);
   _momFree(hNew2);

   _momUnlock(hNew1);
   _momFree(hNew1);
}
