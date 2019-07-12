#include "Common.ch"

// Trova la picture per un'espressione
// -----------------------------------
FUNCTION S2PictExp(xExp, nLen, nDec, lVideo)
   LOCAL cPict := 0
   LOCAL cTyp  := VALTYPE(xExp)
   LOCAL nAppo := 0
   LOCAL nDif  := 0
   DO CASE
      CASE cTyp == "C"
         DEFAULT nLen TO LEN(xExp)

      CASE cTyp == "N"

         // Calcolo quante cifre ci vogliono
         // -----------------------------------
         IF nLen == NIL
            nLen := 1

            nAppo := INT(xExp)
            IF nAppo < 0
               nLen++
               nAppo := ABS(nAppo)
            ENDIF

            DO WHILE nAppo > 0
               nLen++
               nDif /= 10
            ENDDO

         ENDIF

         // Calcolo quanti decimali ci vogliono
         // -----------------------------------
         IF nDec == NIL
            nDec := 0

            nAppo := INT(xExp)
            nDif := ABS(xExp - nAppo)

            IF nDif != 0
               DO WHILE nDif < 0
                  nDec++
                  nDif *= 10
               ENDDO
            ENDIF

         ENDIF

   ENDCASE

   cPict := S2PictDefault( cTyp, nLen, nDec, lVideo )
RETURN cPict

