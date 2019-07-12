#include "Common.ch"

// cChk : "N" NO Check (DEFAULT)
//        "Q" if application found: QUIT
//        "S" if application found: SHOW
//
// Il problema Š che qualsiasi applicazione creata da Xbase
// ha come classe base la XbpDialog quindi non ci possono
// essere due applicazioni Xbase diverse nello stesso momento

FUNCTION dbSeeAppSys(cChk, cAppID)
   LOCAL hWnd

   DEFAULT cChk TO "N"

   cChk := UPPER(cChk)

   IF cChk $ "QS"

      DEFAULT cAppID TO "XbpDialog"

      hWnd := S2PrevWindowFind( cAppID )

      DO CASE
         CASE hWnd != 0 .AND. cChk == "Q"
            QUIT

         CASE hWnd != 0 .AND. cChk == "S"
            S2PrevWindowShow(hWnd)
            QUIT

      ENDCASE

   ENDIF

   SetAppWindow()
RETURN NIL

// 10/settembre/99 Disabilito funzione SetAppWindow... non dovrebbe servire mai
// FUNCTION SetAppWindow()
// RETURN NIL

// STATIC oWin, oMenu
//
// FUNCTION dbSeeAppSys()
// // FUNCTION AppSys()
//    oWin := CreateBaseWindow()
//
//    oMenu := oWin:menuBar()
//
//    S2FormCurr(oWin)
//    SetAppWindow(oWin)
// RETURN NIL
//
// FUNCTION S2BaseWindow()
// RETURN oWin
//
// FUNCTION S2BaseWindowMenu()
// RETURN oMenu
//
// STATIC FUNCTION CreateBaseWindow()
//    LOCAL oDlg
//    LOCAL aPos := {0, S2WinStartMenuSize()[2]}
//    LOCAL aSize := S2AppDesktopSize()
//
//    oDlg := XbpDialog():new(AppDeskTop(), NIL, aPos, aSize, NIL, .T. )
//    // oDlg:close := {|| PostAppEvent() }
//    oDlg:title := "Dbsee application"
//    oDlg:maxButton := .T.
//    oDlg:maxButton := .T.
//    oDlg:hideButton := .T.
//    oDlg:sysMenu:=.T.
//    oDlg:taskList:=.T.
//    oDlg:create()
//    oDlg:show()
// RETURN oDlg
