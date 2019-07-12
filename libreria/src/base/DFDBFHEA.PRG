/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "Fileio.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDBFHeader( cFile, cDriver )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nHandle := FOPEN( ALLTRIM(cFile) +dfdbfExt( cDriver ), FO_READ+FO_SHARED)
LOCAL nRec := 0, cBuf := SPACE(2)
IF nHandle>0
   FSEEK( nHandle, 8, FS_SET )
   FREAD( nHandle, @cBuf, 2 )
   nRec := ASC(SUBSTR( cBuf ,1 ,1 ))              +;
           ASC(SUBSTR( cBuf ,2 ,1 )) *256
   FCLOSE( nHandle )
ENDIF
RETURN nRec
