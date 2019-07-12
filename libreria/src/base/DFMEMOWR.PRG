//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per MEMO
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "dfReport.ch"
#INCLUDE "dfMsg.ch"
#INCLUDE "dfCtrl.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfMemoWri( cMemWri ) // Write memo su disco
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lWri := .F., cTxtWri := SPACE(55), aForm := {}

ATTACH "" TO aForm GET cTxtWri AT 1, 20                 ; // Campo , Top+Left
                       PROMPT dfStdMsg(MSG_DFMEMOWRI01) ; // Prompt
                       PROMPTAT 1,1                     ; // Posizione prompt
                       PICTUREGET "@S30"                ; // Picture in get
                       PICTURESAY "@S30"                ; // Picture in say
                       MESSAGE dfStdMsg(MSG_DFMEMOWRI02)  // Messaggio

IF dfAutoForm( NIL, NIL, aForm, dfStdMsg(MSG_DFMEMOWRI03) )
   lWri:=.T.
   IF FILE( ALLTRIM(cTxtWri) ) .AND. !dfYesNo( dfStdMsg(MSG_DFMEMOWRI04), .F. )
      lWri := .F.
   ENDIF
   IF lWri
      MEMOWRIT( ALLTRIM(cTxtWri), STRTRAN( cMemWri, CHR(141)+CHR(10), CRLF ))
   ENDIF
ENDIF

RETURN
