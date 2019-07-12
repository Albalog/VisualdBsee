//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
#include "dfStd.ch"
#include "dfwin.ch"
#include "dfctrl.ch"
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE tbSys( oTbr, oMaster ) //
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
LOCAL nPos, nControl, aPos := {}, cScr
///////////////////////////////////////////////////////////////
//Mantis 1223
STATIC lFixMantis1123   
IF lFixMantis1123 == NIL
   lFixMantis1123 := dfSet("XbaseeFIXMANTIS1123")== "YES"
ENDIF
DEFAULT lFixMantis1123 TO .F.
///////////////////////////////////////////////////////////////

                        
// RICORDARSI di allineare il tutto con tbis2paint

IF !EMPTY(oTbr:W_R_GROUP) .OR. !EMPTY(oTbr:W_R_CONTROL)

   IF !oTbr:W_SYSSTABLE
      oTbr:W_SYSSTABLE := .T. // SCAN degli oggetti in sys
      oTbr:W_CTRL2SYS  := ""

      FOR nPos  := 1 TO LEN(oMaster:W_CONTROL)
         // Mi passo i control singoli e controllo se devono essere syssati
         FOR nControl := 1 TO LEN(oTbr:W_R_CONTROL)

            // Se l'ID e' da refreshare
            IF UPPER(oMaster:W_CONTROL[nPos][FORM_CTRL_ID]) $;
               UPPER(oTbr:W_R_CONTROL[nControl])

               tbAddControl( oTbr, oMaster, nPos, aPos )

            ENDIF
         NEXT

         // Mi passo i control singoli e controllo se devono essere syssati
         FOR nControl := 1 TO LEN(oTbr:W_R_GROUP)
            // Se il RID dice che e' da refreshare
            IF UPPER(oTbr:W_R_GROUP[nControl])              $;
               UPPER(oMaster:W_CONTROL[nPos][FORM_CTRL_RID])

               tbAddControl( oTbr, oMaster, nPos, aPos )

            ENDIF
         NEXT
      NEXT

      FOR nControl := 1 TO LEN( aPos )
         IF ASCAN( oTbr:W_OBJ2FORCE,;  // L'oggetto non e' in lista
              {|oSub|oSub==oMaster:W_CONTROL[aPos[nControl]][FORM_LIST_OBJECT]} )==0
            AADD( oTbr:W_OBJ2FORCE, oMaster:W_CONTROL[aPos[nControl]][FORM_LIST_OBJECT] )
         ENDIF
      NEXT
   ENDIF

   // A questo punto destabilizzo gli oggetti tBrowse
   IF !EMPTY(oTbr:W_CTRL2SYS)
      FOR nControl := 1 TO LEN( oTbr:W_OBJ2FORCE )
         oTbr:W_OBJ2FORCE[nControl]:W_OBJGOTOP   := .T.
         oTbr:W_OBJ2FORCE[nControl]:W_OBJREFRESH := .T.
      NEXT
      DFDISPBEGIN()
      cScr := SAVESCREEN( TBREALTOP( oTbr )    ,;
                          TBREALLEFT( oTbr )   ,;
                          TBREALBOTTOM( oTbr ) ,;
                          TBREALRIGHT( oTbr )   )
      tbDisItm(oMaster,oTbr:W_CTRL2SYS) // Chiamo il SYS
      ///////////////////////////////////////////////////////////
      ///////////////////////////////////////////////////////////
      //Luca 12/04/2007
      //Non esegue il ricalcolo piede colonna quando necessario.
      //Mantis 1223
      IF lFixMantis1123
         oTbr:calcInfo()
      ENDIF
      ///////////////////////////////////////////////////////////
      ///////////////////////////////////////////////////////////
      RESTSCREEN( TBREALTOP( oTbr )    ,;
                  TBREALLEFT( oTbr )   ,;
                  TBREALBOTTOM( oTbr ) ,;
                  TBREALRIGHT( oTbr ), cScr )
      DFDISPEND()
   ENDIF
ENDIF
tbDisCal( oMaster, oTbr:W_CTRL2CALC )

RETURN

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
STATIC PROCEDURE tbAddControl( oTbr, oMaster, nPos, aPos )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
// Se non e' gia' nella lista di quelli da refresare
IF !(UPPER(oMaster:W_CONTROL[nPos][FORM_CTRL_ID]) $;
    oTbr:W_CTRL2SYS)

   // Sommo
   oTbr:W_CTRL2SYS += ;
       ("-" +UPPER(oMaster:W_CONTROL[nPos][FORM_CTRL_ID]))
ENDIF
// Aggiungo ai control da controllare
IF oMaster:W_CONTROL[nPos][FORM_CTRL_TYP] == CTRL_LISTBOX .AND.;
   !(oMaster:W_CONTROL[nPos][FORM_LIST_OBJECT]==oTbr)
   AADD( aPos, nPos )
ENDIF
RETURN
