#include "dfXBase.ch"
#include "Common.ch"

FUNCTION dfIsCDRom(nDrive)
   LOCAL nResult
   LOCAL cDrive

   DEFAULT nDrive TO 0

   IF nDrive != 0
      cDrive := CHR(nDrive+64)+":\"
   ENDIF

RETURN S2WAPIGetDriveType(cDrive) == S2WAPIGDT_CDROM
