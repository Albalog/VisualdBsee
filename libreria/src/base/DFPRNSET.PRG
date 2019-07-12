/*******************************************************************************
Progetto       : dBsee 4.3
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
*******************************************************************************/
#include "common.ch"
#include "dfstd.ch"
#include "dfReport.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfPrnSet( aBuf, cPrinterID, lDefault )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos
LOCAL aPrn := dfArrPrn()
DEFAULT lDefault TO .F.

//Mantis 2251 -> Runtime su stampa report di tipo Report managere  su XP
//   cPrinterID := UPPER(ALLTRIM(cPrinterID))
IF !EMPTY(cPrinterID)
   cPrinterID := UPPER(ALLTRIM(cPrinterID))
   nPos := ASCAN( aPRN, {|aSub|UPPER(ALLTRIM(cPrinterID))==UPPER(ALLTRIM(aSub[PRINTER_ID]))} )
ELSE 
   nPos := 1
ENDIF 

IF lDefault
   IF EMPTY nPos ASSIGN 1
ENDIF
IF nPos>0
   aBuf[REP_PRINTERID ] := aPrn[nPos][PRINTER_ID]
   aBuf[REP_PRINTERARR] := aPrn[nPos]
   aBuf[REP_SETUP     ] := aBuf[REP_PRINTERARR][PRINTER_SETUP         ]
   aBuf[REP_RESET     ] := aBuf[REP_PRINTERARR][PRINTER_RESET         ]
   aBuf[REP_BOLD_ON   ] := aBuf[REP_PRINTERARR][PRINTER_BOLDON        ]
   aBuf[REP_BOLD_OFF  ] := aBuf[REP_PRINTERARR][PRINTER_BOLDOFF       ]
   aBuf[REP_ENL_ON    ] := aBuf[REP_PRINTERARR][PRINTER_ENLARGEDON    ]
   aBuf[REP_ENL_OFF   ] := aBuf[REP_PRINTERARR][PRINTER_ENLARGEDOFF   ]
   aBuf[REP_UND_ON    ] := aBuf[REP_PRINTERARR][PRINTER_UNDERLINEON   ]
   aBuf[REP_UND_OFF   ] := aBuf[REP_PRINTERARR][PRINTER_UNDERLINEOFF  ]
   aBuf[REP_SUPER_ON  ] := aBuf[REP_PRINTERARR][PRINTER_SUPERSCRIPTON ]
   aBuf[REP_SUPER_OFF ] := aBuf[REP_PRINTERARR][PRINTER_SUPERSCRIPTOFF]
   aBuf[REP_SUBS_ON   ] := aBuf[REP_PRINTERARR][PRINTER_SUBSCRIPTON   ]
   aBuf[REP_SUBS_OFF  ] := aBuf[REP_PRINTERARR][PRINTER_SUBSCRIPTOFF  ]
   aBuf[REP_COND_ON   ] := aBuf[REP_PRINTERARR][PRINTER_CONDENSEDON   ]
   aBuf[REP_COND_OFF  ] := aBuf[REP_PRINTERARR][PRINTER_CONDENSEDOFF  ]
   aBuf[REP_ITA_ON    ] := aBuf[REP_PRINTERARR][PRINTER_ITALICON      ]
   aBuf[REP_ITA_OFF   ] := aBuf[REP_PRINTERARR][PRINTER_ITALICOFF     ]
   aBuf[REP_NLQ_ON    ] := aBuf[REP_PRINTERARR][PRINTER_NLQON         ]
   aBuf[REP_NLQ_OFF   ] := aBuf[REP_PRINTERARR][PRINTER_NLQOFF        ]
   aBuf[REP_USER1ON   ] := aBuf[REP_PRINTERARR][PRINTER_USER01ON      ]
   aBuf[REP_USER1OFF  ] := aBuf[REP_PRINTERARR][PRINTER_USER01OFF     ]
   aBuf[REP_USER2ON   ] := aBuf[REP_PRINTERARR][PRINTER_USER02ON      ]
   aBuf[REP_USER2OFF  ] := aBuf[REP_PRINTERARR][PRINTER_USER02OFF     ]
   aBuf[REP_USER3ON   ] := aBuf[REP_PRINTERARR][PRINTER_USER03ON      ]
   aBuf[REP_USER3OFF  ] := aBuf[REP_PRINTERARR][PRINTER_USER03OFF     ]
ENDIF
RETURN
