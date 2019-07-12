//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Funzioni di Utilita' per Video
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"
#INCLUDE "dfSet.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfSayBut( nRow, nCol, cStr, nTyp,;
                    cColBut, cColHot, cColT, cColB,;
                    cColSel, cColUn) //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC aColor := NIL
IF aColor==NIL
   DEFAULT aColor TO dfColor( "ButtonDefault" )
ENDIF

DEFAULT nTyp    TO AC_BUT_SAYNORMAL
DEFAULT cColBut TO aColor[AC_BUT_NORMAL   ]
DEFAULT cColHot TO aColor[AC_BUT_HOTNORMAL]
DEFAULT cColT   TO aColor[AC_BUT_TNORMAL  ]
DEFAULT cColB   TO aColor[AC_BUT_BNORMAL  ]
DEFAULT cColSel TO aColor[AC_BUT_SELECTED ]
DEFAULT cColUn  TO aColor[AC_BUT_UNSELECTABLE]

_dfSayBut( nRow, nCol, cStr,;
           nTyp,            ;
           dfFontStr( "buttoncharacters" ),;
           cColBut, cColHot,;
           cColT, cColB,    ;
           cColSel, cColUn )

RETURN
