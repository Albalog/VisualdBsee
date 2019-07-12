/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/
#include "Common.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddDup( cFile, cPath )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cOut := "", nPos := 0, cExt
ddSemLock()

DEFAULT cPath TO ""

cPath := dfPathChk(cPath) +"DMM"

IF ddFilePos( cFile )
   cExt := dfDbfExt( ddFileDriver() )
   WHILE FILE( (cOut:=cPath +PADL(++nPos,4,"0")) +cExt ); END
   ddGenDbf( cFile, cOut )
ENDIF

ddSemUnLock()
RETURN cOut
