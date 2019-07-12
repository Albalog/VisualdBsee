#include "common.ch"

FUNCTION dfGetAx(cClass, lCreate, cServer)
#if XPPVER < 01900000
RETURN NIL
#else
   DEFAULT lCreate TO .T.

   IF lCreate
      RETURN CreateObject(cClass,cServer )
   ENDIF
RETURN GetObject(NIL, cClass)
#endif

FUNCTION dfAXInstalled(xClsID)
   LOCAL lOk := .F.
   LOCAL oAX
   LOCAL oErr 
   LOCAL cClsID

   cClsId := IIF(VALTYPE(xClsID)=="O", xClsId:clsId, xClsId)
    
   oErr := ERRORBLOCK({|e| dfErrBreak(e)})
   BEGIN SEQUENCE
      oAX := dfGetAX(cClsID, .F.) 
      IF ! EMPTY(oAX)
         oAX:destroy()
         lOk := .T.
      ENDIF
   END SEQUENCE
   ERRORBLOCK(oErr)
RETURN lOk
