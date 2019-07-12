/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/
#include "common.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfWinDirectory( cDirSpec, cAttributes )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aDir := {}

DEFAULT cDirSpec    TO "*.*"

aDir := DIRECTORY( cDirSpec, cAttributes )
AEVAL( aDir, {|aSub|ASIZE( aSub, 6 ),aSub[6]:=aSub[1]})

RETURN aDir
