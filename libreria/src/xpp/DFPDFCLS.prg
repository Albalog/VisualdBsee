/******************************************************************************
Project     : dBsee xbase 1.8
Description : Pdf Extension Class Function
Programmer  : Luca C.
******************************************************************************/

#include "LibFBin.ch"
#include "dfPdf.ch"
#include "dfMsg1.ch"
#include "XBP.ch"
#include "dfImage.ch"
#include "dll.ch"
#include "common.ch"
#include "Fileio.ch"
#include "GRA.ch"
#include "pdf.ch"

//#define CRLF chr(13)+chr(10)

CLASS dfPdf FROM tPdf
   PROTECTED:
      METHOD Chr_rgb
      VAR aImageCache

   EXPORTED:
      VAR bShowMsg
      VAR aAttribute
      VAR Device

      METHOD Init
      METHOD Destroy
      METHOD Execute
      METHOD ImageInfo
      METHOD Image
      METHOD BMPInfo
      METHOD ATSAY
      METHOD Bmp2Tiff
      METHOD Bmp2Jpeg
      METHOD TIFFInfo
      METHOD FilePrint
      METHOD SetAttrString

      INLINE METHOD getPageSize() // dimensione pagina in POLLICI
      RETURN {::aReport[ PAGEX ]/72,::aReport[ PAGEY ]/72}

      INLINE METHOD ShowMsg(cMsg)
         IF ::bShowMsg != NIL
            EVAL(::bShowMsg, cMsg, .T. )
         ENDIF
      RETURN self

      INLINE METHOD HideMsg(cMsg)
         IF ::bShowMsg != NIL
            EVAL(::bShowMsg, cMsg, .F. )
         ENDIF
      RETURN self
ENDCLASS

METHOD dfPdf:SetAttrString(aAt )
  Local oldaAttr := ::aAttribute
  Local aRGB
  IF EMPTY(aAt) .OR. LEN(aAt) < GRA_AS_COUNT
     RETURN oldaAttr
  ENDIF

  IF !Empty(aAt[ GRA_AS_COLOR ])
     IF VALTYPE(aAt[ GRA_AS_COLOR ]) == "N"   //Del tipo XBASE: GRA_....
        aRGB := GraGetRGBIntensity(aAt[ GRA_AS_COLOR ]  )
        IF !EMPTY(aRGB)
           ::aAttribute[ GRA_AS_COLOR ] := dfByte2Hex(aRGB[1])+;
                                           dfByte2Hex(aRGB[2])+;
                                           dfByte2Hex(aRGB[3])
        ELSE
          ::aAttribute[ GRA_AS_COLOR ] := PDF_BLACK 
        ENDIF
     ELSEIF VALTYPE(aAt[ GRA_AS_COLOR ]) == "C"  //Del tipo Pdf: "AADB05"
        ::aAttribute[ GRA_AS_COLOR ] :=  aAt[ GRA_AS_COLOR ]
     ELSE
        ::aAttribute[ GRA_AS_COLOR ] := PDF_BLACK
     ENDIF
  ENDIF

  IF !Empty(aAt[ GRA_AS_BACKCOLOR ])
     ::aAttribute [ GRA_AS_BACKCOLOR ] :=  aAt[ GRA_AS_BACKCOLOR ]
  ENDIF
  IF !Empty(aAt[ GRA_AS_COLOR ])
     ::aAttribute [ GRA_AS_MIXMODE ] :=  aAt[ GRA_AS_MIXMODE ]
  ENDIF
  IF !Empty(aAt[ GRA_AS_COLOR ])
     ::aAttribute [ GRA_AS_BGMIXMODE ] :=  aAt[ GRA_AS_BGMIXMODE ]
  ENDIF
  //vi sarebbero moltri altri da implementare....

RETURN oldaAttr

METHOD dfPdf:Destroy()
   LOCAL nN
   // Cancello le immagini temporane create
   FOR nN := 1 TO LEN(::aImageCache)
       FERASE(::aImageCache[nN][2])
   NEXT
RETURN Self

//Riscritto .........
//Luca 21/02/03
METHOD dfPdf:Init(cFile, nLen, lOptimize,bShowMsg)
   Local cTemp, nI, nJ, n1, Nn,aArr
   Local cFontFile := "Fonts.Dat"

   DEFAULT nLen      TO 200
   DEFAULT lOptimize TO .F.

   IF VALTYPE(bShowMsg) != "B"
      bShowMsg := NIL
   ENDIF

   ::aImageCache := {}

   ::aReport := array( PDF_PARAMLEN )

   ::aReport[ PDF_FONTNAME     ] := 1
   ::aReport[ PDF_FONTSIZE     ] := 10
   ::aReport[ PDF_LPI          ] := 6
   ::aReport[ PDF_PAGESIZE     ] := PDF_PAGE_A4
   ::aReport[ PDF_PAGEORIENT   ] := PDF_VERTICAL
   ::aReport[ PDF_PAGEX        ] := 8.5 * 72
   ::aReport[ PDF_PAGEY        ] := 11.0 * 72
   ::aReport[ PDF_REPORTWIDTH  ] := nLen    // should be as parameter
   ::aReport[ PDF_REPORTPAGE   ] := 0
   ::aReport[ PDF_REPORTLINE   ] := 0       // 5
   ::aReport[ PDF_FONTNAMEPREV ] := 0
   ::aReport[ PDF_FONTSIZEPREV ] := 0
   ::aReport[ PDF_PAGEBUFFER   ] := ""
   ::aReport[ PDF_REPORTOBJ    ] := 1       //2
   ::aReport[ PDF_DOCLEN       ] := 0
   ::aReport[ PDF_TYPE1        ] := { "Times-Roman", "Times-Bold", "Times-Italic", "Times-BoldItalic", ;
                                      "Helvetica", "Helvetica-Bold", "Helvetica-Oblique", "Helvetica-BoldOblique", ;
                                      "Courier", "Courier-Bold", "Courier-Oblique", "Courier-BoldOblique" ,;
                                      "Arial", "Arial-Bold", "Arial-Oblique", "Arial-BoldOblique", ;
                                      "Verdana", "Verdana-Bold", "Verdana-Oblique", "Verdana-BoldOblique", ;
                                      "Tahoma", "Tahoma-Bold", "Tahoma-Oblique", "Tahoma-BoldOblique" }
   ::aReport[ PDF_MARGINS      ] := .t.
   ::aReport[ PDF_HEADEREDIT   ] := .f.
   ::aReport[ PDF_NEXTOBJ      ] := 0
   ::aReport[ PDF_PDFTOP       ] := 1      // top
   ::aReport[ PDF_PDFLEFT      ] := 10     // left & right
   ::aReport[ PDF_PDFBOTTOM    ] := ::aReport[ PDF_PAGEY ] / 72 * ::aReport[ PDF_LPI ] - 1 // bottom, default "LETTER", "P", 6
   ::aReport[ PDF_HANDLE       ] := fcreate( cFile )
   ::aReport[ PDF_PAGES        ] := {}
   ::aReport[ PDF_REFS         ] := { 0, 0 }
   ::aReport[ PDF_BOOKMARK     ] := {}
   ::aReport[ PDF_HEADER       ] := {}
   ::aReport[ PDF_FONTS        ] := {}
   ::aReport[ PDF_IMAGES       ] := {}
   ::aReport[ PDF_PAGEIMAGES   ] := {}
   ::aReport[ PDF_PAGEFONTS    ] := {}

   ::aReport[ PDF_FONTWIDTH    ] := FontWidthArray()

   ::aReport[ PDF_OPTIMIZE     ] := lOptimize
   ::aReport[ PDF_BUFFERHANDLE ] := 0
   ::aReport[ PDF_NEXTOBJ      ] := ::aReport[ PDF_REPORTOBJ ] + 4

   ::aReport[ PDF_DOCLEN       ] := 0
   cTemp                     := "%PDF-1.3" + CRLF
   ::aReport[ PDF_DOCLEN       ] += len( cTemp )

   Fwrite( ::aReport[ PDF_HANDLE ], cTemp )

   ::bShowMsg   := bShowMsg

   ::aAttribute := ARRAY( GRA_AS_COUNT )
   ::aAttribute[ GRA_AS_COLOR ] := PDF_BLACK

   ::DEVICE     := "_PDF_"
RETURN self

//Riscritto migliorata gestione apertura file Pdf
//Luca 21/02/03
METHOD dfPdf:AtSay( cString, nRow, nCol, cUnits, lExact, cId )    //IN INPUT FILE PDF
local _nFont, lReverse, nId, nAt

// Correzione Simone 10/03/03 perche il "\" Š un codice speciale
// e se voglio mettere il carattere "\" nel PDF devo mettere una doppia "\"
cString := STRTRAN(cString, "\", "\\")

DEFAULT nRow   TO ::aReport[ PDF_REPORTLINE ]
DEFAULT cUnits TO "R"
DEFAULT lExact TO .f.
DEFAULT cId    TO ""

   IF ::aReport[ PDF_HEADEREDIT ]
      return ::Header( "PDFATSAY", cId, { cString, nRow, nCol, cUnits, lExact } )
   ENDIF

   IF ( nAt := at( "#pagenumber#", cString ) ) > 0
      cString := left( cString, nAt - 1 ) + ltrim(str( ::PageNumber())) + substr( cString, nAt + 12 )
   ENDIF

   lReverse = .f.
   IF cUnits == "M"
      nRow := ::M2Y( nRow )
      nCol := ::M2X( nCol )
   ELSEIF cUnits == "R"
      IF .not. lExact
         ::CheckLine( nRow )
         nRow := nRow + ::aReport[ PDF_PDFTOP]
      ENDIF
      nRow := ::R2D( nRow )
      nCol := ::M2X( ::aReport[ PDF_PDFLEFT ] ) + ;
              nCol * 100.00 / ::aReport[ PDF_REPORTWIDTH ] * ;
              ( ::aReport[ PDF_PAGEX ] - ::M2X( ::aReport[ PDF_PDFLEFT ] ) * 2 - 9.0 ) / 100.00
   ENDIF
   IF !empty( cString )
      cString := ::StringB( cString )

      //Questo pezzo Š stato sposta in alto per eseguire prima la gestine colore e poi la sotto lineatura
      //Luca 21/02/03
      // version 0.01
      IF ( nAt := at( chr(253), cString )) > 0 // some color text inside
         /*
         ::aReport[ PAGEBUFFER ] += CRLF + ;
         Chr_RGB( substr( cString, nAt + 1, 1 )) + " " + ;
         Chr_RGB( substr( cString, nAt + 2, 1 )) + " " + ;
         Chr_RGB( substr( cString, nAt + 3, 1 )) + " rg "
         */
         ::AddBuffer( CRLF + ;
                      ::Chr_RGB( substr( cString, nAt + 1, 1 )) + " " + ;
                      ::Chr_RGB( substr( cString, nAt + 2, 1 )) + " " + ;
                      ::Chr_RGB( substr( cString, nAt + 3, 1 )) + " rg " )
         cString := stuff( cString, nAt, 4, "")
      ENDIF
      // version 0.01
      //Questo pezzo Š stato sposta in alto per eseguire prima la gestine colore e poi la sotto lineatura
      //Luca 21/02/03


      IF right( cString, 1 ) == chr(255) //reverse
         cString := left( cString, len( cString ) - 1 )
         ::Box( ::aReport[ PDF_PAGEY ] - nRow - ::aReport[ PDF_FONTSIZE ] + 2.0 , nCol, ::aReport[ PDF_PAGEY ] - nRow + 2.0, nCol + ::M2X( ::length( cString )) + 1,,100, "D")
         //::aReport[ PDF_PAGEBUFFER ] += " 1 g "
         ::AddBuffer( " 1 g " )
         lReverse = .t.
      ELSEIF right( cString, 1 ) == chr(254) //underline
         cString := left( cString, len( cString ) - 1 )
         ::Box( ::aReport[ PDF_PAGEY ] - nRow + 0.5,  nCol, ::aReport[ PDF_PAGEY ] - nRow + 1, nCol + ::M2X( ::length( cString )) + 1,,100, "D")
      ENDIF

      _nFont := ascan( ::aReport[ PDF_FONTS ], {|arr| arr[1] == ::aReport[ PDF_FONTNAME ]} )
      IF ::aReport[ PDF_FONTNAME ] <> ::aReport[ PDF_FONTNAMEPREV ]
         ::aReport[ PDF_FONTNAMEPREV ] := ::aReport[ PDF_FONTNAME ]
         //::aReport[ PDF_PAGEBUFFER ] += CRLF + "BT /Fo" + ltrim(str( _nFont )) + " " + ltrim(::__transform( ::aReport[ PDF_FONTSIZE ], "999.99")) + " Tf " + ltrim(::__transform( nCol, "9999.99" )) + " " + ltrim(::__transform( nRow, "9999.99" )) + " Td (" + cString + ") Tj ET"
         ::AddBuffer( CRLF + "BT /Fo" + ltrim(str( _nFont )) + " " + ltrim(::__transform( ::aReport[ PDF_FONTSIZE ], "999.99")) + " Tf " + ltrim(::__transform( nCol, "9999.99" )) + " " + ltrim(::__transform( nRow, "9999.99" )) + " Td (" + cString + ") Tj ET" )
      ELSEIF ::aReport[ PDF_FONTSIZE ] <> ::aReport[ PDF_FONTSIZEPREV ]
         ::aReport[ PDF_FONTSIZEPREV ] := ::aReport[ PDF_FONTSIZE ]
         //::aReport[ PDF_PAGEBUFFER ] += CRLF + "BT /Fo" + ltrim(str( _nFont )) + " " + ltrim(::__transform( ::aReport[ PDF_FONTSIZE ], "999.99")) + " Tf " + ltrim(::__transform( nCol, "9999.99" )) + " " + ltrim(::__transform( nRow, "9999.99" )) + " Td (" + cString + ") Tj ET"
         ::AddBuffer( CRLF + "BT /Fo" + ltrim(str( _nFont )) + " " + ltrim(::__transform( ::aReport[ PDF_FONTSIZE ], "999.99")) + " Tf " + ltrim(::__transform( nCol, "9999.99" )) + " " + ltrim(::__transform( nRow, "9999.99" )) + " Td (" + cString + ") Tj ET" )
      ELSE
         //::aReport[ PDF_PAGEBUFFER ] += CRLF + "BT " + ltrim(::__transform( nCol, "9999.99" )) + " " + ltrim(::__transform( nRow, "9999.99" )) + " Td (" + cString + ") Tj ET"
         ::AddBuffer( CRLF + "BT " + ltrim(::__transform( nCol, "9999.99" )) + " " + ltrim(::__transform( nRow, "9999.99" )) + " Td (" + cString + ") Tj ET" )
      ENDIF
      IF lReverse
         //::aReport[ PDF_PAGEBUFFER ] += " 0 g "
         ::AddBuffer( " 0 g " )
      ENDIF
   ENDIF

RETURN self


//Riscritto migliorata gestione apertura file Pdf
//Luca 21/02/03
METHOD dfPdf:Execute( cFile )    //IN INPUT FILE PDF
   // Modificato simone 28/8/03 GERR 3911
   dfPdfView(cFile)
/*
   Local cPathAcro :=dfGetAcrobatPath()
   //dfalert("Versione Acrobat Trovata:// //" +cPathAcro+"\AcroRd32.exe")
   cFile := dfFNameBuild(cFile)
   S2OpenRegisteredFile( cFile )
   //RunShell( cFile  ,cPathAcro + "\AcroRd32.exe",.T.,.F. )
*/
RETURN self

//Riscritto migliorata gestion stampa file Pdf
//Luca 21/02/03
METHOD dfPdf:FilePrint( cFile )    //IN INPUT FILE PDF
   Local cPathAcro :=dfGetAcrobatPath()
   cFile := dfFNameBuild(cFile)

   // cMode validi "open", "print",  "explore"
   S2OpenRegisteredFile( cFile, NIL, NIL, "print", NIL )
RETURN self


//Riscritto perche no gestiva i file BMP
//Luca 21/02/03
METHOD dfPdf:ImageInfo( cFile )
local cTemp := upper(substr( cFile, rat('.', cFile) + 1 )), aTemp := {}
   do case
      case cTemp == "TIF"
         aTemp := ::TIFFInfo( cFile )
      case cTemp == "JPG"
         aTemp := ::JPEGInfo( cFile )
      case cTemp == "BMP"
         aTemp := ::BMPInfo( cFile )
   endcase
RETURN aTemp

//Riscritto il metodo perchŠ la gestione del formato bmp Š troppo complicato -> si converte il tutto in tif
//Luca 21/02/03
METHOD dfPdf:BMPInfo( cFile )
   LOCAL aFName      := dfFNameSplit(cFile)
   //LOCAL cFileJPG    := aFName[1]+aFName[2]+aFName[3]+".JPG"
   //LOCAL cFileTif    := aFName[1]+aFName[2]+aFName[3]+".Tif"
   LOCAL cFileOut
   LOCAL aTemp := {}
   LOCAL cConv       := dfSet("XbasePdfBMPConversion")
   DEFAULT cConv   TO "JPG/6"

   cConv := UPPER(cConv)

   IF FILE(cFile)
      IF "JP" $ cConv
         IF !::BMP2JPEG(cFile,cConv,@cFileOut)
            dbmsgerr(dfStdMsg1(MSG1_DFJPG02)+"//"+cFile)
         ENDIF
         aTemp := ::JPEGInfo( cFileOut )
      ELSEIF "TIF" $ cConv
         IF !::BMP2TIFF(cFile,@cFileOut)
            dbmsgerr(dfStdMsg1(MSG1_DFTIFF02)+"//"+cFile)
         ENDIF
         aTemp := ::TIFFInfo( cFileOut )
      ENDIF
      cFile := cfileOut
   ENDIF
RETURN aTemp

//Riscritto il metodo perchŠ la gestione del formato bmp Š troppo complicato -> si converte il tutto in tif
//Luca 21/02/03
METHOD dfPdf:Image( cFile, nRow, nCol, cUnits, nHeight, nWidth, cId )
   LOCAL nImage
   LOCAL aFName      := dfFNameSplit(cFile)
   //LOCAL cFileTif    := aFName[1]+aFName[2]+aFName[3]+".Tif"
   //LOCAL cFileJPG    := aFName[1]+aFName[2]+aFName[3]+".JPG"
   LOCAL cConv       := dfSet("XbasePdfBMPConversion")
   LOCAL cFileOut

   DEFAULT nRow    TO ::aReport[ PDF_REPORTLINE ]
   DEFAULT nCol    TO 0
   DEFAULT nHeight TO 0
   DEFAULT nWidth  TO 0
   DEFAULT cUnits  TO "R"
   DEFAULT cId     TO ""
   DEFAULT cConv   TO "JPG/6"    //Significa conversione in JPEG qualit… GOOD

   cConv := UPPER(cConv)

   //Riscritto il metodo perchŠ la gestione del formato bmp Š troppo complicato -> si converte il tutto in tif
   //Luca 21/02/03
   IF !EMPTY(aFName[4]) .AND. ;
      UPPER(RIGHT(aFName[4],3)) == "BMP"
      IF "JP" $ cConv
         IF !::BMP2JPEG(cFile,cConv,@cFileOut)
            dbmsgerr(dfStdMsg1(MSG1_DFJPG02)+"//"+cFile)
         ENDIF
      ELSEIF "TIF" $ cConv
         IF !::BMP2TIFF(cFile,@cFileOut)
            dbmsgerr(dfStdMsg1(MSG1_DFTIFF02)+"//"+cFile)
         ENDIF
      ENDIF
      cFile := cfileOut
   ENDIF
   //Fine Modifiche LUCA

   IF ::aReport[ PDF_HEADEREDIT ]
      return ::Header( "PDFIMAGE", cId, { cFile, nRow, nCol, cUnits, nHeight, nWidth } )
   ENDIF

   IF cUnits == "M"
      nRow    := ::aReport[ PDF_PAGEY ] - ::M2Y( nRow )
      nCol    := ::M2X( nCol )
      nHeight := ::aReport[ PDF_PAGEY ] - ::M2Y( nHeight )
      nWidth  := ::M2X( nWidth )
   ELSEIF cUnits == "R"
      //IF .not. lExact
      //   ::CheckLine( nRow )
      //   nRow := nRow + ::aReportStyle[ PDF_PDFTOP]
      //ENDIF
      nRow := ::aReport[ PDF_PAGEY ] - ::R2D( nRow )
      nCol := ::M2X( ::aReport[ PDF_PDFLEFT ] ) + ;
              nCol * 100.00 / ::aReport[ PDF_REPORTWIDTH ] * ;
              ( ::aReport[ PDF_PAGEX ] - ::M2X( ::aReport[ PDF_PDFLEFT ] ) * 2 - 9.0 ) / 100.00
      nHeight := ::aReport[ PDF_PAGEY ] - ::R2D( nHeight )
      nWidth := ::M2X( ::aReport[ PDF_PDFLEFT ] ) + ;
              nWidth * 100.00 / ::aReport[ PDF_REPORTWIDTH ] * ;
              ( ::aReport[ PDF_PAGEX ] - ::M2X( ::aReport[ PDF_PDFLEFT ] ) * 2 - 9.0 ) / 100.00
   ELSEIF cUnits == "D"
   ENDIF

   aadd( ::aReport[ PDF_PAGEIMAGES ], { cFile, nRow, nCol, nHeight, nWidth } )

RETURN self

METHOD dfPdf:Bmp2Tiff(cImgIn,cImgOut)
   LOCAL lOK      := .F.
   LOCAL nQuality := TIFF_NONE //VEDI Image.ch
   LOCAL nImg

   nImg := ASCAN(::aImageCache, {|a| a[1]==cImgIn })
   IF nImg >0
      cImgOut := ::aImageCache[nImg][2]
      lOk := .T.
      IF !FILE(cImgOut)
         ::ShowMsg(dfStdMsg1(MSG1_DFPDF06))
         lOK := dfBMP2TIFF(cImgIn,cImgOut,nQuality)
         ::HideMsg("")
      ENDIF
   ELSE
      FCLOSE(dfFileTemp(@cImgOut, "PdfIm", NIL, "TIF"))
      ::ShowMsg(dfStdMsg1(MSG1_DFPDF06))
      lOK := dfBMP2TIFF(cImgIn,cImgOut,nQuality)
      ::HideMsg("")
      AADD(::aImageCache,{cImgIn,cImgOut})
   ENDIF
RETURN lOk

METHOD dfPdf:Bmp2JPEG(cImgIn,cPara,cImgOut)
   LOCAL lOK      := .F.
   LOCAL nQuality := JPEG_QUALITYGOOD
   LOCAL nImg

   DO CASE
      CASE "1" $ cPara
         nQuality := JPEG_FAST
      CASE "2" $ cPara
         nQuality := JPEG_ACCURATE
      CASE "3" $ cPara
         nQuality := JPEG_QUALITYBAD
      CASE "4" $ cPara
         nQuality := JPEG_QUALITYAVERAGE
      CASE "5" $ cPara
         nQuality := JPEG_QUALITYNORMAL
      CASE "6" $ cPara
         nQuality := JPEG_QUALITYGOOD
      CASE "7" $ cPara
         nQuality := JPEG_QUALITYSUPERB
   END CASE

   nImg := ASCAN(::aImageCache, {|a| a[1]==cImgIn })
   IF nImg >0
      cImgOut := ::aImageCache[nImg][2]
      lOk := .T.
      IF !FILE(cImgOut)
         ::ShowMsg(dfStdMsg1(MSG1_DFPDF06))
         lOK := dfBMP2JPEG(cImgIn,cImgOUT,nQuality)
         ::HideMsg("")
      ENDIF
   ELSE
      FCLOSE(dfFileTemp(@cImgOut, "PdfIm", NIL, "JPG"))
      ::ShowMsg(dfStdMsg1(MSG1_DFPDF06))
      lOK := dfBMP2JPEG(cImgIn,cImgOUT,nQuality)
      ::HideMsg("")
      AADD(::aImageCache,{cImgIn,cImgOut})
   ENDIF
RETURN lOk


METHOD dfPdf:TIFFInfo( cFile )
   LOCAL aRet := ::tPdf:TIFFInfo( cFile )

   //Luca
   IF aRet[3] <1
      aRet[3] := 100
   ENDIF
   IF aRet[4] <1
      aRet[4] := 100
   ENDIF
RETURN aRet


METHOD dfPdf:Chr_RGB( cChar )
return str(asc( cChar ) / 255, 4, 2)

STATIC FUNCTION FontWidthArray()
   STATIC aFW
   LOCAL cFontFile
   LOCAL cTemp
   LOCAL aArr
   LOCAL n1,n2 := 896,n12,nI,nJ


   IF aFW == NIL
      IF !EMPTY(dfSet("XbasePdfFontsFile") )
         cFontFile := dfSet("XbasePdfFontsFile")
      ELSE
         cFontFile := "dbPDFFnt.DAT"
      ENDIF

      IF FILE(cFontFile)
         cTemp  := dfFileRead( cFontFile )
      ELSE
         aArr := _FileBin()
         cTemp := ""
         AEVAL( aArr, {|aLine| AEVAL( aLine, {|n| cTemp += CHR(n) } ) })
      ENDIF

      n1  := len( cTemp ) / ( 2 * n2 )
      aFW := Array( n1, n2 )
      n12 := 2 * n2

      For nI := 1 to n1
         For nJ := 1 to n2
            aFW[ nI ][ nJ ] := bin2i( substr( cTemp, ( nI - 1 ) * n12 + ( nJ - 1 ) * 2 + 1, 2 ) )
         Next
      Next
   ENDIF
RETURN aFW

STATIC FUNCTION _FileBin()
   LOCAL aBin := {}
   AADD(aBin, {250, 000, 250, 000, 250, 000, 250, 000, 077, 001, 077, 001})
   AADD(aBin, {077, 001, 133, 001, 152, 001, 043, 002, 164, 001, 043, 002})
   AADD(aBin, {244, 001, 244, 001, 244, 001, 244, 001, 244, 001, 244, 001})
   AADD(aBin, {244, 001, 244, 001, 065, 003, 232, 003, 065, 003, 065, 003})
   AADD(aBin, {010, 003, 065, 003, 010, 003, 010, 003, 077, 001, 077, 001})
   AADD(aBin, {077, 001, 077, 001, 077, 001, 077, 001, 077, 001, 077, 001})
   AADD(aBin, {077, 001, 077, 001, 077, 001, 077, 001, 244, 001, 244, 001})
   AADD(aBin, {244, 001, 244, 001, 052, 002, 058, 002, 163, 002, 058, 002})
   AADD(aBin, {250, 000, 250, 000, 250, 000, 250, 000, 077, 001, 077, 001})
   AADD(aBin, {077, 001, 077, 001, 250, 000, 250, 000, 250, 000, 250, 000})
   AADD(aBin, {022, 001, 022, 001, 022, 001, 022, 001, 244, 001, 244, 001})
   AADD(aBin, {244, 001, 244, 001, 244, 001, 244, 001, 244, 001, 244, 001})
   AADD(aBin, {244, 001, 244, 001, 244, 001, 244, 001, 244, 001, 244, 001})
   AADD(aBin, {244, 001, 244, 001, 244, 001, 244, 001, 244, 001, 244, 001})
   AADD(aBin, {244, 001, 244, 001, 244, 001, 244, 001, 244, 001, 244, 001})
   AADD(aBin, {244, 001, 244, 001, 244, 001, 244, 001, 244, 001, 244, 001})
   AADD(aBin, {244, 001, 244, 001, 244, 001, 244, 001, 244, 001, 244, 001})
   AADD(aBin, {244, 001, 244, 001, 022, 001, 077, 001, 077, 001, 077, 001})
   AADD(aBin, {022, 001, 077, 001, 077, 001, 077, 001, 052, 002, 058, 002})
   AADD(aBin, {163, 002, 058, 002, 052, 002, 058, 002, 163, 002, 058, 002})
   AADD(aBin, {052, 002, 058, 002, 163, 002, 058, 002, 188, 001, 244, 001})
   AADD(aBin, {244, 001, 244, 001, 153, 003, 162, 003, 152, 003, 064, 003})
   AADD(aBin, {210, 002, 210, 002, 099, 002, 155, 002, 155, 002, 155, 002})
   AADD(aBin, {099, 002, 155, 002, 155, 002, 210, 002, 155, 002, 155, 002})
   AADD(aBin, {210, 002, 210, 002, 210, 002, 210, 002, 099, 002, 155, 002})
   AADD(aBin, {099, 002, 155, 002, 044, 002, 099, 002, 099, 002, 155, 002})
   AADD(aBin, {210, 002, 010, 003, 210, 002, 210, 002, 210, 002, 010, 003})
   AADD(aBin, {210, 002, 010, 003, 077, 001, 133, 001, 077, 001, 133, 001})
   AADD(aBin, {133, 001, 244, 001, 188, 001, 244, 001, 210, 002, 010, 003})
   AADD(aBin, {155, 002, 155, 002, 099, 002, 155, 002, 044, 002, 099, 002})
   AADD(aBin, {121, 003, 176, 003, 065, 003, 121, 003, 210, 002, 210, 002})
   AADD(aBin, {155, 002, 210, 002, 210, 002, 010, 003, 210, 002, 210, 002})
   AADD(aBin, {044, 002, 099, 002, 099, 002, 099, 002, 210, 002, 010, 003})
   AADD(aBin, {210, 002, 210, 002, 155, 002, 210, 002, 099, 002, 155, 002})
   AADD(aBin, {044, 002, 044, 002, 244, 001, 044, 002, 099, 002, 155, 002})
   AADD(aBin, {044, 002, 099, 002, 210, 002, 210, 002, 210, 002, 210, 002})
   AADD(aBin, {210, 002, 210, 002, 099, 002, 155, 002, 176, 003, 232, 003})
   AADD(aBin, {065, 003, 121, 003, 210, 002, 210, 002, 099, 002, 155, 002})
   AADD(aBin, {210, 002, 210, 002, 044, 002, 099, 002, 099, 002, 155, 002})
   AADD(aBin, {044, 002, 099, 002, 077, 001, 077, 001, 133, 001, 077, 001})
   AADD(aBin, {022, 001, 022, 001, 022, 001, 022, 001, 077, 001, 077, 001})
   AADD(aBin, {133, 001, 077, 001, 213, 001, 069, 002, 166, 001, 058, 002})
   AADD(aBin, {244, 001, 244, 001, 244, 001, 244, 001, 077, 001, 077, 001})
   AADD(aBin, {077, 001, 077, 001, 188, 001, 244, 001, 244, 001, 244, 001})
   AADD(aBin, {244, 001, 044, 002, 244, 001, 244, 001, 188, 001, 188, 001})
   AADD(aBin, {188, 001, 188, 001, 244, 001, 044, 002, 244, 001, 244, 001})
   AADD(aBin, {188, 001, 188, 001, 188, 001, 188, 001, 077, 001, 077, 001})
   AADD(aBin, {022, 001, 077, 001, 244, 001, 244, 001, 244, 001, 244, 001})
   AADD(aBin, {244, 001, 044, 002, 244, 001, 044, 002, 022, 001, 022, 001})
   AADD(aBin, {022, 001, 022, 001, 022, 001, 077, 001, 022, 001, 022, 001})
   AADD(aBin, {244, 001, 044, 002, 188, 001, 244, 001, 022, 001, 022, 001})
   AADD(aBin, {022, 001, 022, 001, 010, 003, 065, 003, 210, 002, 010, 003})
   AADD(aBin, {244, 001, 044, 002, 244, 001, 044, 002, 244, 001, 244, 001})
   AADD(aBin, {244, 001, 244, 001, 244, 001, 044, 002, 244, 001, 244, 001})
   AADD(aBin, {244, 001, 044, 002, 244, 001, 244, 001, 077, 001, 188, 001})
   AADD(aBin, {133, 001, 133, 001, 133, 001, 133, 001, 133, 001, 133, 001})
   AADD(aBin, {022, 001, 077, 001, 022, 001, 022, 001, 244, 001, 044, 002})
   AADD(aBin, {244, 001, 044, 002, 244, 001, 244, 001, 188, 001, 188, 001})
   AADD(aBin, {210, 002, 210, 002, 155, 002, 155, 002, 244, 001, 244, 001})
   AADD(aBin, {188, 001, 244, 001, 244, 001, 244, 001, 188, 001, 188, 001})
   AADD(aBin, {188, 001, 188, 001, 133, 001, 133, 001, 224, 001, 138, 001})
   AADD(aBin, {144, 001, 092, 001, 200, 000, 220, 000, 019, 001, 220, 000})
   AADD(aBin, {224, 001, 138, 001, 144, 001, 092, 001, 029, 002, 008, 002})
   AADD(aBin, {029, 002, 058, 002, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {077, 001, 077, 001, 133, 001, 133, 001, 244, 001, 244, 001})
   AADD(aBin, {244, 001, 244, 001, 244, 001, 244, 001, 244, 001, 244, 001})
   AADD(aBin, {167, 000, 167, 000, 167, 000, 167, 000, 244, 001, 244, 001})
   AADD(aBin, {244, 001, 244, 001, 244, 001, 244, 001, 244, 001, 244, 001})
   AADD(aBin, {244, 001, 244, 001, 244, 001, 244, 001, 244, 001, 244, 001})
   AADD(aBin, {244, 001, 244, 001, 180, 000, 022, 001, 214, 000, 022, 001})
   AADD(aBin, {188, 001, 244, 001, 044, 002, 244, 001, 244, 001, 244, 001})
   AADD(aBin, {244, 001, 244, 001, 077, 001, 077, 001, 077, 001, 077, 001})
   AADD(aBin, {077, 001, 077, 001, 077, 001, 077, 001, 044, 002, 044, 002})
   AADD(aBin, {244, 001, 044, 002, 044, 002, 044, 002, 244, 001, 044, 002})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 244, 001, 244, 001})
   AADD(aBin, {244, 001, 244, 001, 244, 001, 244, 001, 244, 001, 244, 001})
   AADD(aBin, {244, 001, 244, 001, 244, 001, 244, 001, 250, 000, 250, 000})
   AADD(aBin, {250, 000, 250, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {197, 001, 028, 002, 011, 002, 244, 001, 094, 001, 094, 001})
   AADD(aBin, {094, 001, 094, 001, 077, 001, 077, 001, 077, 001, 077, 001})
   AADD(aBin, {188, 001, 244, 001, 044, 002, 244, 001, 188, 001, 244, 001})
   AADD(aBin, {044, 002, 244, 001, 244, 001, 244, 001, 244, 001, 244, 001})
   AADD(aBin, {232, 003, 232, 003, 121, 003, 232, 003, 232, 003, 232, 003})
   AADD(aBin, {232, 003, 232, 003, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {188, 001, 244, 001, 244, 001, 244, 001, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 077, 001, 077, 001, 077, 001, 077, 001})
   AADD(aBin, {077, 001, 077, 001, 077, 001, 077, 001, 077, 001, 077, 001})
   AADD(aBin, {077, 001, 077, 001, 077, 001, 077, 001, 077, 001, 077, 001})
   AADD(aBin, {077, 001, 077, 001, 077, 001, 077, 001, 077, 001, 077, 001})
   AADD(aBin, {077, 001, 077, 001, 077, 001, 077, 001, 077, 001, 077, 001})
   AADD(aBin, {077, 001, 077, 001, 077, 001, 077, 001, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 077, 001, 077, 001, 077, 001, 077, 001})
   AADD(aBin, {077, 001, 077, 001, 077, 001, 077, 001, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 077, 001, 077, 001, 077, 001, 077, 001})
   AADD(aBin, {077, 001, 077, 001, 077, 001, 077, 001, 077, 001, 077, 001})
   AADD(aBin, {077, 001, 077, 001, 232, 003, 232, 003, 121, 003, 232, 003})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 121, 003, 232, 003})
   AADD(aBin, {121, 003, 176, 003, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {020, 001, 044, 001, 020, 001, 010, 001, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 099, 002, 155, 002, 044, 002, 099, 002})
   AADD(aBin, {210, 002, 010, 003, 210, 002, 210, 002, 121, 003, 232, 003})
   AADD(aBin, {176, 003, 176, 003, 054, 001, 074, 001, 054, 001, 044, 001})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 155, 002, 210, 002, 155, 002, 210, 002})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {022, 001, 022, 001, 022, 001, 022, 001, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {022, 001, 022, 001, 022, 001, 022, 001, 244, 001, 244, 001})
   AADD(aBin, {244, 001, 244, 001, 210, 002, 210, 002, 155, 002, 210, 002})
   AADD(aBin, {244, 001, 044, 002, 244, 001, 244, 001, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 022, 001, 022, 001, 022, 001, 022, 001})
   AADD(aBin, {022, 001, 077, 001, 022, 001, 077, 001, 099, 001, 218, 001})
   AADD(aBin, {099, 001, 218, 001, 044, 002, 044, 002, 044, 002, 044, 002})
   AADD(aBin, {044, 002, 044, 002, 044, 002, 044, 002, 121, 003, 121, 003})
   AADD(aBin, {121, 003, 121, 003, 155, 002, 210, 002, 155, 002, 210, 002})
   AADD(aBin, {222, 000, 022, 001, 222, 000, 022, 001, 077, 001, 077, 001})
   AADD(aBin, {077, 001, 077, 001, 077, 001, 077, 001, 077, 001, 077, 001})
   AADD(aBin, {133, 001, 133, 001, 133, 001, 133, 001, 072, 002, 072, 002})
   AADD(aBin, {072, 002, 072, 002, 022, 001, 022, 001, 022, 001, 022, 001})
   AADD(aBin, {077, 001, 077, 001, 077, 001, 077, 001, 022, 001, 022, 001})
   AADD(aBin, {022, 001, 022, 001, 022, 001, 022, 001, 022, 001, 022, 001})
   AADD(aBin, {044, 002, 044, 002, 044, 002, 044, 002, 044, 002, 044, 002})
   AADD(aBin, {044, 002, 044, 002, 044, 002, 044, 002, 044, 002, 044, 002})
   AADD(aBin, {044, 002, 044, 002, 044, 002, 044, 002, 044, 002, 044, 002})
   AADD(aBin, {044, 002, 044, 002, 044, 002, 044, 002, 044, 002, 044, 002})
   AADD(aBin, {044, 002, 044, 002, 044, 002, 044, 002, 044, 002, 044, 002})
   AADD(aBin, {044, 002, 044, 002, 044, 002, 044, 002, 044, 002, 044, 002})
   AADD(aBin, {044, 002, 044, 002, 044, 002, 044, 002, 022, 001, 077, 001})
   AADD(aBin, {022, 001, 077, 001, 022, 001, 077, 001, 022, 001, 077, 001})
   AADD(aBin, {072, 002, 072, 002, 072, 002, 072, 002, 072, 002, 072, 002})
   AADD(aBin, {072, 002, 072, 002, 072, 002, 072, 002, 072, 002, 072, 002})
   AADD(aBin, {044, 002, 099, 002, 044, 002, 099, 002, 247, 003, 207, 003})
   AADD(aBin, {247, 003, 207, 003, 155, 002, 210, 002, 155, 002, 210, 002})
   AADD(aBin, {155, 002, 210, 002, 155, 002, 210, 002, 210, 002, 210, 002})
   AADD(aBin, {210, 002, 210, 002, 210, 002, 210, 002, 210, 002, 210, 002})
   AADD(aBin, {155, 002, 155, 002, 155, 002, 155, 002, 099, 002, 099, 002})
   AADD(aBin, {099, 002, 099, 002, 010, 003, 010, 003, 010, 003, 010, 003})
   AADD(aBin, {210, 002, 210, 002, 210, 002, 210, 002, 022, 001, 022, 001})
   AADD(aBin, {022, 001, 022, 001, 244, 001, 044, 002, 244, 001, 044, 002})
   AADD(aBin, {155, 002, 210, 002, 155, 002, 210, 002, 044, 002, 099, 002})
   AADD(aBin, {044, 002, 099, 002, 065, 003, 065, 003, 065, 003, 065, 003})
   AADD(aBin, {210, 002, 210, 002, 210, 002, 210, 002, 010, 003, 010, 003})
   AADD(aBin, {010, 003, 010, 003, 155, 002, 155, 002, 155, 002, 155, 002})
   AADD(aBin, {010, 003, 010, 003, 010, 003, 010, 003, 210, 002, 210, 002})
   AADD(aBin, {210, 002, 210, 002, 155, 002, 155, 002, 155, 002, 155, 002})
   AADD(aBin, {099, 002, 099, 002, 099, 002, 099, 002, 210, 002, 210, 002})
   AADD(aBin, {210, 002, 210, 002, 155, 002, 155, 002, 155, 002, 155, 002})
   AADD(aBin, {176, 003, 176, 003, 176, 003, 176, 003, 155, 002, 155, 002})
   AADD(aBin, {155, 002, 155, 002, 155, 002, 155, 002, 155, 002, 155, 002})
   AADD(aBin, {099, 002, 099, 002, 099, 002, 099, 002, 022, 001, 077, 001})
   AADD(aBin, {022, 001, 077, 001, 022, 001, 022, 001, 022, 001, 022, 001})
   AADD(aBin, {022, 001, 077, 001, 022, 001, 077, 001, 213, 001, 072, 002})
   AADD(aBin, {213, 001, 072, 002, 044, 002, 044, 002, 044, 002, 044, 002})
   AADD(aBin, {222, 000, 022, 001, 222, 000, 022, 001, 044, 002, 044, 002})
   AADD(aBin, {044, 002, 044, 002, 044, 002, 099, 002, 044, 002, 099, 002})
   AADD(aBin, {244, 001, 044, 002, 244, 001, 044, 002, 044, 002, 099, 002})
   AADD(aBin, {044, 002, 099, 002, 044, 002, 044, 002, 044, 002, 044, 002})
   AADD(aBin, {022, 001, 077, 001, 022, 001, 077, 001, 044, 002, 099, 002})
   AADD(aBin, {044, 002, 099, 002, 044, 002, 099, 002, 044, 002, 099, 002})
   AADD(aBin, {222, 000, 022, 001, 222, 000, 022, 001, 222, 000, 022, 001})
   AADD(aBin, {222, 000, 022, 001, 244, 001, 044, 002, 244, 001, 044, 002})
   AADD(aBin, {222, 000, 022, 001, 222, 000, 022, 001, 065, 003, 121, 003})
   AADD(aBin, {065, 003, 121, 003, 044, 002, 099, 002, 044, 002, 099, 002})
   AADD(aBin, {044, 002, 099, 002, 044, 002, 099, 002, 044, 002, 099, 002})
   AADD(aBin, {044, 002, 099, 002, 044, 002, 099, 002, 044, 002, 099, 002})
   AADD(aBin, {077, 001, 133, 001, 077, 001, 133, 001, 244, 001, 044, 002})
   AADD(aBin, {244, 001, 044, 002, 022, 001, 077, 001, 022, 001, 077, 001})
   AADD(aBin, {044, 002, 099, 002, 044, 002, 099, 002, 244, 001, 044, 002})
   AADD(aBin, {244, 001, 044, 002, 210, 002, 010, 003, 210, 002, 010, 003})
   AADD(aBin, {244, 001, 044, 002, 244, 001, 044, 002, 244, 001, 044, 002})
   AADD(aBin, {244, 001, 044, 002, 244, 001, 244, 001, 244, 001, 244, 001})
   AADD(aBin, {078, 001, 133, 001, 078, 001, 133, 001, 004, 001, 024, 001})
   AADD(aBin, {004, 001, 024, 001, 078, 001, 133, 001, 078, 001, 133, 001})
   AADD(aBin, {072, 002, 072, 002, 072, 002, 072, 002, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 077, 001, 077, 001, 077, 001, 077, 001})
   AADD(aBin, {044, 002, 044, 002, 044, 002, 044, 002, 044, 002, 044, 002})
   AADD(aBin, {044, 002, 044, 002, 167, 000, 167, 000, 167, 000, 167, 000})
   AADD(aBin, {044, 002, 044, 002, 044, 002, 044, 002, 044, 002, 044, 002})
   AADD(aBin, {044, 002, 044, 002, 044, 002, 044, 002, 044, 002, 044, 002})
   AADD(aBin, {044, 002, 044, 002, 044, 002, 044, 002, 191, 000, 238, 000})
   AADD(aBin, {191, 000, 238, 000, 077, 001, 244, 001, 077, 001, 244, 001})
   AADD(aBin, {044, 002, 044, 002, 044, 002, 044, 002, 077, 001, 077, 001})
   AADD(aBin, {077, 001, 077, 001, 077, 001, 077, 001, 077, 001, 077, 001})
   AADD(aBin, {244, 001, 099, 002, 244, 001, 099, 002, 244, 001, 099, 002})
   AADD(aBin, {244, 001, 099, 002, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {044, 002, 044, 002, 044, 002, 044, 002, 044, 002, 044, 002})
   AADD(aBin, {044, 002, 044, 002, 044, 002, 044, 002, 044, 002, 044, 002})
   AADD(aBin, {022, 001, 022, 001, 022, 001, 022, 001, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 025, 002, 044, 002, 025, 002, 044, 002})
   AADD(aBin, {094, 001, 094, 001, 094, 001, 094, 001, 222, 000, 022, 001})
   AADD(aBin, {222, 000, 022, 001, 077, 001, 244, 001, 077, 001, 244, 001})
   AADD(aBin, {077, 001, 244, 001, 077, 001, 244, 001, 044, 002, 044, 002})
   AADD(aBin, {044, 002, 044, 002, 232, 003, 232, 003, 232, 003, 232, 003})
   AADD(aBin, {232, 003, 232, 003, 232, 003, 232, 003, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 099, 002, 099, 002, 099, 002, 099, 002})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 077, 001, 077, 001})
   AADD(aBin, {077, 001, 077, 001, 077, 001, 077, 001, 077, 001, 077, 001})
   AADD(aBin, {077, 001, 077, 001, 077, 001, 077, 001, 077, 001, 077, 001})
   AADD(aBin, {077, 001, 077, 001, 077, 001, 077, 001, 077, 001, 077, 001})
   AADD(aBin, {077, 001, 077, 001, 077, 001, 077, 001, 077, 001, 077, 001})
   AADD(aBin, {077, 001, 077, 001, 077, 001, 077, 001, 077, 001, 077, 001})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 077, 001, 077, 001})
   AADD(aBin, {077, 001, 077, 001, 077, 001, 077, 001, 077, 001, 077, 001})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 077, 001, 077, 001})
   AADD(aBin, {077, 001, 077, 001, 077, 001, 077, 001, 077, 001, 077, 001})
   AADD(aBin, {077, 001, 077, 001, 077, 001, 077, 001, 232, 003, 232, 003})
   AADD(aBin, {232, 003, 232, 003, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {232, 003, 232, 003, 232, 003, 232, 003, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 114, 001, 114, 001, 114, 001, 114, 001})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 044, 002, 099, 002})
   AADD(aBin, {044, 002, 099, 002, 010, 003, 010, 003, 010, 003, 010, 003})
   AADD(aBin, {232, 003, 232, 003, 232, 003, 232, 003, 109, 001, 109, 001})
   AADD(aBin, {109, 001, 109, 001, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 121, 003, 121, 003})
   AADD(aBin, {121, 003, 121, 003, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 022, 001, 022, 001, 022, 001, 022, 001})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 222, 000, 022, 001, 222, 000, 022, 001})
   AADD(aBin, {099, 002, 099, 002, 099, 002, 099, 002, 176, 003, 176, 003})
   AADD(aBin, {176, 003, 176, 003, 099, 002, 099, 002, 099, 002, 099, 002})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000, 000})
   AADD(aBin, {000, 000, 000, 000, 000, 000, 000, 000, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
   AADD(aBin, {088, 002, 088, 002, 088, 002, 088, 002, 088, 002, 088, 002})
RETURN aBin



