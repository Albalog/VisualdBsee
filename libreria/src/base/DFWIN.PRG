//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "common.ch"
#INCLUDE "dfWin.ch"
#INCLUDE "dfMenu.ch"

#ifdef __XPP__
   // simone 5/11/04 per correzione problema DBGOTO(0)
   // vedi DBGOTO_XPP
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfWin( nTop    ,; // Coordinate
                 nLeft   ,; //
                 nBottom ,; //
                 nRight  ,; //
                 bKey    ,; // Kiave
                 bFilter ,; // Filtro
                 bBreak  ,; // Break
                 cInt    ,; // Intestazione
                 aCol    ,; // Array Colonne
                 aMtd    ,; // Array Metodi
                 bSys    ,; // Code block di SYS
                 cAddAct ,; // Azioni aggiunte al "wri-esc" per lo sgancio
                 nCoordinate_Mode) 
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL oTbr, oCol, nCount, cCho, nRec
#ifdef __XPP__
LOCAL aColor, aTmpColor
#endif

DEFAULT nTop     TO 3
DEFAULT nLeft    TO 3
DEFAULT nBottom  TO MAXROW() -4
DEFAULT nRight   TO MAXCOL() -5
DEFAULT bFilter  TO {||.T.}
DEFAULT bBreak   TO {||.F.}
DEFAULT cInt     TO ""
DEFAULT aCol     TO {}
DEFAULT aMtd     TO {}
DEFAULT bSys     TO {||.T.}
DEFAULT cAddAct  TO ""
DEFAULT nCoordinate_Mode TO W_COORDINATE_ROW_COLUMN
oTbr := tbBrwNew( nTop, nLeft, nBottom, nRight, NIL, "Window",nCoordinate_Mode)
#ifdef __XPP__
 //Modifica Luca del 27/10/2006 per richiesta clienti
 //Prima il default era su no!!!
 IF dfSet("XbasedfWinRowLinecursor") == "NO"  
    oTbr:W_LINECURSOR := .F.
 ELSE
    oTbr:W_LINECURSOR := .T.
 ENDIF

IF ! EMPTY(oTbr:colorSpec)
   // Simone 24/09/02
   // nella dfWin i colori di default sono scambiati!
   // correggo la situazione
   aTmpColor := dfStr2Arr(oTbr:colorSpec, ",")
   aColor := ACLONE(aTmpColor)
   aColor[WC_CC_DATA  ] := aTmpColor[WC_CC_HEADER]
   aColor[WC_CC_CURSOR] := aTmpColor[WC_CC_DATA]
   aTmpColor := NIL
ENDIF
#endif

IF !EMPTY(cInt)
   oTbr:W_TITLE := cInt
ENDIF
oTbr:W_ORDER  := INDEXORD()
oTbr:W_KEY    := bKey
oTbr:W_FILTER := bFilter
oTbr:W_BREAK  := bBreak

nRec := oTbr:W_CURRENTREC

tbSetKey( oTbr )
AEVAL( aMtd, {|aSub|AADD( oTbr:W_KEYBOARDMETHODS, aSub )} )

#ifdef __XPP__
// Guarda commento sotto
EVAL( bSys, WO_EVENT_ACTIVATE , oTbr )
#endif

IF !Empty(aCol)
   FOR nCount := 1 TO Len(aCol)
       #ifdef __XPP__
         tbAddColumn( oTbr,                         ;// Oggetto padre
                      aCol[nCount][2],              ;// Blocco
                      LEN(dfAny2Str(EVAL(aCol[nCount][2]))), ;// Larghezza
                      "",                           ;// ID
                      aCol[nCount][1],              ;// Intestazione di colonna
                      ,                             ;// Code Block per le totalizzazioni
                      ,                             ;// Picture per i dati
                      ,                             ;// Picture per i totali
                      ,                           ;// Label sul footer
                      ,                             ;// Code block da chiamare in SYS
                      ,                             ;// Edit di cella
                      ,                             ;// Messaggio associato
                      aColor)                        // Array dei colori

       #else
       oCol := tbColumnNew( aCol[nCount][1], aCol[nCount][2] )
       IF !EMPTY(aCol[nCount][2])
          oTbr:HEADSEP := "ÂÄ"
       ENDIF
       oTbr:AddColumn( oCol )
       #endif
   NEXT
ELSE
   oTbr:HEADSEP := "ÂÄ"
   FOR nCount := 1 TO FCount()
      #ifdef __XPP__
         tbAddColumn( oTbr,                         ;// Oggetto padre
                      FieldBlock(FieldName(nCount)),;// Blocco
                      LEN(dfAny2Str(EVAL(FieldBlock(FieldName(nCount))))),                             ;// Larghezza
                      "",                           ;// ID
                      FieldName(nCount),            ;// Intestazione di colonna
                      ,                             ;// Code Block per le totalizzazioni
                      ,                             ;// Picture per i dati
                      ,                             ;// Picture per i totali
                      ,                           ;// Label sul footer
                      ,                             ;// Code block da chiamare in SYS
                      ,                             ;// Edit di cella
                      ,                             ;// Messaggio associato
                      aColor)                        // Array dei colori
      #else
         oCol := tbColumnNew( FieldName(nCount), FieldBlock(FieldName(nCount)) )
         oTbr:AddColumn( oCol )
      #endif
   NEXT
ENDIF

M->Act := "ink"

#ifndef __XPP__
// In condizione normale il codeblock di activate Š qui.
// Con alaska Š fatto prima delle tbadcolumn, dato che viene fatta una
// eval di un dato che potrebbe prendere dai valori dall'evento activate
EVAL( bSys, WO_EVENT_ACTIVATE , oTbr )
#endif

#ifdef __XPP__
ATTACH "Z1" TO MENU oTbr:W_MENUARRAY AS MN_LABEL   ; //
      BLOCK {||MN_SECRET}                          ; // Condizione di attivazione
      SHORTCUT "esc-ret-"+cAddAct                  ; // Shortcut
      EXECUTE  {||NIL}                               // Funzione
tbConfig( oTbr )
#endif

tbStab( oTbr )
DO WHILE !(M->Act $ "ret-esc-"+ cAddAct )
   cCho := tbInk( oTbr )
   IF !EVAL( bSys, WO_EVENT_INKEY, oTbr ); EXIT; ENDIF
   IF !EMPTY(cCho)                                 // Esegue azione sul menu
      EVAL( dfMenuBlock(oTbr:W_MENUARRAY,cCho) )
   ENDIF
ENDDO

EVAL( bSys, WO_EVENT_EXIT, oTbr )

tbEnd( oTbr, W_OC_RESTORE +W_OC_DESTROY )

IF M->Act=="esc" // Riposiziona il record
   (oTbr:W_ALIAS)->(DBGOTO(nRec))
ENDIF

RETURN
