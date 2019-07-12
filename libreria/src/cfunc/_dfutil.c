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

void _dfUpper( char *tpp ) {
   short i;
   for( i = 0 ; tpp[i] != '\0' ; i++ ) {
      tpp[i] = tpp[i] >= 'a' && tpp[i] <= 'z' ? (char) ( tpp[i] - 32 ) : tpp[i];
   }
}

int _dfstrlen( char *tpp ) {
   int i=0;
   while(tpp[i]!='\0') i++;
   return i;
}

int _dfstrcpy( char *tpp, char *xpp ) {
   int i=0;
   while( xpp[i] ) {
      tpp[i] = xpp[i];
      i++;
   }
   tpp[i]=0;
   return i;
}

int _dfstrcmp( char *tpp, char *tpp2 ) {
   int i=0;
   while( 1 ){
      if( tpp[i]=='\0' && tpp2[i]=='\0' ){
         i=0;
         break;
      }

      if( tpp[i]=='\0' || tpp2[i]=='\0' ){
         i=1;
         break;
      }

      if( tpp[i]!=tpp2[i] ){
         i=1;
         break;
      }

      i++;
   }
   return i;
}
