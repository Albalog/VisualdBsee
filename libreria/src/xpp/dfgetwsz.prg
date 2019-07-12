// Torna la dimensione della finestra esterna
// in windows normale Š {0, 0, 8, 27} 
// in windows XP con interfaccia LUNA Š {0, 0, 8, 34} 

FUNCTION dfGetWinSizeOffSet()
   LOCAL aSize := dfGetWinSize()
RETURN {aSize[3]-8, aSize[4]-27}

// Torna la dimensione della finestra esterna
// in windows normale Š {0, 0, 8, 27} 
// in windows XP con interfaccia LUNA Š {0, 0, 8, 34} 
FUNCTION dfGetWinSize()
   STATIC aSize := NIL
   LOCAL oDlg
   IF aSize == NIL
      oDlg:=XbpDialog():New(AppDesktop(), NIL, {0, 0}, {100, 100}, NIL, .F.)
      oDlg:title:="TEST"
      oDlg:taskList:=.T.
      oDlg:Create()
      aSize := oDlg:calcFrameRect({0, 0, 0, 0})
      oDlg:destroy()
      oDlg:=NIL
   ENDIF
RETURN aSize
