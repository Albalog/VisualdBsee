                                                     // File include del programma
#INCLUDE "Common.ch"                                 // Include define comunemente utilizzate
#INCLUDE "dfCtrl.ch"                                 //   "       "    per control
#INCLUDE "dfGenMsg.ch"                               //   "       "     "  messaggi
#INCLUDE "dfIndex.ch"                                //   "       "     "  ddIndex()
#INCLUDE "dfLook.ch"                                 //   "       "     "  dbLook()
#INCLUDE "dfMenu.ch"                                 //   "       "     "  menu di oggetto
#INCLUDE "dfNet.ch"                                  //   "       "     "  network
#INCLUDE "dfSet.ch"                                  //   "       "     "  settaggi di ambiente
#INCLUDE "dfWin.ch"                                  //   "       "     "  oggetti dBsee

#include "dfXRes.ch"
#include "Xbp.ch"
#define MENUITEM_SEPARATOR   {NIL, NIL, XBPMENUBAR_MIS_SEPARATOR, 0}

// Crea un menu popup per la toolbar in base al menu di oWin
// come in GIOIA
FUNCTION dfMenuPopUp(oWin, aPos, aMenu)
   STATIC oMenu, aMnu
   IF S2FormCurr() != NIL

      DEFAULT oWin TO S2FormCurr()
      DEFAULT aPos TO {NIL, NIL}
      DEFAULT aMenu TO oWin:W_MENUARRAY

      // Se Š cambiato l'array dei menu, ricreo il menu di popup
      IF oMenu == NIL .OR. aMnu == NIL .OR. ! aMnu == aMenu 
         aMnu := aMenu
         oMenu := S2Menu():new( oWin )
         oMenu:title := "Popup"
         oMenu:itemSelected := {|nItm, uNIL, oXbp | itmsel(amenu, oxbp, nitm) }
         oMenu:create(NIL, NIL, NIL, {}, aMenu)
         oMenu:cargo := {}
         _MenuCreate( oWin, oMenu, aMenu, .T., .F., aMenu   )
      ENDIF

      IF aPos[1] == NIL
         aPos[1] := 10
      ENDIF
      IF aPos[2] == NIL
         aPos[2] := S2FormCurr():getCtrlArea():currentSize()[2] + 22
      ENDIF

      oMenu:popup(oWin:cState, S2FormCurr(), aPos, aMenu )
   ENDIF
RETURN NIL

STATIC FUNCTION _MenuCreate( oWin, oMenu, aArr, lAllTrim, lMenuInForm, aMenu )
   LOCAL nInd := 0
   LOCAL oSubMenu
   LOCAL cPrompt
   LOCAL aLabel
   LOCAL lCanLine := .T.

   DEFAULT lAllTrim TO .F.
   DEFAULT lMenuInForm TO .T.

   FOR nInd := 1 TO LEN(aArr)

      aLabel := aArr[nInd]

      IF aLabel[MNI_TYPE] == MN_LINE
         IF lCanLine // Controllo per evitare due linee di seguito
            oMenu:addItem( MENUITEM_SEPARATOR )
            lCanLine := .F.
         ENDIF
         AADD(oMenu:cargo, aLabel[MNI_CHILD])

      ELSEIF VALTYPE(aLabel[MNI_LABEL])=="C" .AND. ;
             "ELABORAZIONE" $ UPPER( ALLTRIM(aLabel[MNI_LABEL]) )
         // Escludo il menu per cambio data

      ELSE
         // Inserisco solo le voci visibili
         IF aLabel[MNI_SECURITY] == MN_ON .OR. aLabel[MNI_SECURITY] == MN_OFF
            lCanLine := .T.

            /////////////////////////////////////////////////////////////////////////
            //Nuova implementazione etichette dinamiche, mantis 2185, luca 05/09/2012 
            cPrompt := aLabel[MNI_LABEL]
            IF VALTYPE(cPrompt) == "B"
               cPrompt := EVAL(cPrompt)
            ENDIF 
            cPrompt := S2HotCharCvt(cPrompt)
            /////////////////////////////////////////////////////////////////////////

            IF lAllTrim
               cPrompt := ALLTRIM(cPrompt)
            ENDIF

            // ha un sottomenu ?
            // Non aggiungo il menu se Š definito come "MenuInForm"
            IF EMPTY(aLabel[MNI_ARRAY])
               oMenu:addItem( {cPrompt} )

            ELSE
               oSubMenu := S2Menu():new( oMenu )
               oSubMenu:create()
               oSubMenu:title := IIF(lAllTrim, ALLTRIM(cPrompt), cPrompt)
               oSubMenu:Id := aLabel[MNI_CHILD]
               oSubMenu:cargo := {}

               //oSubMenu:itemSelected := {|nItm, uNIL, oXbp | EVAL(dfMenuBlock(aMenu, oXbp:cargo[nItm])) }
               oSubMenu:itemSelected := {|nItm, uNIL, oXbp | itmsel(amenu, oxbp, nitm) }

               _MenuCreate( oWin, oSubMenu, aLabel[MNI_ARRAY], NIL, NIL, aMenu )

               oMenu:addItem( {oSubMenu} )

            ENDIF

            IF aLabel[MNI_SECURITY] == MN_OFF
               oMenu:disableItem(oMenu:numItems())
            ENDIF
            AADD(oMenu:cargo, aLabel[MNI_CHILD])
         ENDIF

      ENDIF

   NEXT

RETURN NIL

static function itmsel(aMenu, oXbp, nItm)
   EVAL( dfMenuBlock(aMenu, oXbp:cargo[nItm]) )
return nil