#include "Common.ch"
#include "Gra.ch"
#include "xbp.ch"
#include "dfXbase.ch"
#include "dfSet.ch"

STATIC aColors

FUNCTION S2AppColorType()
   LOCAL nType := AI_COLORMODE_STD
   LOCAL nSet
  #ifdef _XBASE17_
   nType := dfSet(AI_XBASECOLORMODE)
  #endif
RETURN nType

FUNCTION S2AppColorArray(x)
   IF VALTYPE(x) == "A"
      aColors := ACLONE(x)
   ENDIF
RETURN aColors

// $DOC
// Legge i colori di default da APPS.INI
PROCEDURE S2AppColorInit()
   LOCAL nInd := 0
   LOCAL cColor
   LOCAL nPos
   LOCAL lColorRGB
   LOCAL aDefault := { { "XbaseAppColorSay"      , {GRA_CLR_BLACK , NIL} }, ;
                       { "XbaseAppColorFun"      , {GRA_CLR_DARKBLUE, NIL} }, ;
                       { "XbaseAppColorFPr"      , {GRA_CLR_BLACK , NIL} }, ;
                       { "XbaseAppColorGPr"      , {GRA_CLR_BLACK , NIL} }, ;
                       { "XbaseAppColorChk"      , {GRA_CLR_BLACK , NIL} }, ;
                       { "XbaseAppColorRad"      , {GRA_CLR_BLACK , NIL} }, ;
                       { "XbaseAppColorCmb"      , {GRA_CLR_BLACK , NIL} }, ;
                       { "XbaseAppColorSpn"      , {GRA_CLR_BLACK , NIL} }, ;
                       { "XbaseAppColorFunBox"   , {GRA_CLR_WHITE, GRA_CLR_DARKGRAY} } , ;
                       { "XbaseAppColorBack"     , {NIL, NIL} } , ;
                       { "XbaseAppColorGet"      , {NIL, NIL} } , ;
                       { "XbaseAppColorGetFocus" , {NIL, NIL} } , ;
                       { "XbaseAppColorTxt"      , {NIL, NIL} } , ;
                       { "XbaseAppColorPTx"      , {NIL, NIL} } , ;
                       { "XbaseAppColorBtn"      , {NIL, NIL} } , ;
                       { "XbaseAppColorPSp"      , {NIL, NIL} } , ;
                       { "XbaseAppColorPLsb"     , {NIL, NIL} } , ;
                       { "XbaseAppColorHilite"   , {GRA_CLR_WHITE, GRA_CLR_RED} } }


   aColors := ARRAY(LEN(aDefault))

   // simone 9/3/06 
   // mantis 0001002: i colori di default in dbstart.ini APPCOLORxxx= non possono usare colori RGB andrebbero standardizzati come per i controls
   // modifica funzionante ma DISABILITATA, perchŠ bisogna vedere 
   // meglio come gestire la compatibilit… con i settaggi precedenti!
   // per es. forse Š meglio generare dbstart.ini direttamente con i 
   // settaggi col nuovo formato
   lColorRGB := .F. // dfSet("XbaseAppColorMode")=="RGB"
   // --------------------------------------------------

   FOR nInd := 1 TO LEN(aDefault)

      cColor := dfSet(aDefault[nInd][1])

      IF EMPTY(cColor)
         aColors[nInd] := aDefault[nInd][2]
      ELSE
         IF lColorRGB
            // simone 9/3/06 per compatibilit… considero
            // separatori "," e "/" e se "," o "/" non specificato 
            // lo considero come colore FG
            cColor := STRTRAN(cColor, ",", "/")
            IF ! "/" $ cColor
               cColor+="/"
            ENDIF
            aColors[nInd]  := { S2DbseeColorToRGB(cColor, .F.), ;
                                S2DbseeColorToRGB(cColor, .T.)  }
         ELSE
            nPos := AT(",", cColor)
            IF nPos > 0
               aColors[nInd] := { VAL(LEFT(cColor,nPos-1)), VAL(SUBSTR(cColor,nPos+1)) }
            ELSE
               aColors[nInd] := { VAL(cColor), NIL }
            ENDIF
         ENDIF
      ENDIF
   NEXT
RETURN


// $DOC
// Imposta i colori di testo e sfondo di un oggetto
FUNCTION S2ObjSetColors(oXbp, lBG, cClr, n, nNew)
   // non posso imposto il colore background SE ho una bitmap di sfondo
   // altrimenti ho un brutto effetto nelle form
   DEFAULT lBG TO CanSetBGColor(oXbp)

RETURN S2ItmSetColors({|n|oXbp:setColorFG(n)}, {|n|oXbp:setColorBG(n)}, ;
                      lBG, cClr, n, nNew)

FUNCTION S2ItmSetColors(bSetFG, bSetBG, lBG, cClr, n, nNew)
   LOCAL nType := S2AppColorType()
   LOCAL nColor
   LOCAL aClr

   DO CASE

      CASE nType == AI_COLORMODE_DBSEE
         nColor := S2DbseeColorToRGB(cClr, .F.)
         IF nColor != NIL
            EVAL(bSetFG, nColor) //oXbp:setColorFG( nColor )
         ENDIF
         IF lBG
            nColor := S2DbseeColorToRGB(cClr, .T.)
            IF nColor != NIL
               EVAL(bSetBG, nColor) //oXbp:setColorBG( nColor )
            ENDIF
         ENDIF

      //CASE nType == AI_COLORMODE_WINDBSEE
      //   // nuovo metodo

      CASE nType == AI_COLORMODE_STD
         aClr := _StdClrGet(cClr, n, lBG)

         IF aClr[1] != NIL
            EVAL(bSetFG, aClr[1]) //oXbp:setColorFG(aClr[1])
         ENDIF

         IF aClr[2] != NIL .AND. lBG
            EVAL(bSetBG, aClr[2]) //oXbp:setColorBG(aClr[2])
         ENDIF
   ENDCASE
RETURN NIL

// Cerco se Š figlio di un FORM con bitmap,
// in tal caso NON imposto il colore di sfondo
STATIC FUNCTION CanSetBGColor(o)
   LOCAL lRet := .T.
   LOCAL oParent := o
   LOCAL aLoop := {}    // Serve per evitare una eventuale ricorsione
   LOCAL nLoop := 2000  // Serve per evitare una eventuale ricorsione

   DO WHILE ! EMPTY(oParent) .AND. ;
            ! oParent:isDerivedFrom("XbpDialog") .AND. ;
            ASCAN(aLoop, oParent) == 0 .AND. ;
            --nLoop > 0
      AADD(aLoop, oParent)
      oParent := oParent:setOwner()
   ENDDO

   IF ! EMPTY(oParent)
      lRet := EMPTY(oParent:drawingArea:bitmap)
   ENDIF
RETURN lRet

// $DOC
// Imposta nell'array del presentation parameter i colori
//
// funzionamento xBG:
//  .T. = imposta il colore di FG/BG e il colore di BG disabilitato
//  .F. = imposta FG ma non imposta BG, imposta il BG disab. = trasparente
//  {.T.,  0} = imposta il colore di FG/BG ma non imposta il colore di BG disabilitato
//  {.F.,  0} = imposta FG ma non imposta BG e non imposta il colore di BG disabilitato

FUNCTION S2PPSetColors(aPP, xBG, cClr, n, nNew)
   LOCAL nType := S2AppColorType()
   LOCAL lDisabledBG
   LOCAL aClr

   IF VALTYPE(xBG)=="A"
      lDisabledBG := xBG[2]
      xBG := xBG[1]
   ENDIF

   DEFAULT xBG TO .F.
   DEFAULT lDisabledBG TO xBG

   S2ItmSetColors({|n| aPP := S2PresParameterSet(aPP, XBP_PP_FGCLR, n)}, ;
                  {|n| aPP := S2PresParameterSet(aPP, XBP_PP_BGCLR, n)}, ;
                  xBG, cClr, n, nNew)

#ifdef _XBASE17_
   // FA CASINO CON XBASE 1.5/1.6 infatti
   // nella dfUsrMsg le scritte si sovrappongono
   IF VALTYPE(lDisabledBG) == "L"

      IF nType == AI_COLORMODE_STD
//         cClr := XBPSYSCLR_TRANSPARENT

         // simone 24/9/04 mantis 113
         // imposta il colore disabilitato=colore sfondo
         cClr := S2PresParameterGet(aPP, XBP_PP_BGCLR)

      ELSE
         IF cClr == NIL .OR. ! lDisabledBG
            cClr := XBPSYSCLR_TRANSPARENT
         ELSE
            cClr := S2DbseeColorToRGB(cClr, .T.)
         ENDIF
      ENDIF

      IF cClr != NIL
         aPP := S2PresParameterSet(aPP, XBP_PP_DISABLED_BGCLR, cClr)
      ENDIF
   ENDIF
#endif
RETURN aPP

STATIC FUNCTION _StdClrGet(cClr, n, lBG)
   LOCAL aRet := {NIL, NIL}
   LOCAL aClr

  #ifdef _XBASE17_
   IF !EMPTY(cClr)
      aRet[1] := S2DbseeColorToRGB(cClr, .F., "RXP")
      aRet[2] := S2DbseeColorToRGB(cClr, .T., "RXP")
   ENDIF
  #endif

   IF VALTYPE(n)=="N" .AND. n >= 1 .AND. !EMPTY(aColors) .AND. n <= LEN(aColors)
      IF aRet[1] == NIL .AND. aColors[n][1] != NIL
         aRet[1] := aColors[n][1]
      ENDIF

      IF lBG .AND. aRet[2] == NIL .AND. aColors[n][2] != NIL
         aRet[2] := aColors[n][2]
      ENDIF
   ENDIF
RETURN aRet

// STATIC FUNCTION _SplitClr(cClr)
//    LOCAL nAt := AT("/", cClr)
//    cClr := UPPER(cClr)
// RETURN {ALLTRIM(LEFT(cClr, nAt-1)), ALLTRIM(SUBSTR(cClr, nAt+1))}

// $DOC
// Imposta nell'array del presentation parameter il colore
// di sfondo per control disabilitato default TRASPARENTE

FUNCTION S2PPSetDisabledBGClr(aPP, cClr)
#ifdef _XBASE17_
   IF cClr == NIL
      cClr := XBPSYSCLR_TRANSPARENT
   ELSE
      cClr := S2DbseeColorToRGB(cClr, .T.)
   ENDIF
   IF cClr != NIL
      aPP := S2PresParameterSet(aPP, XBP_PP_DISABLED_BGCLR, cClr)
   ENDIF
#endif
RETURN aPP

