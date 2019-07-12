// Simone 26/10/2009
// apre "n" indici
// se si usa ADS con DIZIONARIO DATI allora
// all'apertura del primo indice apre anche tutti gli altri
// quindi se ne deve aprire uno solo
//
// aInd può contenere anche più indici di quelli di default
// es
//  aInd := {"ANAGRAF1.NTX", "ANAGRAF2.NTX", "ANAGRAF3.NTX", "ANAGRAFYY.NTX"}
//  con DIZIONARIO DATI ADS quando apro ANAGRAF1 apro anche il 2 e 3
//  quindi questa funzione apre solo ANAGRAF1.NTX e ANAGRAFYY.NTX 
// (che non è contenuto nel dizionario dati)
FUNCTION dfIndexesSet(aInd)
   LOCAL n, nMax

   ORDLISTCLEAR()
   FOR n := 1 TO LEN(aInd)
       IF n > ORDCOUNT()
          // se devo aprire l'indice lo apro
          ORDLISTADD(aInd[n])

          IF ORDCOUNT() >= LEN(aInd)
             // se ho aperto tutti gli indici ESCO
             EXIT
          ENDIF
       ENDIF
   NEXT
RETURN .T.