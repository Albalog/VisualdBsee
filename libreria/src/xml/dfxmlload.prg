#include "common.ch"

#define ARR_VERSION    "0"
   // questa versione prevede questo formato di array
   // arr[1] = versione array (ARR_VERSION = "0")
   // arr[2] = array con elementi di controllo
   //          [1]=class name da tornare
   //          [2]=versione classe
   //          [3]=data file .xml
   //          [4]=ora file .xml
   // arr[3] = dati


// parametri:
// cFile = nome file .xml
// oNodeClass= classe base per nodo
// oErr= by reference errore di lettura xml
// lFastLoad= abilita lettura da .xmlbin se esistente (default=.t.)
// nTimeout=crea file .xmlbin solo se tempo di lettura .xml > ntimeout secondi
//          -1= non crea mai .xmlbin (default)
//           0= crea sempre .xmlbin
// bLoad= codeblock per decodifica del file XML (es compresso o criptato)
//        
FUNCTION dfXMLLoad(cFile, oNodeClass, oErr, lFastLoad, nTimeout, bLoad)
   LOCAL xRet
   LOCAL aData := {}
   LOCAL cFast
   LOCAL lLoadXml := .T.
   LOCAL bErr, xErr
   LOCAL nSec

   DEFAULT oNodeClass TO XmlNode()
   DEFAULT lFastLoad TO .T.
   DEFAULT nTimeout TO -1

   IF lFastLoad
      cFast := cFile+".xmlbin"
   ENDIF

   bErr := ERRORBLOCK({|e| dfErrBreak(e)})
   BEGIN SEQUENCE
      // se esiste il file di caricamento veloce
      IF cFast != NIL .AND. FExists(cFast)

         // e il file di caricamento veloce Š pi— recente del file XML
         IF dfFileDate(cFast) > dfFileDate(cFile) .OR. ;
            (dfFileDate(cFast) == dfFileDate(cFile) .AND. ;
             dfFileTime(cFast) > dfFileTime(cFile))

            // carico dal file veloce
            aData := Bin2Var( dfFileRead(cFast) )
            IF aData[1]    == ARR_VERSION                     .AND. ;
               aData[2][1] == oNodeClass:className()          .AND. ;
               aData[2][2] == oNodeClass:getXmlInternalVersion() .AND. ;
               aData[2][3] == dfFileDate(cFile)               .AND. ;
               aData[2][4] == _NormTime(dfFileTime(cFile))

               // se la versione degli oggetti caricati Š uguale alla versione
               // di questa classe OK, altrimenti forzo il reload da XML
               // per ricrearli aggiornati

               // disabilito caricamento da XML
               lLoadXml := .F.

               xRet := aData[3]
            ENDIF
         ENDIF
      ENDIF
   RECOVER USING xErr

      // azzera tutte le variabili
      lLoadXML := .T.
   END SEQUENCE
   ERRORBLOCK(bErr)

   IF lLoadXML
      nSec := SECONDS()+nTimeOut

      // caricamento da file XML (pi— lento)
      DEFAULT bLoad TO {|| dfFileRead(cFile) }

      xRet := dfParseXml1(EVAL(bLoad, cFile), oNodeClass, @oErr)

      // se caricamento prende pi— di ntimeout secondi
      // salvo per caricamento veloce
      IF nTimeOut >= 0 .AND. EMPTY(oErr)   .AND. ;
         ! EMPTY(xRet) .AND. cFast != NIL  .AND. ;
         IsMethod(oNodeClass, "getXmlInternalVersion") .AND. ;
         SECONDS() > nSec

         aData := { ARR_VERSION, ;
                    {oNodeClass:className(),;
                     oNodeClass:getXmlInternalVersion(), ;
                     dfFileDate(cFile), ;
                     _NormTime(dfFileTime(cFile))}, ;
                    xRet}
         // salvo per uso futuro
         dfFileWrite(cFast, Var2Bin(aData))
      ENDIF
   ENDIF
RETURN xRet

// normalizza ora file (togliendo :, . ecc )
STATIC FUNCTION _NormTime(cTime)
   LOCAL cRet := "", n
   FOR n := 1 TO LEN(cTime)
      IF cTime[n] $ "1234567890"
         cRet += cTime[n]
      ENDIF
   NEXT
RETURN PADL(cRet, 8, "0")