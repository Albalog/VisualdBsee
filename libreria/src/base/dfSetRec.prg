//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per File
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfStack.ch"
#include "dfSet.ch"
#include "common.ch"

#ifdef __XPP__
   // simone 5/11/04 per correzione problema DBGOTO(0)
   // vedi DBGOTO_XPP
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif

// simone 22/11/04 gerr 4310
// come RECNO()/DBGOTO() ma gestisce l'informazione di EOF
PROCEDURE dfSetRecNo(nNew)
   // riposiziona su EOF o sul record passato
   DBGOTO( IIF( nNew > 0, nNew, 0) )
RETURN

FUNCTION dfGetRecNo()
RETURN IIF(EOF(), -RECNO(), RECNO())

/*

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfSetRecNo(nNew) 
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL nRet := IIF(EOF(), -RECNO(), RECNO())

   IF nNew != NIL
      // riposiziona su EOF o sul record passato
      DBGOTO( IIF( nNew > 0, nNew, 0) )
   ENDIF
RETURN nRet

*/

