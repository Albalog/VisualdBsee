/*
€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
€                                                                              €
€ MODULE     : 123.prg                                                         €
€ AUTHOR     : jON Rowlan S.A.D.S. Ltd. 1989, 1990, 1991                       €
€              Hunton, Maidstone England 44 6272 688/748                       €
€                      (from 28/05/92 0622 820688 & 820748 )                   €
€              Compuserve : 100013,475                                         €
€                                                                              €
€ PARAMETERS : none                                                            €
€                                                                              €
€ description : This is a self contained module that will create a Lotus       €
€               WKS/WK1 style spreadsheet from an array of character and       €
€               numeric data. Numerics are converted TO the IEEE FORmat as     €
€               used by Lotus. I would be pleased TO hear of any enhancements  €
€               comments or :-( 'BUGS' but IF the module is used in any        €
€               application the copyright notice as bordered by this box must  €
€               be included in the source. IF any modIFications are required   €                                                                            €
€               I will be happy TO do these FOR 'The usual fee plus expenses'. €
€               At the end of the day, I will be happy IF this module helps    €
€               save somebody the hassle I had in trying TO put it TOgether    €
€               when asked by my client, "Can we export TO Lotus ???!!???".    €
€               The IEEE conversion routine can be reworked with Funcky's      €
€               or() and and() functions. Bon Chance!                          €
€                                                                              €
€ Compile with : /n                                                            €
€                                                                              €
€ Link with    : whatever you fancy                                            €
€                                                                              €
€ Modifiche    : 06/set/2001 il numero di righe e colonne arriva fino a 64K    €
€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€*/

#define WKS_BOF          CHR(0)+CHR(0)+CHR(2)+CHR(0)+CHR(4)+CHR(4)
#define WKS_EOF          CHR(1)+CHR(0)+CHR(0)+CHR(0)
#define WKS_LABELHDR     CHR(15)+CHR(0)
#define WKS_NUMBERHDR    CHR(14)+CHR(0)+CHR(13)+CHR(0)

#define LEFT_JUSTIFY     "'"
#define RIGHT_JUSTIFY    CHR(34)
#define CENTERED         "^"
#define REPEATING        "\"
#define PROTECTED        CHR(128)
#define UNPROTECTED      CHR(0)
#define FIXED            0
#define SCIENTIFIC       1
#define CURRENCY         2
#define PERCENT          3
#define COMMA            4
#define UNUSED1          5
#define UNUSED2          6
#define SPECIAL          7
#define STANDARD_FORMAT  CHR(255)

STATIC WKSHandle

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfWKSCreate( WKSFileName, WorkSheet )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL col, row

// Create WKS type file //
IF !( "." $ WKSFileName )
   WKSFileName += ".WKS"
ENDIF

WKSHandle := FCREATE( WKSFileName )
FWRITE( WKSHandle, WKS_BOF )

FOR row=1 TO len(WorkSheet)
   FOR col=1 TO len(WorkSheet[row])
      DO CASE
         CASE VALTYPE( worksheet[row,col] ) == "C"
            WKSWriteStr( WorkSheet[row, col], "L", row, col )
         CASE VALTYPE( worksheet[row,col] ) == "N"
            WKSWriteNum( WorkSheet[row, col], row, col )
      ENDCASE
   NEXT
NEXT

FWRITE( WKSHandle, WKS_EOF )
FCLOSE( WKSHandle )

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION WKSwritestr( ostr, just, row, col )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL r

just := upper( just )
ostr := trim( ostr )

// IF ostr is blank, RETURN //
IF ostr == ""
   RETURN( .t. )
ENDIF

// Text label header, 2 chars //
r := FWRITE( WKSHandle, WKS_LABELHDR )

// Text Label length, 2 chars //
r += FWRITE( WKSHandle, CHR( ( len( trim( ostr ) ) + 7 ) % 256 ) )
r += FWRITE( WKSHandle, CHR( ( len( trim( ostr ) ) + 7 ) / 256 ) )

// default cell FORmat, 1 char //
r += FWRITE( WKSHandle, STANDARD_FORMAT )

// cell co-ordinates, 4 chars TOtal ( numbers in reverse byte FORmat ! ) //
r += WKScoord( row, col )

// JustIFication, 1 char //
do CASE
   CASE just == "R"
        r += FWRITE( WKSHandle, RIGHT_JUSTIFY )
   CASE just == "L"
        r += FWRITE( WKSHandle, LEFT_JUSTIFY )
   CASE just == "C"
        r += FWRITE( WKSHandle, CENTERED )
   CASE just == "R"
        r += FWRITE( WKSHandle, REPEATING )
ENDCASE

// actual textual string, len(ostr) chars //
r += FWRITE( WKSHandle, ostr, len(ostr) )

// Null termination, 1 char //
r += FWRITE( WKSHandle, CHR(0), 1)

RETURN( r == 11+len(ostr) )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION WKSwritenum( num, row, col )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL r:=0

// Number Cell Header, 4 chars //
r := FWRITE( WKSHandle, WKS_NUMBERHDR )

// cell FORmat, 1 char //
r += FWRITE( WKSHandle, STANDARD_FORMAT )

// Worksheet Co-Ordinates, 4 chars //
r += WKScoord( row, col )

// Number converted TO an ieee FORmat, 8 chars //
r += FWRITE( WKSHandle, dec2ieee( num ) )

RETURN( r == 17 )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION WKScoord( row, col )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aRow := {0,0}
LOCAL aCol := {0,0}

col--
row--

aRow[1] := INT(row/256)
aRow[2] := row % 256

aCol[1] := INT(col/256)
aCol[2] := col % 256

RETURN FWRITE( WKSHandle, CHR( aCol[2] )+CHR(aCol[1])+CHR( aRow[2] )+CHR( aRow[1] ) )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dec2ieee( num )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL ieeea := { 0, 0, 0, 0, 0, 0, 0, 0 }, F, exponent, e1, e2, e3, ;
      sign, i, part

IF num != 0

   sign := IF(num<0, 1, 0)
   IF sign != 0
      num := num * -1
   ENDIF
   IF LOG(num)/LOG(2)<0
      exponent:=INT(LOG(num)/LOG(2)-1)+1023
   ELSE
      exponent:=INT(LOG(num)/LOG(2))+1023
   ENDIF

   F := ( num / 2^(exponent-1023) - 1 ) * 2^52

// save exponent //
   e1 := INT(exponent/256)
   e2 := INT((exponent-e1*256)/16)
   e3 := exponent-e1*256-e2*16

   ieeea[8] := (sign*128)+e1*16+e2
   ieeea[7] := e3*16

// save fraction //
   FOR i=6 TO 0 STEP -1
      part := INT( F / 256^i )
      ieeea[i+1] := ieeea[i+1] + part
      F := F-part*256^i
   NEXT

ENDIF

RETURN( CHR(ieeea[1])+CHR(ieeea[2])+CHR(ieeea[3])+CHR(ieeea[4])+ ;
        CHR(ieeea[5])+CHR(ieeea[6])+CHR(ieeea[7])+CHR(ieeea[8]) )
