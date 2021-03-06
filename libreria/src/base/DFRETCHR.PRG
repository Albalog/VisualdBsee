//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per Stringhe
//Programmatore  : Baccan Matteo
//*****************************************************************************

// simone 09/01/07 by reference ritorna se errore
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
FUNCTION dfRetChr( uFun, lErr ) // Traduce un identificativo in carattere
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
LOCAL cRet
lErr := .F.
IF dfIsFun(uFun) .OR. (("-" +TYPE(uFun) +"-") $ "-A-B-C-D-L-M-N-O-")
   cRet := dfAny2Str( &uFun )
ELSE
   cRet := "!"+uFun+"!"
   lErr := .T.
ENDIF

RETURN cRet


* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
//Aggiunta per compatibilit� di libreria. E' documentata ma non esiste
//fRemoveCh( "123456", "24" ) // -> ritorna "1356"
FUNCTION fRemoveCh( cString, cRem ) 
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
  LOCAL cRet
  cRet  := StrTran( cString, cRem ) 
RETURN  cRet