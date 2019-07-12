//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' Varie
//Programmatore  : Baccan Matteo
//*****************************************************************************
//#include <extend.api>
//#include <string.h>
#include <windows.h>
#include <xppdef.h>
#include <xpppar.h>
#include <xppcon.h>

//int _dfFIsRem( char * fpString, int iLen );

//CLIPPER dfFIsRem(){
   //_retl( _dfFIsRem(_parc(1), _parclen(1)) );
//}

//int _dfFIsRem( char * fpString, int iLen ) {
XPPRET XPPENTRY DFFISREM( XppParamList paramList ){

   LONG iLen = _parclen( paramList, 1 );
   MomHandle hNew1 = _momAlloc( sizeof(char)*(iLen+1) );
   char *fpString = _momLock( hNew1 );

   int iRet, iRem, iEmpty, iPos;

   _parc( fpString, iLen+1, paramList, 1 );

   iPos=0;
   iEmpty=1;
   iRem=0;
   iRet=0;

   while( iPos<iLen ){
      if( fpString[iPos]==';' && iEmpty==1 ) iRem=1;

      if( fpString[iPos]!='\x09' &&
          fpString[iPos]!='\x0a' &&
          fpString[iPos]!='\x0d' &&
          fpString[iPos]!='\x20' && iRem!=1 ) iEmpty=0;

      if( iRem==1 || iEmpty==0 ) iPos=iLen;
      iPos++;
   }

   if( iRem==1 || iEmpty==1 ) iRet=1;

   if( iLen==1 && fpString[0]=='\x1a' ) iRet=1; // Riga di EOF()

   //return iRet;
   _retl( paramList, iRet );

   _momUnlock(hNew1);
   _momFree(hNew1);
}
