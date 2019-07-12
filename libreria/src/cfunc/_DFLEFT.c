//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Utility per le configurazioni
//Programmatore  : Baccan Matteo
//*****************************************************************************

//#include <extend.api>
//#include <fm.api>
//#include <string.h>
#include <windows.h>
#include <xppdef.h>
#include <xpppar.h>
#include <xppcon.h>
#include "dBsee4x.h"

#define ISTRAILING( chr )    ( chr==9 || chr==10 || chr==13 || chr==32 )

//CLIPPER dfLeft(){
XPPRET XPPENTRY DFLEFT( XppParamList paramList ){
   //char *fpStr=_parc(1);
   char fpRet[1024];
   int  iPos=0;
   int  iAdd=0;

   //int  iLen=_parclen(1);
   LONG iLen = _parclen( paramList, 1 );

   MomHandle hNew1 = _momAlloc( sizeof(char)*(iLen+1) );
   char *fpStr = _momLock( hNew1 );
   _parc( fpStr, iLen+1, paramList, 1 );

   while( ISTRAILING(fpStr[iPos]) && iPos<iLen ) iPos++; // Skip space

   while( iPos<iLen && fpStr[iPos]!='=' ) fpRet[iAdd++]=fpStr[iPos++];

   if( fpStr[iPos]=='=' && iAdd>0 ){
      fpRet[iAdd--]=0;
      while( iPos<iLen && iAdd>=0 && ISTRAILING(fpRet[iAdd]) ) fpRet[iAdd--]=0;
   }else fpRet[0]=0;

  //_retc(fpRet);
   _retc(paramList, fpRet);

   _momUnlock(hNew1);
   _momFree(hNew1);
}
