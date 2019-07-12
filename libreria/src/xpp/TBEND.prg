#include "Common.ch"
#include "dfSet.ch"

FUNCTION tbEnd( oWin, cClose )
   LOCAL b
   LOCAL cSet

   // simone 25/8/06 
   // mantis 0001128: aggiungere possibilità per l'utente di definire le classi base form/browse/ecc.
   b := dfSet({AI_XBASESTDFUNCTIONS,  AI_STDFUNC_TBCONFIG})
   IF VALTYPE(b)=="B"
      RETURN EVAL(b, oWin, cClose)
   ENDIF

   cSet := dfSet("XbaseObjectDestroy")

   oWin:tbEnd(cClose)

   DEFAULT cSet TO "YES"

   IF cSet == "YES"
      oWin:destroy()

   ELSEIF LEFT(cSet,5) == "AUTO:"
      destroy(oWin, VAL(SUBSTR(cSet,6)))

   ENDIF

   oWin := _tbEnd(oWin,cClose)

RETURN oWin 

STATIC PROCEDURE destroy( oWin, nWin )
   STATIC aNotDestroy := {}
   LOCAL nPos := ASCAN(aNotDestroy, {|x| x[1]==oWin })
   LOCAL nSec := SECONDS()

   IF nPos > 0
      aNotDestroy[nPos][2]++
      aNotDestroy[nPos][3] := nSec

   #ifdef _S2DEBUG_
      S2DebugOutString("UPDATE  "+aNotDestroy[nPos][1]:formName+" "+STR(aNotDestroy[nPos][2])+" "+STR(aNotDestroy[nPos][3]), .T. )
   #endif

   ELSE
      AADD(aNotDestroy, {oWin, 1, nSec})
      nPos := LEN(aNotDestroy)

   #ifdef _S2DEBUG_
      S2DebugOutString("ADD     "+aNotDestroy[nPos][1]:formName+" "+STR(aNotDestroy[nPos][2])+" "+STR(aNotDestroy[nPos][3]), .T. )
   #endif

   ENDIF

   IF LEN(aNotDestroy) > nWin

      // Dovrei fare il destroy della finestra chiamata meno volte e
      // chiamata pi— tempo fa.
      nPos := 1

   #ifdef _S2DEBUG_
      S2DebugOutString("DESTROY "+aNotDestroy[nPos][1]:formName+" "+STR(aNotDestroy[nPos][2])+" "+STR(aNotDestroy[nPos][3]), .T. )
   #endif

      aNotDestroy[nPos][1]:destroy()

      aNotDestroy[nPos] := NIL
      ADEL(aNotDestroy, nPos)
      ASIZE(aNotDestroy, LEN(aNotDestroy)-1)

   ENDIF

#ifdef _S2DEBUG_
   S2DebugOutString("----------------------   ", .T. )
   FOR nPos := 1 TO LEN(aNotDestroy)
      S2DebugOutString("-----   "+aNotDestroy[nPos][1]:formName+" "+STR(aNotDestroy[nPos][1]:status(),1)+" "+STR(aNotDestroy[nPos][2])+" "+STR(aNotDestroy[nPos][3]), .T. )
   NEXT
   S2DebugOutString("----------------------   ", .T. )
#endif

RETURN
