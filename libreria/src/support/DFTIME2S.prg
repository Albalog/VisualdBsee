/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfTime2Sec( cSec )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nTime := 0

nTime := VAL(SUBSTR( cSec, LEN(cSec)-1, 2 ))
nTime += VAL(SUBSTR( cSec, LEN(cSec)-4, 2 ))*60
nTime += VAL(SUBSTR( cSec, 1, AT(":",cSec)-1 ))*3600

RETURN nTime
