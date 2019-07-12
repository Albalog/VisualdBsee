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
FUNCTION dfMgnTop( nPrePost, aBuf )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T.
IF nPrePost == FORM_POSTGET .OR. nPrePost == FORM_CHKGET
   IF !EMPTY( aBuf[REP_VREC] ) .AND. !dfSet( AI_DISABLEMGNOPT )
      aBuf[REP_MGN_TOP] := MIN( aBuf[REP_MGN_TOP],;
                                dfPrnMaxTop( aBuf, aBuf[REP_VREC] ) )
   ENDIF
ENDIF
RETURN lRet
