#include "dfSet.ch"
#include "common.ch"

STATIC oMain

// Simone 14/6/05
// salva/legge la finestra principale
// serve per gestione MDI
FUNCTION dfSetMainWin(o)
   LOCAL oRet := oMain

   IF oRet != NIL .AND. ! S2XbpIsValid(oRet)
      oRet := NIL
   ENDIF

   IF VALTYPE(o) == "O"
      oMain := o
   ENDIF
RETURN oRet


FUNCTION dfSetMainWinMDI(o, lUseMainToolbar, lUseMainStatusLine)
   LOCAL lRet := .F.
   LOCAL nMDI

   DEFAULT lUseMainToolBar    TO .T.
   DEFAULT lUseMainStatusLine TO .T.

   IF VALTYPE(o) == "O" .AND. o:isDerivedFrom("S2Form")

      dfSetMainWin(o)

      // abilita voci di menu eseguite direttamente da dentro tbInk(), 
      // altrimenti non si possono chiamare altre voci di menu
      o:lMenuExe := .T. 

      nMdi := AI_MENUMDI_ENABLED       

      IF lUseMainToolBar
         nMdi += AI_MENUMDI_SHOWTOOLBAR
      ENDIF
      IF lUseMainStatusLine
         nMdi += AI_MENUMDI_SHOWSTATUS
      ENDIF

      // abilita MDI
      dfSet(AI_XBASEMAINMENUMDI, nMDI)

      lRet := .T.
   ENDIF
RETURN lRet