/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/
#include "common.ch"
#include "dfKeySer.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfKey2Serial( cSerial, nVer, nSeed )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos, nChar, cChar, cNew := ""

DEFAULT nSeed TO 85

DO CASE
   CASE nVer==SERIAL_CRIPTED1
        FOR nPos := 1 TO LEN( cSerial )
           nChar := dfXor(ASC(SUBSTR(cSerial,nPos,1)),nSeed)+nPos
           cChar := SUBSTR(dfDec2Hex( nChar ),3,2)
           cNew += cChar
        NEXT
        cNew := dfScramble( cNew, .T. )

   CASE nVer==SERIAL_CRIPTED2
        FOR nPos := 1 TO LEN( cSerial )
           nChar := dfXor(ASC(SUBSTR(cSerial,nPos,1)),nSeed)+nPos
           cChar := dfDec2Hex( nChar )
           cNew += PADL( ASC(SUBSTR(cChar,3,1))*100 +ASC(SUBSTR(cChar,4,1)), 4, "0" )
        NEXT
        cNew := dfScramble( cNew, .T. )

   CASE nVer==SERIAL_NOCONVERSION
        cNew := cSerial
ENDCASE

RETURN cNew

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfSerial2Key( cSerial, nVer, nSeed )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos, cSub, cNew := ""

DEFAULT nSeed TO 85

DO CASE
   CASE nVer==SERIAL_CRIPTED1
        cSerial := dfScramble( cSerial, .F. )
        FOR nPos := 1 TO LEN(cSerial) STEP 2
           cSub := SUBSTR(cSerial,nPos,2)
           cNew += CHR(dfXor(dfHex2Dec(cSub)-LEN(cNew)-1,nSeed))
        NEXT

   CASE nVer==SERIAL_CRIPTED2
        cSerial := dfScramble( cSerial, .F. )
        FOR nPos := 1 TO LEN(cSerial) STEP 4
           cSub := CHR(VAL(SUBSTR(cSerial,nPos,2))) +CHR(VAL(SUBSTR(cSerial,nPos+2,2)))
           cNew += CHR(dfXor(dfHex2Dec(cSub)-LEN(cNew)-1,nSeed))
        NEXT

   CASE nVer==SERIAL_NOCONVERSION
        cNew := cSerial
ENDCASE

RETURN cNew

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfScramble( cSerial, lPas )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cNew := "", cChar, nPos
FOR nPos := 1 TO LEN(cSerial)
   IF lPas
      cChar := SUBSTR(cSerial,nPos,1)
      DO CASE
         // ENCODE
         CASE cChar=="0"; cChar := CHR( 65+dfAnd(nPos,7) )
         CASE cChar=="1"; cChar := CHR( 80+dfAnd(nPos,7) )
         CASE cChar=="2"; cChar := CHR( 73+dfAnd(nPos,7) )
         CASE cChar=="3"; cChar := CHR( 67+dfAnd(nPos,7) )
         CASE cChar=="4"; cChar := CHR( 75+dfAnd(nPos,7) )
         CASE cChar=="5"; cChar := CHR( 74+dfAnd(nPos,7) )
         CASE cChar=="6"; cChar := CHR( 68+dfAnd(nPos,7) )
         CASE cChar=="7"; cChar := CHR( 77+dfAnd(nPos,7) )
         CASE cChar=="8"; cChar := CHR( 79+dfAnd(nPos,7) )
         CASE cChar=="9"; cChar := CHR( 71+dfAnd(nPos,7) )
         CASE cChar=="A"; cChar := CHR( 66+dfAnd(nPos,7) )
         CASE cChar=="B"; cChar := CHR( 81+dfAnd(nPos,7) )
         CASE cChar=="C"; cChar := CHR( 69+dfAnd(nPos,7) )
         CASE cChar=="D"; cChar := CHR( 70+dfAnd(nPos,7) )
         CASE cChar=="E"; cChar := CHR( 72+dfAnd(nPos,7) )
         CASE cChar=="F"; cChar := CHR( 78+dfAnd(nPos,7) )
         OTHERWISE
              cChar:="X"
      ENDCASE
   ELSE
      // DECODE
      cChar := ASC(SUBSTR(cSerial,nPos,1)) -dfAnd(nPos,7)
      DO CASE
         CASE cChar==65; cChar := "0"
         CASE cChar==80; cChar := "1"
         CASE cChar==73; cChar := "2"
         CASE cChar==67; cChar := "3"
         CASE cChar==75; cChar := "4"
         CASE cChar==74; cChar := "5"
         CASE cChar==68; cChar := "6"
         CASE cChar==77; cChar := "7"
         CASE cChar==79; cChar := "8"
         CASE cChar==71; cChar := "9"
         CASE cChar==66; cChar := "A"
         CASE cChar==81; cChar := "B"
         CASE cChar==69; cChar := "C"
         CASE cChar==70; cChar := "D"
         CASE cChar==72; cChar := "E"
         CASE cChar==78; cChar := "F"
         OTHERWISE
              cChar:="X"
      ENDCASE
   ENDIF
   cNew += cChar
NEXT
RETURN cNew
