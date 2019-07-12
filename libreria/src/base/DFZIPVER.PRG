/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/
#include "Common.ch"
#include "fileio.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfZipVer( cFile )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cBuf, cBuffer := SPAC(256), nHandle, nByte, nCtr, nPos, nVer := 0

DEFAULT cFile TO ""

nCtr := 0
IF FILE( cFile )
   IF (nHandle:=FOPEN(cFIle,FO_READ+FO_SHARED))>0
      DO WHILE .T.

         nByte := FREAD(nHandle, @cBuffer, 256)
         nCtr  := nCtr + nByte
         nPos  := AT( "PK"+CHR(1)+CHR(2), cBuffer )

         IF nPos > 0
            EXIT
         ENDIF

         IF nByte < 256
            FCLOSE( nHandle )
            RETURN 0
         ENDIF

      ENDDO

      cBuf := SUBSTR( cBuffer, nPos + 4, 1)
      nVer := (ASC(cBuf)/10) + (ASC(cBuf)%10)

      FCLOSE( nHandle )
   ENDIF
ENDIF

RETURN nVer
