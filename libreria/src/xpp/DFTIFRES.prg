//////////////////////////////////////////////////////////////////////
// Modifica Risoluzione File TIFF per Xbase++ 1.8
//
// Compilare e linkare con:
//    XPP dfTIFRES /M/N/W/Q/LINK
//
//////////////////////////////////////////////////////////////////////

#include "Fileio.ch"
#include "common.ch"
#include "dfImage.ch"
#include "dfMsg1.ch"

// Ritorna risoluzione TIF: NIL=errore lettura file
// altrimenti torna array con risoluzione X e Y in DPI
FUNCTION dfGetTifRes(cNomeFile)
   LOCAL nX := ROUND(dfGetTifTag(cNomeFile,TIFFTAG_XRESOLUTION), 0)
   LOCAL nY := ROUND(dfGetTifTag(cNomeFile,TIFFTAG_YRESOLUTION), 0)
   IF nX <0  .OR. nY <0
      dbmsgerr(dfStdMsg1(MSG1_DFTIFF03))
      RETURN NIL
   ENDIF
RETURN {nX,nY}

FUNCTION dfGetTifTag(cNomeFile,nTagchk)
   LOCAL nHandle
   LOCAL nPPM
   Local npos,nInd,cRow,cType,type,ntypelen,nlen,ncount,cbuff,noffset,ntotlen,nTag,xVal

   DEFAULT nTagchk TO TIFFTAG_XRESOLUTION //RESULUZIONE X

   nHandle     := FOPEN( cNomeFile, FO_READ + FO_SHARED )

   IF FERROR() <> 0
      RETURN -9
   ENDIF

   cBuff:=readstr(nHandle,16)
   nPos := bin2l(substr(cBuff, 5, 4))
   fseek(nHandle,nPos)
   nCount := bin2w(readstr(nHandle,2))

   for nInd := 1 to nCount

      fseek(nHandle,nPos+2+(nInd-1)*12)
      cRow := readstr(nHandle,12)
      type:=bin2w(substr(cRow,3,2))
      nLen:=bin2l(substr(cRow,5,4))

      nTag := bin2w(substr(cRow,1,2))

      nTypeLen := 1
      cType:="(unk)"

      nOffset:=bin2l(substr(cRow,9,4))
      fseek(nHandle, noffset)
      xVal := -999
      IF type==1
         ctype:="byte (1)"
         cRow:=READstr(nHandle, nTotLen)
         xVal := bin2l(cRow)
      ELSEIF type==2
         ctype:="ascii (1)"
         cRow:=READstr(nHandle, nTotLen)
         xVal := bin2l(cRow)
      ELSEIF type==3
         ctype:="short (2)"
         nTypeLen:=2
         nTotLen := nLen*nTypeLen
         cRow:=READstr(nHandle, nTotLen)
         xVal := bin2l(cRow)
      ELSEIF type==4
         ctype:="long (4)"
         nTypeLen:=4
         nTotLen := nLen*nTypeLen
         cRow:=READstr(nHandle, nTotLen)
         xVal := bin2l(cRow)
      ELSEIF type==5
         ctype:="rational (2x4)"
         nTypeLen:=8
         nTotLen := nLen*nTypeLen
         cRow:=READstr(nHandle, nTotLen)
         xVal := bin2l(substr(cRow,1,4))/bin2l(substr(cRow,5,4))
      ENDIF
      IF nTag == nTagChk
         FCLOSE( nHandle )
         IF VALTYPE(xVal) !="N"
            xVal := -999999
         ENDIF
         RETURN xVal
      ENDIF
   NEXT
   FCLOSE( nHandle )
RETURN -999

FUNCTION dfSetTifRes(cNomeFile,xRes,yRes) //Indput deve essere in Dpi
   LOCAL nHandle
   LOCAL nPPM
   LOCAL npos,nInd,cRow,cType,type,ntypelen,nlen,ncount,cbuff,noffset,ntotlen,nTag,xVal,lRet
   LOCAL nTagx := TIFFTAG_XRESOLUTION //RESULUZIONE X
   LOCAL nTagy := TIFFTAG_YRESOLUTION //RESULUZIONE Y
   lRet        := .F.
   nHandle     := FOPEN( cNomeFile, FO_READWRITE + FO_SHARED )

   DEFAULT xRes TO 100
   DEFAULT yRes TO xRes

   IF FERROR() <> 0
      RETURN lRet
   ENDIF

   cBuff:=readstr(nHandle,16)
   nPos := bin2l(substr(cBuff, 5, 4))
   fseek(nHandle,nPos)
   nCount := bin2w(readstr(nHandle,2))

   for nInd := 1 to nCount

      fseek(nHandle,nPos+2+(nInd-1)*12)
      cRow := readstr(nHandle,12)
      type:=bin2w(substr(cRow,3,2))
      nLen:=bin2l(substr(cRow,5,4))

      nTag := bin2w(substr(cRow,1,2))

      nTypeLen := 1
      cType:="(unk)"

      nOffset:=bin2l(substr(cRow,9,4))
      fseek(nHandle, noffset)
      IF type==1
         ctype:="byte (1)"
      ELSEIF type==2
         ctype:="ascii (1)"
      ELSEIF type==3
         ctype:="short (2)"
         nTypeLen:=2
         nTotLen := nLen*nTypeLen
      ELSEIF type==4
         ctype:="long (4)"
         nTypeLen:=4
         nTotLen := nLen*nTypeLen
      ELSEIF type==5
         ctype:="rational (2x4)"
         nTypeLen:=8
         nTotLen := nLen*nTypeLen
      ENDIF

      IF nTag == nTagx
         xVal := L2Bin(xRes)
         lRet := WRITEstr(nHandle, xVal)
         fseek(nHandle, noffset+4)
         xVal := L2Bin(1)
         lRet := WRITEstr(nHandle, xVal)
      ENDIF
      IF nTag == nTagy
         xVal := L2Bin(yRes)
         lRet := WRITEstr(nHandle, xVal)
         fseek(nHandle, noffset+4)
         xVal := l2Bin(1)
         lRet := WRITEstr(nHandle, xVal)
      ENDIF

   NEXT
   FCLOSE( nHandle )
RETURN lRet

STATIC FUNCTION readStr(n, y)
   local hh :=space(y)
   fread(n, @hh, y)
return hh

STATIC FUNCTION WriteStr(nHand, xBin)
   LOCAL lRet := .T.
   LOCAL nLen:= LEN(xBin)
   IF fWrite(nHand, xBin, nLen) < nLen
      lRet := .F.
   ENDIF
RETURN lRet

//STATIC func pToHex(n); RETURN ALLTRIM(STR(n))+" (0x"+toHex(n)+")"
//STATIC func toHex(n);return dfnum2base(n, "0123456789ABCDEF")

