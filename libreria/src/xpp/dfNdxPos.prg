// Ritorna la posizione attuale del recno() secondo l'indice
// in percentuale
// Simone GERR 3657 18/feb/03
FUNCTION dfNdxPosition()
   LOCAL nPerc := 0, nLast := LastRec()

   // In ADS la dbPosition() e la OrdKeyno() sono  lente su archivi grossi...
   IF dfAxsIsLoaded( ALIAS() ) .AND. nLast > 1000
      nPerc := 0.1 //RECNO() * 100 / nLast
      //nPerc := OrdKeyNo() * 100 / nLast
   ELSE
      nPerc := DbPosition_XPP()
   ENDIF

RETURN nPerc