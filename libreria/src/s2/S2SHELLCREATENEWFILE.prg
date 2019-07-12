#include "common.ch"
#include "dll.ch"


// Crea un nuovo file come da menu "Nuovo" dal tasto destro del menu sul desktop
// es. 
//   S2ShellCreateNewFile("C:\pippo.doc") -> crea un documento WORD nuovo
//   S2ShellCreateNewFile("C:\pippo.wav") -> crea un file WAVE nuovo
// ritorna .T. o .F.

//Riga  Mantis 2261
FUNCTION S2ShellCreateNewFile(cFile)
   LOCAL lRet
   LOCAL cExt
   LOCAL cTmp
   LOCAL nMode
   LOCAL cPath
   LOCAL cKey
   LOCAL oReg
   LOCAL aValues
   LOCAL aKeys
   LOCAL nKey
   LOCAL cVal
   LOCAL nVal
   LOCAL n

   IF EMPTY(cFile)
      RETURN .F.


   ENDIF

   lRet := .F.

   // estensione del file
   cExt := dfFNameSplit(cFile, 8)

   IF EMPTY(cExt) .OR. ! VALTYPE(cExt) $ "CM"
      RETURN .F.


   ENDIF


   cKey := "HKEY_CLASSES_ROOT\"+cExt

   oReg := XbpReg():NEW( cKey )
   IF ! oReg:status() // se non esiste esce
      RETURN .F.


   ENDIF

   cTmp := oReg:Standard // valore "(predefinito)"

   // chiavi da valutare   // es "HKCR\.DOC\word.document.8\shellnew" e "HKCR\.DOC\shellnew"
   aKeys := {"\"+cTmp, ""}
   nKey  := 0
   nMode := -1

   // cerca la modalit… di creazione del file
   DO WHILE nMode == -1 .AND. ; 
            ++nKey <= LEN(aKeys)

      oReg := XbpReg():NEW( cKey + aKeys[nKey]+"\shellnew" )

      IF ! oReg:status()  // se non esiste la chiave esce
         LOOP
      ENDIF

      oReg:XbpReg:ReadBinType := "C"
      aValues := oReg:valueList( .T. )

      FOR nVal := 1 TO LEN(aValues)
         cVal := UPPER(ALLTRIM(aValues[nVal][1]))
         cTmp := aValues[nVal][2]
         DO CASE
            CASE cVal == "NULLFILE"
              nMode := 0

            CASE cVal == "DATA"
              nMode := 1

            CASE cVal == "FILENAME"
              nMode := 2

            CASE cVal == "COMMAND"
              nMode := 3
         ENDCASE
         IF nMode != -1
            EXIT
         ENDIF
      NEXT
   ENDDO

   DO CASE 
      CASE nMode == -1
         lRet := .F. // non trovato

      CASE nMode == 0 .OR. nMode == 1 // Nullfile o DATA
         n := FCREATE(cFile)

         IF FERROR() != 0
            RETURN .F.


         ENDIF

         IF nMode == 1 .AND. ! EMPTY(cTmp) // DATA
            FWRITE(n, cTmp)
         ENDIF
         FCLOSE(n)
         lRet := .T.
  
      CASE nMode == 2 // Filecopy
          IF EMPTY(cTmp)
             RETURN .F.


          ENDIF

          IF EMPTY(dfFNameSplit(cTmp, 2 )) // path di default cartella utente\templates

             // percorso cartella MODELLI di default dell'utente (normalmente "C:\Documents and Settings\%utente%\Modelli\" )
             cPath := SPACE(1024)
             #define CSIDL_TEMPLATES  0x0015
             DLLCall("shell32.dll", DLL_STDCALL, "SHGetFolderPathA", 0, CSIDL_TEMPLATES, 0, 0, @cPath)

             cPath :=dfGetCString(cPath)

             IF EMPTY(cPath)
                RETURN .F.


             ENDIF
             cPath := dfFNameBuild(cTmp, cPath)

             IF FILE(cPath)
                cTmp := cPath
             ELSE
                // cartella di default di windows
                cPath := dfGetWindowsDirectory()+"\shellnew"
                cTmp := dfFNameBuild(cTmp, cPath)
             ENDIF
          ENDIF

          IF ! FILE(cTmp)
             RETURN .F.


          ENDIF
          lRet := dfFileCopy(cTmp, cFile)

      CASE nMode == 3  // Command
          // non supportato al momento
          lRet := .F.
   ENDCASE
RETURN lRet
