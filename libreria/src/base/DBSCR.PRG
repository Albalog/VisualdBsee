//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per Screen
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
#include "dfstd.ch"
#include "dfstack.ch"

STATIC aScr := {}
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dbScrSav( cLab, nTop, nLeft, nBottom, nRight ) //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nInd

DEFAULT cLab    TO "dmm"
DEFAULT nTop    TO 0
DEFAULT nLeft   TO 0
DEFAULT nBottom TO MAXROW()
DEFAULT nRight  TO MAXCOL()

cLab := ALLTRIM(UPPER(cLab))
nInd := ASCAN( aScr, {|aInd| aInd[SCR_NAME]==cLab } )

M_CurOff()
IF nInd>0
   aScr[nInd] := { cLab, SAVESCREEN( nTop, nLeft, nBottom, nRight ),;
                                     nTop, nLeft, nBottom, nRight }
ELSE
   AADD( aScr, { cLab, SAVESCREEN( nTop, nLeft, nBottom, nRight ) ,;
                                   nTop, nLeft, nBottom, nRight } )
ENDIF
M_CurOn()
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dbScrRes( cLab, nTop, nLeft, nBottom, nRight, lSpecial, lDel ) //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nInd

DEFAULT cLab     TO "dmm"
DEFAULT lSpecial TO .F.
DEFAULT lDel     TO .F.

cLab := ALLTRIM(UPPER(cLab))
nInd := aScan( aScr, {|aInd| aInd[SCR_NAME]==cLab } )
IF nInd>0 .AND. LEN(aScr[nInd][SCR_SAV])>0
   DEFAULT nTop    TO aScr[nInd][SCR_TOP   ]
   DEFAULT nLeft   TO aScr[nInd][SCR_LEFT  ]
   DEFAULT nBottom TO aScr[nInd][SCR_BOTTOM]
   DEFAULT nRight  TO aScr[nInd][SCR_RIGHT ]
   M_CurOff()
   IF lSpecial
      dfRestScre( nTop                ,;
                  nLeft               ,;
                  nBottom             ,;
                  nRight              ,;
                  aScr[nInd][SCR_SAV]  )
   ELSE
      RESTSCREEN( nTop                ,;
                  nLeft               ,;
                  nBottom             ,;
                  nRight              ,;
                  aScr[nInd][SCR_SAV]  )
   ENDIF
   M_CurOn()
   IF lDel
      dbScrDel(,nInd)
   ENDIF
ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dbScrResDel( cLab, nTop, nLeft, nBottom, nRight ) //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
dbScrRes( cLab, nTop, nLeft, nBottom, nRight, , .T. )
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dbScrDel( cLab, nInd ) //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
DEFAULT cLab    TO "dmm"
cLab := ALLTRIM(UPPER(cLab))

DEFAULT nInd    TO ASCAN( aScr, {|aInd| aInd[SCR_NAME]==cLab } )

IF nInd>0
   ADEL( aScr, nInd )
   ASIZE( aScr, Len(aScr)-1 )
ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dbScrLab()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cLab, nInd
LOCAL nCount := 0

cLab := "DMM" +PADL( nCount, 4, "0")
WHILE nInd := ASCAN( aScr, {|aInd| aInd[SCR_NAME]==cLab } ) > 0
   cLab := "DMM" +PADL( ++nCount, 4, "0")
ENDDO
AADD( aScr, { cLab, "", 0,0,0,0 } )
RETURN cLab

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dbScrBlank( cLab )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nInd

cLab := ALLTRIM(UPPER(cLab))

nInd := ASCAN( aScr, {|aInd| aInd[SCR_NAME]==cLab } )
IF nInd>0
   aScr[nInd] := { cLab, "", 0,0,0,0 }
ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dbScrNum(); RETURN LEN(aScr)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
