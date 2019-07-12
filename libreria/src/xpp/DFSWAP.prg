FUNCTION dfSwap( cCmd, lCls, lWin95)
   LOCAL oFocus := SetAppFocus()
   LOCAL oForm := S2FormCurr()

   IF oForm != NIL
      oForm:disable()
   ENDIF

   RunShell( "/C "+cCmd, NIL, lWin95 )

   IF oForm != NIL
      oForm:enable()
   ENDIF

   IF oFocus != NIL
      SetAppFocus(oFocus)
   ENDIF

RETURN NIL

FUNCTION dfRunShell( cCmd, cPrg, lWin95, lBack)
   LOCAL oFocus := SetAppFocus()
   LOCAL oForm := S2FormCurr()
   LOCAL xRet

   IF oForm != NIL
      oForm:disable()
   ENDIF

   xRet := RunShell( cCmd, cPrg, lWin95, lBack )

   IF oForm != NIL
      oForm:enable()
   ENDIF

   IF oFocus != NIL
      SetAppFocus(oFocus)
   ENDIF

RETURN xRet
