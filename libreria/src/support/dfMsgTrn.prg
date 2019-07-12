/******************************************************************************
Project     : dBsee for Xbase++
Description : Utilities Function
Programmer  : Simone Degl'Innocenti
******************************************************************************/

// converte un messaggio
// es.
//   cMsg := dfStdMsg1(xxx) // -> "Cancellare il file %file% (%dex%)?"
//   dfMsgTran( cMsg, "file="+cfile, "dex="+cFileDex) 
// oppure
//   cMsg := dfStdMsg1(xxx) // -> "Cancellare il file %file% (%dex%)?"
//   dfMsgTran( cMsg, {"file", cfile}, {"dex", cFileDex}) 


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfMsgTran(cMsg)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL n 
   LOCAL c
   LOCAL cLeft
   LOCAL cRight

   FOR n := 2 TO PCOUNT()
      c := PVALUE(n)
      IF VALTYPE(c) == "A"
         cLeft  := "%"+c[1]+"%"
         cRight := dfAny2Str(c[2])
      ELSE
         cLeft  := "%"+dfLeft(c)+"%"
         cRight := dfRight(c)
      ENDIF
      cMsg := STRTRAN(cMsg, cLeft, cRight)
   NEXT
RETURN cMsg
