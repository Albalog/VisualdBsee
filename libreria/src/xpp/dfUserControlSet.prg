#include "dfStd.ch"
#include "dfCtrl.ch"

// Questa funzione sostituisce un control di tipo SAY o PUSHBUTTON (se ha input focus, 
// i pushbutton in vdbsee possono avere un ordine di input)
// inserito in Visual dBsee con un control utente messo a mano

FUNCTION dfUserControlSet(oWin, cCtrl, bCB, aData)
   LOCAL aCtrl, aUsr
   LOCAL cID := "_usr_"+cCtrl

   ATTACH cID TO oWin:W_CONTROL USERCB bCB  ; // <<000005>>ATTCMB.TMP
                    AT   0,   0                   ; // <<000006>>Coordinate dato in get
                    SIZE      { 10, 10}              // <<000021>>Dimensioni Campo get


   aCtrl := tbCtrlArr(oWin, cCtrl)
   aUsr  := tbCtrlArr(oWin, cID)

   aUsr[FORM_CTRL_RID]        := aCtrl[FORM_CTRL_RID]
   aUsr[FORM_CTRL_PAGE]       := aCtrl[FORM_CTRL_PAGE]
   aUsr[FORM_CTRL_DISPLAYIF]  := aCtrl[FORM_CTRL_DISPLAYIF]

   IF ! EMPTY(aData)
      aUsr[FORM_UCB_USERDATA]  := aData
   ENDIF

   IF aCtrl[FORM_CTRL_TYP] == CTRL_SAY
      aUsr[FORM_UCB_ROW]         := aCtrl[FORM_SAY_ROW]
      aUsr[FORM_UCB_COL]         := aCtrl[FORM_SAY_COL]
      aUsr[FORM_UCB_SIZE_WIDTH]  := aCtrl[FORM_SAY_SIZE_WIDTH]
      aUsr[FORM_UCB_SIZE_HEIGHT] := aCtrl[FORM_SAY_SIZE_HEIGHT]

   ELSEIF aCtrl[FORM_CTRL_TYP] == CTRL_BUTTON
                                                         // simone 19/12/07 invertiva x e y!
      aUsr[FORM_UCB_ROW]         := aCtrl[FORM_BUT_TOP]  //aCtrl[FORM_BUT_LEFT]
      aUsr[FORM_UCB_COL]         := aCtrl[FORM_BUT_LEFT] //aCtrl[FORM_BUT_TOP]
      aUsr[FORM_UCB_SIZE_WIDTH]  := aCtrl[FORM_BUT_RIGHT]
      aUsr[FORM_UCB_SIZE_HEIGHT] := aCtrl[FORM_BUT_BOTTOM]

   ENDIF

   // sostituzione control inserito in visual dbsee con l'user control
   aCtrl := tbCtrlPos(oWin, cCtrl)
   aUsr  := tbCtrlPos(oWin, cID)

   oWin:W_CONTROL[aCtrl] := oWin:W_CONTROL[aUsr]
   DFAERASE(oWin:W_CONTROL, aUsr)

RETURN NIL