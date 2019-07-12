#include "Common.ch"
#include "dfReport.ch"
#include "dfWinRep.ch"
#include "gra.ch"
#include "xbp.ch"
#include "dfPdf.ch"
#include "dfMsg1.ch"


#define ATTR_TYPE    1
#define ATTR_TYPE_DEFAULT PRN_NORMAL

#define ATTR_FONT    2




FUNCTION dfPdfPrnReset()
   LOCAL oStackFont := S2Stack():new()
RETURN {ATTR_TYPE_DEFAULT, oStackFont}

// Stampa una stringa ad una posizione (come GRASTRINGAT())
// con gli attributi correnti aCurrAttr ( es. "10.arial" oppure PRN_BOLD+PRN_ITALIC )
// intercettando se nella stringa ci sono degli attributi specificati
//
// Esempio
//
//    nAttr := dfWinPrnReset() // Imposta gli attributi normali
//
//    cString := "PROVA "+DFWINREP_BOLDON+"CARATTERE BOLD"+DFWINREP_BOLDOFF
//
//    // Stampa la stringa con gli attributi correnti
//    dfWinPrnStringAt( oPS, { 0, 1000 }, cString, @nAttr )
//
//

FUNCTION dfPdfStringAt(cString, oPdf, aPos , nFontHeigth, oFont,aCurrAttr , bFont)
   LOCAL nSegment:= 0
   LOCAL lOk     := .F.
   //LOCAL aPrn    := {}
   LOCAL cPre    := ""
   LOCAL aCod
   LOCAL lNoChange := .F.
   LOCAL aTextBox
   LOCAL lPreview := .F. //(nSegment != NIL)
   LOCAL nPrintedWidth
   LOCAL aSTRING := { { DFWINREP_SETUP          , {|| aCurrAttr[ATTR_TYPE] := ATTR_TYPE_DEFAULT  } }, ;
                      { DFWINREP_RESET          , {|| aCurrAttr[ATTR_TYPE] := ATTR_TYPE_DEFAULT  } }, ;
                      { DFWINREP_BOLDON         , {|| SetAttrib(aCurrAttr, PRN_BOLD       , .T.) } }, ;
                      { DFWINREP_BOLDOFF        , {|| SetAttrib(aCurrAttr, PRN_BOLD       , .F.) } }, ;
   /* !! */           { DFWINREP_ENLARGEDON     , {|| SetAttrib(aCurrAttr, PRN_ENLARGED   , .F.) } }, ;
                      { DFWINREP_ENLARGEDOFF    , {|| SetAttrib(aCurrAttr, PRN_ENLARGED   , .F.) } }, ;
                      { DFWINREP_UNDERLINEON    , {|| SetAttrib(aCurrAttr, PRN_UNDERLINE  , .T.) } }, ;
                      { DFWINREP_UNDERLINEOFF   , {|| SetAttrib(aCurrAttr, PRN_UNDERLINE  , .F.) } }, ;
   /* !! */           { DFWINREP_SUPERSCRIPTON  , {|| SetAttrib(aCurrAttr, PRN_SUPERSCRIPT, .F.) } }, ;
                      { DFWINREP_SUPERSCRIPTOFF , {|| SetAttrib(aCurrAttr, PRN_SUPERSCRIPT, .F.) } }, ;
   /* !! */           { DFWINREP_SUBSCRIPTON    , {|| SetAttrib(aCurrAttr, PRN_SUBSCRIPT  , .F.) } }, ;
                      { DFWINREP_SUBSCRIPTOFF   , {|| SetAttrib(aCurrAttr, PRN_SUBSCRIPT  , .F.) } }, ;
                      { DFWINREP_CONDENSEDON    , {|| SetAttrib(aCurrAttr, PRN_CONDENSED  , .T.) } }, ;
                      { DFWINREP_CONDENSEDOFF   , {|| SetAttrib(aCurrAttr, PRN_CONDENSED  , .F.) } }, ;
                      { DFWINREP_ITALICON       , {|| SetAttrib(aCurrAttr, PRN_ITALIC     , .T.) } }, ;
                      { DFWINREP_ITALICOFF      , {|| SetAttrib(aCurrAttr, PRN_ITALIC     , .F.) } }, ;
   /* !! */           { DFWINREP_NLQON          , {|| SetAttrib(aCurrAttr, PRN_NLQ        , .F.) } }, ;
                      { DFWINREP_NLQOFF         , {|| SetAttrib(aCurrAttr, PRN_NLQ        , .F.) } }, ;
                      { DFWINREP_USER01ON       , {|| SetAttrib(aCurrAttr, PRN_USER01     , .T.) } }, ;
                      { DFWINREP_USER01OFF      , {|| SetAttrib(aCurrAttr, PRN_USER01     , .F.) } }, ;
                      { DFWINREP_USER02ON       , {|| SetAttrib(aCurrAttr, PRN_USER02     , .T.) } }, ;
                      { DFWINREP_USER02OFF      , {|| SetAttrib(aCurrAttr, PRN_USER02     , .F.) } }, ;
                      { DFWINREP_USER03ON       , {|| SetAttrib(aCurrAttr, PRN_USER03     , .T.) } }, ;
                      { DFWINREP_USER03OFF      , {|| SetAttrib(aCurrAttr, PRN_USER03     , .F.) } }, ;
                      { DFWINREP_FONTON         , {|| aCurrAttr[ATTR_FONT]:push( S2ApplicationFont( SplitString(@cString, DFWINREP_FONTON) ) )} }, ;
                      { DFWINREP_FONTOFF        , {|| aCurrAttr[ATTR_FONT]:pop() } }, ;
                      { DFWINREP_CODEBLOCK      , {|| EvalCBlock(@cString, oPdf, aPos, nFontHeigth) } }, ;
                      { DFWINREP_IMAGE          , {|| cString:=AddImg(cString,oPdf, aPos,oFont, ;
                                                                    nFontHeigth) } }    }


   // ATTENZIONE:
   // le righe marcate da /* !! */
   // indicano righe che non impostano l'attributo perchŠ non Š ancora
   // supportato dalla funzione dfWinPrnFont()

   IF EMPTY(cString); RETURN lOK; ENDIF


   // Guardo se all'interno della stringa c'Š un cambio
   // di font da COMPRESSO a NON COMPRESSO o viceversa o se c'Š font utente

   lNoChange := ! ( !aCurrAttr[ATTR_FONT]:isEmpty() .OR. ;
                    DFWINREP_FONTON $ cString .OR. ;
                    (dfAnd(aCurrAttr[ATTR_TYPE], PRN_CONDENSED) == 0 .AND. DFWINREP_CONDENSEDON  $ cString) .OR. ;
                    (dfAnd(aCurrAttr[ATTR_TYPE], PRN_CONDENSED) != 0 .AND. DFWINREP_CONDENSEDOFF $ cString) )

   lOk := .T.
   DO WHILE lOk .AND. ! EMPTY(cString)

      aCod := FindCode(cString, aString)



      IF aCod[2] == 0
         lOk := PrintString(oPdf, aPos, cString, @oFont, aCurrAttr,,bFont)
         EXIT
      ENDIF

      cPre := LEFT(cString, aCod[1]-1)

      IF LEN(cPre) > 0
         IF ! (lOk := PrintString(oPdf, aPos, cPre, @oFont, aCurrAttr,,bFont))
            EXIT
         ENDIF
      ENDIF
      nPrintedWidth := printedWidth(aCurrAttr, cPre,  oPdf, oFont, nSegment,bFont)

      // Aggiorno la coord. X per far calcolare la posizione delle immagini
      aPos[1]   += nPrintedWidth
      EVAL(aString[aCod[2]][2])
      cString   := SUBSTR(cString, aCod[1]+DFWINREP_STRINGLENGTH)

   ENDDO
   //Gerr. 3832 Luca 26/06/03 non assegnava il font corrente quando stampava dei box
   // e si ottenevana un distorsione della lunghezza del box. L'errore accade solo
   // quando si effetuano in precedenza assegnazioni di bold o di altri font.
   _WinPrnGetFont( oPdf, oFont, aCurrAttr , bFont)

RETURN lOk

// Esegue un qualsiasi codeblock codificato nel file
STATIC FUNCTION EvalCBlock(cString, oPdf, aPos, nFontHeigth)
   LOCAL nSize := VAL( SplitString(@cString, DFWINREP_CODEBLOCK) )
   LOCAL xCB := LEFT(cString,nSize)
   LOCAL cStrPre, cStrAft 
   // Luca 7/11/03
   //Ho notato un malfunzionamneto e ho inserito la seguente riga:
   xCB := subStr(xCB, AT(DFWINREP_CODEBLOCK, xCB)+DFWINREP_STRINGLENGTH)
   // Luca 7/11/03
   //Ho notato un malfunzionamneto e ho tolto la seguente riga:
   //cString := SUBSTR(cString,nSize + 1)
   // Luca 7/11/03
   //Per il corretto funzionamneto ho inserito le seguenti rige
   cStrPre := LEFT(  cString,  AT(DFWINREP_CODEBLOCK,cString ) - 1 )
   cStrAft := SUBSTR(cString,  AT(DFWINREP_CODEBLOCK,cString ) + DFWINREP_STRINGLENGTH)
   cStrAft := SUBSTR(cStrAft,nSize + 1)
   cString := cStrPre + cStrAft

   xCb := BIN2VAR(xCB)

   EVAL(xCB, oPdf, aPos, nFontHeigth)
RETURN NIL


STATIC FUNCTION FindCode(cString, aString)
   LOCAL nPos    := 0
   LOCAL nString := 0
   LOCAL cCode   := ""

   DO WHILE (nPos := AT(DFWINREP_CODE, cString)) != 0 .AND. nString == 0
      cCode   := SUBSTR(cString, nPos, DFWINREP_STRINGLENGTH)

      IF (nString := ASCAN(aString, {|x| x[1] == cCode} )) == 0
         cString := SUBSTR(cString, nPos+1)
      ENDIF
   ENDDO

RETURN {nPos, nString}

// Workaround per HP deskjet, se il font Š BOLD lo imposta a non BOLD
// altrimenti la dimensione non Š calcolata bene
STATIC FUNCTION PrintedWidth(aAttr, cPre,  oPdf, oFont, nSegment,bFont)
   LOCAL nSize := 0
   LOCAL aTextBox
   LOCAL nOldMode
   LOCAL aNewFont
   LOCAL cAttr
   LOCAL oldFontName := oPdf:GetFontInfo( "NAME" )
   LOCAL oldFontType := oPdf:GetFontInfo( "TYPE" )
   LOCAL oldFontsize := oPdf:aReport[ PDF_FONTSIZE ]
   LOCAL newFontName := oPdf:GetFontInfo( "NAME" )
   LOCAL newFontType := oPdf:GetFontInfo( "TYPE" )
   LOCAL newFontsize := oPdf:aReport[ PDF_FONTSIZE ]

   // Ho stampato in bold?
   IF LEN(cPre) > 0
      aAttr     := ACLONE(aAttr)
      cAttr     := oPdf:GetFontInfo( "TYPE" )
      IF dfAnd(cAttr, PDF_BOLD) != 0 .OR. ! aAttr[ATTR_FONT]:isEmpty()
         // Salvo il font
         oldFontName := oFont:FamilyName
         oldFontType := oFont:Type
         oldFontsize := oFont:Height

         oFont :=_WinPrnGetFont( oPdf,  oFont, aAttr ,bFont )
         oFont:SetPdfFont()

      ENDIF
      nSize         := _GraQueryTextBox( oPdf, REPLICATE("W",LEN(cPre)))

      IF ! EMPTY( OldFontName )  // Reimposto il font
         oFont:FamilyName := oldFontName
         oFont:Type       := oldFontType
         oFont:Height     := oldFontsize
         oFont:SetPdfFont()
      ENDIF

   ENDIF
RETURN nSize

//Ritorna le dimensioni di stampa della stringa
STATIC FUNCTION _GraQueryTextBox(oPdf, cStr)
   Local nlength   :=  oPdf:Length( cStr )
RETURN nLength

STATIC FUNCTION PrintString(oPdf, aPos, cString, oFont, aCurrAttr,cColor, bFont)
   LOCAL _cFont, _nType, _nSize
   DEFAULT cColor  TO PDF_BLACK

   IF !EMPTY(oPdf:SetAttrString()[GRA_AS_COLOR])
      cColor := oPdf:SetAttrString()[GRA_AS_COLOR]
   ENDIF
   oFont := _WinPrnGetFont(oPdf,  oFont, aCurrAttr, bFont)

   cString := ConvToAnsiCP(cString)//Esegue la conversione da caratter in formato Conv to Ansi
   //cString := oFont:SetPdfFont(cString,cColor)

   cString := oFont:SetPdfFont(RTRIM(cString),cColor)
   oPdf:AtSay( cString, aPos[2], aPos[1],"M"  )
RETURN  .T.


STATIC FUNCTION SetAttrib(aCurr, nAttr, lSet)
   LOCAL nCurr := aCurr[ATTR_TYPE]
   IF lSet
      IF dfAnd(nCurr, nAttr) == 0
         nCurr += nAttr
         aCurr[ATTR_TYPE] := nCurr
      ENDIF
   ELSE
      IF dfAnd(nCurr, nAttr) != 0
         nCurr -= nAttr
         aCurr[ATTR_TYPE] := nCurr
      ENDIF
   ENDIF
RETURN nCurr

// IMAGE:c:\nomebmp.bmp#posX#posY#width#height#resX#resY#nRow#nCol;resto della stringa
STATIC FUNCTION AddImg(cString, oPdf, aPos,  oFont, nFontHeight)
   LOCAL aString
   LOCAL aImgPos
   LOCAL nImg  := 0
   LOCAL nPage := 0
   LOCAL oBmp
   LOCAL lOk   := .F.
   LOCAL cImg
   LOCAL aSz, aRX, aRY,nPos

   IF (cImg := SplitString(@cString, DFWINREP_IMAGE)) != NIL
      aString    := dfStr2Arr(cImg, "#")
      aString[1] := UPPER(ALLTRIM(aString[1]))

      IF ! EMPTY(aString[1]) .AND. FILE(aString[1])
            lOk :=  .T.
      ENDIF
      IF lOk
         ASIZE(aString, 9)
         // Posizione X:
         //   se Š specificata uso quella specificata (aString[2])
         //   altrimenti stampo dalla posizione corrente
         aString[2] := IIF(! EMPTY(aString[2]), VAL(aString[2]), 0)
         aString[3] := IIF(! EMPTY(aString[3]), VAL(aString[3]), 0)

         // Risoluzione
         aString[6] := IIF(EMPTY(aString[6]), NIL, VAL(aString[6])) //Non utilizzate
         aString[7] := IIF(EMPTY(aString[7]), NIL, VAL(aString[7]))

         aString[4] := IIF(EMPTY(aString[4]), 0, VAL(aString[4]))
         aString[5] := IIF(EMPTY(aString[5]), 0, VAL(aString[5]))
         IF aString[2]!=0
            aString[2] := aString[2]/10 //Eseguo conversione da decimi di millimetri a millimetri
         ENDIF
         IF aString[3]!=0
            aString[3] := aString[3]/10 //Eseguo conversione da decimi di millimetri a millimetri
         ENDIF
         IF aString[4]>0
            aString[4] := aString[4]/10 //Eseguo conversione da decimi di millimetri a millimetri
         ENDIF
         IF aString[5]>0
            aString[5] := aString[5]/10 //Eseguo conversione da decimi di millimetri a millimetri
         ENDIF

         ///////////////////////////////////
         //Modifica Luca del 29/01/2007    GERR 4792
         IF EMPTY(aString[4]) .AND. EMPTY(aString[5])
         ///////////////////////////////////

         oBmp := S2XbpBitmap():new():create()
         IF oBmp:loadFile(aString[1])
               IF !EMPTY(aString[6]) .AND. !EMPTY(aString[7]) //se la risoluzione X e diversa da nil e zero si  esegue la conversione
               //Modifica Luca del 29/01/2007
               //IF !EMPTY(aString[6])  //se la risoluzione X e diversa da nil e zero si  esegue la conversione
               oBmp:setRes(aString[6], aString[7])
            ENDIF
            aSz := oBmp:getSize(0)
            DEFAULT aSz TO {oBmp:xRes/100, oBmp:yRes/100}
               ///////////////////////////////////
               //Modifica Luca del 29/01/2007
               //aSz[1] *= 100
               //aSz[2] *= 100
               aSz[1] *= 10
               aSz[2] *= 10
               //Fine modifica
               ///////////////////////////////////

               ///////////////////////////////////
               //Modifica Luca del 29/01/2007
               IF !EMPTY(aSz[1]) .AND. !EMPTY(aSz[2])
                  IF EMPTY(aString[4])
                     aString[4] := aSz[2]
                  ENDIF
                  IF EMPTY(aString[5])
                     aString[5] := aSz[1]
                  ENDIF
               ENDIF
               //Fine modifica
               ///////////////////////////////////

            IF aString[4] != aSz[2] .OR. aString[5] != aSz[1]
               // Resize proporzionale all'interno dell'area specificata
               aRX := aSz[2]/aString[4]
               aRY := aSz[1]/aString[5]
               IF aRX > aRY
                  aString[5] := aSz[1]/aRX
               ELSE
                  aString[4] := aSz[2]/aRY
               ENDIF
            ENDIF
         ENDIF
         oBmp:Destroy()

         ///////////////////////////////////
         ENDIF
         //Fine modifica
         ///////////////////////////////////

         // Luca: Riferito a Gerr 4015: Vi sono diverse modifiche che non andavano 
                       // aPos[1] --> X
                       // aPos[2] --> Y

         aString[2] +=  aPos[1] + 0.25 //aString[2]--> X --> Col //- 4       //Il tutto in mm --> 4  per il offset
         aString[3] +=  aPos[2] - 3.95 //aString[3]--> y --> Row//
         // Luca: Vi sono diverse modifiche che non andavano 
         // 4015 24/11/03 Simone oPdf:Image passava le coordinate al contrario
         //oPdf:Image( aString[1], aString[2], aString[3], "M" , aString[4], aString[5])
      //dfPdf:Image( cFile     , nRow      , nCol, cUnits, nHeight, nWidth, cId )
         oPdf:Image( aString[1], aString[3], aString[2], "M" , aString[4], aString[5])
      ENDIF
      IF AT(DFWINREP_IMAGE,cString)>0
         cString   := STUFF(cString, AT(DFWINREP_IMAGE,cString),DFWINREP_STRINGLENGTH,"")
      ENDIF
   ENDIF
RETURN cString

// cStartTag DEVE essere lungo DFWINREP_STINGLENGTH caratteri (cioŠ 7)
// cEndTag  DEVE essere lungo 1 carattere
STATIC FUNCTION SplitString(cString, cStartTag, cEndTag)
   LOCAL nPos  := AT(cStartTag, cString)
   LOCAL nPos1 := AT( IIF(cEndTag==NIL,";",cEndTag), cString)
   LOCAL cRet  := NIL

   IF nPos > 0 .AND. nPos1 > nPos
      nPos  += DFWINREP_STRINGLENGTH
      nPos1 -= nPos

      cRet       := SUBSTR(cString, nPos, nPos1)
      cString    := STUFF(cString, nPos, nPos1+1, "")

   ENDIF
RETURN cRet


STATIC FUNCTION _WinPrnGetFont( oPdf, oFont, aAttr , bFont)
   LOCAL aFont
   LOCAL lDefault := .F.
   LOCAL cFont
   LOCAL nPos
   DEFAULT bFont TO NIL

   DO CASE
      CASE bFont != NIL
           oFont := EVAL(bFont, "PDF", oPdf, aAttr[ATTR_TYPE], .T. , .F. , aAttr)
      CASE ! aAttr[ATTR_FONT]:isEmpty()
         IF ! EMPTY(aAttr[ATTR_FONT]:top())
            cFont := UPPER(aAttr[ATTR_FONT]:top())
            oFont:Create(cFont)
         ENDIF

      OTHERWISE
         oFont := _dfPdfFont( oPdf, aAttr[ATTR_TYPE])
   ENDCASE

RETURN oFont

//Dovrebbe prendere i settaggi standard dei font come per le stampanti
STATIC FUNCTION _dfpdfFont(oPdf, nAttr)

   LOCAL cFont,oFont

   DEFAULT nAttr   TO PRN_NORMAL

   cFont := IIF(dfAnd(nAttr, PRN_CONDENSED) > 0, "7.", "11.")+"COURIER"

   IF dfAnd(nAttr, PRN_BOLD) > 0
      cFont+=" BOLD"
   ENDIF

   IF dfAnd(nAttr, PRN_ITALIC) > 0
      cFont+=" ITALIC"
   ENDIF
   // 7.courier=compresso / 11.courier=normale
   oFont := dfPDFFont():new(oPdf):create(cFont)
   oFont:underscore  := dfAnd(nAttr, PRN_UNDERLINE) > 0
   oFont:Color       := PDF_BLACK //Gestione Colori non supportata
RETURN oFont

// Formato: BOX:type#posX#posY#width#height;resto della stringa
FUNCTION dfFile2PdfDrawBox(cString, oPdf, nMargX, nMargY, nFontHeight, oFont, aCurrAttr)
   LOCAL aString
   LOCAL aPos
   LOCAL oBmp
   LOCAL lOk   := .F.
   LOCAL nPos  := AT(DFWINREP_BOX, cString)
   LOCAL nPos1 := AT(";", cString)
   LOCAL cBox
   LOCAL lChar
   LOCAL aTextBox
   LOCAL nFontWidth
   LOCAL aFont
   LOCAL nLen

   LOCAL x1, y1, x2, y2, nBorder, nShade, cUnits, cColor, cId

   IF nPos > 0 .AND. nPos1 > nPos
      cBox := SUBSTR(cString, nPos+DFWINREP_STRINGLENGTH, ;
                     nPos1-nPos-DFWINREP_STRINGLENGTH )
      cString := LEFT(cString, nPos-1) + SUBSTR(cString, nPos1+1)
      aString := dfStr2Arr(cBox, "#")
      aString[1] := UPPER(ALLTRIM(aString[1]))

      IF ! EMPTY(aString[1])

         lChar := "CHAR" $ UPPER(aString[1])

         ASIZE(aString, 5)
         aString[2] := IIF(EMPTY(aString[2]), 0, VAL(aString[2]))
         aString[3] := IIF(EMPTY(aString[3]), 0, VAL(aString[3]))

         aString[4] := IIF(EMPTY(aString[4]), 0, VAL(aString[4]))
         aString[5] := IIF(EMPTY(aString[5]), 0, VAL(aString[5]))

         IF lChar

            nFontWidth  := oPdf:Length("W") //oFont:Width
            //nPos--     //Perche vi Š il carrattere speciale ""
            //aString[2] += nPos //si somma la psizione dove Š stato trovato il codice
            //                   //di inserimento Box

            aString[2] *= nFontWidth
            aString[4] *= nFontWidth
            aString[3] *= nFontHeight
            aString[5] *= nFontHeight

            //26/06/03 Ger 3823 Luca
            //Da verificare per Bene: se vi sono dei box consecutivi sulla stessa
            //righa vi Š un accavallamento dei bordi poco carino graficamente
            aString[2] -= (nFontWidth * 0.2)//per lo spessore del box
            //aString[2] -= (nFontWidth * 0.4)//per lo spessore del box
            aString[3] -= nFontHeight
            //aString[4] += (nFontWidth * 0.4)//per lo spessore del box


         ENDIF

         x1 :=     aString[2]  +nMargX
         y1 :=     aString[3]  +nMargY
         x2 := x1+ aString[4]
         y2 := y1+ aString[5]
         nBorder :=       0.1 //spessore del Bordo Box
         nShade  :=       0   //Ombra del Box 0 No 1 Si

         IF !EMPTY(oPdf:SetAttrString()[GRA_AS_COLOR])
            cColor := oPdf:SetAttrString()[GRA_AS_COLOR]
         ELSE
            cColor := PDF_BLACK
         ENDIF


         IF lChar
            opdf:Box( y1, x1, y2, x2, nBorder, nShade, "M",cColor  )
         ELSE
            opdf:Box( y1, x1, y2, x2, nBorder, nShade, "R",cColor  )
         ENDIF
      ENDIF
   ENDIF
RETURN cString


