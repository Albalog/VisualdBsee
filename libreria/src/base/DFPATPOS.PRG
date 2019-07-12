/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/
#include "Fileio.ch"

#define PATTERN_LEN  4096

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfPatternPos( cFile, cPattern )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nHandle, nRec := 0, cBuf := SPACE( PATTERN_LEN ), nPos, nRead
LOCAL nLen := LEN(cPattern)

IF VALTYPE( cFile )=="N"
   nHandle := cFile
ELSE
   nHandle := FOPEN( ALLTRIM(cFile), FO_READ+FO_SHARED )
ENDIF

IF nHandle>0
   WHILE ( nRead := FREAD( nHandle, @cBuf, PATTERN_LEN ) ) > 0
      IF ( nPos := AT( cPattern, cBuf ) ) > 0
         nRec := FSEEK( nHandle, 0, FS_RELATIVE )
         nRec -= ( nRead-nPos+1 )
         EXIT
      ENDIF
      IF nRead>nLen
         FSEEK( nHandle, -nLen, FS_RELATIVE )
      ENDIF
   ENDDO
   IF VALTYPE( cFile )!="N"
      FCLOSE( nHandle )
   ENDIF
ENDIF

RETURN nRec
