#include "common.ch"
// e' installato il Borland Database Engine?
FUNCTION dfIsBDEInstalled()
RETURN ! EMPTY( dfQueryRegistry("HKLM","Software\Borland\BLW32","BLAPIPATH") )

// eventualmente esegue l'installazione
// es. dfBDECheck("BDE_SETUP.EXE)
FUNCTION dfBDECheck(cSetup, cPath, cMsg)

   DEFAULT cPath  TO dfExePath()
   DEFAULT cSetup TO "BDE_SETUP.EXE"
   DEFAULT cMsg   TO   "Borland Database Engine non installato//Installare ora?"

   cPath := dfPathChk(cPath)
   cPath+=cSetup

   DO WHILE ! dfIsBDEInstalled() .AND. ;
            FILE(cPath)   .AND. ;
            dfYesNo(cMsg)
      RunShell("", cPath)
   ENDDO
RETURN dfIsBDEInstalled()
    
