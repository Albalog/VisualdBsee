/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/

#include "Fileio.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfIsZip( cFile )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .F., nHandle, cBuf := SPACE(4)

IF FILE(cFile)
   IF (nHandle:=FOPEN(cFIle,FO_READ+FO_SHARED))>0
      IF FREAD( nHandle, @cBuf, 4 )==4
         lRet := cBuf=="PK"+CHR(3)+CHR(4)
      ENDIF
      FCLOSE( nHandle )
   ENDIF
ENDIF

RETURN lRet
