//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' VARIE
//Programmatore  : Baccan Matteo
//*****************************************************************************
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfChkCF( cCode ) // Controllo CODICE FISCALE
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lCheck:=.F., nNum1, nNum2, nLoop1, cCar, nSum, nSum1, nQuoz
LOCAL c1 := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
LOCAL c2 := "010005070913151719210100050709131517192102041820110306081214161022252423"
cCode:=UPPER(ALLTRIM(cCode))

IF LEN(cCode)==16
   nNum1 := 0
   nNum2 := 0
   FOR nLoop1 := 2 TO 14 STEP 2
      cCar := SUBSTR(cCode,nLoop1,1)
      DO CASE
         CASE cCar>="0" .AND. cCar<="9"
              nNum1 += VAL(cCar)
         CASE cCar>="A" .AND. cCar<="Z"
              nNum1 += ASC(cCar)-65
      ENDCASE
   NEXT
   FOR nLoop1 := 1 TO 15 STEP 2
      cCar := SUBSTR(cCode,nLoop1,1)
      nNum2 += VAL(SUBSTR( c2, AT(cCar,c1)*2-1, 2 ))
   NEXT
   nSum  := nNum1 +nNum2
   nSum1 := INT( nSum / 26)
   nQuoz := nSum -nSum1 * 26
   IF CHR(65 +nQuoz)==RIGHT(cCode,1)
      lCheck := .T.
   ENDIF
ENDIF

RETURN lCheck
