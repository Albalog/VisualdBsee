#include "Common.ch"
#include "dfReport.ch"
#include "dfWinRep.ch"
#include "gra.ch"
#include "xbp.ch"

#define ATTR_TYPE    1
   #define ATTR_TYPE_DEFAULT PRN_NORMAL

#define ATTR_FONT    2

FUNCTION dfWinPrnReset()
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

FUNCTION dfWinPrnStringAt(oPs, aPos, cString, xDevice, aCurrAttr, ;
                          lGeneric, nSegment, bFont, ;
                          bImg, aImgCache, nFontHeight, aFontCache, ;
                          lUseMatrix)
   LOCAL lOk     := .F.
   LOCAL aPrn    := {}
   LOCAL cPre    := ""
   LOCAL aCod
   LOCAL lNoChange := .T.
   LOCAL aTextBox
   LOCAL lPreview := (nSegment != NIL)
   LOCAL nPrintedWidth
   LOCAL aString := { { DFWINREP_SETUP          , {|| aCurrAttr[ATTR_TYPE] := ATTR_TYPE_DEFAULT  } }, ;
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
                      { DFWINREP_CODEBLOCK      , {|| EvalCBlock(@cString, oPS, aPos, nFontHeight) } }, ;
                      { DFWINREP_IMAGE          , {|| cString:=AddImg(cString,oPS, aPos, ;
                                                                      bImg, aImgCache, nFontHeight) } }    }

   // ATTENZIONE:
   // le righe marcate da /* !! */
   // indicano righe che non impostano l'attributo perchŠ non Š ancora
   // supportato dalla funzione dfWinPrnFont()

   IF EMPTY(cString); RETURN lOK; ENDIF

   DEFAULT lPreview TO .F.
   DEFAULT aFontCache TO {}
   DEFAULT lUseMatrix TO .T.


   // Simone 2/ott/03
   // Aggiunto settaggio per non far usare il bold
   // per problemi di stampa/anteprima
   IF dfSet("XbasePrintDisableBold") == "YES"
      cString := STRTRAN(cString, DFWINREP_BOLDON , "")
      cString := STRTRAN(cString, DFWINREP_BOLDOFF, "")
   ENDIF

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
         lOk := PrintString(oPS, aPos, cString, xDevice, aCurrAttr, ;
                            lGeneric, bFont, lPreview, aFontCache)
         EXIT
      ENDIF

      cPre := LEFT(cString, aCod[1]-1)

      IF LEN(cPre) > 0
         IF ! (lOk := PrintString(oPS, aPos, cPre, xDevice, aCurrAttr, ;
                                  lGeneric, bFont, lPreview, aFontCache))
            EXIT
         ENDIF
      ENDIF

      nPrintedWidth := printedWidth(aCurrAttr, cPre, xDevice, oPS, lGeneric, ;
                                    bFont, lPreview, nSegment, aFontCache, ;
                                    lUseMatrix)

      // Aggiorno la coord. X per far calcolare la posizione delle immagini
      aPos[1]   += nPrintedWidth
      EVAL(aString[aCod[2]][2])
      cString   := SUBSTR(cString, aCod[1]+DFWINREP_STRINGLENGTH)

      // 8/9/2000 Simone
      // Aggiunto il lNoChange perchŠ l'anteprima di stampa
      // non va bene in caso su una stessa riga ci siano
      // caratteri compressi e caratteri non compressi
      // es. prova di non compresso CONDONprova di compressoCONDOF
      // la stringa "prova di compresso" va sopra la stringa "prova di non compresso"
      IF lPreview .AND. lNoChange
         cString := SPACE(aCod[1]-1)+cString
         aPos[1] -= nPrintedWidth
      ENDIF
   ENDDO

RETURN lOk

// Esegue un qualsiasi codeblock codificato nel file
STATIC FUNCTION EvalCBlock(cString, oPS, aPos, nFontHeight)
   LOCAL nSize := VAL( SplitString(@cString, DFWINREP_CODEBLOCK) )
   LOCAL xCB   := cString
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
   EVAL(xCB, oPS, aPos, nFontHeight)
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
STATIC FUNCTION PrintedWidth(aAttr, cPre, xDevice, oPS, lGeneric, bFont, ;
                             lPreview, nSegment, aFontCache, lUseMatrix)
   LOCAL nSize := 0
   LOCAL oOldFont
   LOCAL oNewFont, aTextBox
   LOCAL nOldMode
   LOCAL nAttr

   // Ho stampato in bold?
   IF LEN(cPre) > 0
      aAttr     := ACLONE(aAttr)
      nAttr     := aAttr[ATTR_TYPE]
      IF dfAnd(nAttr, PRN_BOLD) != 0 .OR. ! aAttr[ATTR_FONT]:isEmpty()
         oOldFont := oPS:setFont() // Salvo il font

         // Imposto un font non BOLD e calcolo la larghezza
         IF dfAnd(nAttr, PRN_BOLD) != 0
            nAttr := SetAttrib(aAttr, PRN_BOLD, .F. )
         ENDIF
         //oNewFont := _WinPrnGetFont( xDevice, aAttr, lGeneric, bFont, ;
         //                            oPS, lPreview, aFontCache )

         // Prendo le "misure" in base ad un font standard (courier)
         IF bFont != NIL
            oNewFont := EVAL(bFont, xDevice, oPS, aAttr[ATTR_TYPE], lGeneric, lPreview, aAttr)
         ELSE
            oNewFont := dfWinPrnFont( xDevice, NIL, aAttr[ATTR_TYPE], lGeneric)
         ENDIF
         IF ! EMPTY( oNewFont )
            oPS:setFont( oNewFont )
         ENDIF
      ENDIF

      aTextBox    := _GraQueryTextBox( oPS, REPLICATE("W",LEN(cPre)), nSegment, lUseMatrix )

      IF aTextBox != NIL
         nSize := aTextBox[3,1] - aTextBox[2,1]
      ENDIF

      IF ! EMPTY( oOldFont )  // Reimposto il font
         oPS:setFont( oOldFont )
      ENDIF

   ENDIF
RETURN nSize

// Se Š in preview la graQueryTextBox non funziona correttamente
// perchŠ funziona sul FONT di oPS che pu• essere diverso da
// quello impostato nel segmento, questa funzione effettua
// il workaround di questo funzionamento vedi PRD3586
// NOTE:
// - Questa funzione Š valida solo se sono in modalit… 
//   che non disegna (GRA_DM_RETAIN) altrimenti Š identico 
//   a chiamare direttamente la GraQueryTextBox() 
//   (ed infatti viene fatto questo)
// - se eseguita su sistemi WinNT/2000/XP BLOCCA il computer per un BUG

STATIC FUNCTION _GraQueryTextBox(oPS, cStr, nSegment, lUseMatrix)
   LOCAL oOldFont
   LOCAL aRet
   LOCAL oFontOri
#ifdef _XBASE15_

   // WORKAROUND SIMONE 15/01/2002: 
   // Disabilito la gestione della riapertura del segmento 
   // su win2000/XP perche'' consuma troppe risorse
   // e pu• piantare il sistema!!!
   IF dfOsFamily() == "WINNT"
      nSegment := NIL
   ENDIF

   IF lUseMatrix 
      nSegment := NIL
   ENDIF

   IF nSegment != NIL
      oOldFont := oPS:setFont()         // Prendo il font del segmento
      GraSegClose(oPS)                  // Chiudo il segmento per lavorare sul pres. space
      oFontOri := oPS:setFont(oOldFont) // Salvo il font del pres. space e
                                        // imposto il font del segmento
   ENDIF

   aRet := GraQueryTextBox( oPS, cStr )

   IF nSegment != NIL
      oPS:setFont(oFontOri)             // Reimposto il font originale nel pres. space
      GraSegOpen(oPS, NIL, nSegment)    // Riapro il segmento
   ENDIF
#else
   aRet := GraQueryTextBox( oPS, cStr )
#endif

RETURN aRet

STATIC FUNCTION PrintString(oPS, aPos, cString, xDevice, aAttr, lGeneric, bFont, lPreview, aFontCache)
   LOCAL oFont := _WinPrnGetFont( xDevice, aAttr, lGeneric, bFont, oPS, lPreview, aFontCache)
   IF ! EMPTY( oFont )
      oPS:setFont( oFont )
   ENDIF
RETURN GraStringAt( oPS, aPos, cString )

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
STATIC FUNCTION AddImg(cString, oPS, aPos, bImg, aImgCache, nFontHeight)
   LOCAL aString
   LOCAL aImgPos
   LOCAL nImg  := 0
   LOCAL nPage := 0
   LOCAL oBmp
   LOCAL lOk   := .F.
   LOCAL cImg
   LOCAL aSz, aRX, aRY

   IF (cImg := SplitString(@cString, DFWINREP_IMAGE)) != NIL
      aString    := dfStr2Arr(cImg, "#")
      aString[1] := UPPER(ALLTRIM(aString[1]))

      IF ! EMPTY(aString[1])

         nImg := ASCAN(aImgCache, {|a| a[1]==aString[1] })

         IF nImg > 0
            oBmp := aImgCache[nImg][2]
            lOk := .T.
         ELSEIF FILE(aString[1])
            oBmp := S2XbpBitmap():new():create(oPS)
            lOk := oBmp:loadFile(aString[1])
         ENDIF
         IF lOk
            ASIZE(aString, 9)
            // Posizione X:
            //   se Š specificata uso quella specificata (aString[2])
            //   altrimenti stampo dalla posizione corrente
            aString[2] := IIF(! EMPTY(aString[2]), VAL(aString[2]), aPos[1])
            aString[3] := IIF(EMPTY(aString[3]), 0, VAL(aString[3]))

            // Risoluzione
            aString[6] := IIF(EMPTY(aString[6]), NIL, VAL(aString[6]))
            aString[7] := IIF(EMPTY(aString[7]), NIL, VAL(aString[7]))

            oBmp:setRes(aString[6], aString[7])

            aSz := oBmp:getSize(0)
            DEFAULT aSz TO {oBmp:xRes/100, oBmp:yRes/100}

            aSz[1] *= 100
            aSz[2] *= 100

            aString[4] := IIF(EMPTY(aString[4]), aSz[1], VAL(aString[4]))
            aString[5] := IIF(EMPTY(aString[5]), aSz[2], VAL(aString[5]))

            IF aString[4] != aSz[1] .OR. aString[5] != aSz[2]
               // Resize proporzionale all'interno dell'area specificata
               aRX := aSz[1]/aString[4]
               aRY := aSz[2]/aString[5]
               IF aRX > aRY
                  aString[5] := aSz[2]/aRX
               ELSE
                  aString[4] := aSz[1]/aRY
               ENDIF
            ENDIF

            aImgPos := {aString[2], ;
                        aPos[2]-aString[3]-aString[5]+nFontHeight-1,;
                        0, 0}

            aImgPos[3] := aImgPos[1] + aString[4]
            aImgPos[4] := aImgPos[2] + aString[5]
            EVAL(bImg, oPS, oBmp, aImgPos, aString[1])

            IF nImg == 0
               AADD(aImgCache, {aString[1], oBmp})
            ENDIF
         ENDIF
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


STATIC FUNCTION _WinPrnGetFont( xDevice, aAttr, lGeneric, bFont, oPS, lPreview, aFontCache)
   LOCAL oFont
   LOCAL cFont
   LOCAL nPos

   DO CASE
      CASE bFont != NIL
         oFont := EVAL(bFont, xDevice, oPS, aAttr[ATTR_TYPE], lGeneric, lPreview, aAttr)

      CASE ! aAttr[ATTR_FONT]:isEmpty()
         IF ! EMPTY(aAttr[ATTR_FONT]:top())
            cFont := UPPER(aAttr[ATTR_FONT]:top())
            nPos := ASCAN(aFontCache, {|x| x[1] == cFont })
            IF nPos > 0 .AND. aFontCache[nPos][2]:status() == XBP_STAT_CREATE
               oFont := aFontCache[nPos][2]
            ELSE
               oFont := XbpFont():new(oPS):create(aAttr[ATTR_FONT]:top())
               AADD(aFontCache,{cFont, oFont})
            ENDIF
         ENDIF

      OTHERWISE
         oFont := dfWinPrnFont( xDevice, NIL, aAttr[ATTR_TYPE], lGeneric)
   ENDCASE

RETURN oFont

// Formato: BOX:type#posX#posY#width#height;resto della stringa
FUNCTION dfFile2WPrnDrawBox(cString, oPS, nMargX, nMargY, nFontHeight, ;
                            xDevice, aAttr, lGeneric, bFont, ;
                            lPreview, aFontCache)
   LOCAL aString
   LOCAL aPos
   LOCAL oBmp
   LOCAL lOk   := .F.
   LOCAL nPos := AT(DFWINREP_BOX, cString)
   LOCAL nPos1 := AT(";", cString)
   LOCAL cBox
   LOCAL lChar
   LOCAL aTextBox
   LOCAL nFontWidth
   LOCAL oFont

   // IF LEFT(LTRIM(cString), DFWINREP_STRINGLENGTH)==DFWINREP_IMAGE

   IF nPos > 0 .AND. nPos1 > nPos
      DEFAULT aFontCache TO {}

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

            oFont := _WinPrnGetFont( xDevice, aAttr, lGeneric, bFont, oPS, lPreview, aFontCache )
            IF ! EMPTY( oFont )
               oPS:setFont( oFont )
            ENDIF

            // le coordinate sono espresse in numero di caratteri

            aTextBox    := _GraQueryTextBox( oPS, REPLICATE("W", aString[2]), NIL, .T. )
            aString[2]  := IIF( EMPTY(aTextBox), 0, aTextBox[3,1] - aTextBox[2,1])

            aTextBox    := _GraQueryTextBox( oPS, REPLICATE("W", aString[4]), NIL, .T. )
            aString[4]  := IIF( EMPTY(aTextBox), 0, aTextBox[3,1] - aTextBox[2,1])

            //aString[2] *= nFontWidth
            //aString[4] *= nFontWidth
            aString[3] *= nFontHeight
            aString[5] *= nFontHeight

            aString[3] -= nFontHeight -1

         ENDIF
         aPos := {nMargX+aString[2], ;
                  nMargY-aString[3]-aString[5] }

         GraBox(oPS, aPos, {aPos[1] + aString[4], aPos[2] + aString[5]})

      ENDIF
   ENDIF
RETURN cString

