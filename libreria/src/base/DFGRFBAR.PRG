/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "Common.ch"
#include "dfGraph.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfGrfBar( x1,y1,x2,y2,nCol,nFil,nTyp )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL x3:=x1, x4, x5, nCol2

DEFAULT nTyp TO BAR_DEFAULT

DO CASE
   CASE nTyp==BAR_TOP_PYRAMIDAL          .OR.;
        nTyp==BAR_TOP_PYRAMIDAL_SIMPLY

        x3 += INT( (x2-x1)/2 )
        FOR x4 := x1 TO x2
           dfDraw( x3, y1, x4, y2, nCol )
        NEXT
        IF nTyp==BAR_TOP_PYRAMIDAL
           FOR x5 := 1 TO 5
              dfDraw( x3, y1, x2+x5, y2-x5, nCol )
           NEXT
           dfDraw( x2, y2, x2+5, y2-5, 0 )
           dfDraw( x3, y1, x2+5, y2-5, 0 )
        ENDIF
        dfDraw( x3, y1, x1, y2, 0 )
        dfDraw( x3, y1, x2, y2, 0 )
        dfDraw( x1, y2, x2, y2, 0 )

   CASE nTyp==BAR_BOTTOM_PYRAMIDAL       .OR.;
        nTyp==BAR_BOTTOM_PYRAMIDAL_SIMPLY

        x3 += INT( (x2-x1)/2 )
        FOR x4 := x1 TO x2
           dfDraw( x4, y1, x3, y2, nCol )
        NEXT

        IF nTyp==BAR_BOTTOM_PYRAMIDAL
           FOR x5 := 1 TO 5
              dfDraw( x1+x5, y1-x5, x2+x5, y1-x5, nCol )
           NEXT
           FOR x5 := 1 TO 5
              dfDraw( x2+x5, y1-x5, x3, y2, nCol )
           NEXT
           dfDraw( x1, y1, x1+5, y1-5, 0 )
           dfDraw( x2, y1, x2+5, y1-5, 0 )
           dfDraw( x1+5, y1-5, x2+5, y1-5, 0 )
           dfDraw( x3, y2, x2+5, y1-5, 0 )
        ENDIF
        dfDraw( x3, y2, x1, y1, 0 )
        dfDraw( x3, y2, x2, y1, 0 )
        dfDraw( x1, y1, x2, y1, 0 )

   CASE nTyp==BAR_DEFAULT                .OR.;
        nTyp==BAR_NORMAL_BAR             .OR.;
        nTyp==BAR_NORMAL_BAR_SIMPLY

        dfGrfBox(x1,y1,x2,y2,0,nFil)

        IF nTyp!=BAR_NORMAL_BAR_SIMPLY
           FOR x3 := 1 TO 5
              IF x3==5
                 nCol2 := 0
              ELSE
                 nCol2 := nCol
              ENDIF
              dfDraw( x1+x3, y1-x3, x2+x3, y1-x3, nCol2 )
           NEXT
           FOR x4 := 1 TO 5
              IF x4==5
                 nCol2 := 0
              ELSE
                 nCol2 := nCol
              ENDIF
              dfDraw( x2+x4, y1-x4, x2+x4, y2-x4, nCol2 )
           NEXT
           dfDraw( x1, y1, x1+5, y1-5, 0 )
           dfDraw( x2, y1, x2+5, y1-5, 0 )
           dfDraw( x2, y2, x2+5, y2-5, 0 )
        ENDIF
ENDCASE

RETURN
