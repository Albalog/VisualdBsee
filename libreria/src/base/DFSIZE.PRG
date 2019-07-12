//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
#include "dfSet.ch"
#include "dfMove.ch"
#include "dfStd.ch"

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE dfSize( aPos, lKey, lShade )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
LOCAL nOldX, nActX, nOldY, nActY, nOfsY
LOCAL nGap := IF( dfSet( AI_WIN95INTERFACE ) , 2, 0 )

DEFAULT lKey   TO .F.
DEFAULT lShade TO .F.

dfPushAct()
dbScrSav( "tbSize" )

M_SetPos( aPos[POS_BOTTOM], aPos[POS_RIGHT] )

nOldX := nOldY := -1
nOfsY := IF(lShade,2,1)

IF lKey
   dfSayBorder( aPos[POS_TOP   ] ,; // Prima  Riga
                aPos[POS_LEFT  ] ,; // Prima  Col.
                aPos[POS_BOTTOM] ,; // Ultima Riga
                aPos[POS_RIGHT ] ,; // Ultima Col.
                "R/GR" )
ENDIF

WHILE (M_Press() == 1) .OR. lKey // Left
    IF lKey
       dbInk()
       nActX := aPos[POS_RIGHT]; nActY := aPos[POS_BOTTOM]
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
       dbScrRes( "tbSize" )

       aPos[POS_BOTTOM] := MAX( nActY           , aPos[POS_TOP   ]+5      )
       aPos[POS_RIGHT ] := MAX( nActX           , aPos[POS_LEFT  ]+5+nGap )
       aPos[POS_BOTTOM] := MIN( MAXROW() -nOfsY , aPos[POS_BOTTOM]        )
       aPos[POS_RIGHT ] := MIN( MAXCOL()        , aPos[POS_RIGHT ]        )

       dfSayBorder( aPos[POS_TOP   ] ,; // Prima  Riga
                    aPos[POS_LEFT  ] ,; // Prima  Col.
                    aPos[POS_BOTTOM] ,; // Ultima Riga
                    aPos[POS_RIGHT ] ,; // Ultima Col.
                    "R/GR" )
       DFDISPEND()
       nOldX := nActX
       nOldY := nActY
    ENDIF
ENDDO
dbScrResDel( "tbSize" )

dfPopAct()
RETURN
