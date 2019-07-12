// da una stringa tipo "{|| xxx }" torna solo l'espressione interna   
// senza codeblock -> "xxx"
// se ci sono errori torna NIL
FUNCTION dfCodeBlock2String(bExp)
   LOCAL cRet := NIL
   LOCAL nInd
   LOCAL cExp

   IF VALTYPE(bExp) $ "CM"
      cExp := bExp
   ELSEIF VALTYPE(bExp) $ "B"
      cExp := VAR2CHAR(bExp)
   ENDIF

   IF cExp == NIL
      RETURN NIL
   ENDIF
        
   cExp := ALLTRIM(cExp)
   IF LEFT(cExp, 1) == "{" .AND. ;
      RIGHT(cExp, 1) == "}" .AND. ;
      "|" $ cExp 

      // Tolgo } finale
      cExp := LEFT(cExp, LEN(cExp)-1)

      // Tolgo { iniziale
      cExp := ALLTRIM(SUBSTR(cExp, 2))

      // DEVE essere un |
      IF LEFT(cExp, 1) == "|"
         nInd := 1

         // Cerco il prossimo |
         DO WHILE (++nInd <= LEN(cExp)) .AND. ;
                  ! SUBSTR(cExp, nInd, 1) == "|"
         ENDDO

         // L'ho trovato,  restituisco l'espressione
         IF SUBSTR(cExp, nInd, 1) == "|"
            cRet := ALLTRIM(SUBSTR(cExp, nInd+1))
         ENDIF
      ENDIF
 
   ENDIF
RETURN cRet
