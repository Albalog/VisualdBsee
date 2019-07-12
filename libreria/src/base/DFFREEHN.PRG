/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "fileio.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfFreeHnd()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nHnd, aHnd := {}

WHILE (nHnd:=FOPEN( "NUL", FO_READ +FO_SHARED ))>0
   AADD( aHnd, nHnd )
   #ifdef __XPP__
   IF LEN(aHnd)>=255
      EXIT
   ENDIF
   #endif
ENDDO
AEVAL( aHnd, {|nSub|FCLOSE(nSub)} )

RETURN LEN(aHnd)
