/******************************************************************************
Project     : dBsee 4.5
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "common.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDateDif( dDate1, dDate2 )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nDiff := 0

IF !EMPTY(dDate1) .AND. !EMPTY(dDate2) .AND. VALTYPE(dDate1)=="D" .AND. VALTYPE(dDate2)=="D"
   IF dDate1<dDate2
      WHILE dDate1<dDate2
          nDiff++
          dDate1++
      ENDDO
   ELSEIF dDate1==dDate2
      // ESCO
   ELSE
      WHILE dDate1>dDate2
          nDiff--
          dDate1--
      ENDDO
   ENDIF
ENDIF

RETURN nDiff
