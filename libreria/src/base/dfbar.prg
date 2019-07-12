/******************************************************************************
Project     : dBsee 4.6
Description : BARCODE Function
Programmer  : Baccan Matteo
******************************************************************************/
#include "Common.ch"
#include "dfReport.ch"
#include "dfBar.ch"
#include "dfStd.ch"

#define BARCODE_INIT                                  1
#define BARCODE_ADD                                   2
#define BARCODE_GET                                   3
#define BARCODE_SIZE                                  4

#define KEY_ESC                                 CHR(27)
#define KEY_CR                                  CHR(13)
#define KEY_LF                                  CHR(10)
#define KEY_ZERO                                 CHR(0)
#define KEY_UNO                                  CHR(1)
#define KEY_ZERO_ZERO_ZERO         CHR(0)+CHR(0)+CHR(0)

#define BARCODE_MAXSTRING_LENGTH                  60000

                //12345678901234567890123456789012345678901234
#define aSCode39 "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%*"
STATIC aVCode39 := {"2123414121",; // 0 0001101000
                    "4123212141",; // 1 1001000010
                    "2143212141",; // 2
                    "4143212121",; // 3
                    "2123412141",; // 4
                    "4123412121",; // 5
                    "2143412121",; // 6
                    "2123214141",; // 7
                    "4123214121",; // 8
                    "2143214121",; // 9
                    "4121232141",; // A
                    "2141232141",; // B
                    "4141232121",; // C
                    "2121432141",; // D
                    "4121432121",; // E
                    "2141432121",; // F
                    "2121234141",; // G
                    "4121234121",; // H
                    "2141234121",; // I
                    "2121434121",; // J
                    "4121212341",; // K
                    "2141212341",; // L
                    "4141212321",; // M
                    "2121412341",; // N
                    "4121412321",; // O
                    "2141412321",; // P
                    "2121214341",; // Q
                    "4121214321",; // R
                    "2141214321",; // S
                    "2121414321",; // T
                    "4321212141",; // U
                    "2341212141",; // V
                    "4341212121",; // W
                    "2321412141",; // X
                    "4321412121",; // Y
                    "2341412121",; // Z
                    "2321214141",; // -
                    "4321214121",; // .
                    "2341214121",; //
                    "2323232121",; // $
                    "2323212321",; // /
                    "2321232321",; // +
                    "2123232321",; // %
                    "2321414121" } // * 0100101000

#define cCodeEan "0123456789"

STATIC a25Int1 := { "22442",; // 0
                    "42224",; // 1
                    "24224",; // 2
                    "44222",; // 3
                    "22424",; // 4
                    "42422",; // 5
                    "24422",; // 6
                    "22244",; // 7
                    "42242",; // 8
                    "24242" } // 9

STATIC a25Int2 := { "11331",; // 0
                    "31113",; // 1
                    "13113",; // 2
                    "33111",; // 3
                    "11313",; // 4
                    "31311",; // 5
                    "13311",; // 6
                    "11133",; // 7
                    "31131",; // 8
                    "13131" } // 9

STATIC a25Ind := { "2121414121",; // 0
                   "4121212141",; // 1
                   "2141212141",; // 2
                   "4141212121",; // 3
                   "2121412141",; // 4
                   "4121412121",; // 5
                   "2141412121",; // 6
                   "2121214141",; // 7
                   "4121214121",; // 8
                   "2141214121" } // 9

#define c25IntStart "2121"
#define c25IntStop  "412"

#define c25IndStart "414121"
#define c25IndStop  "41214"


#define cEANEM      "212"
#define cEANCM      "12121"
#define cEANBGD     "121212"

STATIC aEANGrpA := { "1112212",;
                     "1122112",;
                     "1121122",;
                     "1222212",;
                     "1211122",;
                     "1221112",;
                     "1212222",;
                     "1222122",;
                     "1221222",;
                     "1112122" }
STATIC aEANGrpB := { "1211222",;
                     "1221122",;
                     "1122122",;
                     "1211112",;
                     "1122212",;
                     "1222112",;
                     "1111212",;
                     "1121112",;
                     "1112112",;
                     "1121222" }
STATIC aEANGrpC := { "2221121",;
                     "2211221",;
                     "2212211",;
                     "2111121",;
                     "2122211",;
                     "2112221",;
                     "2121111",;
                     "2111211",;
                     "2112111",;
                     "2221211"  }

STATIC aEAN13Flag := { "AAAAAA",;
                       "AABABB",;
                       "AABBAB",;
                       "AABBBA",;
                       "ABAABB",;
                       "ABBAAB",;
                       "ABBBAA",;
                       "ABABAB",;
                       "ABABBA",;
                       "ABBABA" }

/*
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION Test(  )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SET PRINTER TO LPT1
SET DEVICE  TO PRINTER

AEVAL( dfBarCode( "1234567890123", BARCODE_EAN13, PRN_HPDJ ), {|x|DEVOUT(x)} )
AEVAL( dfBarCode( "12345678"     , BARCODE_EAN8 , PRN_HPDJ ), {|x|DEVOUT(x)} )
AEVAL( dfBarCode( "123456789012" , BARCODE_UPCA , PRN_HPDJ ), {|x|DEVOUT(x)} )
AEVAL( dfBarCode( "123456"       , BARCODE_UPCE , PRN_HPDJ ), {|x|DEVOUT(x)} )
AEVAL( dfBarCode( "1234567890"   , BARCODE_39   , PRN_HPDJ ), {|x|DEVOUT(x)} )
AEVAL( dfBarCode( "1234567890"   , BARCODE_25INT, PRN_HPDJ ), {|x|DEVOUT(x)} )
AEVAL( dfBarCode( "1234567890"   , BARCODE_25IND, PRN_HPDJ ), {|x|DEVOUT(x)} )

SET PRINTER TO
SET DEVICE  TO SCREEN

RETURN NIL
*/

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfBarCode( cCode     ,; // Code To Convert
                    nBarCode  ,; // Used BarCode           DEFAULT BARCODE_39
                    nPrinter  ,; // Printer Used           DEFAULT PRN_EPSON_24
                    nWidth    ,; // Width of the BarCode   DEFAULT 20
                    nRow      ,; // Heigth of the BarCode  DEFAULT  3
                    nLMargin  ,; // Left Margin            DEFAULT  0
                    nCPI       ) // Character Per Inch     DEFAULT 10
                    //nRowPoint  ) // nRowPoint              DEFAULT 12
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cCodIni, aCodType, nRowPoint

DEFAULT nBarCode  TO BARCODE_39
DEFAULT nPrinter  TO PRN_EPSON_24
DEFAULT nWidth    TO 20
DEFAULT nRow      TO  3
DEFAULT nLMargin  TO  0
DEFAULT nCPI      TO 10
DEFAULT nRowPoint TO 12

IF nCPI<1
   nCPI := 1
ENDIF

aCodType := dfCodeType( nBarCode, cCode )

dfBarAdd( BARCODE_INIT )
cCodIni := dfBarCodeIni( nPrinter, aCodType, nWidth, nCPI, nRowPoint)

IF nRow>0
   dfBarAdd( BARCODE_ADD, SPACE(nLMargin) )
   dfSingleBar( nPrinter, cCodIni, nLMargin, nCPI, nRowPoint)
ENDIF

dfBarAdd( BARCODE_SIZE, nRow )

RETURN dfBarAdd( BARCODE_GET )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfBarCodeIni( nPrinter, aCodType, nWidth, nCPI, nRowPoint )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cRet, nNum, nPos, nSize, nLenCod, aBar
LOCAL nCode := aCodType[1], cCodType, cSub, nDispari := 1

cCodType := aCodType[2]
nLenCod  := LEN(cCodType)
nNum     := 0

DO CASE
   CASE nCode == BARCODE_39                                ; nDispari := 2.52
   CASE nCode == BARCODE_25INT .OR. nCode == BARCODE_25IND ; nDispari := 2
ENDCASE

FOR nPos := 1 TO nLenCod
   DO CASE
      CASE SUBSTR(cCodType, nPos, 1)$"12" ; nNum++
      CASE nCode == BARCODE_39    .OR. ;
           nCode == BARCODE_25INT .OR. ;
           nCode == BARCODE_25IND         ; nNum += nDispari
   ENDCASE
NEXT

nSize := IF(nNum!=0, 72 / nCPI * nWidth / nNum, 0)

// Creazione Barre
aBar := { dfBarEmpty( nPrinter, nSize                       ) ,;
          dfBarFull(  nPrinter, nSize           , nRowPoint ) ,;
          dfBarEmpty( nPrinter, nSize * nDispari            ) ,;
          dfBarFull(  nPrinter, nSize * nDispari, nRowPoint )  }

cRet := ""
FOR nPos := 1 TO nLenCod
   cSub := SUBSTR( cCodType, nPos, 1 )
   DO CASE
      CASE cSub == "1"; cRet += aBar[1]  // Dispari Sottile
      CASE cSub == "2"; cRet += aBar[2]  // Pari    Sottile
      CASE cSub == "3"; cRet += aBar[3]  // Dispari Spessa
      CASE cSub == "4"; cRet += aBar[4]  // Pari    Spessa
   ENDCASE
NEXT

RETURN cRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfBarEmpty( nPrinter, nSize )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cStr := ""

DO CASE
   CASE nPrinter == PRN_EPSON_9
        cStr := REPLICATE( KEY_ZERO          , ROUND( nSize * (240/72), 0 ) )

   CASE nPrinter == PRN_EPSON_24
        cStr := REPLICATE( KEY_ZERO_ZERO_ZERO, ROUND( nSize * (180/72), 0 ) )

   CASE nPrinter == PRN_HPDJ .OR. nPrinter == PRN_HPDJPLUS
        cStr := REPLICATE( "0"               , ROUND( nSize * (300/72), 0 ) )

   CASE nPrinter == PRN_HP_LASERJET
        cStr := KEY_ESC +"&a+" +ALLTRIM(STR(nSize * 10)) +"H"

ENDCASE

RETURN cStr


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfBarFull( nPrinter, nSize, nRowPoint )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cStr := ""

DO CASE
   CASE nPrinter == PRN_EPSON_9
        cStr := REPLICATE("ÿ"  , ROUND( nSize * (240/72), 0))

   CASE nPrinter == PRN_EPSON_24
        cStr := REPLICATE("ÿÿü", ROUND( nSize * (180/72), 0))

   CASE nPrinter == PRN_HPDJ .OR. nPrinter == PRN_HPDJPLUS
        cStr := REPLICATE("1"  , ROUND( nSize * (300/72), 0))

   CASE nPrinter == PRN_HP_LASERJET
        cStr := KEY_ESC +"&f0S"                                           +;
                KEY_ESC +"&a-"  +ALLTRIM(STR(nRowPoint * 10 * 0.75)) +"V" +;
                KEY_ESC +"*c"   +ALLTRIM(STR(nSize     * 10       )) +"H" +;
                KEY_ESC +"*c"   +ALLTRIM(STR(nRowPoint * 10       )) +"V" +;
                KEY_ESC +"*c0P"                                           +;
                KEY_ESC +"&f1S"                                           +;
                KEY_ESC +"&a+"  +ALLTRIM(STR(nSize     * 10       )) +"H"

ENDCASE

RETURN cStr

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfSingleBar( nPrinter, cStr, nLMargin, nCPI, nRowPoint)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cStr1 := "", nLenRound, nNum, nNum1, cStr2, cSub, cSub1

DO CASE
   CASE nPrinter == PRN_EPSON_9
        cSub  := CHR(LEN(cStr) % 256) +CHR(INT(LEN(cStr) / 256)) +cStr
        cSub1 := KEY_CR +SPACE(nLMargin)

        dfBarAdd( BARCODE_ADD, KEY_ESC +"U" +KEY_UNO                        +;
                               KEY_ESC +"Z" +cSub                           +;
                               KEY_ESC +"J" +KEY_UNO                +cSub1  +;
                               KEY_ESC +"Z" +cSub                           +;
                               KEY_ESC +"J" +CHR((nRowPoint-8)*3-1) +cSub1  +;
                               KEY_ESC +"Z" +cSub                           +;
                               KEY_ESC +"J" +KEY_UNO                +cSub1  +;
                               KEY_ESC +"Z" +cSub                           +;
                               KEY_ESC +"J" +CHR(23)                +KEY_CR +;
                               KEY_ESC +"U" +KEY_ZERO )

   CASE nPrinter == PRN_EPSON_24
        dfBarAdd( BARCODE_ADD, KEY_ESC +"U"  +KEY_UNO+;
                               KEY_ESC +"*'" +CHR(LEN(cStr)/3%256) +CHR(INT(LEN(cStr)/3/256)) + cStr)
        IF nRowPoint = 12
           dfBarAdd( BARCODE_ADD, KEY_ESC +"J" +KEY_LF  +KEY_CR               +SPACE(nLMargin)                 +;
                                  KEY_ESC +"*" +"'"     +CHR(LEN(cStr)/3%256) +CHR(INT(LEN(cStr)/3/256)) +cStr +;
                                  KEY_ESC +"J" +CHR(20) +KEY_CR)
        ELSE
           dfBarAdd( BARCODE_ADD, CRLF )
        ENDIF
        dfBarAdd( BARCODE_ADD, KEY_ESC+"U"+KEY_ZERO )

   CASE nPrinter == PRN_HPDJ .OR. nPrinter == PRN_HPDJPLUS
        nLenRound := dfRoundUp( LEN(cStr), 8 )

        cStr += REPLICATE("0", nLenRound +LEN(cStr))

        FOR nNum1 := 1 TO nLenRound STEP 8

           cStr2 := SUBSTR(cStr, nNum1, 8)

           IF cStr2 == "11111111"
              cStr1 += "ÿ"
           ELSE
              cStr1 += CHR( dfBin2Num(cStr2) )
           ENDIF

        NEXT

        IF nPrinter = PRN_HPDJ
           cStr1 := REPLICATE(KEY_ZERO, INT(300 / nCPI * nLMargin / 8)) + cStr1
           cStr1 := KEY_ESC +"*b" +ALLTRIM(STR(LEN(cStr1))) +"W" +cStr1
        ELSE
           cStr1 := KEY_ESC +"*b" +ALLTRIM(STR(LEN(cStr1))) +"W" +cStr1
           cStr1 := KEY_ESC +"*b" +ALLTRIM(STR(INT(300 / nCPI * nLMargin))) +"X" +cStr1
        ENDIF

        nNum := ROUND(300/72 *nRowPoint, 0)

        dfBarAdd( BARCODE_ADD, KEY_ESC +"*t300R"+;
                               KEY_ESC +"&a-"   +ALLTRIM(STR(nRowPoint*7.5)) +"V" +;
                               KEY_ESC +"*r0A")

        FOR nNum1 := 1 TO nNum
           dfBarAdd( BARCODE_ADD, cStr1 )
        NEXT

        dfBarAdd( BARCODE_ADD, KEY_ESC +"*rB" +;
                               KEY_ESC +"&a-" +ALLTRIM(STR(nRowPoint*2.5)) +"V" +;
                               KEY_ESC +"&a"  +ALLTRIM(STR(nLMargin))      +"C" +CRLF )

   CASE nPrinter == PRN_HP_LASERJET
        dfBarAdd( BARCODE_ADD, KEY_ESC +"*t300R"+;
                               KEY_ESC +"&f0S"  +cStr +;
                               KEY_ESC +"&f1S"  +CRLF )

ENDCASE

RETURN


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfBarAdd( nFunc, cStr )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC aBARCODE
LOCAL nRow, nLenArray, nPos
DO CASE
   CASE nFunc == BARCODE_INIT
        aBARCODE := {""}

   CASE nFunc == BARCODE_ADD
        IF LEN(ATAIL(aBARCODE)) +LEN(cStr) < BARCODE_MAXSTRING_LENGTH
           aBARCODE[LEN(aBARCODE)] += cStr
        ELSE
           AADD( aBARCODE, cStr )
        ENDIF

   CASE nFunc == BARCODE_SIZE
        nLenArray := LEN(aBARCODE)
        FOR nRow := 2 TO cStr
           FOR nPos := 1 TO nLenArray
              AADD( aBARCODE, aBARCODE[nPos] )
           NEXT
        NEXT

   CASE nFunc == BARCODE_GET

ENDCASE

RETURN aBARCODE

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfCodeType( nBarCode, cStr )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aRet := {,}
DO CASE
   CASE nBarCode==BARCODE_EAN13 ; aRet := dfCodEan( BARCODE_EAN13, cStr )
   CASE nBarCode==BARCODE_EAN8  ; aRet := dfCodEan( BARCODE_EAN8 , cStr )
   CASE nBarCode==BARCODE_UPCA  ; aRet := dfCodEan( BARCODE_UPCA , cStr )
   CASE nBarCode==BARCODE_UPCE  ; aRet := dfCodEan( BARCODE_UPCE , cStr )
   CASE nBarCode==BARCODE_39    ; aRet := dfCod39( cStr )
   CASE nBarCode==BARCODE_25INT ; aRet := dfCod25Int( cStr )
   CASE nBarCode==BARCODE_25IND ; aRet := dfCod25Ind( cStr )
ENDCASE

RETURN aRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfCodEan( nBarCode, cCode )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPosCode, cRet := cEANEM, nLenCode := LEN(cCode), nPosEan, cFormat

DO CASE
   CASE nBarCode == BARCODE_EAN13
        IF nLenCode != 13
           cCode := PADL( cCode, 13, "0" )
        ENDIF

   CASE nBarCode == BARCODE_EAN8
        IF nLenCode != 8
           cCode := PADL( cCode,  8, "0" )
        ENDIF

   CASE nBarCode == BARCODE_UPCA
        IF nLenCode != 12
           cCode := PADL( cCode, 12, "0" )
        ENDIF

   CASE nBarCode == BARCODE_UPCE
        IF nLenCode != 6
           cCode := PADL( cCode,  6, "0" )
        ENDIF

ENDCASE

FOR nPosCode := 1 TO nLenCode

   IF (nPosEan := AT(SUBSTR(cCode, nPosCode, 1), cCodeEan)) > 0

      DO CASE
              // EM ?????? CM CCCCCC EM
         CASE nBarCode == BARCODE_EAN13

              IF nPosCode == 1
                 cFormat := aEAN13Flag[nPosEan]
              ELSEIF nPosCode <= 7
                 IF SUBSTR(cFormat, nPosCode - 1, 1) == "A"
                    cRet += aEANGrpA[nPosEan]
                 ELSE
                    cRet += aEANGrpB[nPosEan]
                 ENDIF
              ELSEIF nPosCode == 8
                 cRet += (cEANCM + aEANGrpC[nPosEan])
              ELSE
                 cRet +=           aEANGrpC[nPosEan]
              ENDIF

              // EM AAAA CM CCCC EM
         CASE nBarCode == BARCODE_EAN8

              IF nPosCode <= 4
                 cRet += aEANGrpA[nPosEan]
              ELSEIF nPosCode == 5
                 cRet += (cEANCM + aEANGrpC[nPosEan])
              ELSE
                 cRet +=           aEANGrpC[nPosEan]
              ENDIF

              // EM AAAAAA CM CCCCCC EM
         CASE nBarCode == BARCODE_UPCA

              IF nPosCode <= 6
                 cRet += aEANGrpA[nPosEan]
              ELSEIF nPosCode == 7
                 cRet += (cEANCM + aEANGrpC[nPosEan])
              ELSE
                 cRet +=           aEANGrpC[nPosEan]
              ENDIF

              // EM AAABBB BGD
         CASE nBarCode == BARCODE_UPCE

              IF nPosCode <= 3
                 cRet += aEANGrpA[nPosEan]
              ELSE
                 cRet += aEANGrpB[nPosEan]
              ENDIF

      ENDCASE

   ENDIF

NEXT

IF nBarCode==BARCODE_UPCE
   cRet += cEANBGD
ELSE
   cRet += cEANEM
ENDIF

RETURN {nBarCode,cRet}

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfCod39( cCode )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos, cRet := "", nLenCode, nPos39

// Preparo il codice per la decodifica, aggiungendo l'asterisco che Š
// il carattere di start/stop del Codice 39
cCode    := "*" +UPPER(cCode) +"*"
nLenCode := LEN(cCode)

// Decodifica il codice secondo la tabella Codice 39
FOR nPos := 1 TO nLenCode
   IF (nPos39 := AT(SUBSTR(cCode, nPos, 1), aSCode39)) > 0
      cRet += aVCode39[nPos39]
   ENDIF
NEXT

RETURN {BARCODE_39,cRet}

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfCod25Int( cCode )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos, cRet := "", nLenCode, nPosStr, cPari, cDispari, cNewCode := ""

// Tolgo i caratteri inutili
FOR nPos := 1 TO LEN( cCode )
   IF SUBSTR( cCode, nPos, 1 )$cCodeEan
      cNewCode += SUBSTR( cCode, nPos, 1 )
   ENDIF
NEXT

cCode := cNewCode

// I numeri devono essere pari, pertanto normalizzo il codice a barre
IF !INT(LEN(TRIM(cCode)) % 2) == 0
   cCode := "0" +cCode
ENDIF

nLenCode := LEN(cCode)

FOR nPos := 1 TO nLenCode STEP 2

   cPari    := a25Int1[AT(SUBSTR(cCode, nPos  , 1), cCodeEan)]
   cDispari := a25Int2[AT(SUBSTR(cCode, nPos+1, 1), cCodeEan)]

   FOR nPosStr := 1 TO 5
      cRet += (SUBSTR(cPari   , nPosStr, 1) +;
               SUBSTR(cDispari, nPosStr, 1))
   NEXT

NEXT

RETURN {BARCODE_25INT, c25IntStart+cRet+c25IntStop}

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfCod25Ind( cCode )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos, cRet := "", nLenCode, cNewCode := ""

// Tolgo i caratteri inutili
FOR nPos := 1 TO LEN( cCode )
   IF SUBSTR( cCode, nPos, 1 )$cCodeEan
      cNewCode += SUBSTR( cCode, nPos, 1 )
   ENDIF
NEXT

cCode := cNewCode

// I numeri devono essere pari, pertanto normalizzo il codice a barre
IF !INT(LEN(TRIM(cCode)) % 2) == 0
   cCode := "0" +cCode
ENDIF

nLenCode := LEN(cCode)
FOR nPos := 1 TO nLenCode
   cRet += a25Ind[ AT(SUBSTR(cCode, nPos, 1), cCodeEan) ]
NEXT

RETURN {BARCODE_25IND, c25IndStart+cRet+c25IndStop}
