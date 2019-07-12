FUNCTION dfChrInc(cKey)
   LOCAL cR := ""
   LOCAL nV := 0

   DO WHILE .T.
      cR := RIGHT(cKey,1)
      cKey := LEFT(cKey, LEN(cKey)-1)
      nV := ASC(cR)+1

      // Fix for CDX
      // If a value "0000:" is seeked, alaska  don't seek the rigth value
      // I must to increase value until A
      IF nV < ASC("0")
         nV := ASC("0")
      ENDIF


      IF nV>ASC("9") .AND. nV<ASC("A")
         nV := ASC("A")
      ENDIF
      // Fix for CDX

      IF nV <= 255
         cKey += CHR(nV)
         EXIT
      ENDIF

      IF LEN(cKey) == 0
         EXIT
      ENDIF

   ENDDO

RETURN cKey
