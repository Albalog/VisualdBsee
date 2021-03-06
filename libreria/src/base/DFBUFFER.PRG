/*******************************************************************************
Progetto       : dBsee 4.4
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
*******************************************************************************/

STATIC cBuf := ""

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
PROCEDURE dfBufferIns( cNewBuf )
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
IF dfIsWin() .AND. dfIsWinClp()
   dfWinClpOpen()
   dfWinClpEmpty()
   dfWinClpSet( ALLTRIM(cNewBuf) )
   dfWinClpClose()
ELSE
   cBuf := cNewBuf
ENDIF
RETURN

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfBufferGet()
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL cRet := ""
IF dfIsWin() .AND. dfIsWinClp()
   dfWinClpOpen()
   cRet := dfWinClpGet()
   dfWinClpClose()
ELSE
   cRet := ALLTRIM(cBuf)
ENDIF
RETURN cRet
