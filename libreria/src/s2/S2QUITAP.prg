PROCEDURE S2QuitApplication()
   LOCAL cFunc := dfSet("XbaseUserQuitExe")
   IF !EMPTY(cFunc)
     //Personalizzata
     dfFun2Do( cFunc )
   ELSE
     // Standard
     dfFun2Do( "QuitExe" )
   ENDIF
RETURN
