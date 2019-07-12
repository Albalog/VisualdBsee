#define MAX_NUM_FONT 9

STATIC aFnt

FUNCTION S2ApplicationFont(cFont)
   IF ! EMPTY(cFont)
      cFont := ALLTRIM(cFont)
      IF dfIsDigit(cFont)

         cFont := VAL(cFont)

         IF cFont >= 1 .AND. cFont <= MAX_NUM_FONT
            IF aFnt == NIL 
               _LoadFont()
            ENDIF
            RETURN aFnt[cFont]
         ENDIF

         cFont := dfSet("XbaseApplicationFont"+STRZERO(cFont, 2, 0))
      ENDIF
   ENDIF
   IF ! EMPTY(cFont)
      cFont := dfFontCompoundNameNormalize(cFont)
   ENDIF
RETURN cFont

STATIC FUNCTION _LoadFont()
   LOCAL n
   LOCAL cFont

   aFnt := ARRAY(MAX_NUM_FONT)
   FOR n := 1 TO LEN(aFnt)
      cFont := dfSet("XbaseApplicationFont"+STRZERO(n, 2, 0))
      IF ! EMPTY(cFont)
         cFont := dfFontCompoundNameNormalize(cFont)
      ENDIF
      aFnt[n] := cFont
   NEXT
RETURN NIL