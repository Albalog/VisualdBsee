//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' VARIE
//Programmatore  : Baccan Matteo
//*****************************************************************************
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfCodQua( nVal )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nQua := ALLTRIM(STR(nVal)), nLen, cQua := "", cCod := "ZAEGHMPSTK", cSub
FOR nLen := 1 TO LEN(nQua)
   cSub := SUBSTR(nQua,nLen,1)
   IF cSub$"."
      cQua += ","
   ELSE
      cQua += SUBSTR( cCod, VAL(cSub)+1, 1 )
   ENDIF
NEXT
RETURN cQua
