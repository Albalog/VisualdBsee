FUNCTION dfIsDBF(cFName)
   LOCAL n := FOPEN(cFName)
   LOCAL lRet := .F.
   LOCAL cByte := ""

   IF n > 0
      cByte := FREADSTR(n, 1)
      lRet := (cByte == CHR(3) .OR. cByte == CHR(128+3))
      FCLOSE(n)
   ENDIF
RETURN lRet