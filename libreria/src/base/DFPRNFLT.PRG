//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per Stampe
//Programmatore  : Baccan Matteo
//*****************************************************************************

#INCLUDE "dfReport.ch" // Struttura Report e Virtual record
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfPrnFltDes()  // Descrizione della query
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
RETURN dfPrnArr()[REP_QRY_DES]

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfPrnFltExp()  // Espressione della query
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
RETURN dfPrnArr()[REP_QRY_EXP]

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfPrnFlt( aBuf )
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL bFilt := .F.
IF !dfSet( AI_DISABLEREPORTFILTER )
   IF dfAnd( aBuf[REP_DISABLE], PRN_DISABLE_FILTER )==0
      IF !EMPTY( aBuf[REP_VREC] )                  .AND.;
          LEN(aBuf[REP_VREC])>0                    .AND.;
          LEN(aBuf[REP_VREC][1])>0                 .AND.;
          DFISSELECT( aBuf[REP_VREC][1][VR_NAME] )

          // Staccato da help e dbtabd
          IF !( "-"+UPPER(ALLTRIM(aBuf[REP_VREC][1][VR_NAME]))+"-" $ "-DBDD-DBHLP-DBTABD-DBLOGIN-" )
             bFilt := .T.
          ENDIF
      ENDIF
   ENDIF
ENDIF

RETURN bFilt
