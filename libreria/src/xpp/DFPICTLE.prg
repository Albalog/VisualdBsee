// Ritorna la lunghezza di una picture
// -----------------------------------
// Es: "@ZE 9,999" -> torna 5 perch┼ a video occuper┘ cinque caratteri

// FUNCTION S2PictLen( cPict )
//    LOCAL nRet := 0
//    LOCAL nPos := 0
//    cPict := UPPER(cPict)
//
//    IF LEFT(cPict, 2) == "@S"
//       nRet :=  VAL(SUBSTR(cPict, 3))
//    ELSE
//       IF LEFT(cPict, 1) == "@"
//          nPos := AT(" ", cPict)
//          IF nPos > 0
//             cPict := SUBSTR(cPict, nPos+1)
//          ELSE
//             cPict := STRTRAN(cPict, "@")
//          ENDIF
//       ENDIF
//       nRet := LEN(cPict)
//    ENDIF
// RETURN nRet
//
//     Ё   @           Ё
// ддддедддддддддддддддеддддддддддддд
// SAY ЁB C D L<n>     Ё A N X 9 #
//     ЁR X Z ( )      Ё C Y ! $ , .
//     Ё$ !            Ё
// ддддедддддддддддддддеддддддддддддд
// GET ЁA B C D K L<c> Ё A L N X Y 9
//     ЁR S<n> X Z ( ) Ё # ! $ , .
//     Ё$ !            Ё

FUNCTION dfPictLen( cPict )
   LOCAL nInd := 0
   LOCAL nInd2:= 0
   LOCAL nLen := LEN(cPict)
   LOCAL cP   := ""
   LOCAL nS   := 0
   LOCAL cFmt := "@ABCDKLRSXYZ()$!EPJ0P"
   LOCAL nRet := 0

   cPict := UPPER(cPict)

   IF cPict == "@!" .OR. cPict == "@P"
      RETURN 0
   ENDIF

   // Le picture di dBsee
   // non sono ELSEIF perche' possono esserci piu' volte
   IF "@0"$cPict
      cPict = STRTRAN( cPict, "@0", "" )
   ENDIF
   IF "@J"$cPict
      cPict = STRTRAN( cPict, "@J", "" )
   ENDIF
   IF "@K"$cPict
      cP := "@K"

      nInd := AT("@K", cPict)+2

      DO WHILE SUBSTR(cPict, nInd,1) $ "ZE"
         cP += SUBSTR(cPict, nInd,1)
         nInd++
      ENDDO

      cPict = STRTRAN( cPict, cP, "" )

      cP := ""
      nInd := 0
   ENDIF
   // --------------------------------------------------

   IF LEFT(cPict, 1) == "@"
      nInd := 0
      DO WHILE ++nInd <= nLen .AND. ;
               (cP := SUBSTR(cPict, nInd, 1)) $ cFmt

         IF cP == "L"
            nInd++ // Salto il carattere successivo

         ELSEIF cP == "S"

            nInd2 := nInd

            DO WHILE ++nInd2 <= nLen .AND. ;
                     (cP:=SUBSTR(cPict, nInd2, 1)) $ cFmt
            ENDDO

            IF cP $ "0123456789"
               nInd := nInd2

               DO WHILE ++nInd2 <= nLen .AND. ;
                        SUBSTR(cPict, nInd2, 1) $ "0123456789"
               ENDDO

               nS := VAL(SUBSTR(cPict, nInd, nInd2-nInd))
            ENDIF

            nInd := nInd2-1
         ENDIF

      ENDDO
      nRet := IF(EMPTY(nS), LEN(ALLTRIM(SUBSTR(cPict, nInd))), nS)
      // Se ┼ ancora 0 .. tolgo il primo CHAR e calcolo la lunghezza
      IF nRet==0
         nRet := MAX( LEN(ALLTRIM(cPict))-1, 1 )
      ENDIF
   ELSE
      nRet := LEN(ALLTRIM(cPict))
   ENDIF

RETURN nRet
