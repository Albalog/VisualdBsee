#include "os.ch"

//xl4667 
//Mantis 2263 Luca 17/11/2015
FUNCTION dfisWindows10()        
   STATIC lRet  := NIL
   LOCAL  cVer  := dfGetOsver() 

   IF !lRet == NIL
      RETURN lRet
   ENDIF 
   lRet := .F.
   //cVer := OS(OS_VERSION)
   IF !EMPTY(cVER ) .AND. LEFT(Alltrim(cVer), 2) ==  "10"
      lRet := .T.
      //IF dfisWindows7()
      //   lRet := .F.
      //ENDIF 
   ENDIF
RETURN lRET
