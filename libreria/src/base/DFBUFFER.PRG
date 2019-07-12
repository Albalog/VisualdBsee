/*******************************************************************************
Progetto       : dBsee 4.4
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
*******************************************************************************/

STATIC cBuf := ""

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfBufferIns( cNewBuf )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF dfIsWin() .AND. dfIsWinClp()
   dfWinClpOpen()
   dfWinClpEmpty()
   dfWinClpSet( ALLTRIM(cNewBuf) )
   dfWinClpClose()
ELSE
   cBuf := cNewBuf
ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfBufferGet()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cRet := ""
IF dfIsWin() .AND. dfIsWinClp()
   dfWinClpOpen()
   cRet := dfWinClpGet()
   dfWinClpClose()
ELSE
   cRet := ALLTRIM(cBuf)
ENDIF
RETURN cRet
