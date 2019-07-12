//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per STAMPE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"
#INCLUDE "dfReport.ch" // Struttura Report e Virtual record

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfUpdVR( aVRec, nIndex, bKey, bFilter, bBreak )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF EMPTY( aVRec[1][VR_DEFAULT] )
   ASIZE( aVRec[1][VR_DEFAULT], VR_DEF_LEN )
   aVRec[1][VR_DEF_ORDER ] := aVRec[1][VR_ORDER ]
   aVRec[1][VR_DEF_KEY   ] := aVRec[1][VR_KEY   ]
   aVRec[1][VR_DEF_FILTER] := aVRec[1][VR_FILTER]
   aVRec[1][VR_DEF_BREAK ] := aVRec[1][VR_BREAK ]
ENDIF

DEFAULT nIndex  TO aVRec[1][VR_DEF_ORDER ]
DEFAULT bKey    TO aVRec[1][VR_DEF_KEY   ]
DEFAULT bFilter TO aVRec[1][VR_DEF_FILTER]
DEFAULT bBreak  TO aVRec[1][VR_DEF_BREAK ]

(aVRec[1][VR_NAME])->(ORDSETFOCUS(nIndex))
aVRec[1][VR_ORDER ] := nIndex
aVRec[1][VR_KEY   ] := bKey
DO CASE
   CASE VALTYPE(bFilter)=="B"
        aVRec[1][VR_FILTER]     := bFilter

   CASE VALTYPE(bFilter)=="C"
        dfPrnArr()[REP_QRY_EXP] := bFilter

   //CASE VALTYPE(bFilter)=="A" // Da controllare
   //   aVRec[1][VR_SKIPARRAY]  := bFilter

   OTHERWISE
        aVRec[1][VR_FILTER]     := aVRec[1][VR_DEF_FILTER]
ENDCASE
aVRec[1][VR_BREAK ] := bBreak

RETURN
