// Conta quante volte una sottostringa Š contenuta in una stringa

FUNCTION dfStrCount(cString, cSearch)
   LOCAL nNum := 0
   LOCAL nInd := 0
   LOCAL nLen := LEN( cSearch )

   DO WHILE ++nInd <= LEN(cString)

      IF SUBSTR(cString, nInd, nLen) == cSearch
         nNum++
         nInd += (nLen - 1)  // PerchŠ 1 viene aggiunto nel ciclo
      ENDIF

   ENDDO
RETURN nNum

