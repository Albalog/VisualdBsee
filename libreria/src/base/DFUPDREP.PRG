/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/
#include "Common.ch"
#include "FileIo.ch"
#include "dfReport.ch"
#include "dfSet.ch"
#include "xbpdev.ch"
#INCLUDE "dfpdf.ch"


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfUpdRep( cRep, aBuf )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nHnd, nHnd1, nPrf, aPrf, cPrinterID
LOCAL nPAGE_FORMAT, nORIENTATION
LOCAL oPrinter,nWinPage,nWinOrient 

cRep  := UPPER(ALLTRIM(cRep))
nPrf  := ASCAN( dfArrRep(), {|aSub|aSub[PRN_PRF_NAME]==cRep} )
IF nPrf>0
   aPrf := dfArrRep()[nPrf] // Array con i settaggi del report
ELSE
   aPrf := { cRep, ARRAY( PRN_PRF_LEN ) }
   AADD( dfArrRep(), aPrf )
ENDIF

                  
//nHnd1 := FCREATE( dfInitPath() +"Report.dmm" )
//IF (nHnd:=dfFopen( dfInitPath() +"Report.ini", FO_READ +FO_DENYWRITE ))>0
nHnd1   := FCREATE( dfReportINIPath() + "Report.dmm" )
IF (nHnd:= dfFopen( dfReportINIPath() + "Report.ini", FO_READ +FO_DENYWRITE ))>0
   WHILE !dfFEof()
      IF nHnd1>0
         IF UPPER(dfLeft( dfFRead() ))==cRep .OR.;
            ALLTRIM(dfFRead())==CHR(26)
            dfFskip()
            LOOP
         ENDIF
         FWRITE( nHnd1, dfFRead() +CRLF )
      ENDIF
      dfFskip()
   ENDDO
   dfFClose()
ENDIF

IF dfSet( AI_DISABLEPRINTERSAVE )
   cPrinterID := aPrf[PRN_PRF_PRINTERID]
   DEFAULT cPrinterID TO aBuf[REP_PRINTERID]
ELSE
   cPrinterID := aBuf[REP_PRINTERID]
ENDIF



////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
oPrinter := aBuf[REP_XBASEPRINTOBJ]
IF EMPTY(oPrinter) .AND.;
  !EMPTY(aBuf[REP_XBASEPRINTDISP]) .AND.;
   IsMemberVar(aBuf[REP_XBASEPRINTDISP],"oPrinter") 

   oPrinter := aBuf[REP_XBASEPRINTDISP]:oPrinter

ENDIF 

IF !EMPTY(oPrinter)

   //oPrinter := dfWinPrinterObject()
   nWinPage   := oPrinter:setFormSize()    
   nWinOrient := oPrinter:setOrientation()

   aBuf[REP_PAGE_FORMAT  ] := nWinPage
   aBuf[REP_ORIENTATION  ] := nWinOrient

   aBuf[REP_PDF_PAGE_FORMAT  ] := S2ConvPrinterWintoPDFPage(nWinPage)
   aBuf[REP_PDF_ORIENTATION  ] := S2ConvPrinterWintoPDFOrientation(nWinOrient)

ENDIF

nPAGE_FORMAT  := aBuf[REP_PAGE_FORMAT  ]
IF EMPTY(nPAGE_FORMAT)
   nPAGE_FORMAT := XBPPRN_FORM_A4   
ENDIF 
nORIENTATION  := aBuf[REP_ORIENTATION  ]
IF EMPTY(nORIENTATION)
   nORIENTATION  := XBPPRN_ORIENT_PORTRAIT  
ENDIF 
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////

                   
IF nHnd1>0
   FWRITE( nHnd1, cRep                                 +"=" +;
                  STR(aBuf[REP_PAGELENGHT   ],3)       +"," +;
                  STR(aBuf[REP_MGN_TOP      ],3)       +"," +;
                  STR(aBuf[REP_MGN_BOTTOM   ],3)       +"," +;
                  STR(aBuf[REP_MGN_LEFT     ],3)       +"," +;
                  IF( aBuf[REP_IS_CONDENSED ],"1","0") +"," +;
                  IF( aBuf[REP_IS_NLQ       ],"1","0") +"," +;
                      cPrinterID                       +"," +;
                      aBuf[REP_PRINTERPORT  ]          +"," +;
                  IF( aBuf[REP_USEUSER1     ],"1","0") +"," +;
                  IF( aBuf[REP_USEUSER2     ],"1","0") +"," +;
                  IF( aBuf[REP_USEUSER3     ],"1","0") +"," +;
                  IF( aBuf[REP_NO_EJECT     ],"1","0") +"," +;
                  IF( aBuf[REP_ALLPAGE      ],"1","0") +"," +;
                  STR(aBuf[REP_FROMPAGE     ],5)       +"," +;
                  STR(aBuf[REP_TOPAGE       ],5)       +"," +;
                  STR(aBuf[REP_COPY         ],5)       +"," +;
                  STR(nPAGE_FORMAT           ,5)       +"," +;
                  STR(nORIENTATION           ,5)       +CRLF )
   FCLOSE( nHnd1 )

//   FERASE( dfInitPath() +"Report.ini" )
//   FRENAME( dfInitPath() +"Report.dmm", dfInitPath() +"Report.ini" )
   FERASE( dfReportINIPath()  + "Report.ini" )
   FRENAME( dfReportINIPath() + "Report.dmm", dfReportINIPath() +"Report.ini" )
ENDIF

aPrf[PRN_PRF_PAGELENGHT ] := STR(aBuf[REP_PAGELENGHT   ],3)
aPrf[PRN_PRF_MGN_TOP    ] := STR(aBuf[REP_MGN_TOP      ],3)
aPrf[PRN_PRF_MGN_BOTTOM ] := STR(aBuf[REP_MGN_BOTTOM   ],3)
aPrf[PRN_PRF_MGN_LEFT   ] := STR(aBuf[REP_MGN_LEFT     ],3)
aPrf[PRN_PRF_CONDENSED  ] := IF( aBuf[REP_IS_CONDENSED ],"1","0")
aPrf[PRN_PRF_NLQ        ] := IF( aBuf[REP_IS_NLQ       ],"1","0")
aPrf[PRN_PRF_PRINTERID  ] :=     cPrinterID
aPrf[PRN_PRF_PRINTERPORT] :=     aBuf[REP_PRINTERPORT  ]
aPrf[PRN_PRF_USEUSER1   ] := IF( aBuf[REP_USEUSER1     ],"1","0")
aPrf[PRN_PRF_USEUSER2   ] := IF( aBuf[REP_USEUSER2     ],"1","0")
aPrf[PRN_PRF_USEUSER3   ] := IF( aBuf[REP_USEUSER3     ],"1","0")
aPrf[PRN_PRF_NO_EJECT   ] := IF( aBuf[REP_NO_EJECT     ],"1","0")
aPrf[PRN_PRF_ALLPAGE    ] := IF( aBuf[REP_ALLPAGE      ],"1","0")
aPrf[PRN_PRF_FROMPAGE   ] := STR(aBuf[REP_FROMPAGE     ],5)
aPrf[PRN_PRF_TOPAGE     ] := STR(aBuf[REP_TOPAGE       ],5)
aPrf[PRN_PRF_COPY       ] := STR(aBuf[REP_COPY         ],5)

aPrf[PRN_PRF_PAGE         ] := STR(nPAGE_FORMAT,5)
aPrf[PRN_PRF_ORIENTATION  ] := STR(nORIENTATION,5)

RETURN


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfReadRep( cRep, aBuf )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nHnd, nHnd1, nPrf, aPrf, cPrinterID


cRep  := UPPER(ALLTRIM(cRep))
nPrf := ASCAN( dfArrRep(), {|aSub|aSub[PRN_PRF_NAME]==cRep} )
IF nPrf>0
   aPrf := dfArrRep()[nPrf] // Array con i settaggi del report
ELSE
   RETURN
ENDIF

/*                  
//nHnd1 := FCREATE( dfInitPath() +"Report.dmm" )
//IF (nHnd:=dfFopen( dfInitPath() +"Report.ini", FO_READ +FO_DENYWRITE ))>0
nHnd1 := FCREATE( dfReportINIPath() +"Report.dmm" )
IF (nHnd:=dfFopen( dfReportINIPath() +"Report.ini", FO_READ +FO_DENYWRITE ))>0
   WHILE !dfFEof()
      IF nHnd1>0
         IF UPPER(dfLeft( dfFRead() ))==cRep .OR.;
            ALLTRIM(dfFRead())==CHR(26)
            dfFskip()
            LOOP
         ENDIF
         FWRITE( nHnd1, dfFRead() +CRLF )
      ENDIF
      dfFskip()
   ENDDO
   dfFClose()
ENDIF
*/



aBuf[REP_PAGELENGHT   ] := INT(VAL(aPrf[PRN_PRF_PAGELENGHT ]),3)
aBuf[REP_MGN_TOP      ] := INT(VAL(aPrf[PRN_PRF_MGN_TOP    ]),3)
aBuf[REP_MGN_BOTTOM   ] := INT(VAL(aPrf[PRN_PRF_MGN_BOTTOM ]),3)
aBuf[REP_MGN_LEFT     ] := INT(VAL(aPrf[PRN_PRF_MGN_LEFT   ]),3)
aBuf[REP_IS_CONDENSED ] := IF( aPrf[PRN_PRF_CONDENSED  ]=="1",.T.,.F.)
aBuf[REP_IS_NLQ       ] := IF( aPrf[PRN_PRF_NLQ        ]=="1",.T.,.F.)
aBuf[REP_PRINTERID    ] :=     aPrf[PRN_PRF_PRINTERID  ]
aBuf[REP_PRINTERPORT  ] :=     aPrf[PRN_PRF_PRINTERPORT]
aBuf[REP_USEUSER1     ] := IF( aPrf[PRN_PRF_USEUSER1   ]=="1",.T.,.F.)
aBuf[REP_USEUSER2     ] := IF( aPrf[PRN_PRF_USEUSER2   ]=="1",.T.,.F.)
aBuf[REP_USEUSER3     ] := IF( aPrf[PRN_PRF_USEUSER3   ]=="1",.T.,.F.)
aBuf[REP_NO_EJECT     ] := IF( aPrf[PRN_PRF_NO_EJECT   ]=="1",.T.,.F.)
aBuf[REP_ALLPAGE      ] := IF( aPrf[PRN_PRF_ALLPAGE    ]=="1",.T.,.F.)
aBuf[REP_FROMPAGE     ] := INT(VAL(aPrf[PRN_PRF_FROMPAGE   ]),5)
aBuf[REP_TOPAGE       ] := INT(VAL(aPrf[PRN_PRF_TOPAGE     ]),5)
aBuf[REP_COPY         ] := INT(VAL(aPrf[PRN_PRF_COPY       ]),5)

aBuf[REP_PAGE_FORMAT  ] := INT(VAL(aPrf[PRN_PRF_PAGE       ]),5)
aBuf[REP_ORIENTATION  ] := INT(VAL(aPrf[PRN_PRF_ORIENTATION]),5)  

RETURN


FUNCTION S2ConvPrinterWintoPDFPage(nPageS)
 LOCAL cPage := PDF_PAGE_A4 

   /////////////////////////////////////////////
   //Luca 28/10/2014
   //Mantis 2254
   DEFAULT nPageS TO XBPPRN_FORM_A4  
   /////////////////////////////////////////////

   DO CASE 
      CASE nPageS == XBPPRN_FORM_A4 
           cPage := PDF_PAGE_A4 
      CASE nPageS == XBPPRN_FORM_A3 
           cPage := PDF_PAGE_A3 
      CASE nPageS == XBPPRN_FORM_A5 
           cPage := PDF_PAGE_A5 
      CASE nPageS == XBPPRN_FORM_LETTER 
           cPage := PDF_PAGE_LETTER   
      CASE nPageS == XBPPRN_FORM_LEGAL    
           cPage := PDF_PAGE_LEGAL    
      CASE nPageS == XBPPRN_FORM_LEDGER       
           cPage := PDF_PAGE_LEDGER   
      CASE nPageS == XBPPRN_FORM_EXECUTIVE
           cPage := PDF_PAGE_EXECUTIVE
      CASE nPageS == XBPPRN_FORM_ENVELOPE_B4
           cPage := PDF_PAGE_JIS_B4   
      CASE nPageS == XBPPRN_FORM_ENVELOPE_B5
           cPage := PDF_PAGE_JIS_B5   
      //CASE nPageS == XBPPRN_FORM_
      //     cPage := PDF_PAGE_JPOST    
      //CASE nPageS == XBPPRN_FORM_
      //     cPage := PDF_PAGE_JPOSTD   
      //CASE nPageS == XBPPRN_FORM_
      //     cPage := PDF_PAGE_COM10    
      //CASE nPageS == XBPPRN_FORM_
      //     cPage := PDF_PAGE_MONARCH  
      CASE nPageS == XBPPRN_FORM_ENVELOPE_C5 
           cPage := PDF_PAGE_C5       
      //CASE nPageS == XBPPRN_FORM_
      //     cPage := PDF_PAGE_DL       
      CASE nPageS == XBPPRN_FORM_B5
           cPage := PDF_PAGE_B5       
      OTHERWISE
           cPage := PDF_PAGE_A4 
   END CASE
RETURN cPage


FUNCTION S2ConvPagePDFtoWinPrinter(cPageIn)
 LOCAL nPage := XBPPRN_FORM_A4 
   /////////////////////////////////////////////
   //Luca 28/10/2014
   //Mantis 2254
   DEFAULT cPageIn TO PDF_PAGE_A4  
   /////////////////////////////////////////////

   DO CASE 
      CASE cPageIn == PDF_PAGE_A4  
           nPage := XBPPRN_FORM_A4 
      CASE cPageIn == PDF_PAGE_A3  
           nPage := XBPPRN_FORM_A3 
      CASE cPageIn == PDF_PAGE_A5  
           nPage := XBPPRN_FORM_A5 
      CASE cPageIn == PDF_PAGE_LETTER    
           nPage := XBPPRN_FORM_LETTER 
      CASE cPageIn == PDF_PAGE_LEGAL     
           nPage := XBPPRN_FORM_LEGAL    
      CASE cPageIn == PDF_PAGE_LEDGER    
           nPage := XBPPRN_FORM_LEDGER       
      CASE cPageIn == PDF_PAGE_EXECUTIVE 
           nPage := XBPPRN_FORM_EXECUTIVE
      CASE cPageIn == PDF_PAGE_JIS_B4    
           nPage := XBPPRN_FORM_ENVELOPE_B4
      CASE cPageIn == PDF_PAGE_JIS_B5    
           nPage := XBPPRN_FORM_ENVELOPE_B5
      //CASE cPageIn == PDF_PAGE_JPOST     
      //     nPage := XBPPRN_FORM_
      //CASE cPageIn == PDF_PAGE_JPOSTD    
      //     nPage := XBPPRN_FORM_
      //CASE cPageIn == PDF_PAGE_COM10     
      //     nPage := XBPPRN_FORM_
      //CASE cPageIn == PDF_PAGE_MONARCH   
      //     nPage := XBPPRN_FORM_
      CASE cPageIn == PDF_PAGE_C5        
           nPage := XBPPRN_FORM_ENVELOPE_C5 
      //CASE cPageIn == XBPPRN_FORM_
      //     nPage := PDF_PAGE_DL       
      CASE cPageIn == PDF_PAGE_B5        
           nPage := XBPPRN_FORM_B5
      OTHERWISE
           nPage := XBPPRN_FORM_A4  
   END CASE

RETURN nPage

FUNCTION S2ConvPrinterWintoPDFOrientation( nWinOrient)
  LOCAL cPdfOrient := PDF_VERTICAL 

  IF  nWinOrient == XBPPRN_ORIENT_LANDSCAPE 
      cPdfOrient := PDF_HORIZONTAL  
  ELSE 
      cPdfOrient := PDF_VERTICAL 
  ENDIF 

RETURN cPdfOrient

FUNCTION S2ConvPrinterPDFtoWINOrientation( cPdfOrient)
  LOCAL nWinOrient := XBPPRN_ORIENT_PORTRAIT 

  IF  cPDFOrient == PDF_HORIZONTAL   
      nWinOrient := XBPPRN_ORIENT_LANDSCAPE 
  ELSE 
      nWinOrient := XBPPRN_ORIENT_PORTRAIT 
  ENDIF 

RETURN nWinOrient
