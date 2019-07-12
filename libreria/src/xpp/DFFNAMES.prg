// Divide il nome di un file in 4 componenti:
// Drive (o Server+risorsa per UNC), path, nome file, estensione, Server, Risorsa
// gli ultimi 2 solo per UNC 
//
// Esempio normale:
//    aFName:= dfFNameSplit("F:\APPS\DBSEE\GIOIA\EXE\MENU.EXE")
//    ? aFName[1]    // Stampa "F:"
//    ? aFName[2]    // Stampa "\APPS\DBSEE\GIOIA\EXE\"
//    ? aFName[3]    // Stampa "MENU"
//    ? aFName[4]    // Stampa ".EXE"
//    ? aFName[5]    // Stampa ""
//    ? aFName[6]    // Stampa ""
//
// Esempio con UNC:
//    aFName:= dfFNameSplit("\\Simone\c\APPS\DBSEE\GIOIA\EXE\MENU.EXE")
//    ? aFName[1]    // Stampa "\\Simone\c"
//    ? aFName[2]    // Stampa "\APPS\DBSEE\GIOIA\EXE\"
//    ? aFName[3]    // Stampa "MENU"
//    ? aFName[4]    // Stampa ".EXE"
//    ? aFName[5]    // Stampa "\\Simone"
//    ? aFName[6]    // Stampa "\c"

// nRetVal indica cosa tornare
// se 0 = torna array come sopra
// altrimenti si guardano i BIT
// 1=DRIVE
// 2=PATH
// 4=NOME FILE
// 8=ESTENSIONE
//16=SERVER
//32=CONDIVISIONE
// es
// ? dfFnameSplit("c:\pippo\pluto.dbf", 1)    ->C:
// ? dfFnameSplit("c:\pippo\pluto.dbf", 1+2)  ->C:\pippo\
// ? dfFnameSplit("c:\pippo\pluto.dbf", 4+8)  ->pluto.dbf
// ? dfFnameSplit("c:\pippo\pluto.dbf", 8)    ->.dbf
// ? dfFnameSplit("\\serv2000\share\pippo\pluto.dbf", 16)    -> \\serv2000
// ? dfFnameSplit("\\serv2000\share\pippo\pluto.dbf", 32)    -> \share

FUNCTION dfFNameSplit(cFName, nRetVal)
   LOCAL aRet := {"", "", "", "", "", ""}
   LOCAL nPos := 0
   LOCAL nP1  := 0
   LOCAL cRet := ""

   IF !EMPTY(cFName)
      cFName := Alltrim(cFName)
   ENDIF 
   cFName := UPPER(cFName)

   // Drive
   // -----
   IF LEN(cFName) >= 2 .AND. ;
      SUBSTR(cFName, 2, 1) == ":"

      aRet[1] := LEFT(cFName, 2)
      cFName := SUBSTR(cFName, 3)

   ELSEIF LEFT(cFName,2) == "\\"   // Controllo formato UNC: \\nome\risorsa

      nPos := AT("\", cFName, 3)
      IF nPos > 3 .AND. LEN(cFName) > nPos
         aRet[5] := LEFT(cFName, nPos-1)
         nP1 := nPos

         nPos := AT("\", cFName, nPos+1)
         IF nPos == 0

            aRet[6] := SUBSTR(cFName, nP1)

            aRet[1] := cFName
            cFName := ""
         ELSE
            aRet[6] := SUBSTR(cFName, nP1, nPos-1)

            aRet[1] := LEFT(cFName , nPos-1)
            cFName  := SUBSTR(cFName, nPos)
         ENDIF

      ENDIF

   ENDIF

   // Path
   // ----
   nPos := RAT("\", cFName)
   IF nPos > 0
      aRet[2] := SUBSTR(cFName, 1, nPos)
      cFName := SUBSTR(cFName, nPos+1)
   ENDIF

   // Nome del file
   // -------------
   nPos := RAT(".", cFName)

   IF nPos == 0
      aRet[3] := cFName
   ELSE
      aRet[3] := LEFT(cFName, nPos-1)
      aRet[4] := SUBSTR(cFName, nPos)
   ENDIF

   IF ! EMPTY(nRetVal) .AND. VALTYPE(nRetVal) == "N"
      cRet := ""
      IF dfAnd(nRetVal, 1) != 0  // bit 1 on?   (disco o condivisione)
         cRet += aRet[1]
      ENDIF
      IF dfAnd(nRetVal,16) != 0  // bit 5 on?   (se condivisione: server)
         cRet += aRet[5]
      ENDIF
      IF dfAnd(nRetVal,32) != 0  // bit 6 on?   (se condivisione: share)
         cRet += aRet[6]
      ENDIF
      IF dfAnd(nRetVal, 2) != 0  // bit 2 on?   (path)
         cRet += aRet[2]
      ENDIF
      IF dfAnd(nRetVal, 4) != 0  // bit 3 on?   (nome file)
         cRet += aRet[3]
      ENDIF
      IF dfAnd(nRetVal, 8) != 0  // bit 4 on?   (estensione)
         cRet += aRet[4]
      ENDIF
      aRet := cRet
   ENDIF

RETURN aRet


