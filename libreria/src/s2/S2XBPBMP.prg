// Classe identica alla XbpBitmap, per• dopo il loadFile
// Š possibile chiamare :getXRes() e :getYRes() per
// avere informazioni sulla risoluzione usata

#include "common.ch"
#include "fileio.ch"

#define CM_TO_INCH      2.54  // 1 pollice = 2.54 centimetri

STATIC CLASS ImgFormat
EXPORTED:
   INLINE METHOD isFormat(cBmpName); RETURN .F.
   INLINE METHOD getResolution(oBmp); RETURN {0,0}
ENDCLASS

// Classi da fare JPG-GIF-PNG!
STATIC CLASS ImgFormatJPG FROM ImgFormat; ENDCLASS
STATIC CLASS ImgFormatGIF FROM ImgFormat; ENDCLASS
STATIC CLASS ImgFormatPNG FROM ImgFormat; ENDCLASS

STATIC CLASS ImgFormatBMP FROM ImgFormat
EXPORTED:
   METHOD isFormat
   METHOD getResolution
ENDCLASS

METHOD ImgFormatBMP:isFormat(cBmpName)
   LOCAL nH, cBuff
   LOCAL lRet := .F.
   nH := FOPEN(cBmpName)
   IF nH > 0
      // Guardo se l'immagine Š in formato BMP
      cBuff := SPACE(6)
//    Simone 1/12/2005 
//    mantis 0000922: classe s2xbpbitmap non prende informazioni di risoluzione se il file Š un BMP Š compresso
//    se il file Š un BMP compresso
//    il controllo della lunghezza file Š errato.
//    basta guardare se i primi 2 bytes sono BM
//      lRet := FREAD(nH, @cBuff, 6) == 6 .AND. LEFT(cBuff,2)=="BM" .AND. ;
//              BIN2U(SUBSTR(cBuff,3,4)) == FSEEK(nH, 0, FS_END)
      lRet := FREAD(nH, @cBuff, 6) == 6 .AND. LEFT(cBuff,2)=="BM" 
      FCLOSE(nH)
   ENDIF
RETURN lRet

METHOD ImgFormatBMP:getResolution(oBmp)
   // 25 = Byte all'interno del file setbuffer per BMP
   //      dove Š impostata la risoluzione X
   //
   // 29 = Byte all'interno del file setbuffer per BMP
   //      dove Š impostata la risoluzione Y
   LOCAL xRes := BIN2U(SUBSTR(oBmp:DBBitmap:setBuffer(), 25, 4))
   LOCAL yRes := BIN2U(SUBSTR(oBmp:DBBitmap:setBuffer(), 29, 4))
RETURN {xRes,yRes}

CLASS S2XbpBitmap FROM DBBitmap
   PROTECTED:
      VAR oBMPType READONLY
      VAR xRes READONLY
      VAR yRes READONLY
      METHOD cvtRes
      METHOD updRes
      METHOD getImgFormat

   EXPORTED:
      METHOD load
      METHOD loadFile
      METHOD setBuffer
      METHOD getXRes
      METHOD getYRes
      METHOD setRes
      METHOD getSize

ENDCLASS

METHOD S2XbpBitmap:getImgFormat(cBmpName)
   LOCAL oRet
   LOCAL nInd
   LOCAL aFmt := {ImgFormatBmp():new(), ;
                  ImgFormatJpg():new(), ;
                  ImgFormatGif():new(), ;
                  ImgFormatPng():new()  }

   FOR nInd := 1 TO LEN(aFmt)
      oRet := aFmt[nInd]
      IF oRet:isFormat(cBmpName)
         EXIT
      ENDIF
   NEXT
   IF nInd > LEN(aFmt)
      oRet := NIL     // Non trovato
   ENDIF
RETURN oRet

METHOD S2XbpBitmap:setRes(x,y)
   IF VALTYPE(x) == "N"
      ::xRes := x
   ENDIF
   IF VALTYPE(y) == "N"
      ::yRes := y
   ENDIF
RETURN self


METHOD S2XbpBitmap:updRes(xRes,yRes)
   LOCAL aRes
   IF ::oBMPType != NIL
      aRes := ::oBMPType:getResolution(self)
      ::xRes := aRes[1]
      ::yRes := aRes[2]
   ELSE
      ::xRes := 0
      ::yRes := 0
   ENDIF

   // Risoluzione di default
   IF ::xRes <= 0
      ::xRes := 72
   ENDIF
   IF ::yRes <= 0
      ::yRes := 72
   ENDIF

   ::setRes(xRes,yRes)

RETURN self

METHOD S2XbpBitmap:load(cDll, nId, xRes, yRes, cType)
   LOCAL lRet := .F.

   // prima prova a caricare l'immagine con il gruppo 
   // "IMAGES" che deve essere definito nel file .ARC
   // come 
   // USERDEF IMAGES
   //    BTN_GOTOP = FILE "pippo.png"
   // nota: deve essere tutto in maiuscolo tranne nome file!

   IF EMPTY(cType)
      cType := NIL
      IF cDll == NIL
         lRet := ::DBBitmap:load(NIL, nId, "IMAGES")
      ELSE
         lRet := ::DBBitmap:load(cDll, nId, "IMAGES")
      ENDIF
   ENDIF

   // prova con immagini standard
   IF ! lRet
      // Questo IF Š necessario altrimenti Xbase da un runtime error
      IF cDll == NIL
         lRet := ::DBBitmap:load(NIL, nId, cType)
      ELSE
         lRet := ::DBBitmap:load(cDll, nId, cType)
      ENDIF
   ENDIF

   ::oBMPType := NIL
   ::updRes(xRes,yRes)
RETURN lRet

METHOD S2XbpBitmap:loadFile(cBmpName, xRes, yRes)
   LOCAL lRet := ::DBBitmap:loadFile(cBmpName)
   ::oBMPType := ::getImgFormat(cBmpName)
   //::cBMPType := IIF(UPPER(RIGHT(cBmpName,4))==".BMP", "BMP", NIL)

   ::updRes(xRes,yRes)
RETURN lRet

METHOD S2XbpBitmap:setBuffer(cBuff, nFmt)
   LOCAL cRet

   // Questo DO CASE Š necessario altrimenti Xbase da un runtime error
   // se metto direttamente questo..

   DO CASE
      CASE cBuff == NIL .AND. nFmt == NIL
         cRet := ::DBBitmap:setBuffer()

      CASE cBuff != NIL .AND. nFmt == NIL
         cRet := ::DBBitmap:setBuffer(cBuff)

      CASE cBuff == NIL .AND. nFmt != NIL
         cRet := ::DBBitmap:setBuffer(NIL, nFmt)

      CASE cBuff != NIL .AND. nFmt != NIL
         cRet := ::DBBitmap:setBuffer(cBuff, nFmt)

   ENDCASE

   ::updRes()
RETURN cRet

// Torna array con dimensioni X e Y dell'immagine in Metri
// (se nDim = NIL),  CM (se nDim = 0) o pollici (se nDim = 1)
METHOD S2XbpBitmap:getSize(nDim)
   LOCAL aRet := NIL

   IF ::xRes != NIL .AND. ::yRes != NIL

       aRet := { ::xSize / ::xRes, ;
                 ::ySize / ::yRes  }

       DO CASE
          CASE nDim == 0
            // Dimensioni in CM
            aRet := { ::xSize * 100 / ::xRes, ;
                      ::ySize * 100 / ::yRes }

          CASE nDim == 1
            // Dimensioni in pollici
            aRet := { ::xSize * 100 / ::xRes / CM_TO_INCH, ;
                      ::ySize * 100 / ::yRes / CM_TO_INCH  }
       ENDCASE

   ENDIF
RETURN aRet

// Torna la risoluzione X in Pixel per Metro (se nDim=NIL),
// Pixel per CM (se nDim = 0) o Pixel per pollice (se nDim = 1)
METHOD S2XbpBitmap:getXRes( nDim )
RETURN ::cvtRes(::xRes, nDim)

// Torna la risoluzione y in Pixel per Metro (se nDim=NIL),
// Pixel per CM (se nDim = 0) o Pixel per pollice (se nDim = 1)
METHOD S2XbpBitmap:getYRes( nDim )
RETURN ::cvtRes(::yRes, nDim)

// Converte da Pixel per Metro a DPI o DPC
METHOD S2XbpBitmap:cvtRes( nVal, nDim )
   IF nVal != NIL
      DO CASE
         CASE nDim == 0
            // Converte da Pixel per Metro a Pixel per Centimetro
            nVal := ROUND(nVal/100, 0)

         CASE nDim == 1
            // Converte da Pixel per Metro a Pixel per Pollice (DPI)
            nVal := ROUND(nVal/100* CM_TO_INCH, 0)
      ENDCASE
   ENDIF
RETURN nVal

CLASS dbBitmap FROM XbpBitmap
   EXPORTED:

   // just needs to overload :load method
   // of XbpBitmap class as this method should
   // be able to load all support graphic formats
   // which are currently BMP, JPG, GIF and PNG
   INLINE METHOD Load( cDll, nID, cType )
      LOCAL xResource, lSuccess
      IF Empty( cType )
         // this is the standard :load
         // which supports BMP
         lSuccess := ::XbpBitmap:load( cDll, nID )
      ELSE
         // when it comes to GIF, JPG or PNG
         // we can load it from a recource file
         // per LoadResource() function call
         xResource := LoadResource( nID, cDll, cType )
         lSuccess := ! Empty( xResource )
         ::setBuffer( xResource )
      ENDIF
   RETURN( lSuccess )

ENDCLASS
