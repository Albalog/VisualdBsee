#include "common.ch"
#include "xbp.ch"
#include "appevent.ch"
#include "dfXbase.ch"
#include "dfLook.ch"
#include "dfStd.ch"
#include "dfCtrl.ch"

// Funzioni per leggere/impostare un elemento 
// dell'array USERDATA dei un control utente
FUNCTION dfUserControlDataSet(oWin, cCtrl, cID, xVal, lAdd)
   LOCAL n
   LOCAL aCtrl, aData
 
   DEFAULT lAdd TO .F.

   IF VALTYPE(oWin) == "A"
      aData := oWin
   ELSE
   IF VALTYPE(cCtrl)=="N"
      aCtrl := oWin:W_CONTROL[cCtrl]
   ELSE
      aCtrl := tbCtrlArr(oWin, cCtrl)
   ENDIF
      aData := aCtrl[FORM_UCB_USERDATA]
   ENDIF

   cID := LOWER(cID)
   //n := ASCAN(aData, {|x|LOWER(x[1])==cID})
   _GetVar(aData, cID, @n)

   IF n != 0 
      aData[n][2] := xVal
      RETURN .T.
   ENDIF

   IF lAdd
      AADD(aData, {cID, xVal})
      RETURN .T.
   ENDIF
RETURN .F.

FUNCTION dfUserControlDataGet(oWin, cCtrl, cID)
   LOCAL n
   LOCAL aCtrl 
   LOCAL aData

   IF VALTYPE(oWin) == "A"
      aData := oWin
   ELSE
   IF VALTYPE(cCtrl)=="N"
      aCtrl := oWin:W_CONTROL[cCtrl]
   ELSE
      aCtrl := tbCtrlArr(oWin, cCtrl)
   ENDIF
      aData := aCtrl[FORM_UCB_USERDATA]
   ENDIF
RETURN _GetVar(aData, cID)

STATIC FUNCTION _GetVar(aData, cID, n)
   cID := LOWER(cID)
   n := ASCAN(aData, {|x|LOWER(x[1]) == cID})
   IF n == 0
      RETURN NIL
   ENDIF
RETURN aData[n][2]
