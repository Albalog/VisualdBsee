#include "dfMenu.ch"

FUNCTION dfHot( cNew )
   STATIC cCh := MNI_HOTCHAR
   LOCAL cRet := cCh
   IF ! cNew == NIL
      cCh := cNew
   ENDIF
RETURN cRet

