/*******************************************************************************
Project     : dBsee 4.4
Description : Supporto per funzioni dBsee 3.0
Programmer  : Baccan Matteo
*******************************************************************************/
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dbWar( nTop, nLeft, nBottom, nRight,;
                cTit,;
                nUnd,;
                aArr,;
                nUnd1,;
                nUnd2,;
                nUnd3,;
                nUnd4,;
                nUnd5,;
                nUnd6,;
                nUnd7,;
                nUnd8 )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF nTop==0   ; nTop   := NIL; ENDIF
IF nLeft==0  ; nLeft  := NIL; ENDIF
IF nBottom==0; nBottom:= NIL; ENDIF
IF nRight==0 ; nRight := NIL; ENDIF
RETURN dfArrWin( nTop, nLeft, nBottom, nRight, &aArr, cTit )
