/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "Common.ch"
#include "dfwin.ch"
#include "dfmouse.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION tbDefOpt( oTbr, cState ) // Mouse Option Control
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nCol    := M_PosX(), nRow := M_PosY()
LOCAL nTop    := TBREALTOP( oTbr )
LOCAL nLeft   := TBREALLEFT( oTbr )
LOCAL nBottom := TBREALBOTTOM( oTbr )
LOCAL nRight  := TBREALRIGHT( oTbr )
LOCAL nOpt    := 1, nActual
LOCAL lRet    := .F.
LOCAL nGap    := IF( dfSet( AI_WIN95INTERFACE ) , 2, 0 )

FOR nOpt := 0 TO 7
   nActual := 2^nOpt
   IF TBISOPT( oTbr, nActual ) .AND. !lRet // Opzione Trovata
      IF cState==DE_STATE_INK .OR. ;
         (cState!=DE_STATE_INK .AND. ( nActual==W_MM_MOVE       .OR.;
                                       nActual==W_MM_ESCAPE     .OR.;
                                       nActual==W_MM_HSCROLLBAR    ))
         DO CASE
            CASE nActual==W_MM_ESCAPE     .AND. ;
                 nRow==nTop .AND. nCol>=nLeft .AND. nCol<=nLeft+1

                 IF oTbr:WOBJ_TYPE==W_OBJ_FRM
                    dbAct2Kbd( "smp" )         // Chiamo il menu
                    oTbr:W_MENUPOS := dfMenuScan( oTbr:W_MENUARRAY, nRow, nCol )
                 ELSE // Oggetti browse
                    IF EMPTY(oTbr:W_MENUARRAY) // Menu vuoto
                       dbAct2Kbd( "esc" )         // ESC
                    ELSE
                       dbAct2Kbd( "smp" )         // Chiamo il menu
                       oTbr:W_MENUPOS := dfMenuScan( oTbr:W_MENUARRAY, nRow, nCol )
                    ENDIF
                 ENDIF
                 lRet := .T.

            CASE nActual==W_MM_ESCAPE     .AND. nGap>0 .AND. ;
                 nRow==nTop .AND. nCol>=nRight-1 .AND. nCol<=nRight

                 dbAct2Kbd( "esc" )         // ESC
                 lRet := .T.

            CASE nActual==W_MM_MOVE       .AND. ;
                 nRow==nTop .AND. nCol>=nLeft+2-nGap .AND. nCol<=nRight-4-nGap

                 tbMove( oTbr )
                 lRet := .T.

            CASE nActual==W_MM_MINIMIZE   .AND. ;
                 nRow==nTop .AND. nCol>=nRight-3-nGap .AND. nCol<=nRight-2-nGap

                 tbMinimize( oTbr )
                 lRet := .T.

            CASE nActual==W_MM_MAXIMIZE   .AND. ;
                 nRow==nTop .AND. nCol>=nRight-1-nGap .AND. nCol<=nRight-nGap

                 tbMaximize( oTbr )
                 lRet := .T.

            CASE nActual==W_MM_VSCROLLBAR .AND. ;
                 nRow>=nTop+1   .AND. nRow<=nBottom-1 .AND. ;
                 nCol>=nRight-1 .AND. nCol<=nRight

                 tbVScroll( oTbr )
                 lRet := .T.

            CASE nActual==W_MM_SIZE       .AND. ;
                 nRow==nBottom .AND. nCol>=nRight-1 .AND. nCol<=nRight

                 IF oTbr:WOBJ_TYPE==W_OBJ_FRM
                    // ???????????? da fare
                 ELSE
                    tbSize( oTbr )
                    lRet := .T.
                 ENDIF

            CASE nActual==W_MM_HSCROLLBAR .AND. ;
                 nRow==nBottom .AND. nCol>=nLeft .AND. nCol<=nRight

                 IF oTbr:WOBJ_TYPE==W_OBJ_FRM
                    tbPageMou( oTbr )
                 ELSE
                    tbHScroll( oTbr )
                 ENDIF
                 lRet := .T.

            CASE nActual==W_MM_EDIT       .AND. ;
                 nRow>=oTbr:nTop  .AND. nRow<=oTbr:nBottom .AND. ;
                 nCol>=oTbr:nLeft .AND. nCol<=oTbr:nRight

                 IF oTbr:WOBJ_TYPE==W_OBJ_FRM
                    dbAct2Kbd( "mod" ) // Lancio la modifica
                 ELSE
                    tbMouMov( oTbr )
                    lRet := .T.
                 ENDIF

         ENDCASE
      ENDIF
   ENDIF
NEXT

IF !lRet .AND. nRow == nTop+1 .AND. ;
               nCol >= nLeft  .AND. ;
               nCol <= nRight .AND. ;
               tbIsMenu( oTbr )
   dbAct2Kbd( "smp" )
   oTbr:W_MENUPOS := dfMenuScan( oTbr:W_MENUARRAY, nRow, nCol )
   lRet := .T.
ENDIF

RETURN lRet
