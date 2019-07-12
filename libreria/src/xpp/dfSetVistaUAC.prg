#include "common.ch"
#include "Appevent.ch" 
#define HKEY_LOCAL_MACHINE          2147483650


FUNCTION dfIsEnableVistaUAC()
RETURN dfSetVistaUAC()

FUNCTION dfSetVistaUAC(lSet)
  LOCAL nHKey      := HKEY_LOCAL_MACHINE
  LOCAL cKeyName   := ""
  LOCAL cEntryName := ""
  LOCAL lRetSet    := .F.
  LOCAL xRet       := ""

  IF .F. //!dfisWindowsVista()
     lRetSet := .F.
     RETURN lRetSet
  ENDIF

  cKeyName   := "Software\Microsoft\Windows\CurrentVersion\Policies\System" 
  cKeyName   := UPPER(cKeyName)
  cEntryName := "EnableLUA"
  cEntryName := UPPER(cEntryName)

  IF lSet == NIL
     xRet := QueryRegistry(nHKey, cKeyName, cEntryName)
     IF !EMPTY(xRet) 
        xRet := ALLTRIM(dfAny2str(xRet)) 
        IF xRet ==  "0"
           lRetSet := .F.
           RETURN lRetSet
        ELSEIF xRet ==  "1"
           lRetSet := .T.
           RETURN lRetSet
        ENDIF 
     ELSE
       lRetSet := .F.
       RETURN lRetSet
     ENDIF 
  ELSE
     //Non Funziona
     //dfWriteRegistry(nHKey, cKeyName, cEntryName, IIF(lSet, 1, 0) )
  ENDIF 

RETURN lRetSet        

