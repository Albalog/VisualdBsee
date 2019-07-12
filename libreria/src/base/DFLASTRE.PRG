/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "Fileio.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfLastRec( cFile, cDriver )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nHandle := FOPEN( ALLTRIM(cFile) +dfdbfExt( cDriver ), FO_READ+FO_SHARED)
LOCAL nRec := 0, cBuf := SPACE(4)
IF nHandle>0
   FSEEK( nHandle, 4, FS_SET )
   FREAD( nHandle, @cBuf, 4 )
   nRec := ASC(SUBSTR( cBuf ,1 ,1 ))              +;
           ASC(SUBSTR( cBuf ,2 ,1 )) *256         +;
           ASC(SUBSTR( cBuf ,3 ,1 )) *256*256     +;
           ASC(SUBSTR( cBuf ,4 ,1 )) *256*256*256
   FCLOSE( nHandle )
ENDIF
RETURN nRec
