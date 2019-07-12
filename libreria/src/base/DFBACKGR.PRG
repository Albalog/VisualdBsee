/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfBackGraph( cHeader, nMax )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nLen := LEN(cHeader), nRow, c1stChar := LEFT(cHeader,1), nPos, nNum
LOCAL nPart

nPos    := AT( c1stChar, PADC( cHeader, 80 ) )-1

dfGrfBox( nPos*8-8 , 13, (nPos+nLen+1)*8, 35, 14, 12 )
dfGrfSay( 1, nPos, cHeader, 206 )

dfGrfBox(  90, 48, 639, 320, 11, 11 )

/*     90/48
       ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      /³                    ³
     / ³                    ³
     | ³90/320              ³
     | ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 639/320
     |/                    /
     /____________________/
*/

FOR nRow := 1 TO 80
   dfDraw(  90-nRow, 320+nRow, 639-nRow, 320+nRow, 3 )
NEXT

FOR nRow := 0 TO 320-48
   dfDraw(  90-80, 48+80+nRow, 90, 48+nRow, 3 )
NEXT

dfDraw( 90, 320, 90-80, 320+80, 0 )

dfDraw( 90,  48, 90   , 320   , 0 )

nPart := INT(nMax/4)
FOR nNum := 1 TO 5
   IF nNum!=5
      dfGrfSay( nNum*4-1, 67, PADL( INT(nMax-nPart*(nNum-1)), 12), 176 )
   ENDIF
   dfDraw( 90, nNum*4*16,   639, nNum*4*16   , 0 )
   dfDraw( 90, nNum*4*16, 90-80, nNum*4*16+80, 0 )
NEXT

RETURN
