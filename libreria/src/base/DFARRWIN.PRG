//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"
#INCLUDE "inkey.ch"
#INCLUDE "dfWin.ch"
#INCLUDE "dfMenu.ch"

#ifdef __XPP__
   #define TAG_SIZE 4
#else
   #define TAG_SIZE 3
#endif

STATIC aIntArr := {}
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfArrWin( nTop    ,; // Coordinate
                   nLeft   ,; //
                   nBottom ,; //
                   nRight  ,; //
                   aRow    ,; // Righe
                   cInt    ,; // Intestazione Window
                   cRow    ,; // Intestazione Righe
                   aTag    ,; // Tag
                   nSce    ,; // Scelta di partenza
                   aMtd    ,; // Array Metodi
                   bSys    ,; // Code block di SYS
                   cQuit   ,; // Azioni di sgancio
                   lhorizontal)// Abilita il cursore orizontale nel Browser   
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL b, nRet
   b := dfSet({AI_XBASESTDFUNCTIONS,  AI_STDFUNC_DFARRWIN})
   IF VALTYPE(b)=="B"
      // simone 27/3/08
      // mantis 0001803: dare la possibilit… di sostituire le funzioni standard dfArrwin() e dfAutoForm()
      nRet := EVAL(b, nTop    ,; // Coordinate
                      nLeft   ,; //
                      nBottom ,; //
                      nRight  ,; //
                      aRow    ,; // Righe
                      cInt    ,; // Intestazione Window
                      cRow    ,; // Intestazione Righe
                      aTag    ,; // Tag
                      nSce    ,; // Scelta di partenza
                      aMtd    ,; // Array Metodi
                      bSys    ,; // Code block di SYS
                      cQuit   ,; // Azioni di sgancio
                      lhorizontal)// Abilita il cursore orizontale nel Browser   
   ELSE
      nRet := dfArrWin1( nTop    ,; // Coordinate
                      nLeft   ,; //
                      nBottom ,; //
                      nRight  ,; //
                      aRow    ,; // Righe
                      cInt    ,; // Intestazione Window
                      cRow    ,; // Intestazione Righe
                      aTag    ,; // Tag
                      nSce    ,; // Scelta di partenza
                      aMtd    ,; // Array Metodi
                      bSys    ,; // Code block di SYS
                      cQuit   ,; // Azioni di sgancio
                      lhorizontal)// Abilita il cursore orizontale nel Browser   
   ENDIF

RETURN nRet


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfArrWin1( nTop    ,; // Coordinate
                   nLeft   ,; //
                   nBottom ,; //
                   nRight  ,; //
                   aRow    ,; // Righe
                   cInt    ,; // Intestazione Window
                   cRow    ,; // Intestazione Righe
                   aTag    ,; // Tag
                   nSce    ,; // Scelta di partenza
                   aMtd    ,; // Array Metodi
                   bSys    ,; // Code block di SYS
                   cQuit   ,; // Azioni di sgancio
                   lhorizontal)// Abilita il cursore orizontale nel Browser   
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL oWar
LOCAL oCol
LOCAL nRet := 0
LOCAL nRow, nCol, nCursor := SETCURSOR()

#ifdef __XPP__
LOCAL cFont
#endif

DEFAULT cInt     TO ""
DEFAULT cRow     TO ""
DEFAULT nSce     TO 1
DEFAULT aMtd     TO {}
DEFAULT bSys     TO {||.F.}
DEFAULT cQuit    TO "ret-esc"
DEFAULT lhorizontal TO .T.

AADD( aIntArr, aRow )

#ifndef __XPP__
SET CURSOR OFF
#endif

nRow := MIN( LEN(aRow) +IF(!EMPTY(cRow),3,1), MAXROW()-5 ) // Numero Massimo
                                                           // di righe per
                                                           // una dfArrWin
IF VALTYPE(aTag)=="A" .OR. !EMPTY(cRow) // Se ci sono header
   nRow+=2                              // Aumento di due righe
ENDIF

nRow := MAX( nRow, 5 ) // Il Numero minimo di righe e' 5

IF nTop == NIL .AND. nBottom == NIL
   nTop    := INT( (MAXROW()-nRow)/2 )      // Provo a mettere la prima riga
   nBottom := nTop +nRow                    // metto il fondo
ENDIF

nCol := MAX( LEN(cInt)+3, LEN(cRow) )           // Massimo fra le descrizioni
AEVAL( aRow, {|aSub|nCol:=MAX(nCol,LEN(dfAny2Str(aSub)))}) // Massimo fra la prima riga
nCol := MIN( nCol+IF(aTag#NIL,TAG_SIZE,0), MAXCOL()-2 )           // Minimo con MAXCOL()

IF nLeft == NIL .AND. nRight == NIL
   nLeft  := INT((MAXCOL()-nCol)/2)-1         // Provo a centrare le colonne
   nRight := nLeft + nCol +2                  // metto la destra
ENDIF

DEFAULT nTop    TO MAX(nBottom-nRow,  2)   // Sistemo eventuali cappelle
DEFAULT nBottom TO MIN(   nTop+nRow, MAXROW()-1)
DEFAULT nLeft   TO MAX( nRight-nCol,  2)
DEFAULT nRight  TO MIN(  nLeft+nCol, MAXCOL()-6)
                                           // Controllo la scelta
nSce := MAX(nSce,1)
nSce := MIN(nSce,LEN(aRow))

oWar := tbBrwNew( nTop, nLeft, nBottom, nRight, W_OBJ_ARRWIN ) // Apro la WAR

#ifdef __XPP__

// simone 21/9/06 se non ho intestaz. e TAG 
// nascondo le righe di intestazione
IF EMPTY(cRow) .AND. ! VALTYPE(aTag) == "A"
   oWar:W_HEADERROWS := 0
ENDIF

// simone 21/9/06 se ho toolbar su main allora la visualizzo
IF oWar:useMainToolbar()
   oWar:aToolbar        := {}
   oWar:showToolBar     := .T.
ELSE
   oWar:showToolBar     := .F.
ENDIF
oWar:showMessageArea := .F.

IF lhorizontal
   oWar:W_LINECURSOR:= .T.
ELSE
   oWar:W_LINECURSOR:= .F.
ENDIF

cFont := dfSet("XbaseArrWinFont")
IF !EMPTY(cFont)
   oWar:setFontCompoundName(dfFontCompoundNameNormalize(cFont))
ENDIF
#endif

oWar:W_TITLE      := cInt
oWar:W_MENUHIDDEN := .T.
AEVAL( aMtd, {|aSub|AADD( oWar:W_KEYBOARDMETHODS, aSub )} )

IF !EMPTY(cRow); oWar:HEADSEP := "ÂÄ"; END

IF VALTYPE(aTag)=="A"
   #ifndef __XPP__
   oCol := TBCOLUMNNEW( "T", {||tbDisTag(oWar)} )
   oCol:COLORBLOCK := {||{2,3}}
   oWar:ADDCOLUMN( oCol )
   #else
   tbAddColumn( oWar,                         ;// Oggetto padre
                {||tbDisTag(oWar)},           ;// Blocco
                3,                            ;// Larghezza
                "",                           ;// ID
                "TAG")                         // Intestazione di colonna
   #endif

   oWar:HEADSEP    := "ÂÄ"
   oWar:COLSEP     := "³"

   oWar:W_TAGARRAY := aTag
ENDIF

#ifndef __XPP__
oCol := TBCOLUMNNEW( cRow, {|| dfGetArr( aRow, oWar:W_CURRENTREC ) } )
oCol:COLORBLOCK := {||{2,3}}
oCol:WIDTH      := (nRight-nLeft)-IF(aTag#NIL,TAG_SIZE+2,2)
oWar:ADDCOLUMN( oCol )
#else
tbAddColumn( oWar,                         ;// Oggetto padre
             {|| dfGetArr( aRow, oWar:W_CURRENTREC ) },           ;// Blocco
             (nRight-nLeft)-IF(aTag#NIL,TAG_SIZE+2,2),                     ;// Larghezza
             "",                           ;// ID
             IF(EMPTY(cRow), NIL, cRow))                          // Intestazione di colonna
#endif

tbArrLen( oWar, LEN(aRow) )
oWar:W_CURRENTREC := nSce

#ifdef __XPP__
ATTACH "Z1" TO MENU oWar:W_MENUARRAY AS MN_LABEL   ; //
      BLOCK {||MN_SECRET}                          ; // Condizione di attivazione
      SHORTCUT cQuit                               ; // Shortcut
      EXECUTE  {||NIL}                               // Funzione
tbConfig( oWar )
tbStab( oWar )
#endif

M->Act := "ink"
EVAL( bSys, WO_EVENT_ACTIVATE , oWar )
tbPim( oWar )

DO WHILE !(M->Act $ cQuit)
   tbInk( oWar )
   IF EVAL( bSys, WO_EVENT_INKEY, oWar ); EXIT; ENDIF
ENDDO

EVAL( bSys, WO_EVENT_EXIT, oWar )

IF M->Act == "ret"
   nRet := oWar:W_CURRENTREC
ENDIF
oWar := tbEnd( oWar, W_OC_RESTORE +W_OC_DESTROY )
#ifndef __XPP__
SETCURSOR( nCursor )
#endif

ASIZE( aIntArr, LEN(aIntArr)-1 )

RETURN nRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfArrWinA(); RETURN ATAIL(aIntArr)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
