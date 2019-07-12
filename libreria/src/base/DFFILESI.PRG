//*****************************************************************************
//Progetto       : dBsee 4.1
//Descrizione    : Funzioni di utilita'
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "fileio.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfFileSize( cFile )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nSize := 0, nHandle := -1, nCurrent

DO CASE
   CASE VALTYPE(cFile)="C"
        nHandle := FOPEN(cFile,FO_READ+FO_SHARED)

   CASE VALTYPE(cFile)="N"
        nHandle := cFile
ENDCASE

IF nHandle>0
   nCurrent := FSEEK(nHandle,0,FS_RELATIVE)
   nSize    := FSEEK(nHandle,0,FS_END)
   FSEEK(nHandle,nCurrent,FS_SET)
   IF VALTYPE(cFile)="C"
      FCLOSE(nHandle)
   END
ENDIF

RETURN nSize
