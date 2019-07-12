/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/
#include "Common.ch"
#include "fileio.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfZipMade( cFile )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cRet := "", cBuffer := SPAC(256), nHandle, nByte, nCtr, nPos, nBuf

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
            RETURN ""
         ENDIF

      ENDDO

      nByte := FREAD(nHandle, @cBuffer, 256)
      nCtr  := nCtr + nByte
      nBuf  := ASC(SUBSTR(cBuffer, nPos + 5, 1))

      DO CASE
         CASE nBuf == 0
              cRet := "MS-DOS and OS/2 (F.A.T. file systems)"

         CASE nBuf == 1
              cRet := "Amiga"

         CASE nBuf == 2
              cRet := "VMS"

         CASE nBuf == 3
              cRet := "*nix"

         CASE nBuf == 4
              cRet := "VM/CMS"

         CASE nBuf == 5
              cRet := "Atari ST"

         CASE nBuf == 6
              cRet := "OS/2 H.P.F.S."

         CASE nBuf == 7
              cRet := "Macintosh"

         CASE nBuf == 8
              cRet := "Z-System"

         CASE nBuf == 9
              cRet := "CP/M"
      ENDCASE
      FCLOSE( nHandle )
   ENDIF
ENDIF

RETURN cRet
