
#include "os.ch"

// Torna WIN9X o WINNT
FUNCTION dfOsFamily()
   LOCAL cRet := "WIN9X"
//  #ifdef _XBASE17_
   cRet := OS(OS_FAMILY)
//  #else
//   IF ("NT" $ UPPER(GETENV("OS"))) 
//      cRet := "WINNT"
//   ENDIF
//  #endif
  IF dfisWindowsVista()       
     cRet := "WINDOWS VISTA"
  ENDIF 
  IF dfisWindows10()        
     cRet := "WINDOWS 10"
  ENDIF 

RETURN cRet

FUNCTION dfIsWin2000()
   LOCAL lRet := .F.
   IF ALLTRIM(UPPER(OS(OS_FULLNAME))) == "WINDOWS 2000"
      lRet := .T. 
   ENDIF
RETURN lRet

FUNCTION dfisWindowsVista()        
   STATIC lRet  := NIL
   LOCAL  cVer  := NIL 

   IF !lRet == NIL
      RETURN lRet
   ENDIF 
   lRet := .F.
   cVer := OS(OS_VERSION)
   IF !EMPTY(cVER ) .AND. LEFT(cVer, 2) ==  "06"
      lRet := .T.
      IF dfisWindows7()
         lRet := .F.
      ENDIF 
   ENDIF
RETURN lRET

//Mantis 2132
FUNCTION dfisWindows7()        
   STATIC lRet  := NIL
   LOCAL  cVer  := NIL 

   IF !lRet == NIL
      RETURN lRet
   ENDIF 
   lRet := .F.
   cVer := OS(OS_VERSION)

   IF !EMPTY(cVER ) 
      IF VAL( SUBSTR(cVER, RAT(".", cVER)+1)) >= 7000
         lRet := .T.
      ENDIF 
   ENDIF
RETURN lRET

FUNCTION  dfWinVer()        
  LOCAL cRet := ""
  cRet := ALLTRIM(OS(OS_FAMILY)) +" - " + ALLTRIM(OS(OS_FULLNAME)) 

//xl4667 
//Mantis 2263 Luca 17/11/2015
  IF dfisWindows10()        
     cRet := "WINDOWS 10"
  ENDIF 
  //RETURN "4.0"
RETURN cRet

//Mantis 2132
FUNCTION dfisWindowsVistaOrAfter()        
   STATIC lRet  := NIL
   LOCAL  cVer  := NIL 

   IF !lRet == NIL
      RETURN lRet
   ENDIF 
   lRet := .F.
   cVer := OS(OS_VERSION)
   IF !EMPTY(cVER ) 
      IF VAL( LEFT(cVer, 2)) >= 6
         lRet := .T.
      ENDIF 
   ENDIF
RETURN lRET


