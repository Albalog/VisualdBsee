/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita' per tBrowse
Programmatore  : Baccan Matteo
******************************************************************************/
#include "Common.ch"
#include "dfWin.ch"
#include "dfMouse.ch"
#include "dfStd.ch"
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE tbHScroll( oTbr )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
LOCAL nCol := M_PosX()
LOCAL nPos := 0, nLeft, nRight

nLeft  := TBREALLEFT( oTbr )
nRight := TBREALRIGHT( oTbr )-2

IF oTbr:WOBJ_TYPE != W_OBJ_BRW .AND. ;
   oTbr:WOBJ_TYPE != W_OBJ_ARRWIN
   nLeft++
ENDIF

DO CASE
   CASE nCol == nLeft  .OR. nCol == nLeft +1; nPos := 1
   CASE nCol == nRight .OR. nCol == nRight-1; nPos := 2
ENDCASE

IF oTbr:WOBJ_TYPE == W_OBJ_BRW       .OR. ;
   oTbr:WOBJ_TYPE == W_OBJ_ARRWIN    .OR. ;
   oTbr:WOBJ_TYPE == W_OBJ_BROWSEBOX .OR. ;
   oTbr:WOBJ_TYPE == W_OBJ_ARRAYBOX
   DO CASE
      CASE nPos==1; tbLeft(oTbr) ; dfINKEY(0.2); WHILE M_PRESS()==1;tbLeft(oTbr) ;END //FW
      CASE nPos==2; tbRight(oTbr); dfINKEY(0.2); WHILE M_PRESS()==1;tbRight(oTbr);END //FW
   ENDCASE
ENDIF
RETURN

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE tbHorBar( oTbr, cCol )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
LOCAL nOfs := 0

IF oTbr:WOBJ_TYPE != W_OBJ_BRW .AND. ;
   oTbr:WOBJ_TYPE != W_OBJ_ARRWIN
   nOfs++
ENDIF

IF oTbr:WOBJ_TYPE == W_OBJ_BRW       .OR. ;
   oTbr:WOBJ_TYPE == W_OBJ_ARRWIN    .OR. ;
   oTbr:WOBJ_TYPE == W_OBJ_BROWSEBOX .OR. ;
   oTbr:WOBJ_TYPE == W_OBJ_ARRAYBOX
   dfHorBar( oTbr:ColPos   ,; // Range
             oTbr:ColCount ,;
             TBREALBOTTOM( oTbr)    ,; // coor
             TBREALLEFT( oTbr)+nOfs ,;
             TBREALRIGHT( oTbr)-2   , cCol ) // color
ENDIF
RETURN

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE tbVScroll( oTbr )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
LOCAL nCol := M_PosX(), nRow := M_PosY()
LOCAL nPos := 0

IF nCol == TBREALRIGHT( oTbr )    .OR.;
   nCol == TBREALRIGHT( oTbr )-1
   DO CASE
      CASE nRow == TBREALTOP( oTbr )+1   ; nPos := 1
      CASE nRow == TBREALBOTTOM( oTbr )-1; nPos := 2
   ENDCASE
ENDIF

DO CASE
   CASE nPos==1
        tbUp(oTbr)
        dfINKEY(0.2) //FW
        WHILE M_PRESS()==1
           //INKEY(0.01)
           //KEYBOARD CHR(255)
           tbUp( oTbr )
        END

   CASE nPos==2
        tbDown(oTbr)
        dfINKEY(0.2) //FW
        WHILE M_PRESS()==1
           //INKEY(0.01)
           //KEYBOARD CHR(255)
           tbDown( oTbr )
        END
ENDCASE

IF nPos>0
   tbRefCurrent( oTbr )
ENDIF

RETURN

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
STATIC PROCEDURE tbRefCurrent( oTbr )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
DFDISPBEGIN()
   tbStab( oTbr, .T. ) // Posiziona in modo corretto perche' a volte
   tbSysFooter( oTbr ) // il file non e' sincronizzato col browse
   tbSayOpt( oTbr, W_MM_VSCROLLBAR+W_MM_HSCROLLBAR )
DFDISPEND()
RETURN

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE tbVerBar( oTbr, cCol )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北

DO CASE
   CASE oTbr:WOBJ_TYPE == W_OBJ_BRW       .OR. ;
        oTbr:WOBJ_TYPE == W_OBJ_BROWSEBOX .OR. ;
        oTbr:WOBJ_TYPE == W_OBJ_FRM
        dfVerBar( IF( oTbr:W_ORDER>0, ;
                      (oTbr:W_ALIAS)->(dfNtxPos( oTbr:W_ORDER, oTbr:W_CURRENTREC )),;
                             oTbr:W_CURRENTREC ) ,; // Range
                  (oTbr:W_ALIAS)->(RECCOUNT()) ,;
                  TBREALRIGHT( oTbr )-1 ,; // coor
                  TBREALTOP( oTbr )+1   ,;
                  TBREALBOTTOM( oTbr )-1,;
                  cCol ) // color
   CASE oTbr:WOBJ_TYPE == W_OBJ_ARRAYBOX  .OR. ;
        oTbr:WOBJ_TYPE == W_OBJ_ARRWIN
        dfVerBar( oTbr:W_CURRENTREC   ,; // Range
                  oTbr:W_AI_LENGHT    ,;
                  TBREALRIGHT( oTbr )-1 ,; // coor
                  TBREALTOP( oTbr )+1   ,;
                  TBREALBOTTOM( oTbr )-1,;
                  cCol ) // color
ENDCASE
RETURN

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE tbMouMov( oTbr )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
LOCAL nCol := M_PosX(), nRow := M_PosY()
LOCAL nUp  := 0, nLeft := 0, nActCol, lRefresh

IF oTbr:WOBJ_TYPE#W_OBJ_FRM
   DFDISPBEGIN()

   oTbr:HILITE()        // Mi serve per posizionare il cursore sulla
                        // cella corrente
   nUp   := nRow -dfRow() // Righe di spostamento
   nLeft := nCol -dfCol()
   IF nLeft>0
      nLeft := dfCol() +tbColWidth( oTbr, oTbr:GETCOLUMN( oTbr:COLPOS ) ) -1
      IF nLeft<nCol
         nLeft:=1
      ELSE
         nLeft:=0
      ENDIF
   ENDIF

   lRefresh := (ABS(nUp) +ABS(nLeft))>0

   dfClearType() //FW
   DO CASE
      CASE nUp>0
           WHILE nUp>0
              oTbr:DOWN()
              oTbr:FORCESTABLE()
              nUp--
           ENDDO
      CASE nUp<0
           WHILE nUp<0
              oTbr:UP()
              oTbr:FORCESTABLE()
              nUp++
           ENDDO
   ENDCASE

   oTbr:HILITE()
   nActCol := oTbr:COLPOS-1
   DO CASE
      CASE nLeft>0
           WHILE nCol>dfCol() +tbColWidth( oTbr, oTbr:GETCOLUMN( oTbr:COLPOS ) ) -1 .AND. ;
                 nActCol#oTbr:COLPOS
              nActCol := oTbr:COLPOS
              oTbr:RIGHT()
              oTbr:FORCESTABLE()
              oTbr:HILITE()
           ENDDO
      CASE nLeft<0
           WHILE nCol<dfCol() .AND. nActCol#oTbr:COLPOS
              nActCol := oTbr:COLPOS
              oTbr:LEFT()
              oTbr:FORCESTABLE()
              oTbr:HILITE()
           ENDDO
   ENDCASE

   IF lRefresh
      tbRefCurrent( oTbr )
   ENDIF

   DFDISPEND() // Evito di fare il dispend dopo il tbtag, perche'
               // la funzione di tag potrebbe chiamarmi un sotto oggetto o
               // una dfarrwin e NON visualizzare nulla

   DO CASE
      CASE oTbr:COLPOS==1 .AND. oTbr:W_TAGARRAY#NIL
           tbTag( oTbr, .F. )
           tbRefCurrent( oTbr )
      CASE M->A == ME_LDBCLK
           dbAct2Kbd( "ret" )
   ENDCASE
ENDIF

IF M->A == ME_RDOWN
   dbAct2Kbd( "mcr" )
ENDIF

RETURN
