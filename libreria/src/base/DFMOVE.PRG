//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
#include "dfWin.ch"
#include "dfMove.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfMove( aPos, lKey, lShade, lInBox )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nVert  := aPos[POS_BOTTOM] -aPos[POS_TOP ]
LOCAL nHoriz := aPos[POS_RIGHT ] -aPos[POS_LEFT]
LOCAL nOldX, nActX, nOldY, nActY, nMaxCol, nMaxRow

DEFAULT lKey   TO .F.
DEFAULT lShade TO .F.
DEFAULT lInBox TO .F.

nOldX := nOldY := -1

nMaxRow := MAXROW() -nVert -IF(lShade,2,1)
nMaxCol := MAXCOL() -2
IF lInBox
   nMaxCol := MAXCOL() -2 -nHoriz
ENDIF

dfPushAct()
dbScrSav( "tbMove" )

M_SetPos( aPos[POS_TOP], aPos[POS_LEFT] )

IF lKey
   M_CurOff()
   dfSayBorder( aPos[POS_TOP   ] ,; // Prima  Riga
                aPos[POS_LEFT  ] ,; // Prima  Col.
                aPos[POS_BOTTOM] ,; // Ultima Riga
                aPos[POS_RIGHT ] ,; // Ultima Col.
                "R/GR")
   M_CurOn()
ENDIF

WHILE (M_Press() == 1) .OR. lKey // Left
    IF lKey
       dbInk()
       nActX := aPos[POS_LEFT]; nActY := aPos[POS_TOP]
       DO CASE
          CASE M->Act == "uar"; nActY--
          CASE M->Act == "dar"; nActY++
          CASE M->Act == "rar"; nActX++
          CASE M->Act == "lar"; nActX--
          CASE M->Act == "Cla"; nActX -= 5
          CASE M->Act == "Cra"; nActX += 5
          CASE M->Act == "mou"; lKey := !lKey
          CASE M->Act == "ret"; EXIT
       ENDCASE
    ELSE
       nActX := M_PosX(); nActY := M_PosY()
    ENDIF
    IF nActX # nOldX .OR. nActY # nOldY
       DFDISPBEGIN()
       dbScrRes( "tbMove" )

       aPos[POS_TOP   ] := MAX(MIN( nActY, nMaxRow ), 0)
       aPos[POS_LEFT  ] := MAX(MIN( nActX, nMaxCol ), 0)
       aPos[POS_BOTTOM] := aPos[POS_TOP ] +nVert
       aPos[POS_RIGHT ] := aPos[POS_LEFT] +nHoriz

       dfSayBorder( aPos[POS_TOP   ] ,; // Prima  Riga
                    aPos[POS_LEFT  ] ,; // Prima  Col.
                    aPos[POS_BOTTOM] ,; // Ultima Riga
                    aPos[POS_RIGHT ] ,; // Ultima Col.
                    "R/GR")
       DFDISPEND()
       nOldX := nActX
       nOldY := nActY
    ENDIF
ENDDO
dbScrResDel( "tbMove" )
dfPopAct()
RETURN
