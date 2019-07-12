#include "Set.ch"
#include "Common.ch"

// Torna una picture di default
// Se lVideo ä .T. la lunghezza sarÖ considerata
// come lunghezza di visualizzazione
// Esempio:
// S2PictDefault("N", 4, 0, .F.)  -> "9999"  se la pict. ä numerica e
//                                   <= 5 torna solo "9"
// S2PictDefault("N", 7, 0, .F.)  -> "@ZE 9,999,999"  pict. per un numero di 7 cifre
//
// S2PictDefault("N", 7, 0, .T.)  -> "@ZE 999,999" pict. che a video occuperä 7 cifre
//
// ---------------------------
FUNCTION S2PictDefault(cTyp, nLen, nDec, lVideo)
   LOCAL cPict := ""
   LOCAL cDec  := ""
   LOCAL nLung := 3

   DEFAULT cTyp TO "C"
   DEFAULT nLen TO 10
   DEFAULT nDec TO 0
   DEFAULT lVideo TO .F.
   IF lVideo
      nLung := 4
   ENDIF

   DO CASE
      CASE cTyp == "L"
         cPict := "Y"

      CASE cTyp == "C"
         IF nLen <= 10
            cPict := REPLICATE("!", nLen)
         ELSE
            cPict := REPLICATE("X", nLen)
         ENDIF

      CASE cTyp == "D"
         cPict := UPPER( SET(_SET_DATEFORMAT) )

         cPict := STRTRAN(cPict, "D", "9")
         cPict := STRTRAN(cPict, "M", "9")
         cPict := STRTRAN(cPict, "Y", "9")

      CASE cTyp == "N"
         IF nDec < nLen

            cDec := ""

            // Se ci sono decimali aggiusto la lunghezza
            IF nDec > 0
               nLen -= nDec+1
               cDec := "."+REPLICATE("9", nDec)
            ENDIF

            IF nLen <= 5
               cPict := REPLICATE("9", nLen)
            ELSE
               DO WHILE nLen > nLung
                  cPict += ",999"
                  nLen  -= nLung
               ENDDO

               cPict := "@ZE "+REPLICATE("9", nLen)+cPict
            ENDIF

            cPict += cDec

         ENDIF
   ENDCASE

RETURN cPict




