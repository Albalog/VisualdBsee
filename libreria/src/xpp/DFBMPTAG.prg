#include "Fileio.ch"
#include "common.ch"
#include "dfImage.ch"



///////////////////////////////////////////////////////////////////////////////
Function dfGetBmpTAG( cFile,cTag ) //Estrapola da un file bmp le informazioni di struttura
///////////////////////////////////////////////////////////////////////////////
   local c255, nAt, nHandle
   local nWidth := 0, nHeight := 0, nBits := 8, nFrom := 0
   local nLength := 0,n,cTemp1,cTemp2,cTemp3,cTemp
   LOCAL aTAG := ARRAY(BMPTAG_LEN)

   DEFAULT cTAG TO BMPTAG_XRESOLUTION

   nHandle := fopen( cFile )

   c255 := space(1024)
   fread( nHandle, @c255, 1024 )


   //BMPTAG_IDCODE
   ctemp := substr( c255, 1, 2 )
   aTAG[BMPTAG_IDCODE] := ctemp
   n :=0


   //BMPTAG_FILESIZE
   ctemp  := substr( c255, 3+n*4, 4 )
   ctemp1 := Bin2l(ctemp)
   aTAG[BMPTAG_FILESIZE] := ctemp1
   n++

   //BMPTAG_RESERVED
   ctemp  := substr( c255, 3+n*4, 4 )
   ctemp1 := Bin2l(ctemp)
   aTAG[BMPTAG_RESERVED] := ctemp1
   n++

   //BMPTAG_OFFSET
   ctemp := substr( c255, 3+n*4, 4 )
   ctemp1 := Bin2l(ctemp)
   aTAG[BMPTAG_OFFSET] := ctemp1
   n++

   //BMPTAG_HEADERSIZE
   ctemp := substr( c255, 3+n*4, 4 )
   ctemp1 := Bin2l(ctemp)
   aTAG[BMPTAG_HEADERSIZE] := ctemp1
   n++

   //BMPTAG_WIDTH
   ctemp := substr( c255, 3+n*4, 4 )
   ctemp1 := Bin2l(ctemp)
   aTAG[BMPTAG_WIDTH] := ctemp1
   n++

   //BMPTAG_HEIGHT
   ctemp := substr( c255, 3+n*4, 4 )
   ctemp1 := Bin2l(ctemp)
   aTAG[BMPTAG_HEIGHT] := ctemp1
   n := 3+n*4 +4

   //BMPTAG_PLANES
   ctemp := substr( c255, n, 2 )
   ctemp1 := Bin2l(ctemp)
   aTAG[BMPTAG_PLANES] := ctemp1
   n +=2

   //BMPTAG_BITSPERPIXEL
   ctemp  := substr( c255, n, 2 )
   ctemp1 := Bin2l(ctemp)
   aTAG[BMPTAG_BITSPERPIXEL] := ctemp1
   n +=2

   //BMPTAG_COMPRESSION
   ctemp  := substr( c255, n, 4 )
   ctemp1 := Bin2l(ctemp)
   aTAG[BMPTAG_COMPRESSION] := ctemp1
   n +=4

   //BMPTAG_BITMAPDATASIZE
   ctemp  := substr( c255, n, 4 )
   ctemp1 := Bin2l(ctemp)
   aTAG[BMPTAG_BITMAPDATASIZE] := ctemp1
   n +=4

   //BMPTAG_XRESOLUTION
   ctemp  := substr( c255, n, 4 )
   ctemp1 := Bin2l(ctemp)
   aTAG[BMPTAG_XRESOLUTION] := ctemp1
   n +=4

   //BMPTAG_YRESOLUTION
   ctemp  := substr( c255, n, 4 )
   ctemp1 := Bin2l(ctemp)
   aTAG[BMPTAG_YRESOLUTION] := ctemp1
   n +=4

   ctemp := substr( c255, n, 4 )
   ctemp1 := Bin2l(ctemp)
   aTAG[BMPTAG_COLORS] := ctemp1
   n +=4

   fclose( nHandle )


RETURN aTag[cTag]

/*

#include "dfMsg1.ch"
#include "dll.ch"

///////////////////////////////////////////////////////////////////////////////
Function dfGetBmpRes( cFile ) //Estrapola da un file bmp le informazioni di Risoluzione
///////////////////////////////////////////////////////////////////////////////
   LOCAL nX := ROUND(dfGetBmpTag(cFile,BMPTAG_XRESOLUTION), 0)
   LOCAL nY := ROUND(dfGetBmpTag(cFile,BMPTAG_YRESOLUTION), 0)
   IF nX <0  .OR. nY <0
      dbmsgerr(dfStdMsg1(MSG1_DFBMP01))
      RETURN NIL
   ENDIF
RETURN {nX,nY}

///////////////////////////////////////////////////////////////////////////////
Function dfSetBmpRes( cFile,xRes,yRes ) //Setta la risuluzione d un file Bmp
///////////////////////////////////////////////////////////////////////////////
   LOCAL c255, nAt, nHandle
   LOCAL nWidth := 0, nHeight := 0, nBits := 8, nFrom := 0
   LOCAL nLength := 0,n,cTemp1,cTemp2,cTemp3,cTemp,lRet,lx,ly

   DEFAULT xRes TO 100
   DEFAULT yRes TO xRes

   nHandle := FOPEN( cFile, FO_READWRITE + FO_SHARED )
   IF FERROR() <> 0
      RETURN .F.
   ENDIF

   c255 := space(1024)
   fread( nHandle, @c255, 1024 )


   //BMPTAG_IDCODE
   //ctemp := substr( c255, 1, 2 )
   //ctemp1 := Bin2l(ctemp)
   n :=0


   //BMPTAG_FILESIZE
   //ctemp  := substr( c255, 3+n*4, 4 )
   //ctemp1 := Bin2l(ctemp)
   n++

   //BMPTAG_RESERVED
   //ctemp  := substr( c255, 3+n*4, 4 )
   //ctemp1 := Bin2l(ctemp)
   n++

   //BMPTAG_OFFSET
   //ctemp := substr( c255, 3+n*4, 4 )
   //ctemp1 := Bin2l(ctemp)
   n++

   //BMPTAG_HEADERSIZE
   //ctemp := substr( c255, 3+n*4, 4 )
   //ctemp1 := Bin2l(ctemp)
   n++

   //BMPTAG_WIDTH
   //ctemp := substr( c255, 3+n*4, 4 )
   //ctemp1 := Bin2l(ctemp)
   n++

   //BMPTAG_HEIGHT
   //ctemp := substr( c255, 3+n*4, 4 )
   //ctemp1 := Bin2l(ctemp)

   n := 3+n*4 +4

   //BMPTAG_PLANES
   //ctemp := substr( c255, n, 2 )
   //ctemp1 := Bin2l(ctemp)
   n +=2

   //BMPTAG_BITSPERPIXEL
   //ctemp  := substr( c255, n, 2 )
   //ctemp1 := Bin2l(ctemp)
   n +=2

   //BMPTAG_COMPRESSION
   //ctemp  := substr( c255, n, 4 )
   //ctemp1 := Bin2l(ctemp)
   n +=4

   //BMPTAG_BITMAPDATASIZE
   //ctemp  := substr( c255, n, 4 )
   //ctemp1 := Bin2l(ctemp)
   n +=4

   lRet := .F.
   //BMPTAG_XRESOLUTION
   cTemp := l2Bin(xRes)
   fseek(nHandle,N-1)
   lx := FWRITE(nHandle, cTemp,4)>0
   //ctemp  := substr( c255, n, 4 )
   //ctemp1 := Bin2l(ctemp)
   n +=4

   //BMPTAG_YRESOLUTION
   cTemp := l2Bin(yRes)
   fseek(nHandle,N-1)
   ly := FWRITE(nHandle, cTemp,4)>0
   //ctemp  := substr( c255, n, 4 )
   //ctemp1 := Bin2l(ctemp)
   n +=4

   //ctemp := substr( c255, n, 4 )
   //ctemp1 := Bin2l(ctemp)
   n +=4
   lRet := lx .AND. ly
   fClose( nHandle )
RETURN lRet
*/


// //#######################################################################
// Function dfBmpInfo( cFile ) //Estrapola da un file bmp le informazioni di struttura
// //#######################################################################
// local c255, nAt, nHandle
// local nWidth := 0, nHeight := 0, nBits := 8, nFrom := 0
// local nLength := 0, xRes := 0, yRes := 0, aTemp := {},n,cTemp1,cTemp2,cTemp3,cTemp
//
//    nHandle := fopen( cFile )
//
//    c255 := space(1024)
//    fread( nHandle, @c255, 1024 )
//
//    ctemp := substr( c255, 1, 2 )
//    dfalert({"Codice:",ctemp})
//    n :=0
//
//    ctemp := substr( c255, 3+n*4, 4 )
//    n++
//    ctemp1 := Bin2l(ctemp)
//    dfalert({"File Size ",ctemp1})
//
//    ctemp := substr( c255, 3+n*4, 4 )
//    n++
//    ctemp1 := Bin2l(ctemp)
//    dfalert({"Reserved ",ctemp1})
//
//    ctemp := substr( c255, 3+n*4, 4 )
//    n++
//    ctemp1 := Bin2l(ctemp)
//    dfalert({"Bitmap Header Ofset",ctemp1})
//
//    ctemp := substr( c255, 3+n*4, 4 )
//    n++
//    ctemp1 := Bin2l(ctemp)
//    dfalert({"Bitmap Header Size",ctemp1})
//
//    ctemp := substr( c255, 3+n*4, 4 )
//    n++
//    ctemp1 := Bin2l(ctemp)
//    dfalert({"Width ",ctemp1})
//
//    ctemp := substr( c255, 3+n*4, 4 )
//    n := 3+n*4 +4
//    ctemp1 := Bin2l(ctemp)
//    dfalert({"Height ",ctemp1})
//
//    ctemp := substr( c255, n, 2 )
//    n +=2
//    ctemp1 := Bin2l(ctemp)
//    dfalert({"Planes ",ctemp1})
//
//    ctemp := substr( c255, n, 2 )
//    n +=2
//    ctemp1 := Bin2l(ctemp)
//    dfalert({"Bits per pixel ",ctemp1})
//
//    ctemp := substr( c255, n, 4 )
//    n +=4
//    ctemp1 := Bin2l(ctemp)
//    dfalert({"Compresion ",ctemp1})
//
//    ctemp := substr( c255, n, 4 )
//    n +=4
//    ctemp1 := Bin2l(ctemp)
//    dfalert({"Bitmap Data Size ",ctemp1})
//
//    ctemp := substr( c255, n, 4 )
//    n +=4
//    ctemp1 := Bin2l(ctemp)
//    dfalert({"H Resulution ",ctemp1})
//
//    ctemp := substr( c255, n, 4 )
//    n +=4
//    ctemp1 := Bin2l(ctemp)
//    dfalert({"V Resulution ",ctemp1})
//
//    ctemp := substr( c255, n, 4 )
//    n +=4
//    ctemp1 := Bin2l(ctemp)
//    dfalert({"Colors ",ctemp1})
//
//    fclose( nHandle )
//
//    nLength := filesize( cFile )
//    dfalert({"Length ",nLength})
//
// return NIL
// static function FileSize( cFile )
//
//    LOCAL nLength
//    LOCAL nHandle
//
//    nHandle := fOpen( cFile )
//    nLength := fSeek( nHandle, 0, FS_END )
//    fClose( nHandle )
//
// return ( nLength )
