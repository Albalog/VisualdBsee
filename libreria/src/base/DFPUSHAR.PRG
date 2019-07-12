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

STATIC aFile := {}

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfPushArea(lSaveEOF) // Salva l'area correntemente aperta
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aFlt
LOCAL nRecno
LOCAL xSave

DEFAULT lSaveEOF TO .T.

IF EMPTY(ALIAS())
   AADD( aFile, {"", 0, 0, ""} )
ELSE
   xSave := dfSet(AI_SAVEFILTERONPUSHAREA)
   IF VALTYPE(xSave)=="L"
      xSave := IIF(xSave, 3, 0)
   ENDIF
   IF xSave > 0
      aFlt := dfFilterGet(xSave)
   ENDIF

   // simone 22/11/04 gerr 4310
   // se Š su EOF salva 0
   // in modo che il dfPopArea() 
   // riposizioni su EOF
/*
   IF EOF() .AND. lSaveEOF
      nRecno := 0
   ELSE
      nRecno := RECNO()
   ENDIF
   AADD( aFile, {ALIAS(), INDEXORD(), nRecno, aFlt} )
*/
   nRecno := dfGetRecno()
   IF nRecno < 0 .AND. ! lSaveEOF 
      nRecno := -nRecno  // riporto in positivo
   ENDIF
   AADD( aFile, {ALIAS(), INDEXORD(), nRecno, aFlt} )
ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfPopArea() // Ristabilisce l'ultima area pushata
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL xSave
IF !EMPTY(ATAIL(aFile)[PA_ALIAS])
   SELECT       (ATAIL(aFile)[PA_ALIAS])
   xSave := dfSet(AI_SAVEFILTERONPUSHAREA)
   IF VALTYPE(xSave)=="L"
      xSave := IIF(xSave, 3, 0)
   ENDIF
   IF xSave > 0
      dfFilterSet(ATAIL(aFile)[PA_FILTER], xSave)
   ENDIF
   SET ORDER TO (ATAIL(aFile)[PA_ORDER])
//   DBGOTO(      (ATAIL(aFile)[PA_RECNO]) )
   dfSetRecno( (ATAIL(aFile)[PA_RECNO])  )
ENDIF
ASIZE( aFile, LEN(aFile)-1 )
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfPushAreNum(); RETURN LEN(aFile)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
