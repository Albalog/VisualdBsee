#include "Common.ch"
#include "dfWin.ch"
#include "dfSet.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE tbDisPage( oTbr, cColor )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC cPageL, cPageR, cStepL, cStepR
LOCAL cHead, nBottom, nLeft, nRight
IF cPageL==NIL
   cPageR := cPageL := LEFT(dfFontStr("sizingicon"),1) +;
                       RIGHT(dfFontStr("SystemMenuIcon"),1)
   cStepL := LEFT(dfFontStr("scrollleftarrow"),1) +;
             RIGHT(dfFontStr("SystemMenuIcon"),1)
   cStepR := LEFT(dfFontStr("SystemMenuIcon"),1)  +;
             RIGHT(dfFontStr("scrollrightarrow"),1)
ENDIF
nBottom := TBREALBOTTOM( oTbr )
nLeft   := TBREALLEFT( oTbr )
nRight  := TBREALRIGHT( oTbr )

cHead := dfGetArr( oTbr:W_PAGELABELS, oTbr:W_CURRENTPAGE )
cHead := PADC( cHead, nRight -nLeft -7 )

@ nBottom, nLeft    SAY cPageL +cStepL COLOR cColor
@ nBottom, nRight-3 SAY cStepR +cPageR COLOR cColor
@ nBottom, nLeft+4  SAY cHead          COLOR oTbr:W_COLORARRAY[AC_FRM_HEADER]
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE tbPageMou( oTbr )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nCol := M_PosX()
LOCAL nLeft  := TBREALLEFT( oTbr )
LOCAL nRight := TBREALRIGHT( oTbr )

DO CASE
   CASE nCol == nLeft    .OR. nCol == nLeft+1  ; tbPgGoto( oTbr, 1 )
   CASE nCol == nLeft+2  .OR. nCol == nLeft+3  ; tbPgSkip( oTbr, -1 )
   CASE nCol == nRight   .OR. nCol == nRight-1 ; tbPgGoto( oTbr, oTbr:W_PAGEMAX )
   CASE nCol == nRight-2 .OR. nCol == nRight-3 ; tbPgSkip( oTbr, 1 )
   OTHERWISE                                   ; tbPgList( oTbr )
ENDCASE

RETURN
