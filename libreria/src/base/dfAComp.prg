// torna .T. se 2 array contengono gli stessi valori
FUNCTION dfAComp( aArray1, aArray2 ) 
   LOCAL nElements := Len(aArray1)       // Number of elements 

   LOCAL lEqual    := (nElements == Len(aArray2)) 
   LOCAL nCount    := 0 
   LOCAL cType 

   DO WHILE lEqual .AND. ++nCount <= nElements 
      cType := Valtype( aArray1[nCount] ) // Get data type 
      lEqual:= (cType == Valtype( aArray2[nCount] )) 

      IF lEqual 
         IF cType == "A"                  // Compare subarrays 
            lEqual := dfAComp(aArray1[nCount], aArray2[nCount]) 
         ELSE 
            lEqual := (aArray1[nCount] == aArray2[nCount]) 

         ENDIF 
      ENDIF 
   ENDDO 

RETURN lEqual 