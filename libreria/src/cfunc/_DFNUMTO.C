/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function for Alaska Xbase++
Programmer  : Baccan Matteo
******************************************************************************/

#include <windows.h>
#include <xppdef.h>
#include <xpppar.h>
#include <xppcon.h>

XPPRET XPPENTRY DFNUMTOKEN( XppParamList paramList ){
   register short  Tok;
   register char           Delim;
   register char           TypTok;

   char                                    * String;

   if ( PCOUNT(paramList) != 2 ) {
      return;
   }else{

      LONG nPar1Len = _parclen( paramList, 1 );
      MomHandle hNew1 = _momAlloc( sizeof(char)*(nPar1Len+1) );
      char *String = _momLock( hNew1 );

      LONG nPar2Len = _parclen( paramList, 2 );
      MomHandle hNew2 = _momAlloc( sizeof(char)*(nPar2Len+1) );
      char *nPar2 = _momLock( hNew2 );

      _parc( String, nPar1Len+1, paramList, 1 );
      _parc( nPar2, nPar2Len+1, paramList, 2 );
      Delim = nPar2[0];

      TypTok = (char) ( nPar2Len == 1 ? 0 : 1 );

      if( String[0] == '\0' ){                /* stringa vuota: 0 token */
         _retni(paramList, 0 );
      }else{
         Tok = 1;

         while( * String ) {      /* conta i token */
            if( *( String ++ ) == Delim ) {
                Tok ++;
                if( TypTok ) {
                    while( * String == Delim && * String )
                       String ++;
                }
            }
         }

        _retni( paramList, Tok );                                                          /* ritorna il numero di token */
      }
      _momUnlock(hNew1);
      _momFree(hNew1);
      _momUnlock(hNew2);
      _momFree(hNew2);
   }
   return;
}
