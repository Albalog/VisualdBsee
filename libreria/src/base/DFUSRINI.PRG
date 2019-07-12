//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per Inkey
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfUsr.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfUsrIni( nTop, nLeft, nRight, cSepAct, cSepInv, cUsrState ) //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aUsr := dfArrUsr()

aUsr[ USR_TOP    ] := nTop
aUsr[ USR_LEFT   ] := nLeft
aUsr[ USR_RIGHT  ] := nRight
aUsr[ USR_SEPACT ] := cSepAct
aUsr[ USR_SEPINV ] := cSepInv
aUsr[ USR_MSG    ] := cUsrState

RETURN
