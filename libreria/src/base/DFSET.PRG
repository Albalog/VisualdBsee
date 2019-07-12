//*****************************************************************************
//Progetto       : dBsee 4.5
//Descrizione    : Funzioni di utilita' per SETTAGGI
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "COMMON.CH"
#include "dfStd.ch"
#include "dfSet.ch"

STATIC aSet := {}

// per migliorare le performance usa una hash table
// invece di un array normale
#define _HASHTABLE_

#ifdef _HASHTABLE_
STATIC lHTToInit:= .T.

INIT PROCEDURE _InitHashTable()
   __InitHashTable()
RETURN

STATIC PROCEDURE __InitHashTable()
   IF lHTToInit
      aSet := dfHTNew(23)
      lHTToInit := .F. 
   ENDIF
  // aSet := dfHTNew()
RETURN
#endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfSet( nSet, uSet, lNIL ) // Settaggi dell'applicazione
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL b
   // simone 30/11/06 
   // mantis (da inserire): aggiungere possibilitÖ per l'utente di definire la funzione dfSet
   b := dfSet1({AI_XBASESTDFUNCTIONS,  AI_STDFUNC_DFSET})
   IF VALTYPE(b)=="B"
      RETURN EVAL(b, nSet, uSet, lNIL ) // Settaggi dell'applicazione
   ENDIF
RETURN dfSet1( nSet, uSet, lNIL ) // Settaggi dell'applicazione


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfSet1( nSet, uSet, lNIL ) // Settaggi dell'applicazione
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC aApp
LOCAL uRet
LOCAL nIdx, nID, nPos

DEFAULT aApp TO dfArrApp()
DEFAULT lNIL TO .F.
IF VALTYPE( nSet )=="A" .AND. LEN(nSet) >= 2
   nIdx := nSet[1]
   nId  := nSet[2]

   // ricerca in settaggio come array es. (AI_XBASETOOLBAROPTIONS, AI_XBASESTDFUNCTIONS)
   // es: x := dfSet({AI_XBASETOOLBAROPTIONS, AI_TOOLBAR_HEIGHT}, 10) // imposta altezza toolbar=10
   uRet := aApp[ nIdx ]
   nPos := ASCAN(uRet, {|x|x[1]==nID})
   IF nPos > 0
      uRet := uRet[nPos][2]
      IF uSet # NIL .OR. lNIL
         aApp[nIdx][nPos][2] := uSet
      ENDIF
   ELSE 
      uRet := NIL
      IF uSet # NIL .OR. lNIL
         AADD(aApp[ nIdx ], {nID, uSet})
      ENDIF
   ENDIF

ELSEIF VALTYPE( nSet )=="N"
   uRet := aApp[ nSet ]
   IF uSet # NIL .OR.  lNIL
      aApp[nSet] := uSet
   ENDIF
ELSE
   uRet := dfUserSet( nSet, uSet, lNIL )
ENDIF

RETURN uRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfSetAdd( cSet, cValue )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
#ifdef _HASHTABLE_
   IF lHTToInit
      __InitHashTable()
   ENDIF
   dfHTMod(aSet, cValue, UPPER(ALLTRIM(cSet)), .T.)
#else
LOCAL nPos := ASCAN( aSet, {|aEle|UPPER(ALLTRIM(aEle[1]))==UPPER(ALLTRIM(cSet))} )
  IF nPOS == 0
     AADD( aSet, { cSet, cValue } )
  ELSE
     /////////////////////////////////////////////
     //Mantis 919
     //Dopo riunione tecnica (L and S) si ä deciso di dare maggiore prioritÖ ai settaggi del Apps.ini di conseguenza
     //viene riabilitato il codice che era commentato... 
     // // Non viene aggiornato volutamente l'array per dare prioritÖ pió alta ai settaggi dbstart.ini  
     // //IF cValue # NIL 
     // //   aSet[nPos][2]:= cValue
     // //ENDIF
     IF cValue # NIL 
        aSet[nPos][2]:= cValue
     ENDIF
     //FINE Mantis 919
     /////////////////////////////////////////////
  ENDIF
#endif
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfUserSet( cSet, uSet, lNIL )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
#ifdef _HASHTABLE_
   LOCAL cRet
   IF lHTToInit
      __InitHashTable()
   ENDIF
   cRet := dfHTFind(aSet, UPPER(ALLTRIM(cSet)) )
   IF uSet # NIL .OR.  lNIL
      dfHTMod(aSet, uSet, UPPER(ALLTRIM(cSet)), .T.)
   ENDIF
#else
LOCAL nPos := ASCAN( aSet, {|aEle|UPPER(ALLTRIM(aEle[1]))==UPPER(ALLTRIM(cSet))} )
LOCAL cRet
IF nPos>0
   cRet := aSet[nPos][2]
   IF uSet # NIL .OR.  lNIL
      aSet[nPos][2] := uSet
   ENDIF
ELSE
// 14:58:21 giovedç 10 febraio 2000 - se scrivo un settaggio utente .. mi
// sembra piu' corretto crearlo al volo
   IF uSet!=nil .OR. lNIL
      dfSetAdd( cSet, uSet )
   ENDIF
ENDIF
#endif
RETURN cRet