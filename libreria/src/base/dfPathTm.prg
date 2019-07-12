#include "common.ch"

FUNCTION dfPathTemp(cPath, cPrefix, nFnameLen, cExt)
   LOCAL nHandle := -1
   LOCAL nInd := 0
   LOCAL cFName
   LOCAL nPrefLen
   LOCAL nSemFile
   LOCAL nSec := 0
   LOCAL cSemFile

   DEFAULT cPath TO dfTemp()
   DEFAULT cPrefix TO "~DB"
   DEFAULT nFNameLen TO 8
   DEFAULT cExt TO ""

   IF ! EMPTY(cExt) .AND. ! LEFT(cExt,1)=="."
      cExt := "."+cExt
   ENDIF

   cPath := dfPathChk(cPath)
   nPrefLen := LEN(cPrefix)
   BEGIN SEQUENCE
      IF nPrefLen >= nFNameLen; BREAK; ENDIF

      nSec := SECONDS()+10 // Attendo al massimo 10 secondi
      cSemFile := cPath+"_DBSTEMP_.$$$"
      DO WHILE (nSemFile := FCREATE(cSemFile)) < 0 .AND. ;
               SECONDS() < nSec
      ENDDO
      IF nSemFile <= 0; BREAK; ENDIF

      DO WHILE .T.
         cFName := cPath+cPrefix+STRZERO(++nInd, nFNameLen-nPrefLen, 0)+cExt
         IF dfChkDir(cFName)
            LOOP
         ENDIF

         nHandle := dfMD(cFName)
         IF nHandle != 0
            // errore
            LOOP
         ENDIF

         //cPath := dfPathChk(cFName)
         EXIT
      ENDDO

      FCLOSE(nSemFile)
      FERASE(cSemFile)
   END SEQUENCE

RETURN IIF(nHandle==0, dfPathChk(cFName), NIL)