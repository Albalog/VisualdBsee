/*******************************************************************************
Project     : Generato dBsee 4.0
Description : Funzioni per tabelle
Programmer  : Baccan Matteo
*******************************************************************************/

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dbTabConv( uStr, cTyp ) // Converte una stringa nel tipo desiderato
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cRet := ""

DO CASE
   CASE cTyp=[C]
        cRet := uStr

   CASE cTyp=[N]
        cRet := VAL( uStr )

   CASE cTyp=[D]
        //cRet := CTOD( uStr )
        // Se il 3 char non Š un numero la gestione Š quella nuova
        IF SUBSTR( uStr, 3, 1 )$"0123456789 "
           cRet = dfNtoD( VAL(SUBSTR(uStr,7,2)) ,;
                          VAL(SUBSTR(uStr,5,2)) ,;
                          VAL(SUBSTR(uStr,1,4))  )
        ELSE
           cRet = CTOD( uStr )
        ENDIF

   CASE cTyp=[L]
        cRet := (UPPER(uStr)=="T")

ENDCASE

RETURN cRet
