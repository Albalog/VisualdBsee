/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/
#include "Common.ch"
#include "dfSet.ch"
#include "dfUsr.ch"
#include "dfWin.ch"
#include "dfCTRL.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfMtdEval( aMtd ,cState, uPar, cAct )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nSel := 0 ,lRet := .F.

DEFAULT cState TO DE_STATE_INK
DEFAULT cAct   TO M->ACT

IF (nSel:=ASCAN(aMtd, {|El| El[MTD_ACT]==cAct .AND. ;
                            (El[MTD_WHEN]==NIL .OR. EVAL(El[MTD_WHEN] ,cState)) }) ) > 0
   IF aMtd[nSel][MTD_RUN]==NIL .OR. EVAL(aMtd[nSel][MTD_RUN])
      IF VALTYPE(aMtd[nSel][MTD_BLOCK])=="B"
         EVAL(aMtd[nSel][MTD_BLOCK], uPar )
      ENDIF
      lRet := .T.
   ENDIF
ENDIF

RETURN lRet
