#include "dll.ch"

// Torna un array con:
// 1) Nome risorsa windows
// 2) coda di stampa (es: \\SERVERNT\HPLASERJET)

FUNCTION S2WinPrnGetQueueName()
   LOCAL aPrinters
   LOCAL nInd
   LOCAL aPorts
   LOCAL cName := S2WAPINetServerGetInfo()
   LOCAL aRet := {}
   LOCAL cPort
   LOCAL nPos

   IF EMPTY(cName)
      cName := "*SCONOSCIUTO*"
   ELSE
      cName := cName[1]
   ENDIF

   aPrinters := dfWinPrintersGet( 6 ) // Stampanti locali e di rete
   IF ! EMPTY(aPrinters)
#ifdef OLD_MODE
      non funziona bene per le stampanti di rete su XP, non so su win2000

      perche riporta come nome \\pclocale\nomerisorsa invece del pc di rete
      es. se la risorsa di rete Š \\massimo\aficio e lancio questa funzione 
          dal pc simonexp
          riporta nelle porte \\simonexp\aficio invece di \\massimo\aficio


      aPorts := dfWinPortsGet()

      IF VALTYPE(aPorts) != "A"
         aPorts := {}
      ENDIF

      FOR nInd := 1 TO LEN(aPrinters)
         cPort := aPrinters[nInd][4]
         IF "," $ cPort
            //cPort := dfStr2Arr(cPort,",")[1]
         ENDIF

         IF EMPTY(cPort) .OR. ! LEFT(cPort, 2) == "\\"

            // E' connessa con LPTx:, guardo se la porta Š di rete o locale

            nPos := ASCAN(aPorts, {|x| x[1]==cPort })
            IF nPos > 0

               IF LEFT(aPorts[nPos][3],2) == "\\"
                  // E' una porta di rete
                  cPort := aPorts[nPos][3]

               ELSEIF ! EMPTY(aPrinters[nInd][3])
                  // Se Š una porta locale guardo se Š condivisa...
                  cPort := "\\"+cName+"\"+aPrinters[nInd][3]
               ENDIF
            ENDIF

         ENDIF

         cPort := IIF(EMPTY(cPort), "", UPPER(cPort))

         // 1) Nome della stampante
         // 2) Vuota oppure nome della coda di stampa
         AADD(aRet, {aPrinters[nInd][2], cPort})
      NEXT
#else

      FOR nInd := 1 TO LEN(aPrinters)
         IF ! EMPTY(aPrinters[nInd][1]) .AND. ! EMPTY(aPrinters[nInd][3])
            cPort := aPrinters[nInd][1]+"\"+aPrinters[nInd][3]
         ELSE
            cPort := aPrinters[nInd][4]
         ENDIF

         cPort := IIF(EMPTY(cPort), "", UPPER(cPort))

         // 1) Nome della stampante
         // 2) Vuota oppure nome della coda di stampa
         AADD(aRet, {aPrinters[nInd][2], cPort})
      NEXT

#endif

   ENDIF
RETURN aRet
