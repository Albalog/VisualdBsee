#include "common.ch"

// Ricostruisco il nome del file con il percorso completo
// in base al percorso corrente o ad un percorso passato
// Es. dfFNameBuild("PIPPO.TXT") -> "C:\DBSEE\PROJ1\PIPPO.TXT"

FUNCTION dfFNameBuild(cFname, cPath, cExt)
   LOCAL aFName

   DEFAULT cPath TO dfCurPath()

   cPath := dfPathChk(cPath)

   IF !EMPTY(cFName)
      cFName := Alltrim(cFName)
   ENDIF 

   aFName := dfFNameSplit(cFName)

   IF EMPTY(aFName[1])
      aFName[1] := dfFNameSplit(cPath)[1]
   ENDIF
   // simone d. 17/4/07 migliore gestione percorsi relativi
   IF EMPTY(aFname[2]) .OR. ! LEFT(aFname[2], 1) $ "\/" // se non inizia per "\" o "/" Š un percorso relativo
      aFName[2] := dfFNameSplit(cPath)[2]+aFName[2]
   ENDIF
//   IF EMPTY(aFName[2])
//      aFName[2] := dfFNameSplit(cPath)[2]
//   ENDIF

   IF EMPTY(aFName[4]) .AND. cExt != NIL
      aFName[4] := cExt
   ENDIF

   cFName := aFName[1]+aFName[2]+aFName[3]+aFName[4]
   IF !EMPTY(cFName)
      cFName := Alltrim(cFName)
   ENDIF 
RETURN cFName
