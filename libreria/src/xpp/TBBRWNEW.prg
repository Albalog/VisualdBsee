// #include "Xbp.ch"
// #include "Gra.ch"
#include "common.ch"
#include "dfWin.ch"
#include "dfSet.ch"

MEMVAR EnvId

FUNCTION tbBrwNew( nTop, nLeft, nBott, nRight, nObjType, cLabel, nCoordMode)
   LOCAL b
   LOCAL oDlg
   DEFAULT nObjType TO W_OBJ_BRW
   DEFAULT nCoordMode   TO S2CoordModeDefault()
   // Controllo che le coordinate della BROWSE siano corrette

   //13/05/04 Luca: Inserito per gestione pixel o Row/Column
   IF nCoordMode == W_COORDINATE_ROW_COLUMN
      IF nTop+1>nBott-1 // Minimo 3 Righe
         nBott:=nTop+2
      ENDIF
      IF nLeft+1>nRight-2 // Minimo 4 Colonne
         nRight:=nLeft+3
      ENDIF
      nLeft  := MAX(  nLeft,        0 )
      nRight := MIN( nRight, MAXCOL() )
   ENDIF

   // simone 25/8/06 
   // mantis 0001128: aggiungere possibilità per l'utente di definire le classi base form/browse/ecc.
   b := dfSet({AI_XBASESTDFUNCTIONS,  AI_STDFUNC_TBBRWNEW})
   IF VALTYPE(b)=="B"
      oDlg := EVAL(b, nTop, nLeft, nBott, nRight, nObjType, cLabel, nCoordMode)
   ENDIF

   //Mantis 937
   DO CASE
      CASE ! EMPTY(oDlg)
         // definito da funzione utente

      CASE nObjType == W_OBJ_FRM

         oDlg := S2Form():new( nTop, nLeft, nBott, nRight, nObjType, ;
                               NIL, NIL, NIL, NIL, NIL, .F.,nCoordMode  )

         oDlg:FormName := EnvId

      CASE nObjType == W_OBJ_BRW

         oDlg := S2Browse():new( nTop, nLeft, nBott, nRight, nObjType, ;
                                 NIL, NIL, NIL, NIL, NIL, .F.,nCoordMode )


         oDlg:FormName := EnvId

      CASE nObjType == W_OBJ_ARRWIN
         oDlg := S2ArrWin():new( nTop, nLeft, nBott, nRight, nObjType, ;
                                 NIL, NIL, NIL, NIL, NIL, .F.,nCoordMode )


         oDlg:FormName := EnvId

      CASE nObjType == W_OBJ_ARRAYBOX
         oDlg := S2ArrayBox():new( nTop, nLeft, nBott, nRight, nObjType, ;
                                   NIL, NIL, NIL, NIL, NIL, .F.,nCoordMode )


      CASE nObjType == W_OBJ_BROWSEBOX

         oDlg := S2BrowseBox():new( nTop, nLeft, nBott, nRight, nObjType, ;
                                    NIL, NIL, NIL, NIL, NIL, .F.,nCoordMode )

   ENDCASE
   IF cLabel != NIL
      oDlg:W_COLORARRAY := dfColor(cLabel)
   ENDIF
   oDlg:W_MOUSEMETHOD := tbMouDef( nObjType )

RETURN oDlg

