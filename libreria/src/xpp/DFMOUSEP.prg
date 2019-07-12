#include "dll.ch"
#include "common.ch"

/*
func main
  do while .t.
     ? dfgetmousepos(), dfgetmousepos(setappwindow())
  enddo
retu
*/

// Ritorna la posizione del mouse
FUNCTION dfGetMousePos( oWin, lTrasla )
   LOCAL aRet := NIL
   LOCAL cBuff := SPACE(8)

   DEFAULT lTrasla TO .T.
   IF VALTYPE(oWin) == "O"
      lTrasla := .T.
   ENDIF

   DllCall("USER32.DLL", DLL_STDCALL, "GetCursorPos", @cBuff)
   aRet := { BIN2L( SUBSTR(cBuff, 1, 4) )  , ;
             BIN2L( SUBSTR(cBuff, 5, 4) )    }

   IF lTrasla
      // Traslo su asse Y in base al desktop
      aRet[2] := AppDesktop():currentSize()[2] - aRet[2]-1
   ENDIF

   IF VALTYPE(oWin) == "O"
      // calcola la pos. relativa all'oggetto passato
      aRet[1] -= oWin:currentPos()[1]
      aRet[2] -= oWin:currentPos()[2]
   ENDIF
  
RETURN aRet