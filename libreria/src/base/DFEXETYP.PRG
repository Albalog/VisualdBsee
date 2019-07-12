/*******************************************************************************
Progetto       : dBsee 4.4
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
*******************************************************************************/
#include "dfExeTyp.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfExeType( cExe )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nRet := EXE_TYPE_UNKNOWN, cBuf := SPACE(2), nExeTyp, nHandle, nExeHeader

nHandle := FOPEN( cExe )
FREAD( nHandle, @cBuf, 2 )

IF cBuf$"MZM"

   nRet := EXE_TYPE_MZ

   FSEEK( nHandle, dfHex2Dec("18") )
   FREAD( nHandle, @cBuf, 2 )
   nExeTyp := BIN2W(cBuf)

   IF (nExeTyp==dfHex2Dec("40"))
      FSEEK( nHandle, dfHex2Dec("3C") )
      cBuf := SPACE(4)
      FREAD( nHandle, @cBuf, 4 )
      nExeHeader := BIN2L(cBuf)
      FSEEK( nHandle, nExeHeader )

      cBuf := SPACE(2)
      FREAD( nHandle, @cBuf, 2 )

      DO CASE
         CASE (cBuf=="NE"); nRet := EXE_TYPE_NE
         CASE (cBuf=="LE"); nRet := EXE_TYPE_LE
         CASE (cBuf=="LX"); nRet := EXE_TYPE_LX
         CASE (cBuf=="W3"); nRet := EXE_TYPE_W3
         CASE (cBuf=="PE"); nRet := EXE_TYPE_PE
         CASE (cBuf=="DL"); nRet := EXE_TYPE_DL
         CASE (cBuf=="MP"); nRet := EXE_TYPE_MP
         CASE (cBuf=="P2"); nRet := EXE_TYPE_P2
         CASE (cBuf=="P3"); nRet := EXE_TYPE_P3
      ENDCASE

   ENDIF
ENDIF

FCLOSE( nHandle )

RETURN nRet
