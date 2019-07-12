#include "common.ch"

// Funzioni per salvataggio e ripristino path corrente
// con supporto per percorsi UNC
FUNCTION dfPathGet()
   LOCAL cPath := NIL
   LOCAL oErr 

   oErr := ERRORBLOCK({|e| dfErrBreak(e)})
   BEGIN SEQUENCE
      cPath := CURDIR()
      
      // simone 29/11/06
      // mantis 0001175: supportare percorsi UNC
      
      // simone 7/6/2006 modificato perche in Xbase++ 1.90
      // curdrive() Š stata modificata per percorsi UNC 
      // (ritorna stringa "" invece di "\")
      // comunque basta controllare il curdir()
      IF ! dfPathIsUNC(cPath) // se NON Š un percorso UNC

//     #ifdef __HARBOUR__
//      IF ! LEFT(cPath, 2) == "\\"  // se NON Š un percorso UNC
//     #else
//      IF ! CURDRIVE() == "\"  // se NON Š un percorso UNC
//     #endif

         cPath := CURDRIVE()+":\"+cPath
      ENDIF

   RECOVER
      cPath := NIL

   END SEQUENCE
   ERRORBLOCK(oErr)
RETURN cPath

FUNCTION dfPathSet(cPath)
   LOCAL oErr 
   LOCAL lRet := .F.

   IF EMPTY(cPath)
      RETURN lRet
   ENDIF

   oErr := ERRORBLOCK({|e| dfErrBreak(e)})
   BEGIN SEQUENCE

      // simone 29/11/06
      // mantis 0001175: supportare percorsi UNC
      IF dfPathIsMap(cPath) //SUBSTR(cPath, 2, 1) == ":"
         CURDRIVE( LEFT(cPath, 1) )
         cPath := SUBSTR(cPath, 3)
      ENDIF
      CURDIR(cPath)

      lRet := .T.
   END SEQUENCE
   ERRORBLOCK(oErr)

RETURN lRet

// simone 29/11/06
// mantis 0001175: supportare percorsi UNC
FUNCTION dfPathIsUNC(cPath)
   DEFAULT cPath TO CURDIR()
RETURN LEFT(cPath, 2) == "\\"

FUNCTION dfPathIsMAP(cPath)
   DEFAULT cPath TO dfPathGet()
   DEFAULT cPath TO ""
RETURN SUBSTR(cPath, 2, 1) == ":" .AND. ;
       UPPER(SUBSTR(cPath, 1, 1)) $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

// se "c:\pippo\pluto" ritorna "c:" 
// se "\\server\condivisione\apps\dbsee" ritorna "\\server\condivisione"
FUNCTION dfPathRoot(cPath)
   DEFAULT cPath TO dfPathGet()
RETURN dfFNameSplit(cPath)[1] 