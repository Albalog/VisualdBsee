#include "dfwin.ch"
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
FUNCTION tbRecCng( oTbr )
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
LOCAL lRet := .T., nRec

IF !EMPTY(oTbr:W_ALIAS) // Memorizzo Record
   nRec := (oTbr:W_ALIAS)->(RECNO())
   IF nRec == oTbr:W_CURRENTREC
      lRet := .F.
   ENDIF
   oTbr:W_CURRENTREC := nRec
   IF (oTbr:W_ALIAS)->(EOF())
      oTbr:W_CURRENTREC := 0
      oTbr:W_CURRENTKEY := NIL
   ENDIF
ENDIF

RETURN lRet
