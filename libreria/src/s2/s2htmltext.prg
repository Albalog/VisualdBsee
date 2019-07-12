#include "common.ch"

// Usato in S2StaticX e dfAlert
//
//
// esegue il parse di una stringa tipo
// sintassi [HTMLFILE:pippo.htm]
// sintassi [HTMLTEXT:<b>ciao</b>]
// sintassi [HTMLURL:http://www.google.it]
// sintassi [HTMLFILE:size:120,90:pippo.htm]
FUNCTION S2HtmlTextParse(c, aSize, lURL)
   LOCAL l := .F., x
   lURL :=.F.
   aSize := NIL
   IF ! EMPTY(c) .AND. UPPER(LEFT(c, 5))=="[HTML" .AND. RIGHT(c, 1)=="]"
      IF UPPER(LEFT(c,  10))=="[HTMLFILE:"
         c:= SUBSTR(c, 11, LEN(c)-11)
         c:= "file://"+dfFNameBuild(c)
         lURL :=.T.
         l:=.T.
      ELSEIF UPPER(LEFT(c,  9))=="[HTMLURL:"
         c:= SUBSTR(c, 10, LEN(c)-10)
         lURL :=.T.
         l:=.T.
      ELSEIF UPPER(LEFT(c, 10))=="[HTMLTEXT:"
         c:= SUBSTR(c, 11, LEN(c)-11)
         lURL :=.F.
         l:=.T.
      ENDIF
      IF l .AND. UPPER(LEFT(c, 5))=="SIZE:"
         c:=SUBSTR(c, 6)
         l:=AT(",", c)
         IF l > 0
            x:=AT(":", c, l)
            IF x>l
               aSize := {VAL(LEFT(c, l-1)), VAL(SUBSTR(c, l+1, x-l))}
               c:=SUBSTR(c, x+1)
            ENDIF
         ENDIF
         l:=.T.
      ENDIF
   ENDIF
RETURN l

FUNCTION S2HtmlTextBuild(c, nType, aSize)
   LOCAL cRet
   LOCAL cSize := ""

   DEFAULT nType TO 0

   IF aSize != NIL
      cSize := "SIZE:"+ALLTRIM(STR(aSize[1]))+","+ALLTRIM(STR(aSize[2]))+":"
   ENDIF
   IF nType==0 // TEXT
      cRet := "[HTMLTEXT:"+cSize+c+"]"
   ELSEIF nType == 1 // FILE
      cRet := "[HTMLFILE:"+cSize+c+"]"
   ELSEIF nType == 2 // URL
      cRet := "[HTMLURL:"+cSize+c+"]"
   ELSE
      cRet := c
   ENDIF
RETURN cRet
      