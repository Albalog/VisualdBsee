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
#INCLUDE "dfMsg1.ch"    // Messaggistica
#INCLUDE "dfStd.ch"    // Standard

#ifdef __XPP__
#INCLUDE "dfWinRep.ch" // report windows

STATIC cPrinter
#endif

// Visualizza il Menu di stampa
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfPrnMenu( aBuf, nUserMenu, cIdPrinter, cIdPort )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL lRet := .F.
#ifdef __XPP__
   LOCAL oReportType := aBuf[REP_XBASEREPORTTYPE]

   IF oReportType != NIL
      lRet := oReportType:printMenu( aBuf, nUserMenu, cIdPrinter, cIdPort)
   ELSE
      lRet := dfRepDbseeMenu( aBuf, nUserMenu, cIdPrinter, cIdPort )
   ENDIF
#else
   lRet := _dfPrnMenu( aBuf, nUserMenu, cIdPrinter, cIdPort )
#endif
RETURN lRet

#ifdef __XPP__

// Menu di stampa per report dBsee Standard
// il menu pu• essere standard o windows 
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfRepDbseeMenu( aBuf, nUserMenu, cIdPrinter, cIdPort )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .F.
   IF dfSet( AI_XBASEPRNMENUNEW )
      // Windows Print Menu
      lRet := _dfXPrnMenu( aBuf, nUserMenu, cIdPrinter, cIdPort )
   ELSE
      // Standard Print Menu
      lRet := _dfPrnMenu( aBuf, nUserMenu, cIdPrinter, cIdPort )
   ENDIF
RETURN lRet

#endif

// Menu di stampa STANDARD per report dBsee Standard
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION _dfPrnMenu( aBuf, nUserMenu, cIdPrinter, cIdPort )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T., cDmm
MEMVAR EnvId

DEFAULT nUserMenu  TO PM_MENU
DEFAULT cIdPrinter TO aBuf[REP_PRINTERID  ]
DEFAULT cIdPort    TO aBuf[REP_PRINTERPORT]

dfPrnSet( aBuf, cIdPrinter, .T. )

cIdPort    := UPPER(ALLTRIM(cIdPort   ))
aBuf[REP_PRINTERPORT] := cIdPort

IF !(LEFT(cIdPort,3)=="LPT"   .OR.;
     LEFT(cIdPort,3)=="COM"   .OR.;
     LEFT(cIdPort,5)=="VIDEO")
   aBuf[REP_PRINTERPORT] := "FILE"
   aBuf[REP_FNAME]       := cIdPort
ENDIF

aBuf[REP_FNAME] := ALLTRIM(aBuf[REP_FNAME])
aBuf[REP_FNAME] := PADR(aBuf[REP_FNAME],MAX(50,LEN(aBuf[REP_FNAME])))
IF !dfSet( AI_DISABLEMGNOPT ) .AND. !EMPTY( aBuf[REP_VREC] )
   aBuf[REP_MGN_TOP] := dfPrnMaxTop( aBuf, aBuf[REP_VREC] )
ENDIF

DO CASE
   CASE nUserMenu == PM_MENU
        IF dBsee45Win()
           lRet := df5GetParam( aBuf )
        ELSE
           lRet := dfGetParam( aBuf )
        ENDIF
        IF lRet
           dfUpdRep( EnvId, aBuf )
           IF M->Act=="new"
              aBuf[REP_PRINTERPORT] := "VIDEO"
           ENDIF
        ENDIF

   CASE nUserMenu == PM_MESSAGE
        dfAlert( dfStdMsg(MSG_DFPRNSTART02) +aBuf[REP_NAME] )

   CASE nUserMenu == PM_NUL

ENDCASE

IF lRet

   aBuf[REP_FOOTER_LINE] := aBuf[REP_PAGELENGHT] -aBuf[REP_MGN_BOTTOM]
   aBuf[REP_PRINTERPORT] := UPPER(ALLTRIM( aBuf[REP_PRINTERPORT] ))

   // LAYOUT
   IF aBuf[REP_PRINTERPORT]=="VIDEO"
   #ifdef __XPP__
      aBuf[REP_SETUP      ] := DFWINREP_SETUP
      aBuf[REP_RESET      ] := DFWINREP_RESET
      aBuf[REP_BOLD_ON    ] := DFWINREP_BOLDON
      aBuf[REP_BOLD_OFF   ] := DFWINREP_BOLDOFF
      aBuf[REP_ENL_ON     ] := DFWINREP_ENLARGEDON
      aBuf[REP_ENL_OFF    ] := DFWINREP_ENLARGEDOFF
      aBuf[REP_UND_ON     ] := DFWINREP_UNDERLINEON
      aBuf[REP_UND_OFF    ] := DFWINREP_UNDERLINEOFF
      aBuf[REP_SUPER_ON   ] := DFWINREP_SUPERSCRIPTON
      aBuf[REP_SUPER_OFF  ] := DFWINREP_SUPERSCRIPTOFF
      aBuf[REP_SUBS_ON    ] := DFWINREP_SUBSCRIPTON
      aBuf[REP_SUBS_OFF   ] := DFWINREP_SUBSCRIPTOFF
      aBuf[REP_COND_ON    ] := DFWINREP_CONDENSEDON
      aBuf[REP_COND_OFF   ] := DFWINREP_CONDENSEDOFF
      aBuf[REP_ITA_ON     ] := DFWINREP_ITALICON
      aBuf[REP_ITA_OFF    ] := DFWINREP_ITALICOFF
      aBuf[REP_NLQ_ON     ] := DFWINREP_NLQON
      aBuf[REP_NLQ_OFF    ] := DFWINREP_NLQOFF
      aBuf[REP_USER1ON    ] := DFWINREP_USER01ON
      aBuf[REP_USER1OFF   ] := DFWINREP_USER01OFF
      aBuf[REP_USER2ON    ] := DFWINREP_USER02ON
      aBuf[REP_USER2OFF   ] := DFWINREP_USER02OFF
      aBuf[REP_USER3ON    ] := DFWINREP_USER03ON
      aBuf[REP_USER3OFF   ] := DFWINREP_USER03OFF
   #else
      aBuf[REP_SETUP      ] := "" 
      aBuf[REP_RESET      ] := ""
      aBuf[REP_BOLD_ON    ] := "^1"
      aBuf[REP_BOLD_OFF   ] := "^0"
      aBuf[REP_ENL_ON     ] := "^2"
      aBuf[REP_ENL_OFF    ] := "^0"
      aBuf[REP_UND_ON     ] := "^3"
      aBuf[REP_UND_OFF    ] := "^0"
      aBuf[REP_SUPER_ON   ] := "^4"
      aBuf[REP_SUPER_OFF  ] := "^0"
      aBuf[REP_SUBS_ON    ] := "^4"
      aBuf[REP_SUBS_OFF   ] := "^0"
      aBuf[REP_COND_ON    ] := "^2"
      aBuf[REP_COND_OFF   ] := "^0"
      aBuf[REP_ITA_ON     ] := "^1"
      aBuf[REP_ITA_OFF    ] := "^0"
      aBuf[REP_NLQ_ON     ] := "^1"
      aBuf[REP_NLQ_OFF    ] := "^0"
      aBuf[REP_USER1ON    ] := ""
      aBuf[REP_USER1OFF   ] := ""
      aBuf[REP_USER2ON    ] := ""
      aBuf[REP_USER2OFF   ] := ""
      aBuf[REP_USER3ON    ] := ""
      aBuf[REP_USER3OFF   ] := ""
   #endif
   ENDIF

   // File di Output
   IF !(aBuf[REP_PRINTERPORT]=="FILE" .AND. !EMPTY( aBuf[REP_FNAME] )) // Report Name
      aBuf[REP_FHANDLE] := dfFileTemp( @cDmm )  // Report Handle
      aBuf[REP_FNAME]   := cDmm
      FCLOSE( aBuf[REP_FHANDLE] )
      //////////////////////////////////////////////////////////
      //dfXbaseExitProcAdd( dfExecuteActionDelFile():new(cDmm))
      //////////////////////////////////////////////////////////
   ENDIF

   FCLOSE( FCREATE( aBuf[REP_FNAME] ) )
ENDIF

aBuf[REP_IS_ABORT] := !lRet

RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfGetParam( aBuf )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aPrn := {}, nFilter := 6, nGetRow := 10, nButRow := 12, lRet
LOCAL lParBox, nButLine

#ifdef __XPP__
LOCAL aPort := {}, cmb0020, nPort, aPortS := {}
#endif

ATTACH "01" TO aPrn BOX      1                           AT 0,  0, 3, 56 FILL " "
ATTACH "02" TO aPrn SAY      dfStdMsg(MSG_DFPRNSTART04)  AT 0,  1
ATTACH "03" TO aPrn SAY      dfStdMsg(MSG_DFPRNSTART05)  AT 1,  1
#ifdef __XPP__
/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³ Inizializza List-Box su array (vedere Norton Guide ) ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
cmb0020 := 0->(tbBrwNew(  2                                 ,; // Prima  Riga
                       19                                   ,; // Prima  Colonna
                       10                                   ,; // Ultima Riga
                       19+36                                ,; // Ultima Colonna
                      W_OBJ_ARRAYBOX                        )) // List-Box su ARRAY

cmb0020:W_COLORARRAY[AC_LSB_BACK  ]      := "N/RB*"            // Colore fondo
cmb0020:W_COLORARRAY[AC_LSB_TOPLEFT]     := "G+/GR*"           //    "   bordo superiore
cmb0020:W_COLORARRAY[AC_LSB_BOTTOMRIGHT] := "G+/GR*"           //    "   bordo inferiore
cmb0020:W_COLORARRAY[AC_LSB_PROMPT]      := "N/GR*"            //    "   prompt
cmb0020:W_COLORARRAY[AC_LSB_HILITE]      := "N/N"              //    "   prompt selezionato
cmb0020:W_COLORARRAY[AC_LSB_HOTKEY]      := "G+/GR*"           //    "   hot key
cmb0020:COLORSPEC    := "N/RB*"
cmb0020:W_MOUSEMETHOD:= W_MM_EDIT + W_MM_VSCROLLBAR

AEVAL( dfArrPrn(), {|aSub|AADD(aPort,PADR(aSub[PRINTER_INFO],35))} )
AEVAL( dfArrPrn(), {|aSub|AADD(aPortS,IF( dfIsWinPrinter(ALLTRIM(aSub[PRINTER_INFO])), "W", "D" ) ) } )

ATTACH COLUMN "exp00200001" TO cmb0020                       ; // ATTCOL.TMP
                       BLOCK    {|| tbGetArr(cmb0020,aPort,NIL) }  ;
                       PICTURE REPLICATE("X",30)             ; // Picture visualizzazione dato
                       WIDTH    30                           ; // Larghezza colonna
                       COLOR  {"B+/W*","BG/W*","W+/BG"}  ; // Array dei colori
                       MESSAGE ""                              // Messaggio
tbArrLen( cmb0020 ,LEN(aPort) )
cPrinter := PADR(aBuf[REP_PRINTERARR][PRINTER_INFO],35)

ATTACH COLUMN "exp00200002" TO cmb0020                       ; // ATTCOL.TMP
                       BLOCK    {|| tbGetArr(cmb0020,aPortS,NIL) }  ;
                       PICTURE "XX"                          ; // Picture visualizzazione dato
                       WIDTH    2                            ; // Larghezza colonna
                       COLOR  {"B+/W*","BG/W*","W+/BG"}  ; // Array dei colori
                       MESSAGE ""                              // Messaggio
tbArrLen( cmb0020 ,LEN(aPortS) )

ATTACH "cmb0020" TO aPrn GET AS COMBO cPrinter ; // ATTCMB.TMP
                AT   1, 19                                   ; // Coordinate dato in get
                COLOR  {"N/GR*","G+/GR*","N/W*","W+/BG"}     ; // Array dei colori
                PICTURESAY REPLICATE("X",35)                 ; // Picture in say
                ACTIVE {||.T. }                              ; // Stato di attivazione
                PROMPT ""                                    ; // Prompt
                PROMPTAT   1 , 19                            ; // Coordinate prompt
                VARNAME "cFoto"                              ; //
                LISTBOX cmb0020                                // Listbox-Box-Combo
#else
ATTACH "04" TO aPrn FUNCTION PADR(aBuf[REP_PRINTERARR][PRINTER_INFO],37)  AT 1, 19, 1, 19
#endif

ATTACH "05" TO aPrn SAY dfStdMsg(MSG_DFPRNSTART06)  AT 2,  1

#ifdef __XPP__
ATTACH "06" TO aPrn FUNCTION dfGetPort( aBuf, cPrinter ) AT 2, 19, 2, 19 REALTIME
#else
ATTACH "06" TO aPrn FUNCTION PADR(aBuf[REP_PRINTERPORT],37) AT 2, 19, 2, 19
#endif

lParBox := dfGetParBox( aBuf, aPrn ) // Box vari
IF !lParBox
   nGetRow := 4
ENDIF

nButLine := dfGetParBut( aBuf, aPrn ) // Pulsanti vari
IF nGetRow == 4
   nButRow := MAX( nButLine, 6 )
ENDIF

#ifdef __XPP__
ATTACH "font" TO aPrn GET AS PUSHBUTTON dfStdMsg1(MSG1_DFPRNMENU01) AT nGetRow-1, 1, nGetRow+1, 10 ;
                     FUNCTION dfGetFont( aBuf )   // Funzione di controllo
#else
IF dfAnd( aBuf[REP_DISABLE], PRN_DISABLE_SPOOLER )==0
   ATTACH "51" TO aPrn GET AS CHECKBOX   aBuf[REP_SPOOLER] ;
                       PROMPT dfStdMsg(MSG_DFPRNSTART16) AT nGetRow, 0  ;
                    VALUEON  .T. VALUEOFF .F. GAP 1
ENDIF
#endif

IF dfAnd( aBuf[REP_DISABLE], PRN_DISABLE_COPY )==0
   ATTACH "52" TO aPrn GET aBuf[REP_COPY]  AT  nGetRow, 31 ;
                       PROMPT  dfStdMsg(MSG_DFPRNSTART17) ;
                       PROMPTAT nGetRow, 23               ;
                       MESSAGE dfStdMsg(MSG_DFPRNSTART18) ;
                       PICTURE "999"
ENDIF

IF dfAnd( aBuf[REP_DISABLE], PRN_DISABLE_FILE )==0
   ATTACH "53" TO aPrn GET aBuf[REP_FNAME] AT  nGetRow, 44;
                       PROMPT dfStdMsg(MSG_DFPRNSTART19) ;
                       PROMPTAT nGetRow,  37              ;
                       MESSAGE ""                    ;
                       PICTURESAY "@S12"             ;
                       PICTUREGET "@S12"             ;
                       CONDITION {||UPPER(ALLTRIM( aBuf[REP_PRINTERPORT] ))=="FILE"}
ENDIF

// Se posso fare il filtro
IF dfPrnFlt( aBuf )
   nFilter := 0
ENDIF

// Preso da dfAutoForm
IF dfAnd( aBuf[REP_DISABLE], PRN_DISABLE_PREVIEW )==0
   ATTACH "__NEW" TO aPrn GET AS PUSHBUTTON dfStdMsg(MSG_DFPRNSTART20) AT nButRow,  5+nFilter, nButRow+2, 17+nFilter ;
                         FUNCTION dbAct2Kbd("new")   // Funzione di controllo
ENDIF

ATTACH "__WRI" TO aPrn GET AS PUSHBUTTON dfStdMsg(MSG_DFPRNSTART21)    AT nButRow, 19+nFilter, nButRow+2, 28+nFilter ;
                      FUNCTION dbAct2Kbd("wri")   // Funzione di controllo

ATTACH "__ESC" TO aPrn GET AS PUSHBUTTON dfStdMsg(MSG_DFPRNSTART22)    AT nButRow, 30+nFilter, nButRow+2, 40+nFilter ;
                      FUNCTION dbAct2Kbd("esc")   // Funzione di controllo

IF dfAnd( aBuf[REP_DISABLE], PRN_DISABLE_INFO )==0
   ATTACH "__INF" TO aPrn GET AS PUSHBUTTON dfStdMsg(MSG_DFPRNSTART35) AT nButRow, 42+nFilter, nButRow+2, 55+nFilter ;
                         FUNCTION dfInfoRep(aBuf)    // Funzione di controllo
ENDIF
IF nFilter==0
   ATTACH "__FIL" TO aPrn GET AS PUSHBUTTON dfStdMsg(MSG_DFPRNSTART48) AT nButRow, 57        , nButRow+2, 66         ;
                  FUNCTION dfFltRep(aBuf)    // Funzione di controllo
ENDIF

lRet := dfAutoForm( NIL, NIL, aPrn, aBuf[REP_NAME],, "__WRI" )

#ifdef __XPP__

dfPrnSet( aBuf, dfGetPrnID( cPrinter ) )
// Imposto a FALSE la stampa ASCII
aBuf[REP_ASCII_REPORT ] := .F.
if dfIsWinPrinter( aBuf )
   // In caso di stampante windows reimposto a TRUE la stampa ASCII
   aBuf[REP_ASCII_REPORT ] := .T.
   dfWinPrinterObjSet( ALLTRIM(aBuf[REP_PRINTERARR][PRINTER_INFO]) )
endif

#endif

RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfGetParBox( aBuf, aPrn )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nCol := 0

IF dfAnd( aBuf[REP_DISABLE], PRN_DISABLE_QUALITY )==0
   ATTACH "11" TO aPrn BOX      1                           AT 4, nCol, 7, nCol+17 FILL " "
   ATTACH "12" TO aPrn SAY      dfStdMsg(MSG_DFPRNSTART07)  AT 4, nCol+1
   ATTACH "13" TO aPrn GET AS RADIOBUTTON aBuf[REP_IS_NLQ] ;
               PROMPT dfStdMsg(MSG_DFPRNSTART08)    AT 5, nCol+1 VALUE .F. GAP 1
   ATTACH "14" TO aPrn GET AS RADIOBUTTON aBuf[REP_IS_NLQ] ;
                       PROMPT dfStdMsg(MSG_DFPRNSTART09)    AT 6, nCol+1 VALUE .T. GAP 1
   nCol += 19
ENDIF

IF dfAnd( aBuf[REP_DISABLE], PRN_DISABLE_CHARACTER )==0
   ATTACH "21" TO aPrn BOX      1                           AT 4, nCol, 7, nCol+17 FILL " "
   ATTACH "22" TO aPrn SAY      dfStdMsg(MSG_DFPRNSTART10)  AT 4, nCol+1
   ATTACH "23" TO aPrn GET AS RADIOBUTTON aBuf[REP_IS_CONDENSED] ;
                       PROMPT dfStdMsg(MSG_DFPRNSTART11)    AT 5, nCol+1 VALUE .F. GAP 1
   ATTACH "24" TO aPrn GET AS RADIOBUTTON aBuf[REP_IS_CONDENSED] ;
                       PROMPT dfStdMsg(MSG_DFPRNSTART12)    AT 6, nCol+1 VALUE .T. GAP 1
   nCol += 19
ENDIF

IF dfAnd( aBuf[REP_DISABLE], PRN_DISABLE_SETUP )==0
   ATTACH "21" TO aPrn BOX      1                           AT 4, nCol, 8, nCol+18 FILL " "
   ATTACH "22" TO aPrn SAY      dfStdMsg(MSG_DFPRNSTART36)  AT 4, nCol+1
   ATTACH "23" TO aPrn GET AS CHECKBOX aBuf[REP_USEUSER1] ;
                       PROMPT   dfStdMsg(MSG_DFPRNSTART37)  AT 5, nCol+1 ;
                       VALUEON  .T. VALUEOFF .F. GAP 1
   ATTACH "24" TO aPrn GET AS CHECKBOX aBuf[REP_USEUSER2] ;
                       PROMPT   dfStdMsg(MSG_DFPRNSTART38)  AT 6, nCol+1 ;
                       VALUEON  .T. VALUEOFF .F. GAP 1
   ATTACH "25" TO aPrn GET AS CHECKBOX aBuf[REP_USEUSER3] ;
                       PROMPT   dfStdMsg(MSG_DFPRNSTART39)  AT 7, nCol+1 ;
                       VALUEON  .T. VALUEOFF .F. GAP 1
   nCol += 19
ENDIF

RETURN nCol>0

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfGetParBut( aBuf, aPrn )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nBut := 0

IF dfAnd( aBuf[REP_DISABLE], PRN_DISABLE_PORT )==0
   ATTACH "41" TO aPrn GET AS PUSHBUTTON dfStdMsg(MSG_DFPRNSTART13) AT nBut, 58,  nBut+2, 71 ;
                       FUNCTION (dfChoPort( aBuf ),tbDisItm(tbGetObj()))
   nBut += 3
ENDIF

IF dfAnd( aBuf[REP_DISABLE], PRN_DISABLE_MARGIN )==0
   ATTACH "42" TO aPrn GET AS PUSHBUTTON dfStdMsg(MSG_DFPRNSTART14) AT nBut, 58,  nBut+2, 71 ;
                       FUNCTION dfChoset( aBuf )
   nBut += 3
ENDIF

IF dfAnd( aBuf[REP_DISABLE], PRN_DISABLE_PAGE )==0
   ATTACH "43" TO aPrn GET AS PUSHBUTTON dfStdMsg(MSG_DFPRNSTART40) AT nBut, 58,  nBut+2, 71 ;
                       FUNCTION dfPageRep(aBuf)
   nBut += 3
ENDIF

IF dfAnd( aBuf[REP_DISABLE], PRN_DISABLE_PRINTER )==0
   #ifdef __XPP__
   ATTACH "44" TO aPrn GET AS PUSHBUTTON "Proprieta'" AT nBut, 58,  nBut+2, 71 ;
                       FUNCTION (dfChoPrn( aBuf ),tbDisItm(tbGetObj()))
   #else
   ATTACH "44" TO aPrn GET AS PUSHBUTTON dfStdMsg(MSG_DFPRNSTART15) AT nBut, 58,  nBut+2, 71 ;
                       FUNCTION (dfChoPrn( aBuf ),tbDisItm(tbGetObj()))
   #endif
   nBut += 3
ENDIF

RETURN nBut

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfChoPort( aBuf ) // Scelta della porta di OUTPUT FISICHE
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aPort := {}, nPort
//#ifdef __XPP__
//dfPrnSet( aBuf, dfGetPrnID( cPrinter ) )
//if dfIsWinPrinter( ALLTRIM(aBuf[REP_PRINTERARR][PRINTER_INFO]) )
   // Do nothing
   //dbMsgErr(dfStdMsg1(MSG1_DFPRNMENU09))
//else
//#endif

dfPushAct()
AEVAL( dfArrPor(), {|aSub|AADD(aPort,aSub[1])} )
nPort := ASCAN( dfArrPor(), {|aSub|aBuf[REP_PRINTERPORT]==aSub[1]} )
IF (nPort := dfArrWin( NIL, NIL, NIL, NIL, aPort, dfStdMsg(MSG_DFPRNSTART28),,,nPort ))>0
   aBuf[REP_PRINTERPORT] := aPort[nPort]
   IF UPPER(ALLTRIM(aPort[nPort]))#"FILE"
      aBuf[REP_FNAME] := SPACE(12)
   ENDIF
ENDIF
dfPopAct()

//#ifdef __XPP__
//endif
//#endif

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfChoPrn( aBuf )  // Scelta STAMPANTI
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aPort := {}, nPort

#ifdef __XPP__

dfPrnSet( aBuf, dfGetPrnID( cPrinter ) )
//if dfIsWinPrinter( ALLTRIM(aBuf[REP_PRINTERARR][PRINTER_INFO]) )
if dfIsWinPrinter( aBuf )
   dfWinPrinterObjSet( ALLTRIM(aBuf[REP_PRINTERARR][PRINTER_INFO]) )
   dfWinPrinterObject():SetupDialog()
else
   dbMsgErr(dfStdMsg1(MSG1_DFPRNMENU09))
endif

#else

dfPushAct()
AEVAL( dfArrPrn(), {|aSub|AADD(aPort,aSub[PRINTER_INFO])} )
nPort :=  ASCAN( dfArrPrn(), {|aSub|aBuf[REP_PRINTERARR]==aSub} )
IF (nPort := dfArrWin( NIL, NIL, NIL, NIL, aPort, dfStdMsg(MSG_DFPRNSTART29),,,nPort ))>0
   dfPrnSet( aBuf, dfArrPrn()[nPort][PRINTER_ID] )
ENDIF
dfPopAct()

#endif

RETURN

#ifdef __XPP__
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfGetFont( aBuf )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
dfPrnSet( aBuf, dfGetPrnID( cPrinter ) )
//if dfIsWinPrinter( ALLTRIM(aBuf[REP_PRINTERARR][PRINTER_INFO]) )
if dfIsWinPrinter( aBuf )
   dfWinPrinterObjSet( ALLTRIM(aBuf[REP_PRINTERARR][PRINTER_INFO]) )
   dfWinPrnFontDlg()
else
   // ## da tradurre
   dbMsgErr("Nessuna proprieta' da impostare")
endif
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfGetPrnID( cPrinterINFO )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cPrinterID := "", nPos
cPrinterINFO := UPPER(ALLTRIM(cPrinterINFO))
nPos := ASCAN( dfArrPrn(), {|aSub|cPrinterINFO==UPPER(ALLTRIM(aSub[PRINTER_INFO]))} )
IF nPos>0
   cPrinterID := dfArrPrn()[nPos][PRINTER_ID]
ENDIF
RETURN cPrinterID
#endif


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfInfoRep( aBuf )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cStr := ""

cStr += dfStdMsg(MSG_DFPRNSTART32) + " [" +M->EnvId          +"]////"
cStr += dfStdMsg(MSG_DFPRNSTART33) +"//[" +aBuf[REP_QRY_DES] +"]////"
cStr += dfStdMsg(MSG_DFPRNSTART34) +"//[" +aBuf[REP_QRY_EXP] +"]"

dbMsgErr( cStr )

RETURN

#ifdef __XPP__
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfGetPort( aBuf, cPrinter )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cRet

dfPrnSet( aBuf, dfGetPrnID(cPrinter) )

//IF dfIsWinPrinter(ALLTRIM(aBuf[REP_PRINTERARR][PRINTER_INFO])) .AND. !"FILE"$UPPER(aBuf[REP_PRINTERPORT])
IF dfIsWinPrinter( aBuf ) .AND. !"FILE"$UPPER(aBuf[REP_PRINTERPORT])
   cRet := dfWinPrnGetPort( ALLTRIM(aBuf[REP_PRINTERARR][PRINTER_INFO]) )
ELSE
   cRet := aBuf[REP_PRINTERPORT]
ENDIF

RETURN PADR( cRet, 37 )
#else
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfIsWinPrinter()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN .F.
#endif
