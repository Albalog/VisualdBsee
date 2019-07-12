/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/
#include "Fileio.ch"
#include "Common.ch"
#include "dfMsg.ch"
#include "dfstd.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfChkDbf( cFile, cDriver )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T., nLen, nHeader, nRec, nRecReal, nLenRec, nHandle, cBuf, nVal

DEFAULT cDriver TO RDDSETDEFAULT()

cDriver := ALLTRIM(UPPER(cDriver))
IF cDriver$"DBFCDX-DBFMDX-DBFNDX-DBFNTX-COMIX-SIXCDX-SIXNSX-FLEXFILE"
   nLen     := dfFileSize( ALLTRIM(cFile) +dfdbfExt( cDriver ) )

   nHeader  := dfDBFHeader( cFile )
   nLenRec  := dfDBFRecLen( cFile )

   nRec     := dfLastRec( cFile, cDriver )

   IF nLenRec>0
      nRecReal := INT((nLen-nHeader)/nLenRec)
      IF nRecReal!=nRec
         IF dfYesNo( dfStdMsg(MSG_DFCHKDBF01) +;
                     cFile                    +;
                     dfStdMsg(MSG_DFCHKDBF02) +;
                     dfStdMsg(MSG_DFCHKDBF03) +STR(nRec)     +;
                     dfStdMsg(MSG_DFCHKDBF04) +STR(nRecReal) +;
                     dfStdMsg(MSG_DFCHKDBF05) +;
                     dfStdMsg(MSG_DFCHKDBF06) +;
                     dfStdMsg(MSG_DFCHKDBF07) +;
                     dfStdMsg(MSG_DFCHKDBF08)  )

            nHandle := FOPEN( ALLTRIM(cFile) +dfdbfExt( cDriver ), FO_READWRITE+FO_EXCLUSIVE)
            IF nHandle>0
               cBuf := ""
               FSEEK( nHandle, 4, FS_SET )

               IF nRecReal>256*256*256
                  nVal     := INT(nRecReal/256*256*256)
                  cBuf     := CHR(nVal) +cBuf
                  nRecReal -= (nVal*256*256*256)
               ELSE
                  cBuf     := CHR(0) +cBuf
               ENDIF

               IF nRecReal>256*256
                  nVal     := INT(nRecReal/256*256)
                  cBuf     := CHR(nVal) +cBuf
                  nRecReal -= (nVal*256*256)
               ELSE
                  cBuf     := CHR(0) +cBuf
               ENDIF

               IF nRecReal>256
                  nVal     := INT(nRecReal/256)
                  cBuf     := CHR(nVal) +cBuf
                  nRecReal -= (nVal*256)
               ELSE
                  cBuf     := CHR(0) +cBuf
               ENDIF

               IF nRecReal>0
                  nVal     := nRecReal
                  cBuf     := CHR(nVal) +cBuf
                  nRecReal -= nVal
               ELSE
                  cBuf     := CHR(0) +cBuf
               ENDIF

               FWRITE( nHandle, @cBuf, 4 )
               FCLOSE( nHandle )
               lRet := .F.
            ENDIF
         ENDIF
      ENDIF
   ENDIF
ENDIF

RETURN lRet
