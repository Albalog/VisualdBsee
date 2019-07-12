#include "Common.ch"

// $DOC
// Converte un colore dBsee nel colore RGB
// Il formato della stringa Š
//   <colore foreground>/<colore background>
//
// dove <colore foreground> o <background> pu• essere
//   [RED-GREEN-BLUE] oppure
//   [numero colore xbase] oppure
//   numero palette oppure
//   colore clipper
//   in caso di numero palette il colore Š quello associato a 
//   PALETTExx in DBSTART.INI
//   in caso di numero il colore Š il cod. colore Xbase (es 0=GRA_CLR_WHITE)
//
// $EXAMPLE
// ? S2DbseeColorToRGB("[100-100-100]/[2]") 
// ? S2DbseeColorToRGB("2/B*") 

FUNCTION S2DbseeColorToRGB(cClr, lBG, cFormatEnabled)
   LOCAL nRet := NIL
   LOCAL aClr
   LOCAL cClr1
   LOCAL nCol

   IF EMPTY(cClr)
      RETURN NIL
   ENDIF

   DEFAULT lBG TO .F.

   // Formati abilitati
   //    R=colori rgb nel formato     -> [R-G-B]
   //    X=colori Xbase nel formato   -> [numero]
   //    P=numero palette nel formato -> numero
   //    C=colore clipper nel formato -> stringa

   DEFAULT cFormatEnabled TO "RXPC"
   cFormatEnabled := UPPER(cFormatEnabled)

   ////////////////////////////////////////////////////////////////////////////////
   //Luca 09/05/2016  inserito perche con xbase 20 da runtime error in alcuni casi.
   IF EMPTY(cClr)
      RETURN nRet
   ENDIF 
   ////////////////////////////////////////////////////////////////////////////////

   cClr1:= _SplitClr(cClr)[ IIF(lBG, 2, 1) ];

   DO CASE
      CASE EMPTY(cClr1)
         // simone 10/2/03 per GERR 3652 
         // correzione per valori vuoti
         // non fa niente, torna NIL!


      CASE LEFT(cClr1, 1)=="[" .AND. RIGHT(cClr1, 1)=="]"
         cClr1 := SUBSTR(cClr1, 2, LEN(cClr1)-2)
         aClr := dfStr2Arr(cClr1, "-")
         IF LEN(aClr) >= 3
            IF "R" $ cFormatEnabled
               aClr[1] := VAL(aClr[1])
               aClr[2] := VAL(aClr[2])
               aClr[3] := VAL(aClr[3])

               // Formato: [RED-GREEN-BLUE] es [255-255-255]
               // in questo caso la palette va sempre da 0-255
               nRet := GraMakeRGBColor(aClr)
            ENDIF
         ELSEIF LEN(aClr) >= 1 .AND. S2IsNumber(cClr1)
            // Formato: [COLORE_XBASE] es [0]=GRA_CLR_WHITE
            // 
            IF "X" $ cFormatEnabled
               // simone 10/2/03 per GERR 3652 
               // correzione per valori negativi 
               nRet := VAL(cClr1) //aClr[1] 
            ENDIF
         ENDIF

      CASE S2IsNumber(cClr1)
         // Formato: NUMERO_PALETTE es 22=colore del PALETTE22
         // 
         nCol := VAL(cClr1)
         IF nCol != NIL .AND. ;
            "P" $ cFormatEnabled
            nRet := Palette2RGB(nCol)
         ENDIF

      OTHERWISE
         IF "C" $ cFormatEnabled
            // Formato: COLORE_CLIPPER es. GR+
            nCol := _ClipToNum(cClr1, lBG)
            IF nCol != NIL
               nRet := Palette2RGB(nCol)
            ENDIF
         ENDIF
   ENDCASE

RETURN nRet

// $DOC
// Converte un colore clipper nel colore RGB
// $EXAMPLE
// ? S2ClipColorToNumbers("B+/G") 
STATIC FUNCTION _ClipColorToRGB(cClr, lBG)
   LOCAL nRet := NIL
   LOCAL nCol
   LOCAL aObj

   IF EMPTY(cClr)
      RETURN NIL
   ENDIF

   DEFAULT lBG TO .F.

   nCol := _ClipColorToNumbers(cClr)[ IIF(lBG, 2, 1) ]
   nRet := Palette2RGB(nCol)
RETURN nRet

// $DOC
// Converte un colore clipper nel num. di palette DOS 
// per foreground e background
// $EXAMPLE                          
//                                   FG  BG    FG+BG*16= num. DOS
// ? S2ClipColorToNumbers("B+/G") -> {9, 2} ->  9+ 2*16=41

STATIC FUNCTION _ClipColorToNumbers(cClr)
   LOCAL aClr  := _SplitClr(cClr)
RETURN {_ClipToNum(aClr[1], .F.), _ClipToNum(aClr[2], .T.)}

STATIC FUNCTION _SplitClr(cClr)
   LOCAL nAt := 0
   IF EMPTY(cClr)
      RETURN {"", ""}
   ENDIF 
   nAt := AT("/", cClr)
   cClr := UPPER(cClr)
RETURN {ALLTRIM(LEFT(cClr, nAt-1)), ALLTRIM(SUBSTR(cClr, nAt+1))}

// Converte un colore nel suo numero di palette
STATIC FUNCTION _ClipToNum(cClr, lBG)
   LOCAL aCol  := {"N", "B", "G", "BG", "R", "RB", "GR", "W"}
   LOCAL cHigh := IIF(lBG, "*", "+")
   LOCAL nPos

   // Alta intensita?
   IF cHigh $ cClr
      cClr := STRTRAN(cClr, cHigh, "")
   ELSE
      cHigh := NIL
   ENDIF

   nPos := ASCAN(aCol, cClr)
   IF nPos > 0 
      nPos--
      IF cHigh != NIL
         nPos+=8
      ENDIF
   ENDIF
RETURN nPos

// Converte un colore della palette considerando la palette 
// a 64 colori (DOS) o a 256 colori (WINDOWS)
STATIC FUNCTION Palette2RGB(nCol)
   LOCAL nRet
   LOCAL aClr

   IF nCol >= 0 .AND. nCol <= 99
      aClr := dfColor( "PALETTE" +PADL(nCol,2,"0") )
      IF ! EMPTY(aClr)
         IF LEN(aClr) < 3
            nRet := aClr[1]  // colore Xbase (GRA_CLR_xxx)
         ELSE
            // in questo caso la palette va sempre da 0-63 o 0-255
            // a seconda del settaggio globale
            IF !dfSet("XbasePaletteMode")=="WIN"
               aClr := ACLONE(aClr)
               aClr[1]*=4
               aClr[2]*=4
               aClr[3]*=4
            ENDIF

            nRet := GraMakeRgbColor(aClr)
         ENDIF
      ENDIF
   ENDIF
RETURN nRet

