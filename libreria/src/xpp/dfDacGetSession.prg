#include "dfAdsDbe.ch"

// torna una connessione ad un dizionario dati ADS
// presente in un nPath
//
// by reference torna il cPath da usare per aprire il DBF
//
// Es:
// nPath := 1
// cPath := NIL
// cDriver
// oSession := dfDacGetSession(nPath, NIL, @cPath, @cDriver)
// lOpen := dfUseFile( cPath +cFName, cAlias, NIL, cDriver )
FUNCTION dfDacGetSession(nPath, cAdsDDAutoFile, cPath, cDriver)
   LOCAL cConnID
   LOCAL oSession
   LOCAL cAdsDDFile

   // valore ritornato by reference
   cPath := dbDbfPath(nPath)

   // connnessione al dizionario dati
   cConnId := dfDACConnIDBuild(nPath)
   IF ! EMPTY(cConnID)
      IF ! dfDACConnIDRegistered(cConnID)
/*
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
         IF ! EMPTY(cAdsDDAutoFile) .AND. FILE(cPath+cADSDDAutoFile)
*/
         // trovo percorso al dizionario dati
         cAdsDDFile := dfDacGetDDFromPath(nPath, cAdsDDAutoFile)
         IF ! EMPTY(cAdsDDFile) 
            oSession := dfDACConnStringGet(cAdsDDFile)
            IF EMPTY(oSession)
               cConnID := NIL // non carico dizionario dati
            ELSE
               dfDACConnIDRegister( cConnID , oSession)
            ENDIF
            oSession := NIL
         ELSE
            cConnID := NIL // non carico dizionario dati
         ENDIF
      ENDIF

      IF ! EMPTY(cConnID)
         // se Š registrato fra le connessioni DAC prendo o creo la connessione
         // per il thread corrente
         oSession := dfDACConnIDGetSession(cConnID, .T., .T.)
      ENDIF
   ENDIF

   IF ! EMPTY(oSession)
      // valore ritornato by reference
      cDriver := oSession 
      cPath   := ""
   ENDIF
RETURN oSession