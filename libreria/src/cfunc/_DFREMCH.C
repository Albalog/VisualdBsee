//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Utility per le configurazioni
//Programmatore  : Baccan Matteo
//*****************************************************************************

#include <windows.h>
#include <xppdef.h>
#include <xpppar.h>
#include <xppcon.h>
//#include "dBsee4x.h"

XPPRET XPPENTRY DFREMCHR( XppParamList paramList ){
   unsigned int punstr = 0;          // puntatore stringa
   unsigned int punret = 0;          // puntatore stringa di ritorno
   unsigned int puncar = 0;          // puntatore caratteri
   unsigned int lencar = 0;
   char * str=NULL;
   char * car=NULL;
   MomHandle hNew2=NULL;

   if( PCOUNT(paramList)==0 ){
      _retc(paramList, "" );
   } else {
      unsigned int lenstr = _parclen( paramList, 1 );       // lunghezza stringa
      MomHandle hNew1 = _momAlloc( sizeof(char)*(lenstr+1) );
      str = _momLock( hNew1 );
      _parc( str, lenstr+1, paramList, 1 );

      if( PCOUNT(paramList)==1 ){
         car    = " !\x22#$%&'()*+,-./:;<=>?[\\]^_`{|}~";
         lencar = strlen(car);    // lunghezza caratteri
      } else if( PCOUNT(paramList)==2 ){
         lencar = _parclen( paramList, 2 );       // lunghezza stringa
         hNew2 = _momAlloc( sizeof(char)*(lencar+1) );
         car = _momLock( hNew2 );
         _parc( car, lencar+1, paramList, 2 );

         //car    = _parc(2);
         //lencar = _parclen( paramList, 2 );     // lunghezza caratteri
      }

      //str = (char *) _xgrab( lenstr + 1 ); // alloco per la stringa master + \n
      //strcpy( str, _parc(1) );             // copio la stringa nel destination

      while(punstr<lenstr){   // finche' puntatore a stringa minore della lunghezza

        while(puncar<lencar){ // finche' ci sono caratteri
          if(str[punstr]==car[puncar])    // se carattere str = carattere car
            puncar=lencar;                // forzo l'uscita
          puncar++;
        }// endwhile

        // se esco normale puncar = lencar altrimenti puncar = lencar ++
        if(puncar==lencar)               // se uscita normale
          str[punret++]=str[punstr];     // metto in str

        puncar = 0;
        punstr++;
      }// endwhile

      while(punret<lenstr) str[punret++]=' '; // paddo la stringa

      str[lenstr]='\0';

      _retc(paramList, str );                    // torno la stringa a clipper

      //_xfree( str );                   // disalloco la memoria
      _momUnlock(hNew1);
      _momFree(hNew1);
      if( PCOUNT(paramList)==2 ){
         _momUnlock(hNew2);
         _momFree(hNew2);
      }
   }
}
