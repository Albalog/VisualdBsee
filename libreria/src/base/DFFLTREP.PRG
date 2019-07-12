//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per STAMPE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "dfReport.ch" // Struttura Report e Virtual record
#INCLUDE "dfCTRL.ch"   // Maschere di Data Entry
#INCLUDE "dfSet.ch"    // Settaggi d'ambiente
#INCLUDE "dfMsg.ch"    // Messaggistica
#INCLUDE "dfStd.ch"    // Standard
#INCLUDE "dfWinRep.ch" // report windows

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfFltRep( aBuf )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cNewExp := (aBuf[REP_VREC][1][VR_NAME])->(ddQry()), lSub := .T.

IF !EMPTY(cNewExp)
   IF !EMPTY( aBuf[REP_QRY_EXP] ) .AND. aBuf[REP_QRY_EXP]!=".T."
      lSub := dfYesNo( dfStdMsg(MSG_DFPRNSTART49) )
   ENDIF
   IF lSub
      aBuf[REP_QRY_EXP] := cNewExp
      aBuf[REP_QRY_DES] := cNewExp
   ELSE
      aBuf[REP_QRY_EXP] := "(" +aBuf[REP_QRY_EXP] +")" +" .AND. (" +cNewExp +")"
      aBuf[REP_QRY_DES] := "(" +aBuf[REP_QRY_DES] +")" +" .AND. (" +cNewExp +")"
   ENDIF
ENDIF

RETURN
