/*******************************************************************************
Project     : dBsee 4.4
Description : Supporto per funzioni dBsee 3.0
Programmer  : Baccan Matteo
*******************************************************************************/
#INCLUDE "dfWin.ch"
#INCLUDE "dfCtrl.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dbDe( nTop, nLeft, aBol, cTit )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aCtrl := {}, nRow, cVar, cBefore, cAfter
LOCAL nMinRow := 99

FOR nRow := 1 TO LEN(aBol)
   IF UPPER( ddGetSlot(aBol[nRow],"±",1) )=="S" // SAY
      nMinRow := MIN( nMinRow, VAL(ddGetSlot(aBol[nRow],"±",2)) )
   ELSE                                       // GET
      nMinRow := MIN( nMinRow, VAL(ddGetSlot(aBol[nRow],"±",2)) )
   ENDIF
NEXT

FOR nRow := 1 TO LEN(aBol)
   IF UPPER( ddGetSlot(aBol[nRow],"±",1) )=="S" // SAY
      ATTACH "SAY" TO aCtrl SAY ddGetSlot(aBol[nRow],"±",4) ;
                            AT  VAL(ddGetSlot(aBol[nRow],"±",2)) -nMinRow,;
                                VAL(ddGetSlot(aBol[nRow],"±",3))
   ELSE                                       // GET
      ATTACH "GET" TO aCtrl GET cVar                      ;
                            AT  VAL(ddGetSlot(aBol[nRow],"±",2)) -nMinRow,;
                                VAL(ddGetSlot(aBol[nRow],"±",3)) ;
                            PICTUREGET ddGetSlot(aBol[nRow],"±",5) ;
                            MESSAGE    ddGetSlot(aBol[nRow],"±",8)

      cVar    := ALLTRIM(ddGetSlot(aBol[nRow],"±",4))
      cBefore := ddGetSlot(aBol[nRow],"±",6)
      cAfter  := ddGetSlot(aBol[nRow],"±",7)

      ATAIL( aCtrl )[FORM_GET_VAR] := ;
         &( "{|uVal|0->(IF(uVal==NIL," +cVar +"," +cVar +":=uVal))}" )

      ATAIL( aCtrl )[FORM_GET_CONDITION] := ;
         &( "{|nPre|0->(_dbde( nPre, " +["] +cBefore +["] +", " +["] +cAfter +["] +"))}" )

   ENDIF


NEXT

IF nTop==0 ; nTop := NIL; ENDIF
IF nLeft==0; nLeft:= NIL; ENDIF

dfAutoForm( nTop, nLeft, aCtrl, cTit )

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION _dbde( nPre, cBefore, cAfter )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet
IF nPre==FORM_PREGET
   lRet := !(&cBefore)
ELSE
   lRet :=  (&cAfter)
ENDIF
RETURN lRet
