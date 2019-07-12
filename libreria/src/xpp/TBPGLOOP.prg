#include "Common.ch"

FUNCTION tbPgLoop(oWin, lUp)
   DEFAULT lUp TO .T.
RETURN oWin:tbPgLoop(IIF(lUp, 1, -1))
