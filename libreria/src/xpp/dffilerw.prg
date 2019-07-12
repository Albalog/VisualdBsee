// Funzioni sui file
#INCLUDE "Common.ch"                                       // Include define comunemente utilizzate
#include "Directry.ch"


FUNCTION dfFileRead(cFile, nBytes)
   LOCAL cRet := "", nHandle
   IF FILE(cFile)
      DEFAULT nBytes TO dfFileSize(cFile)
      nHandle := FOPEN(cFile, 0)
      IF FERROR()==0
         cRet := SPACE(nBytes)
         IF FREAD(nHandle, @cRet, nBytes) != nBytes
            cRet := ""
         ENDIF
         FCLOSE(nHandle)
      ENDIF
   ENDIF
RETURN cRet

FUNCTION dfFileWrite(cFile, cStr, nBytes, lAppend)
   LOCAL nHandle := 0
   LOCAL lOk := .F.

   DEFAULT nBytes TO LEN(cStr)
   DEFAULT lAppend TO .F.

   // Se voglio l'append e non esiste il file vado in create
   IF lAppend .AND. ! FILE(cFile)
      lAppend := .F.
   ENDIF

   IF lAppend
      nHandle := FOPEN(cFile, 2) // Apro il file
   ELSE
      nHandle := FCREATE(cFile, 0)
   ENDIF

   IF FERROR() == 0

      IF lAppend
         FSEEK(nHandle, 0, 2) // Muovo in fondo al file
      ENDIF

      lOk := (FWRITE(nHandle, cStr, nBytes) == nBytes)
      FCLOSE(nHandle)
   ENDIF

RETURN lOk

