//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per MEMO
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "dfMsg.CH"
#INCLUDE "dfCTRL.CH"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfMemoRead()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cTxtRea := SPACE(55), aForm := {}
ATTACH "" TO aForm GET cTxtRea AT 1, 20              ; // Campo , Top+Left
                       PICTUREGET "@S30"             ; // Picture in get
                       PICTURESAY "@S30"             ; // Picture in say
                       PROMPT dfStdMsg(MSG_DFMEMO11) ; // Prompt
                       PROMPTAT 1,1                  ; // Posizione prompt
                       MESSAGE dfStdMsg(MSG_DFMEMO11)  // Messaggio

IF dfAutoForm( NIL, NIL, aForm, dfStdMsg(MSG_DFMEMO12) ) .AND. FILE(ALLTRIM(cTxtRea))
   cTxtRea := ALLTRIM(MEMOREAD(ALLTRIM(cTxtRea)))
ELSE
   cTxtRea := ""
ENDIF

RETURN cTxtRea
