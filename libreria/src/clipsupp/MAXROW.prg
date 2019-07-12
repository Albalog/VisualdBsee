#include "dfXBase.ch"

//FUNCTION MaxRow(); RETURN 25
FUNCTION MaxRow()
   //13/05/04 Luca: Inserito per gestione pixel o Row/Column
  IF S2UsePixelCoordinateDefault()
     RETURN INT(S2AppDesktopSize()[2])
  ENDIF
RETURN 25
//FUNCTION MaxRow(); RETURN INT(S2AppDesktopSize()[2] / ROW_SIZE) - 2
