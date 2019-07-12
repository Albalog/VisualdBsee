//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' FILE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "dfmsg.ch"
#include "common.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfPathChk( cPath, aStack ) // normalizza il PATH
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//
// Se il primo carattere del path e' una chiocciola,
// nel path c'e' una variabile allora la devo valorizzare
//

// Simone 14/2/2005
// mantis 0000582: uscita improvvisa in compilazione applicativo.
// per loop se la variabile ambiente LIB=%LIB%
DEFAULT aStack TO {}

cPath := dfEnvSub(cPath, aStack)

IF LEFT(cPath, 1) == [@]
   cPath := SUBSTR(cPath, 2)
   IF TYPE(cPath) # "C"
      dbMsgErr( dfStdMsg(MSG_DBPATH01) +TRIM(cPath)+"//"+;
                dfStdMsg(MSG_DBPATH02) )
      cPath := ""
   ELSE
      cPath := &cPath
   ENDIF
ENDIF

//
//  Se nel path c'e' scritto qualcosa, deve terminare con lo "\"
//
cPath := ALLTRIM(cPath)
IF !EMPTY(cPath) .AND. RIGHT(cPath, 1) # [\]
   cPath += "\"
ENDIF

RETURN cPath
