#include "Fileio.ch"
#include "common.ch"
#include "dfMsg1.ch"


FUNCTION dfSetJPGRes(cNomeFile,xRes,yRes) //Input deve essere in Dpi
   local   nHandle, xVal, lRet := .F.
   DEFAULT xRes TO 100
   DEFAULT yRes TO xRes

   nHandle := FOPEN( cNomeFile, FO_READWRITE + FO_SHARED )
   IF FERROR() <> 0
      RETURN lRet
   ENDIF

   fseek(nHandle,10)
   FWRITE(nHandle, CHR(0))

   fseek(nHandle,13)
   xVal := CHR(1) // Dot per INCH
   xVal += CHR(INT(xRes/256)) + CHR(xRes%256)  
   xVal += CHR(INT(yRes/256)) + CHR(yRes%256) 

   lRet := FWRITE(nHandle, xVal)>0

   FCLOSE( nHandle )

RETURN lret

// Ritorna risoluzione JPEG: NIL=errore lettura file
// altrimenti torna array con risoluzione X e Y in DPI
FUNCTION dfGetJPGRes(cNomeFile)
   local nHandle, xVal, c255, xRes, yRes
   LOCAL nUM

   nHandle := FOPEN( cNomeFile)
   IF FERROR() <> 0
      RETURN Nil
   ENDIF

   c255 := space(1)
   fseek(nHandle,13)
   fread( nHandle, @c255, 1 )
   nUM := ASC(c255)
   IF nUM ==0     // risol. non definita
      xRes := 0
      yRes := 0
   ELSE
      c255 := space(2)
      fseek(nHandle,14)
      fread( nHandle, @c255, 2 )
      xRes := asc( substr( c255, 1, 1 )) * 256 + asc(substr( c255, 2, 1 ))

      fseek(nHandle,16)
      fread( nHandle, @c255, 2 )
      yRes := asc( substr( c255, 1, 1 )) * 256 + asc(substr( c255, 2, 1 ))

      IF nUM == 2 // Š espresso in Dot per CM converto in Dot per INCH
         xRes := ROUND(xRes * 2.54, 0)
         yRes := ROUND(yRes * 2.54, 0)
      ENDIF

   ENDIF
   FCLOSE( nHandle )
   IF xRes <0  .OR. yres <0
      dbmsgerr(dfStdMsg1(MSG1_DFJPG01))
      RETURN NIL
   ENDIF

RETURN {xRes, yRes}

