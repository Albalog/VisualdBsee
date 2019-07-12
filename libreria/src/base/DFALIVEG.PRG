//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per GET
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "inkey.ch"
#include "Common.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfAliveGet( nRow, nCol, nMaxLen, cColor )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nLen, cString, nInk

#ifdef __XPP__
   dfPushAct()
   cString := SPACE(nMaxLen)
   dfGetW(nRow, nCol, NIL,  @cString, NIL, NIL, "ret-esc")
   dfPopAct()
#else

LOCAL cChar := IF(MAXROW()==49,"úþÛ²±°  ","Ä\|/")

DEFAULT cColor TO SETCOLOR()
dfPushCursor()

SET CURSOR OFF
nLen    := 0
cString := ""
@ nRow, nCol SAY PADR(cString,nMaxLen) COLOR cColor
WHILE nLen<nMaxLen   // Acquisisco il CheckSum
   WHILE .T.
      nInk := dfInkey( 0.1 )
      DO CASE
         CASE nInk == K_ESC                           ;EXIT
         CASE nInk == K_RETURN                        ;EXIT
         CASE nInk>=32                                ;EXIT
         CASE nInk == K_BS .AND. nLen>0
              @ nRow, nCol+nLen SAY " " COLOR cColor
              nLen--
              cString := LEFT( cString, LEN(cString)-1 )
         OTHERWISE
              cChar := SUBSTR( cChar, 2 ) +LEFT(cChar,1)
              @ nRow, nCol+nLen SAY LEFT(cChar,1) COLOR cColor
      ENDCASE
   END
   IF nInk == K_ESC;    EXIT; ENDIF
   IF nInk == K_RETURN; EXIT; ENDIF
   cString += CHR(nInk)
   @ nRow, nCol+nLen SAY CHR(nInk) COLOR cColor
   nLen++
END
@ nRow, nCol SAY (cString:=PADR(cString,nMaxLen)) COLOR cColor
dfPopCursor()
#endif
RETURN cString
