#include "font.ch"

STATIC aFnt

FUNCTION dfFontCompoundNameNormalizeINIT()
   aFnt := dfHTNew(23, {|a| UPPER(ALLTRIM(a[1]))})
RETURN NIL

FUNCTION dfFontCompoundNameBuild(cFamily, nSize, lBold, lItalic, lUnderline)
RETURN ALLTRIM(STR(nSize))+"."+;
       cFamily+;
       IIF(EMPTY(lBold), "", FONT_STYLE_BOLD)+;
       IIF(EMPTY(lItalic), "", FONT_STYLE_ITALIC)+;
       IIF(EMPTY(lUnderline), "", "") // underline non supportato

// normalizza il nome di un font
// Simone 21/12/04
// mantis 0000279: Incongruenze Dimensione/Font caratteri tra Form designer e Progetto finale compilato
// per referenza torna se Š BOLD/ITALIC/UNDERLINE

FUNCTION dfFontCompoundNameNormalize(cFont, lBold, lItalic, lUnderline, cFamily, nSize)
   LOCAL aArr

   IF EMPTY(cFont)
      lBold      := .F.
      lItalic    := .F.
      lUnderline := .F.
      cFamily    := ""
      nSize      := -1

      RETURN ""
   ENDIF

   aArr := dfHTFind(aFnt, UPPER(ALLTRIM(cFont)))

   IF aArr == NIL
      aArr := ARRAY(6)
      aArr[1] := _Normalize(cFont, @aArr[2], @aArr[3], @aArr[4], @aArr[5], @aArr[6])
      //aArr[1] := _Normalize2(cFont, @aArr[2], @aArr[3], @aArr[4], @aArr[5], @aArr[6])
      //IF ! EMPTY(aArr)
         dfHTAdd(aFnt, aArr)
      //ENDIF
   ENDIF

   lBold      := aArr[2]
   lItalic    := aArr[3]
   lUnderline := aArr[4]
   cFamily    := aArr[5]
   nSize      := aArr[6]
RETURN aArr[1]

/* commentato perche' non credo riconosca le scritte "grassetto" "corsivo" ecc
STATIC FUNCTION _Normalize2(cFont, lBold, lItalic, lUnderline, cFamily, nSize)
   LOCAL oFont, cRet

   oFont := XbpFont():new():create(cFont)

   lBold      := oFont:bold
   lItalic    := oFont:italic
   lUnderline := oFont:underScore
   cFamily    := oFont:familyName
   nSize      := oFont:nominalPointsize
   cRet       := ALLTRIM(STR(nSize))+"."+oFont:compoundName
   oFont:destroy()
RETURN cRet
*/

// potrebbe avere problemi con font con il "BOLD" nel nome del font
// es. "Albertus Extra Bold"
STATIC FUNCTION _Normalize(cFont, lBold, lItalic, lUnderline, cFamily, nSize)
   LOCAL aArr
   LOCAL cRet := ""
   LOCAL cToken
   LOCAL n, nPos, nAttrib

   lBold := .F.
   lItalic := .F.
   lUnderline := .F.
   cFamily    := ""
   nSize      := -1


   IF ! EMPTY(cFont)
      //cFont := UPPER(ALLTRIM(cFont))
      cFont := ALLTRIM(cFont)

      aArr := dfStr2Arr(cFont, " ")
      nAttrib := LEN(aArr)+1
      FOR n := LEN(aArr) TO 2 STEP -1 // arrivo fino a 2 perchŠ il primo Š per forza il nome del font
         cToken := UPPER(ALLTRIM(aArr[n]))

         IF ! lItalic .AND. (cToken == "ITALIC" .OR. cToken == "CORSIVO" )
            aArr[n] := ALLTRIM(FONT_STYLE_ITALIC)
            lItalic := .T.
            nAttrib := MIN(n, nAttrib)

         ELSEIF ! lBold .AND. (cToken == "BOLD" .OR. cToken == "GRASSETTO" )
            aArr[n] := ALLTRIM(FONT_STYLE_BOLD)
            lBold := .T.
            nAttrib := MIN(n, nAttrib)

         ELSEIF ! lUnderline .AND. (cToken == "UNDERLINED" .OR.cToken == "UNDERLINE" .OR. cToken == "SOTTOLINEATO" )
            aArr[n] := "" // da gestire se possibile
            lUnderline := .T.
            nAttrib := MIN(n, nAttrib)

         ELSE
           //Commentato perche potrebbe esserci 12.ARIAL BOLD CE
           //EXIT // se partendo da destra non ho trovato nessun altro attributo esco
         ENDIF
      NEXT

      IF LEN(aArr) >= 1 .AND. "." $ aArr[1] .AND. nAttrib >= 2
         cToken := aArr[1]
         nPos := AT(".", cToken)
         IF dfIsDigit(LEFT(cToken, nPos-1))
            nSize   := VAL(LEFT(cToken, nPos-1))
            cFamily := SUBSTR(aArr[1], nPos+1)
            nAttrib--
            FOR n := 2 TO nAttrib
               cFamily += " "+aArr[n]
            NEXT
         ENDIF
      ENDIF

      // riconverto in stringa
      cRet := dfArr2Str(aArr, " ")
   ENDIF
RETURN ALLTRIM(cRet)