//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per Stampe
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"
#INCLUDE "dfReport.ch"
#INCLUDE "dfSet.ch"
#INCLUDE "dfpdf.ch"
#include "xbpdev.ch"


STATIC aBuf
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfPrnCfg() // Configura Stampa
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPrn, nPrf, aPrf
LOCAL oRT
aBuf := ARRAY(REP_BUFFER_LEN)

aBuf[REP_RB           ] := {||NIL}
aBuf[REP_EJECT_RB     ] := .F.
aBuf[REP_BANNER_FORMAT] := .T.
aBuf[REP_BANNER_INPAGE] := .T.
aBuf[REP_PH           ] := {||NIL}
aBuf[REP_CANPH        ] := {||.T.}
aBuf[REP_RF           ] := NIL
aBuf[REP_CANRF        ] := {||.T.}
aBuf[REP_PF           ] := {||NIL}
aBuf[REP_CANPF        ] := {||.T.}

nPrf := ASCAN( dfArrRep(), {|aSub|aSub[PRN_PRF_NAME]==UPPER(ALLTRIM(M->EnvId))} )
IF nPrf>0
   aPrf := dfArrRep()[nPrf] // Array con i settaggi del report
   aBuf[REP_PAGELENGHT   ] := VAL(aPrf[PRN_PRF_PAGELENGHT ] )
   aBuf[REP_MGN_TOP      ] := VAL(aPrf[PRN_PRF_MGN_TOP    ] )
   aBuf[REP_MGN_BOTTOM   ] := VAL(aPrf[PRN_PRF_MGN_BOTTOM ] )
   aBuf[REP_MGN_LEFT     ] := VAL(aPrf[PRN_PRF_MGN_LEFT   ] )
   aBuf[REP_IS_CONDENSED ] := VAL(aPrf[PRN_PRF_CONDENSED  ] )=1
   aBuf[REP_IS_NLQ       ] := VAL(aPrf[PRN_PRF_NLQ        ] )=1
   aBuf[REP_PRINTERID    ] :=     aPrf[PRN_PRF_PRINTERID  ]
   aBuf[REP_PRINTERPORT  ] :=     aPrf[PRN_PRF_PRINTERPORT]
   aBuf[REP_USEUSER1     ] := VAL(aPrf[PRN_PRF_USEUSER1   ] )=1
   aBuf[REP_USEUSER2     ] := VAL(aPrf[PRN_PRF_USEUSER2   ] )=1
   aBuf[REP_USEUSER3     ] := VAL(aPrf[PRN_PRF_USEUSER3   ] )=1
   aBuf[REP_NO_EJECT     ] := VAL(aPrf[PRN_PRF_NO_EJECT   ] )=1
   aBuf[REP_ALLPAGE      ] := VAL(aPrf[PRN_PRF_ALLPAGE    ] )=1
   aBuf[REP_FROMPAGE     ] := VAL(aPrf[PRN_PRF_FROMPAGE   ] )
   aBuf[REP_TOPAGE       ] := VAL(aPrf[PRN_PRF_TOPAGE     ] )
   aBuf[REP_COPY         ] := VAL(aPrf[PRN_PRF_COPY       ] )
   aBuf[REP_PAGE_FORMAT  ] := VAL(aPrf[PRN_PRF_PAGE       ] ) 
   aBuf[REP_ORIENTATION  ] := VAL(aPrf[PRN_PRF_ORIENTATION] ) 

   DEFAULT aBuf[REP_PAGE_FORMAT ]  TO XBPPRN_FORM_A4 
   DEFAULT aBuf[REP_ORIENTATION ]  TO XBPPRN_ORIENT_PORTRAIT 

ELSE
   aBuf[REP_PAGELENGHT   ] := 66
   aBuf[REP_MGN_TOP      ] :=  5
   aBuf[REP_MGN_BOTTOM   ] :=  5
   aBuf[REP_MGN_LEFT     ] :=  5
   aBuf[REP_IS_CONDENSED ] := .F.
   aBuf[REP_IS_NLQ       ] := .F.
   aBuf[REP_PRINTERID    ] := dfSet(AI_DEFAULTPRINTER)
   aBuf[REP_PRINTERPORT  ] := dfSet(AI_DEFAULTPORT)
   aBuf[REP_USEUSER1     ] := .F.
   aBuf[REP_USEUSER2     ] := .F.
   aBuf[REP_USEUSER3     ] := .F.
   aBuf[REP_NO_EJECT     ] := .F.
   aBuf[REP_ALLPAGE      ] := .T.
   aBuf[REP_FROMPAGE     ] := 1
   aBuf[REP_TOPAGE       ] := 99999
   aBuf[REP_COPY         ] := 1
   aBuf[REP_PAGE_FORMAT  ] := XBPPRN_FORM_A4  
   aBuf[REP_ORIENTATION  ] := XBPPRN_ORIENT_PORTRAIT  

ENDIF

// Assegnato per eventuali stampe a mano
aBuf[REP_FOOTER_LINE]   := aBuf[REP_PAGELENGHT] -aBuf[REP_MGN_BOTTOM]

aBuf[REP_PRINTERPORT  ] := UPPER(ALLTRIM(aBuf[REP_PRINTERPORT]))
aBuf[REP_PRINTERID    ] := UPPER(ALLTRIM(aBuf[REP_PRINTERID]  ))

aBuf[REP_QRY_EXP      ] := ""
aBuf[REP_QRY_DES      ] := ""

aBuf[REP_NAME         ] := ""

aBuf[REP_SETUP        ] := ""
aBuf[REP_RESET        ] := ""
aBuf[REP_BOLD_ON      ] := ""
aBuf[REP_BOLD_OFF     ] := ""
aBuf[REP_ENL_ON       ] := ""
aBuf[REP_ENL_OFF      ] := ""
aBuf[REP_UND_ON       ] := ""
aBuf[REP_UND_OFF      ] := ""
aBuf[REP_SUPER_ON     ] := ""
aBuf[REP_SUPER_OFF    ] := ""
aBuf[REP_SUBS_ON      ] := ""
aBuf[REP_SUBS_OFF     ] := ""
aBuf[REP_SPOOLER      ] := .F.
aBuf[REP_FNAME        ] := SPACE(12)

IF aBuf[REP_PRINTERARR]==NIL
   nPrn := ASCAN( dfArrPrn(), {|aSub|ALLTRIM(UPPER(aSub[PRINTER_ID])) ==;
                                     aBuf[REP_PRINTERID]              })
   IF EMPTY(nPrn)
      nPrn:=1
   ENDIF
   aBuf[REP_PRINTERARR] := dfArrPrn()[nPrn]
ENDIF

// Assegnazioni Standard
aBuf[REP_ACT_ROW  ]     := 1
aBuf[REP_ACT_COL  ]     := 0
aBuf[REP_ACT_PAGE ]     := 0
aBuf[REP_BAN_ROW  ]     := 1
aBuf[REP_IS_FOOTER]     := .F.
aBuf[REP_IS_ABORT ]     := .F.
aBuf[REP_IS_BANNER]     := .F.
aBuf[REP_ITEMINPAGE]    := 0
aBuf[REP_POSINFILE]     := 0
aBuf[REP_ROWRB]         := 0
aBuf[REP_ROWPH]         := 0
aBuf[REP_IS_QUIT]       := .F.
aBuf[REP_IS_LAST]       := .F.
aBuf[REP_NO_LAST_EJECT] := .F.
aBuf[REP_FLOATPF      ] := .F.
aBuf[REP_DISABLE      ] := 0
aBuf[REP_EMPTYREPORT  ] := .F.
aBuf[REP_VREC         ] := NIL
aBuf[REP_NO_PAGE_EJECT] := .F.

#ifdef __XPP__
aBuf[REP_ASCII_REPORT ] := .T.
#else
aBuf[REP_ASCII_REPORT ] := .F.
#endif

aBuf[REP_XBASEPRINTDISP  ] := NIL
aBuf[REP_XBASEPRINTOBJ   ] := NIL
aBuf[REP_XBASEPRINTEXTRA ] := NIL
aBuf[REP_XBASEUSERPRNDISP] := NIL
aBuf[REP_CARGO           ] := NIL
aBuf[REP_XBASEFONT       ] := NIL

oRT := dfReportTypeDefault( NIL, REP_XBASE_RT_DBSEE )
IF EMPTY(oRT)
   aBuf[REP_XBASEREPORTTYPE ] := NIL
ELSE
   aBuf[REP_XBASEREPORTTYPE ] := oRT:new()
ENDIF

//aBuf[REP_PDF_PAGE_FORMAT]  := NIL
//aBuf[REP_PDF_ORIENTATION]  := NIL

IF EMPTY(aBuf[REP_PDF_PAGE_FORMAT])
   aBuf[REP_PDF_PAGE_FORMAT]  := S2ConvPrinterWintoPDFPage(        aBuf[REP_PAGE_FORMAT  ] )
ENDIF 
IF EMPTY(aBuf[REP_PDF_ORIENTATION])
   aBuf[REP_PDF_ORIENTATION]  := S2ConvPrinterWintoPDFOrientation( aBuf[REP_ORIENTATION  ] )
ENDIF 

aBuf[REP_MAX_ROW  ]     := aBuf[REP_ACT_ROW  ]
aBuf[REP_MAX_COL  ]     := aBuf[REP_ACT_COL  ]
aBuf[REP_MAX_PAGE ]     := aBuf[REP_ACT_PAGE ]

RETURN aBuf

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfPrnArr() // Configura Stampa
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN aBuf