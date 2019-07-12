FUNCTION dfGetActive()
RETURN GetActive()

FUNCTION GetActive()
   LOCAL oDlg
   LOCAL oRet
   LOCAL oCtrl

   BEGIN SEQUENCE
      oDlg := S2FormCurr()
      IF EMPTY(oDlg) .OR. ! oDlg:isDerivedFrom("S2Form"); BREAK; ENDIF

      oCtrl := oDlg:getActiveCtrl()
      IF EMPTY(oCtrl) .OR. ! oCtrl:isDerivedFrom("S2Get"); BREAK; ENDIF

      oRet := oCtrl

   END SEQUENCE
RETURN oRet
