#include "dfMsg1.ch"
#include "dfImage.ch"
#include "dll.ch"
#include "common.ch"

// crea bitmap che contiene quello che Š visualizzato in un Oggetto 
FUNCTION dfXbp2Bitmap( oXbp, aPos, aSize )
   LOCAL oPS 
   LOCAL oBitmap

   IF VALTYPE(oXbp) != "O" 
      RETURN NIL
   ENDIF

   IF ! oXbp:isDerivedFrom("XbpWindow")
      RETURN NIL
   ENDIF

   DEFAULT aPos  TO {0, 0}
   DEFAULT aSize TO oXbp:currentSize()

   oPS := oXbp:lockPS()
   oBitmap := dfGraSaveScreen( oPS, aPos, aSize )

   // se fa unlock non si pu• pi— usare l'immagine'
   //oXbp:unlockPS( oPS )
RETURN {oBitmap, oPS}

FUNCTION dfGraSaveScreen( oSourcePS, aPos, aSize )
  LOCAL oBitmap   := S2XbpBitmap():new():create( oSourcePS )
  LOCAL oTargetPS := XbpPresSpace():new():create()
  LOCAL aSourceRect[4], aTargetRect

  aSourceRect[1] := aSourceRect[3] := aPos[1]
  aSourceRect[2] := aSourceRect[4] := aPos[2]
  aSourceRect[3] += aSize[1]
  aSourceRect[4] += aSize[2]
  aTargetRect    := {0, 0, aSize[1], aSize[2]}

  oBitmap:presSpace( oTargetPS )
  oBitmap:make( aSize[1], aSize[2] )

  GraBitBlt( oTargetPS, oSourcePS, aTargetRect, aSourceRect )
RETURN oBitmap

// The function GraRestScreen() redisplays a saved
// section of screen. It just uses the :draw() method

FUNCTION dfGraRestScreen( oTargetPS, aPos, oBitmap )
  oBitmap:draw( oTargetPS, aPos )
RETURN NIL


FUNCTION dfBMP2JPEG(cImgIn,cImgOut,nQuality)
   Local lOk := .F.
   LOCAL xResIn,yResIn
   LOCAL aFName      := dfFNameSplit(cImgIn)

   DEFAULT nQuality TO JPEG_DEFAULT
   DEFAULT cImgOut  TO aFName[1]+aFName[2]+aFName[3]+".JPG"

   IF UPPER(aFName[4]) != ".BMP"
      RETURN lOk
   ENDIF

   FERASE(cImgOut)
   IF dfImageConvert(cImgIn, cImgOut,24,nQuality,@xResIn,@yResIn)
      lOk := .T.
      IF !dfSetJPGRes(cImgOut,xResIn,yResIn)
         dbmsgerr(dfStdMsg1(MSG1_DFJPG03))
         lOk := .F.
      ENDIF
   ENDIF
RETURN lOk

FUNCTION dfBMP2TIFF(cImgIn,cImgOut,nComp)
   Local lOk := .F.
   Local xResIn,yResIn
   LOCAL aFName      := dfFNameSplit(cImgIn)

   DEFAULT nComp TO TIFF_NONE
   DEFAULT cImgOut  TO aFName[1]+aFName[2]+aFName[3]+".TIF"

   IF UPPER(aFName[4]) != ".BMP"
      RETURN lOk
   ENDIF

   FERASE(cImgOut)
   IF dfImageConvert(cImgIn, cImgOut,24,nComp,@xResIn,@yResIn)
      lOk := .T.
      IF !dfSetTIFRes(cImgOut,xResIn,yResIn)
         dbmsgerr(dfStdMsg1(MSG1_DFTIFF04))
         lOk := .F.
      ENDIF
   ENDIF
RETURN lOk

FUNCTION dfImageConvert(cImgIn, cImgOut,nBIT,nQuality,xResIn,yResIn)
   LOCAL nDll
   LOCAL lOk
   LOCAL Fif,dib,dib2,fif2,suppw,bpp,suppexpBPP,val

   DEFAULT nBIT TO 0
   DEFAULT nQuality TO 0

   lOk := .F.

   nDll := dllLoad("dbImage.dll")
   IF nDll == 0
      dbmsgerr(dfStdMsg1(MSG1_DFTIFF01))
      RETURN lOk
   ENDIF

   dllCall(nDll, DLL_STDCALL, "_FreeImage_Initialise@4")
   dib := dllCall(nDll, DLL_STDCALL, "_FreeImage_Load@12", fif, cImgIn)

   IF dib != 0

      DllCall(nDll, DLL_STDCALL, "_FreeImage_SetTransparent@8", dib, 0)

      fif2   := dllCall(nDll, DLL_STDCALL, "_FreeImage_GetFIFFromFilename@4", cImgOut)
      suppw  := dllCall(nDll, DLL_STDCALL, "_FreeImage_FIFSupportsWriting@4", fif2)

      xResIn := INT(dllCall(nDll, DLL_STDCALL, "_FreeImage_GetDotsPerMeterX@4" , dib)*2.54 /100 +0.5)
      yResIn := INT(dllCall(nDll, DLL_STDCALL, "_FreeImage_GetDotsPerMeterY@4" , dib)*2.54 /100 +0.5)

      DO CASE
         CASE nBIT == 0
         CASE nBIT == 8
            dib2   := dllCall(nDll, DLL_STDCALL, "_FreeImage_ConvertTo8Bits@4" , dib)
            DllCall(nDll, DLL_STDCALL, "_FreeImage_Free@4", dib)
            dib := dib2
         CASE nBIT == 24
            dib2   := dllCall(nDll, DLL_STDCALL, "_FreeImage_ConvertTo24Bits@4" , dib)
            DllCall(nDll, DLL_STDCALL, "_FreeImage_Free@4", dib)
            dib := dib2
         CASE nBIT == 32
            dib2   := dllCall(nDll, DLL_STDCALL, "_FreeImage_ConvertTo32Bits@4" , dib)
            DllCall(nDll, DLL_STDCALL, "_FreeImage_Free@4", dib)
            dib := dib2
      ENDCASE

      // Ritorna il numero di bits per gestire il colore: 2, 4, 8,16, 24, 32
      bpp:= dllCall(nDll, DLL_STDCALL, "_FreeImage_GetBPP@4", dib)
      // Controlla se il file, trammite l'estensione , supporta 24 bits di colore
      suppexpBPP := dllCall(nDll, DLL_STDCALL, "_FreeImage_FIFSupportsExportBPP@8", fif2, bpp)

      IF (suppw>0 .and. suppExpBPP>0)
         Val := dllCall(nDll, DLL_STDCALL, "_FreeImage_Save@16", fif2, dib, cImgOut, nQuality)
         IF Val<>0
            lOk := .T.
         ENDIF
      ELSE
         lOk := .F.
      ENDIF

      DllCall(nDll, DLL_STDCALL, "_FreeImage_Free@4", dib)
   ENDIF
   DllCall(nDll, DLL_STDCALL, "_FreeImage_DeInitialise@0")
RETURN lOk

