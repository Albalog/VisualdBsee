#include "dfAdsDbe.ch"

// ritorna il dizionario dati eventualmente presente in un path
FUNCTION dfDacGetDDFromPath(xPath, cAdsDDAutoFile)
   LOCAL cPath 
   
   IF VALTYPE(xPath)=="N"
      cPath := dbDbfPath(xPath)
   ELSE
      cPath := xPath
   ENDIF

   IF ! UPPER("."+ADSRDD_EXT_ADD) $ UPPER(cPath)
      // Apertura del file 
      // definito il settaggio per nome file dizionario dati automatico?
      IF cADSDDAutoFile == NIL
         cADSDDAutoFile := dfSet("XbaseADSDDAutoFile")
         IF EMPTY(cADSDDAutoFile)
            cADSDDAutoFile := ""
         ELSE
            // metto estensione .ADD
            cADSDDAutoFile := dfFNameBuild(cADSDDAutoFile, "", "."+ADSRDD_EXT_ADD)
         ENDIF
      ENDIF

      IF ! EMPTY(cADSDDAutoFile) .AND. FILE(cPath+cADSDDAutoFile)
         cPath := cPath+cADSDDAutoFile
      ELSE
         cPath := ""
      ENDIF
   ENDIF
RETURN cPath
