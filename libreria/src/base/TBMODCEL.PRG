//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per BROWSE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfSet.ch"
#include "dfCTRL.ch"
#include "dfWin.ch"
#include "dfNet.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION tbModCel( oTbr )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL oCol := oTbr:GETCOLUMN(oTbr:COLPOS), uGet, lRet := .F.
LOCAL cField := ""
//
// Verificare se serve il refresh in caso di cambio cella
//
dfPushAct()
IF EMPTY(oTbr:W_ALIAS) .OR. !(oTbr:W_ALIAS)->(EOF())
   tbDcv( oTbr ) // Decrementa i totali col valore corrente
   IF EMPTY(oTbr:W_ALIAS) .OR. (oTbr:W_ALIAS)->(dfNet(NET_RECORDLOCK)) // se riesce il lock


    //   Gestione dell'eventuale Codeblock WC_BEFOREDIT                       
    // ----------------------------------------------------------------    
      IF Valtype(oCol:WC_BEFOREDIT) == "B"
         Eval(oCol:WC_BEFOREDIT)
      ENDIF	  
   // ------------------------------------------------------------------   
     
      uGet:=EVAL(oCol:BLOCK)
      oTbr:HILITE()

      M->Act := "rep"
      WHILE .T.
         IF EVAL( dfSet( AI_EDITCELLCB )            ,;
                  FORM_PREGET                       ,;
                  @uGet                             ,;
                  UPPER(ALLTRIM(oTbr:W_ALIAS))      ,;
                  IIF(VALTYPE(oCol:WC_EDITFIELD)=="B", ;        // il codeblock pu• essere usato per EDIT di colonne su array
                      "", UPPER(ALLTRIM(oCol:WC_EDITFIELD))) ,;
                  oTbr                              ,;
                  oCol                               )

            #ifdef __XPP__
            _ColumnGet( oTbr, oCol, @uGet, oCol:PICTURE)
            #else
            dfGet( dfRow(), dfCol(), @uGet, oCol:PICTURE, "W+/R" )
            #endif

            IF M->Act!="esc"
               IF !EVAL( dfSet( AI_EDITCELLCB )            ,;
                         FORM_CHKGET                       ,;
                         @uGet                             ,;
                         UPPER(ALLTRIM(oTbr:W_ALIAS))      ,;
                         IIF(VALTYPE(oCol:WC_EDITFIELD)=="B", ;  // il codeblock pu• essere usato per EDIT di colonne su array
                             "", UPPER(ALLTRIM(oCol:WC_EDITFIELD))) ,;
                         oTbr                              ,;
                         oCol                               )
                  LOOP
               ENDIF
            ENDIF
            EXIT
         ELSE
            EXIT
         ENDIF
      ENDDO

      IF ! EMPTY(oTbr:W_ALIAS) 
         IF ( lRet := M->Act=="ret" )
            //////////////////////////////////////////////////////
            //Mantis 2218
            IF VALTYPE(oCol:WC_EDITFIELD) == "B"
            // cField  :=  EVAL(oCol:WC_EDITFIELD, uGet, M->Act)    
            //////////////////////////////////////////////////////
           /* ----------------------------------------------------------------- *
            | Do' la possibilità di modificare il valore inserito dall'utente   | 
            | all'interno della WC_EDITFIELD                                    |
            * ----------------------------------------------------------------- */
               cField  :=  EVAL(oCol:WC_EDITFIELD, @uGet, M->Act)    
            ELSE
               cField  := oCol:WC_EDITFIELD
            ENDIF 
            //(oTbr:W_ALIAS)->(FIELDPUT( FIELDPOS( oCol:WC_EDITFIELD ), uGet ))
            //////////////////////////////////////////////////////
            /* ---------------------------------------------------------------- *
             | Ricontrollo M->Act in quanto potrebbe essere stato cambiato      |  
             | all'interno della WC_EDITFIELD per evitare la modifica           |
             * ---------------------------------------------------------------- */
            IF ( lRet := M->Act=="ret" )                             
               (oTbr:W_ALIAS)->(FIELDPUT( FIELDPOS( cField ), uGet ))
               (oTbr:W_ALIAS)->(DBCOMMIT())
            ENDIF
         ENDIF
         (oTbr:W_ALIAS)->(dfNet(NET_RECORDUNLOCK))
      ELSEIF VALTYPE(oCol:WC_EDITFIELD) == "B"
          EVAL(oCol:WC_EDITFIELD, @uGet, M->Act)
      ENDIF
   ENDIF
   IF Valtype(oCol:WC_AFTEREDIT)=="B"
      Eval(oCol:WC_AFTEREDIT, uGet, m->act)
   ENDIF	  
   tbIcv( oTbr ) // Incrementa i totali col nuovo valore
   tbRtr( oTbr )
ENDIF
dfPopAct()
RETURN lRet

#ifdef __XPP__

#include "AppEvent.ch"


// Effettua il GET di una variabile all'interno di una colonna
// di un browse

STATIC FUNCTION _ColumnGet(oTbr, oCol, uGet, cPict)
   LOCAL nLoop := 0
   LOCAL _XbpGet
   LOCAL nEvent, mp1, mp2, oXbp
   LOCAL bBlock
   LOCAL lEnabled := oTbr:keyboardEnabled

   _XbpGet            := XbpGet():new( oCol:dataArea, oCol:dataArea, NIL, NIL, NIL, .F. )
   _XbpGet:dataLink   := {|x| IIF(x==NIL, uGet, uGet := x) }
   _XbpGet:picture    := cPict
   _XbpGet:killInputFocus := {|| nLoop := -1 }
   _XbpGet:create()
   _XbpGet:Get:SetFocus()

   _setPosAndSize(_XbpGet, oTbr:rowPos, oCol)

   _XbpGet:setData()
   _XbpGet:changed( .F. )
   _XbpGet:show()

   SetAppFocus( _XbpGet )

   _XbpGet:keyboard := {|n,uNil,o| nLoop := _keyboard(n, o, oTbr, oCol, @bBlock) }

   IF lEnabled
      oTbr:keyboardEnabled := .F.
   ENDIF

   DO WHILE nLoop == 0
      nEvent := dfAppEvent( @mp1, @mp2, @oXbp )
      oXbp:handleEvent( nEvent, mp1, mp2 )
   ENDDO

   IF nLoop > 0
      _XbpGet:getData()
   ENDIF

   _XbpGet:hide()
   SetAppFocus(oTbr)
   _XbpGet:destroy()

   IF lEnabled
      oTbr:keyboardEnabled := .T.
   ENDIF

   IF bBlock != NIL
      EVAL(bBlock, oCol)
   ENDIF
RETURN NIL

STATIC FUNCTION _setPosAndSize( _XbpGet, nRowPos, oCol )
   LOCAL aRect, aPos, aSize

   aRect := oCol:dataArea:cellRect( nRowPos )
   aPos  := { aRect[1], aRect[2] }
   aSize := { aRect[3]-aRect[1], aRect[4]-aRect[2] }
   _XbpGet:setPos ( aPos  )
   _XbpGet:setSize( aSize )
RETURN NIL

STATIC FUNCTION _keyBoard( nKey, o, oTbr, oCol, bBlock )
   LOCAL nLoop := 0

   dbActSet(nKey)

   DO CASE
      CASE nKey == xbeK_ENTER
         nLoop := 1

      CASE nKey == xbeK_ESC
         nLoop := -1

      CASE nkey == xbeK_DOWN       .OR. ;
           nKey == xbeK_UP         .OR. ;
           nkey == xbeK_PGUP       .OR. ;
           nkey == xbeK_PGDN       .OR. ;
           nkey == xbeK_CTRL_PGDN  .OR. ;
           nKey == xbeK_CTRL_PGUP

         nLoop := -1
         PostAppEvent(xbeP_Keyboard, nKey, NIL, oCol)

   ENDCASE

RETURN nLoop

#endif
