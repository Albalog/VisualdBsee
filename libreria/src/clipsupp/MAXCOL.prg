#include "dfXBase.ch"

FUNCTION MaxCol()
   //13/05/04 Luca: Inserito per gestione pixel o Row/Column
  IF S2UsePixelCoordinateDefault()
     RETURN INT(S2AppDesktopSize()[1])
  ENDIF
RETURN 80
//FUNCTION MaxCol(); RETURN INT(S2AppDesktopSize()[1] / COL_SIZE) - 2
