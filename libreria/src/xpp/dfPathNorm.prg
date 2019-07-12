#include "common.ch"


// normalizza un path togliendo eventuali . e ..
// es dfPathNorm("f:\apps\..\test") -> "f:\test"

FUNCTION dfPathNorm(cPath)
   LOCAL cSplit := "\"
   LOCAL aArr 
   LOCAL n
   LOCAL aFName
   LOCAL nLen
   LOCAL nSkip 
   aFName := dfFNameSplit( dfFNameBuild("test.tst", cPath) )

   cPath := aFName[2] // prendo solo il percorso

   aArr := dfStr2Arr(cPath, cSplit)

   IF LEN(aArr) > 1 .AND. EMPTY(ATAIL(aArr)) // tolgo ultimo 
      AREMOVE(aArr)
   ENDIF

   /////////////////////////////////////////////////
   nSkip := 0
   FOR n:= 1 TO LEN(aArr)
       nLen := LEN(aArr[n])
       IF aArr[n] == REPLICATE(".", nLen)
          nSkip++
       ELSE
          EXIT
       ENDIF
   NEXT
   /////////////////////////////////////////////////

   n     := 0
   DO WHILE .T.
      IF ++n > LEN(aArr)
         EXIT
      ENDIF

      nLen := LEN(aArr[n])

      IF nLen > 0 .AND. aArr[n] == REPLICATE(".", nLen) // se sono tutti "."
   
         //DO WHILE n > 0 .AND. nLen > 0
         DO WHILE n > nSkip  .AND. nLen > 0
            AREMOVE(aArr, n)
            n--
            nLen--
         ENDDO
      ENDIF
   ENDDO

   // ricostruisco
   cPath := aFName[1]
   FOR n := 1 TO LEN(aArr)
      cPath += aArr[n]+cSplit
   NEXT
RETURN cPath
