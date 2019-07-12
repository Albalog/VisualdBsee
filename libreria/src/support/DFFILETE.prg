#include "common.ch"
#include "dll.ch"

// Funzione di creazione file temporaneo con maggiore compatibilita
// con quella DOS, infatti non viene aggiunta l'estensione.
//
// Modifiche:
//   SD 27/2/03 aggiunto parametro cExt

FUNCTION dfFileTemp(cPath, cPrefix, nFnameLen, cExt)
   LOCAL nHandle := -1
   LOCAL nInd := 0
   LOCAL cFName
   LOCAL nPrefLen
   LOCAL nSemFile
   LOCAL nSec := 0
   LOCAL cSemFile
   ///////////////////////////////
   ///////////////////////////////
   //08/06/2007 Luca
   //Modificato perche alcune volte la funzione va in loop
   LOCAL cPostString
   ///////////////////////////////
   ///////////////////////////////

   DEFAULT cPath TO dfTemp()
   DEFAULT cPrefix TO "DBS"
   DEFAULT nFNameLen TO MAX(8, LEN(cPrefix)+5)
   DEFAULT cExt TO ""
   IF ! EMPTY(cExt) .AND. ! LEFT(cExt,1)=="."
      cExt := "."+cExt
   ENDIF

   cPath := dfPathChk(cPath)
   nPrefLen := LEN(cPrefix)
   BEGIN SEQUENCE
      IF nPrefLen >= nFNameLen; BREAK; ENDIF

      nSec := SECONDS()+10 // Attendo al massimo 10 secondi
      cSemFile := cPath+"_DFTEMP_.$$$"
      DO WHILE (nSemFile := FCREATE(cSemFile)) < 0 .AND. ;
               SECONDS() < nSec
      ENDDO
      IF nSemFile <= 0; BREAK; ENDIF

      DO WHILE .T.
         ///////////////////////////////
         ///////////////////////////////
         //08/06/2007 Luca
         //Modificato perche alcune volte la funzione va in loop
         //Sel <nInd> diventa troppo grande la funzione STRZERO inserisce degli <*> che fanno andare in loop la funzione File()
         //cFName := cPath+cPrefix+STRZERO(++nInd, nFNameLen-nPrefLen, 0)+cExt
         cPostString := STRZERO(++nInd, nFNameLen-nPrefLen, 0)
         IF AT("*",cPostString )>0
            nFNameLen++
            cPostString := STRZERO(++nInd, nFNameLen-nPrefLen, 0)
         ENDIF 
         cFName := cPath+cPrefix+cPostString+cExt
         ///////////////////////////////
         ///////////////////////////////
         IF FILE(cFName)
            LOOP
         ENDIF

         nHandle := FCREATE(cFName)
         IF FERROR() == 32
            // violazione di condivisione
            LOOP
         ENDIF

         cPath := cFName
         EXIT
      ENDDO

      FCLOSE(nSemFile)
      FERASE(cSemFile)
   END SEQUENCE

RETURN nHandle

// FUNCTION dfFileTemp(cPath, cPrefix)
//    LOCAL nHandle := 0
//    LOCAL nRet
//    LOCAL cBuffer := SPACE(512)
//
//    DEFAULT cPath   TO dfTemp()
//    DEFAULT cPrefix TO ""
//
//    cPath  := dfPathChk(cPath)
//    cPath  += CHR(0)
//    cPrefix+= CHR(0)
//
//    nRet := DLLCall("KERNEL32.DLL", DLL_STDCALL, "GetTempFileNameA", ;
//                    @cPath, @cPrefix, 0, @cBuffer)
//
//    cBuffer := ALLTRIM(cBuffer)
//
//    DO WHILE RIGHT(cBuffer,1)==CHR(0)
//       cBuffer := LEFT(cBuffer, LEN(cBuffer)-1)
//    ENDDO
//
//    IF FILE(cBuffer)
//       nHandle := FCREATE(cBuffer)
//    ENDIF
//
//    cPath := cBuffer
//
// RETURN nHandle

