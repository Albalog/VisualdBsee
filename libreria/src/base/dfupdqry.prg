//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per STAMPE
//Programmatore  : Luca C.
//*****************************************************************************
#INCLUDE "Common.ch"
#INCLUDE "dfReport.ch" // Struttura Report e Virtual record

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfUpdQryRep(aVRec, aQuery, nIndex, bKey, bFilter, bBreak )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nNewOrd   
LOCAL bNewKey   
LOCAL bNewFilter
LOCAL bNewBreak 

   IF ! dfSet("XbaseDisableSetReportFilterinQuery") == "YES"

      DEFAULT nIndex  TO aVRec[1][VR_ORDER ]
//Luca: Correzione Mantis 2172 del 27/12/2011: Non veniva passato correttamente chiave e break dalla form di query associata 
//      DEFAULT bKey    TO aVRec[1][VR_KEY   ]
      DEFAULT bFilter TO aVRec[1][VR_FILTER]
//Luca: Correzione Mantis 2172 del 27/12/2011: Non veniva passato correttamente chiave e break dalla form di query associata 
//      DEFAULT bBreak  TO aVRec[1][VR_BREAK ]

      nNewOrd    := nIndex
      bNewKey    := bKey
      bNewFilter := bFilter
      bNewBreak  := bBreak

      // posso usare ottimizzazione query se uso stesso indice 
      // e non ho key/break del report
      IF EMPTY(nIndex) .OR. nIndex == aQuery[QRY_OPT_INDEX ]

         IF EMPTY(bKey) 
            bNewKey    := aQuery[QRY_OPT_KEY   ]
         ENDIF
//         IF EMPTY(bFilter)
//            bFilter    := aQuery[QRY_OPT_FILTER]
//         ENDIF
         IF EMPTY(bBreak)
            bNewBreak  := aQuery[QRY_OPT_BREAK ]
         ENDIF
      ENDIF

      ////////////////////////////////////////////////
      //Luca: Correzione Mantis 2172 del 27/12/2011: Non veniva passato correttamente chiave e break dalla form di query associata 
      ////////////////////////////////////////////////
      DEFAULT bKey    TO aVRec[1][VR_KEY   ]
      DEFAULT bBreak  TO aVRec[1][VR_BREAK ]
      ////////////////////////////////////////////////
      ////////////////////////////////////////////////


   ELSE
      nNewOrd    := aQuery[QRY_OPT_INDEX ]
      bNewKey    := aQuery[QRY_OPT_KEY   ]
      bNewFilter := aQuery[QRY_OPT_FILTER]
      bNewBreak  := aQuery[QRY_OPT_BREAK ]
   ENDIF
#ifdef __IGNORE_THIS_

   nNewOrd    := aQuery[QRY_OPT_INDEX ]
   bNewKey    := aQuery[QRY_OPT_KEY   ]
   bNewFilter := aQuery[QRY_OPT_FILTER]
   bNewBreak  := aQuery[QRY_OPT_BREAK ]

   IF ! dfSet("XbaseDisableSetReportFilterinQuery") == "YES"
      IF EMPTY(nIndex) .OR. aQuery[QRY_OPT_INDEX ] == nIndex
         //IF EMPTY(aQuery[QRY_OPT_KEY   ]) .AND. !EMPTY(bKey)
         //   bNewKey := bKey
         //ENDIF 
         //IF EMPTY(aQuery[QRY_OPT_BREAK ]) .AND. !EMPTY(bBreak)
         //   bNewBreak := bBreak
         //ENDIF 
         IF !EMPTY(bKey)
            bNewKey := bKey
         ENDIF 
         IF !EMPTY(bBreak)
            bNewBreak := bBreak
         ENDIF 
      ENDIF 
      IF !EMPTY(bFilter) 
         //Il filtro della query viene passato con aBuffer[REP_QRY_EXP] := nella Repini
         //IF EMPTY(aQuery[QRY_OPT_FILTER])
            bNewFilter := bFilter
         //ELSE
            //bNewFilter := dfMergeBlocks(aQuery[QRY_OPT_FILTER], bFilter)
         //   bNewFilter := bFilter
         //ENDIF 
      ENDIF
   ENDIF

#endif
  dfUpdVR( aVRec, nNewOrd, bNewKey, bNewFilter, bNewBreak )

RETURN .T.
