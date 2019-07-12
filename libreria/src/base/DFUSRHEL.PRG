//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per Inkey
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
#include "dfUsr.ch"
#include "dfMsg.ch"
#include "dfWin.ch"
#include "dfSet.ch"
#include "dfCtrl.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfUsrHelp( aObjMtd, cState ) //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC nCount := 0
LOCAL nAct, aDesc := {}, aPos := {}, aMtd := {}

dfPushCursor()  // Salva il cursore
nCount++
IF nCount>1
   dbMsgErr( dfStdMsg( MSG_USRHELP01 ) +; // "Help contestuale non disponibile"
             dfStdMsg( MSG_USRHELP02 )  ) // "in questo ambiente!"
ELSE
   DEFAULT cState TO DE_STATE_MOD
   AEVAL( aObjMtd , {|aSub|AADD(aMtd,aSub)} )
   ADDKEY "C04" TO aMtd                                  MESSAGE dfStdMsg(MSG_USRHELP04)
   ADDKEY "A01" TO aMtd WHEN {||!dfIsCalc()}             MESSAGE dfStdMsg(MSG_USRHELP05)
   ADDKEY "A04" TO aMtd WHEN {||dfSet(AI_ALTF4ISACTIVE)} MESSAGE dfStdMsg(MSG_USRHELP06)

   AEVAL( aMtd, {|aSub, nPos| dfAddUsr( aSub, cState, aDesc, aPos, nPos )} )

   nAct := dfArrWin(   NIL ,; // Coordinate
                       NIL ,;
                       NIL ,;
                       NIL ,;
                     aDesc ,; // Array delle righe
               dfStdMsg( MSG_USRHELP03 ) ) // Intestazione della finestra

   IF nAct>0
      dbAct2Kbd( aMtd[aPos[nAct]][MTD_ACT] ) // keyboard dell'azione
   ENDIF
ENDIF
M->Act := "rip"
nCount--
dfPopCursor()  // Risetta il cursore

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfAddUsr( aSub, cState, aDesc, aPos, nPos ) //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cDesc := " "+ PADR( dbAct2Mne(aSub[MTD_ACT]), 15) + " - "

IF SUBSTR( aSub[MTD_MSG], 1, 1 ) $ [@-] // NON togliere, i GRAB precedenti alla
   cDesc += SUBSTR( aSub[MTD_MSG], 2 )  // release 4.0c hanno dei caratteri
ELSE                                    // in testa "@-" per compatibilita' con
   cDesc += aSub[MTD_MSG]               // la 3.0 Tali caratteri sono stati
ENDIF                                   // levati con la 4.0c

IF aSub[MTD_WHEN]==NIL .OR. EVAL( aSub[MTD_WHEN], cState )
   IF aSub[MTD_RUN]==NIL .OR. EVAL( aSub[MTD_RUN] )
      AADD( aDesc , cDesc )
      AADD( aPos  , nPos  )
   ENDIF
ENDIF

RETURN
