//////////////////////////////////////////////////////////////////////
//
//  BARCHART.PRG
//
//  Copyright:
//      Alaska Software Inc., (c) 1997-1999. All rights reserved.
//
//  Contents:
//      This program draws a simple barchart.
//
//////////////////////////////////////////////////////////////////////
/*
 * Include files:
 */
#include "Gra.ch"
#include "AppEvent.ch"
#include "xbp.ch"
#include "font.ch"
#include "xbpdev.ch"
#include "common.ch"
#include "dfMsg1.ch"

#INCLUDE "dfCtrl.ch"                                 //   "       "    per control
#INCLUDE "dfGenMsg.ch"                               //   "       "     "  messaggi
#INCLUDE "dfWin.ch"                                  //   "       "     "  oggetti Visual dBsee
#INCLUDE "dfMenu.ch"                                 //   "       "     "  menu di oggetto


MEMVAR EnvID

/*
****************
PROCEDURE Main()

   //
   // Value set for bars
   //
   LOCAL aValues := { 184,  84, 144, 254, 170, 235, ;
                      289, 190, 152,  36, 107, 128  }

   LOCAL aStr := { "stringa lunga", "seconda stringa", "333333333", "433333333", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16"  }

   dfGraph3( "test", aStr, aValues, 1 )

return
//*/

// FUNCTION AppSys(); RETURN dbSeeAppSys()
//
// PROCEDURE dbeSys()
//
//   /*
//    *   Adaption of Sorting order to hosting environment
//    */
//
//   SET COLLATION TO ASCII
//
//   /*
//    *   The database engines DBFDBE and NTXDBE are loaded "hidden"
//    *   and are combined to the abstract database engine DBFNTX
//    */
//   dfDBFNTX()
//
// RETURN
****************

/*
#define TOOLBAR_HEIGHT 32
PROCEDURE __dfGraph3( cHeader, aStr, aValues, nBar )
   LOCAL oDlg, oPS, lLoop := .T.
   LOCAL oXbp, mp1, mp2, nEvent
   LOCAL aPos, aSize
   LOCAL xPrinterObjectName:=NIL
   LOCAL oGraph
   LOCAL btnExit
   LOCAL btnPrint

   aPos  := {0, S2WinStartMenuSize()[2]}
   aSize := S2AppDesktopSize()

   oDlg := S2Dialog():new(0,0,1,1)

   oDlg:border    := XBPDLG_SIZEBORDER
   oDlg:title     := cHeader
   oDlg:maxButton := .T.
   oDlg:titleBar  := .T.
   oDlg:keyboard := {|n| IIF(n==xbeK_ESC, lLoop := .F., NIL) }
   oDlg:close := {|| lLoop := .F. }
   oDlg:drawingArea:paint := {|| _paint(oPS, aStr, aValues, nBar) }
   oDlg:Create(NIL,NIL, aPos, aSize)

   aSize:=oDlg:drawingArea:currentSize()
   aSize[2]-=TOOLBAR_HEIGHT
   oGraph := XbpStatic():new(oDlg:drawingArea,NIL,NIL,aSize)
   oGraph:create()

   oDlg:tbConfig()

   oPs := oGraph:lockPS()
   //oPs := oDlg:drawingArea:lockPS()

   oDlg:show()

   DO WHILE lLoop
       nEvent := dfAppEvent( @mp1, @mp2, @oXbp, NIL, oDlg )
       IF oXbp != NIL
          oXbp:handleEvent( nEvent, mp1, mp2 )
       ENDIF
       IF nEvent==xbeP_Keyboard .AND. mp1==xbeK_CTRL_P // ctrl-p per stampare
          _PrintGraph(xPrinterObjectName, cHeader, aStr, aValues, nBar)
       ENDIF
   ENDDO
   oDlg:tbEnd()

   oDlg:destroy()
RETURN
*/

// Simone 10/12/09
// mantis 0002114: dare possibilit… di stampare la statistica richiamabile con Ctrl-T 
// XL1069 possibilità di stampa del grafico
// Cambiata totalmente la funzione che genera la form
// perchè è necessaria la toolbar per lanciare la stampa
*******************************************************************************
FUNCTION dfGraph3( cHeader, aStr, aValues, nBar)  // Parametro Opzionale passato all'Entità
*******************************************************************************
   LOCAL oWin
   LOCAL lRet   := .F.                         // Valore ritornato
   LOCAL cState := DE_STATE_MOD
   LOCAL lBreak := .F.
   LOCAL cCho
   LOCAL oPS
   LOCAL bPrint
   LOCAL oMainWin

   PRIVATE EnvId := "dfGraph"                    //<<000149>> Identificativi per help

   bPrint := {||_PrintMenu(NIL, cHeader, aStr, aValues, nBar)}
   Graph3Act(@oWin, @cState, @lBreak, bPrint, cHeader)                                   // Attivazione oggetto

   // per disattivare toolbar su main form
   IF oWin:UseMainToolbar()
      oMainWin := dfSetMainWin(oWin)
   ENDIF

   oWin:lFullScreen := .T.

   tbConfig( oWin )                               // Riconfigura i parametri interni dell'oggetto ( vedere Norton Guide )

   oPs := oWin:getCtrlArea():lockPS()

   oWin:getCtrlArea():paint := {|| _paint(oPS, aStr, aValues, nBar) }

   WHILE( !lBreak )
     tbDisItm( oWin )                                   //  Visualizza i dati

     cCho := tbink( oWin )                             //  Inkey di tastiera ( vedere Norton Guide )

     IF !Empty(cCho)                                   //  Esegue azione sul menu
        EVAL( dfMenuBlock(oWin:W_MENUARRAY,cCho) )    //  dfMenuBlock() ritorna il code block associato
     END    //  alla voce di menu (vedere Norton Guide )
   ENDDO
   oWin:=tbEnd( oWin ,  W_OC_RESTORE +W_OC_DESTROY )                         // ( vedere Norton Guide )
   lRet := .T.
   dfSetMainWin(oMainWin)
RETURN lRet

*******************************************************************************
STATIC FUNCTION Graph3Act(oWin, cState, lBreak, bPrint, cHeader)                                // [ 03 ] INIZIALIZZA OGGETTO
*******************************************************************************
LOCAL aPfkItm

IF oWin!=NIL                                         // Si ritorna l'oggetto se già inizializzato
   oWin:FormName := EnvId                            // e si aggiorna il nome della form
   RETURN oWin
ENDIF

M_Cless()                                            // Stato di attesa con mouse a clessidra

/*+---------------------------------------------+
  ¦ Inizializza oggetto ( vedere Norton Guide ) ¦
  +---------------------------------------------+*/

oWin := 0->(TbBrwNew(  760                        ,; // <<000007>>Prima  Riga
                          0                        ,; // <<000008>>Prima  Colonna
                        576                        ,; // <<000009>>Ultima Riga
                        630                        ,; // <<000010>>Ultima Colonna
                       W_OBJ_FRM                             ,; // <<000010>>Tipo oggetto ( form )
                       NIL ,; // <<000011>>Label
                       W_COORDINATE_PIXEL                    )) // <<000012>>Gestione in Pixel
oWin:W_TITLE     := cHeader    // Titolo oggetto
oWin:W_KEY       := NIL                              // Non esegue la seek
oWin:W_FILTER    := {||.T.}                          // CodeBlock per il filtro
oWin:W_BREAK     := {||.F.}                          // CodeBlock per il break
oWin:W_PAGELABELS:= {}                               // Array delle pagine
oWin:W_PAGERESIZE:= {}
//ATTACH PAGE LABEL "Pagina N°1" TO oWin:W_PAGELABELS
oWin:W_MENUHIDDEN:= .T.                              // Stato attivazione barra azioni
oWin:W_COLORARRAY[AC_FRM_BACK  ] := "B+/G"           // Colore di FONDO
oWin:W_COLORARRAY[AC_FRM_BOX   ] := "B+/G"           // Colore di BOX
oWin:W_COLORARRAY[AC_FRM_HEADER] := "RB+/B*"         // Colore di HEADER ON
oWin:W_COLORARRAY[AC_FRM_OPTION] := "W+/BG"          // Colore di ICONE

oWin:border      := XBPDLG_DLGBORDER
oWin:lCenter := .T.
oWin:icon := APPLICATION_ICON
oWin:sysMenu  := .T.
oWin:minButton:= .T.
oWin:maxButton:= .F.
oWin:W_MOUSEMETHOD := W_MM_PAGE + W_MM_MOVE          // Inizializzazione ICONE per mouse

/*+-----------------------------+
  ¦ Inizializza menu e azioni   ¦
  +-----------------------------+*/

ATTACH "Z1" TO MENU oWin:W_MENUARRAY AS MN_LABEL  ; //
        BLOCK    {||if((cState$"iam"),MN_SECRET,MN_OFF)}  ; // Condizione di stato di attivazione
        PROMPT   dfStdMsg( MSG_FORMESC )           ; // Label
        SHORTCUT "esc"                             ; // Azione (shortcut)
        EXECUTE  {||lBreak:=.T.}                   ; // Funzione
        MESSAGE  dfStdMsg( MSG_FORMESC )             // Message
ATTACH "Z2" TO MENU oWin:W_MENUARRAY AS MN_LABEL  ; //
        BLOCK    {||if((cState$"am"),MN_SECRET,MN_OFF)}  ; // Condizione di stato di attivazione
        PROMPT  dfStdMsg1(MSG1_DFGRAPH30000)                           ;
        SHORTCUT "C_p"                             ; // Azione (shortcut)
        EXECUTE  bPrint                    ; // Funzione
        MESSAGE  dfStdMsg1(MSG1_DFGRAPH30010)            // Message
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {|mp1, mp2, oBtn| dbAct2Kbd("esc")}  ; //
        WHEN    {|| (cState $ "iam") }             ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   dfStdMsg1(MSG1_DDKEYWIN0060)           ; //
        TOOLTIP dfStdMsg1(MSG1_DDKEYWIN0060)  ; //
        IMAGES  TOOLBAR_ESC_H                      ; //
        ID "0911007467"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {|mp1, mp2, oBtn| dbAct2Kbd("C_p")}  ; //
        WHEN    {|| .T. }              ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT  dfStdMsg1(MSG1_DFGRAPH30000)                           ;
        TOOLTIP dfStdMsg1(MSG1_DFGRAPH30010)            ;
        IMAGES  TOOLBAR_PRINT                      ; //
        ID "0128007659"
/*
ATTACH TOOLSEPARATOR TO oWin                         // ACTTBR.TMP
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {|mp1, mp2, oBtn| dbAct2Kbd("hlp")}  ; //
        WHEN    {|| (cState $ "iam") }             ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Aiuto (F1)"                      ; //
        TOOLTIP "Aiuto (F1)"                       ; //
        IMAGES  TOOLBAR_HELP_H                     ; //
        ID "0911007469"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {|mp1, mp2, oBtn| dbAct2Kbd("ush")}  ; //
        WHEN    {|| (cState $ "iam") }             ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Aiuto (Shift-F1)"                ; //
        TOOLTIP "Aiuto (Shift-F1)"                 ; //
        IMAGES  TOOLBAR_KEYHELP_H                  ; //
        ID "0911007470"
*/
/*+-----------------------------+
  ¦ Control                     ¦
  +-----------------------------+*/
/*
ATTACH "box0003" TO oWin:W_CONTROL BOX 01          ; // ATTBOX.TMP
                 AT    4,   2, 152, 344            ; // Coordinate
                 BOXTEXT ""                        ; // BOX Text
                 COORDINATE  W_COORDINATE_PIXEL    ; // Tipo Coordinate
                 BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                 COLOR {"W+/G","B+/G","N/G"}         // Array dei colori
ATTACH "say0018" TO oWin:W_CONTROL SAY "che hanno data scadenza successiva al" AT   16,  12  ; // ATTSAY.TMP
                 SIZE       { 252,  18}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // SAY ALIGNMENT
                 COLOR    {"N/G"}                    // Array dei colori
*/
M_Normal()                                           // Stato mouse normale

RETURN oWin

// mostra il menu di stampa
// con attivo solo il dispositivo di stampante Windows
STATIC PROCEDURE _PrintMenu(xPrinterObjectName, cHeader, aStr, aValues, nBar)
   LOCAL aBuffer
   LOCAL aDisp
   LOCAL nPos
   aBuffer := dfPrnCfg()                      // Inizializzazione

   aBuffer[ REP_NAME ]  := dbMMrg(STRTRAN(cHeader,dfHot()))  //  Intestazione report

   aDisp := NIL

   DO CASE
      CASE VALTYPE(aBuffer[REP_XBASEUSERPRNDISP])== "A"
           DEFAULT aDisp TO aBuffer[REP_XBASEUSERPRNDISP]

      CASE EMPTY(aBuffer[REP_XBASEREPORTTYPE])
           // dispositivi di default del Report standard
           DEFAULT aDisp TO dfXPrnMenuDispDef()
      OTHERWISE
           // dispositivi di default del Report standard
           DEFAULT aDisp TO aBuffer[REP_XBASEREPORTTYPE]:getDefaultDisp()
   ENDCASE

   IF ! EMPTY(aDisp)
      // Lascio solo stampanti dispositivo per stampanti windows
      FOR nPos :=1 TO LEN(aDisp)
          IF ! aDisp[nPos]:isDerivedFrom("S2PrintDispWinPrinter")
             AREMOVE(aDisp,nPos)
             nPos--
          ENDIF
      NEXT
      aBuffer[REP_XBASEUSERPRNDISP]:=aDisp
   ENDIF

   IF dfPrnMenu( aBuffer )
      IF EMPTY(aBuffer[REP_XBASEPRINTDISP]) .OR. ;
         !aBuffer[REP_XBASEPRINTDISP]:isDerivedFrom("S2PrintDispWinPrinter")
         dfAlert(dfStdMsg1(MSG1_DFGRAPH30020))
      ELSE
          // lancio la stampa sulla stampante scelta
          _PrintGraph(aBuffer[REP_XBASEPRINTDISP]:oPrinter, cHeader, aStr, aValues, nBar)
      ENDIF
   ENDIF
   IF ! EMPTY(aBuffer[REP_FNAME]) .AND. FILE(aBuffer[REP_FNAME])
      FERASE(aBuffer[REP_FNAME])
   ENDIF
RETURN

// Simone 10/12/09
// mantis 0002114: dare possibilit… di stampare la statistica richiamabile con Ctrl-T 
// XL1069 possibilità di stampa del grafico
// lancio la stampa sulla stampante scelta
STATIC PROCEDURE _PrintGraph(xPrinterObjectName, cHeader, aStr, aValues, nBar)
   LOCAL oPS
   LOCAL oDC
   LOCAL oFont,oHeaderFont
   LOCAL nPrevOrientation

   // se è una stampante ne creo un'altra
   IF VALTYPE(xPrinterObjectName)=="O"
      oDC:=xPrinterObjectName
   ELSE
      oDC := XbpPrinter():New()
      oDC:Create( xPrinterObjectName )
   ENDIF

   // Create presentation space for default printer
   oPS := PrinterPS(oDC,@nPrevOrientation)
   //oPS:setPageSize( {580,350} )

   oFont := XbpFont():new()
   oFont:create(FONT_DEFPROP_MEDIUM)

   oHeaderFont := XbpFont():new()
   oHeaderFont:create(FONT_DEFPROP_XLARGE + FONT_STYLE_BOLD )

   // Set font for printer
   GraSetFont( oPS, oFont )

   // Activate spooling
   oPS:device():startDoc(cHeader)

   // Spool graphic output
   _Paint(oPS, aStr, aValues, nBar, cHeader, oHeaderFont)

   // End spooling
   oPS:device():endDoc()
   oFont:destroy()
   oPS:destroy()

   //DestroyDevice( oPS )
   IF nPrevOrientation != NIL
      oDC:setOrientation(nPrevOrientation)
   ENDIF
   IF ! VALTYPE(xPrinterObjectName)=="O"
      oDC:destroy()
   ENDIF
RETURN

// Create presentation space and link to
// device context for printer. The coordinate
// system unit is 1/10 millimeter.
STATIC FUNCTION PrinterPS( oDC, nPrevOrientation )
   LOCAL oPS
   LOCAL aSize
   LOCAL x

   oPS := XbpPresSpace():New()

   aSize := oDC:paperSize()

   // Size of printable region on paper
   aSize := { aSize[5] - aSize[3], ;
              aSize[6] - aSize[4]  }

   // inverto il foglio se Y > X+10%
   IF aSize[2] > aSize[1]*1.1
      nPrevOrientation := oDC:setOrientation()
      IF nPrevOrientation==XBPPRN_ORIENT_PORTRAIT
         oDC:setOrientation(XBPPRN_ORIENT_LANDSCAPE)
      ELSE
         oDC:setOrientation(XBPPRN_ORIENT_PORTRAIT)
      ENDIF
      x:=aSize[2]
      aSize[2]:=aSize[1]
      aSize[1]:=x
   ENDIF
   oPS:Create( oDC, aSize, GRA_PU_LOMETRIC )
RETURN oPS

// costruisce il grafico sul Presentation Space (Video o Stampante)
STATIC PROCEDURE _paint(oPS, aStr, aValues, nBar, cHeader, oHeaderFont )

   /* Array containing values for chart     */
   /* Fill patterns                         */
   LOCAL aAttr
   LOCAL i, imax, nX
   LOCAL nEvent, mp1, mp2, oXbp

   /* Origin for x and y axis               */
   LOCAL nX0   := 45, nY0   := 40

   /* Relative max. values for x and y      */
   LOCAL nXmax := 580, nYmax := 350

   /* Relative x value for first bar        */
   LOCAL nStart:= 0

   /* X distance between two bars           */
   LOCAL nStep := 45

   /* Width of a bar                        */
   LOCAL nWidth:= 30

   LOCAL nMax, nMaxGrf, nBarH, nRow
   LOCAL nMaxValues:=16
   LOCAL aPageSize

   // stringa con 1 carattere alto e 1 basso per calcolare l'altezza di una riga
   // la larghezza è usata come dimensione minima di una barra+spazio
   //Modifica del 30/05/2012 per migliorare grafica anche con risoluzione schermo diverse.
   //Luca c. Mantis 2196
   //LOCAL aDim := GraQueryTextBox(oPS, "^ggggggggggggggg")
   LOCAL aDim := GraQueryTextBox(oPS, "^ggggggg")
   LOCAL nBarWidth   := MAX(aDim[3][1], aDim[4][1]) - MIN(aDim[1][1], aDim[2][1])
   LOCAL nFontHeight := MAX(aDim[3][2], aDim[4][2]) - MIN(aDim[1][2], aDim[2][2])
   LOCAL nDec

   // Simone 10/12/09
   // mantis 0002114: dare possibilit… di stampare la statistica richiamabile con Ctrl-T 
   // XL1069 possibilità di stampa del grafico
   // calcolo per ridimensionare in base alla dimensione presentation space
   aPageSize := oPS:setPageSize()[1]

   // calcolo il margine per 3 righe
   nY0 := 3*nFontHeight

   // lascio spazio per 3 righe in basso e in alto
   nYMax :=aPageSize[2] -nY0 * 2
   nXMax :=aPageSize[1] -nX0 * 2

   IF ! EMPTY(cHeader)
      // se c'è intestazione tolgo altro spazio perchè
      // l'intestazione ha un font più grande
      nYMax -= nY0*2
   ENDIF

   // numero massimo di barre visualizzabili nella pagina
   nMaxValues :=INT( nXMax / (nBarWidth+1) )

   // se ci sono meno valori di quelli massimi che posso viaulizzare allargo la barra
   //////////////////////////////////////////////////////////////////////////////////////                         
   //Modifica del 30/05/2012 per migliorare grafica anche con risoluzione schermo diverse.
   //Luca c. Mantis 2196
   //IF LEN(aStr)<=nMaxValues
   IF LEN(aValues)<=nMaxValues
      //nBarWidth  := INT( nXMax / (LEN(aStr)+1 ) )
      nBarWidth  := INT( nXMax / (LEN(aValues)+1 ) )
      //nMaxValues := INT( nXMax / nBarWidth )
   ENDIF
   nMaxValues :=INT( nXMax / (nBarWidth+1) )
   //////////////////////////////////////////////////////////////////////////////////////                         

   // dimensione di una barra e spazio fra le barre
   nStep := ROUND(nXMax/nMaxValues,0)
   // dimensione di una barra, una barra è l'75% della dimensione
   nWidth := ROUND(nStep*0.75,0)

   //////////////////////////////////////////////////////////////////////////////////////                         
   //Modifica del 30/05/2012 per migliorare grafica anche con risoluzione schermo diverse.
   //Luca c. Mantis 2196
   //ASIZE( aStr   , MIN( LEN(aStr), nMaxValues ) )
   //ASIZE( aValues, MIN( LEN(aStr), nMaxValues ) )
   ASIZE( aStr   , MIN( LEN(aValues), nMaxValues ) )
   ASIZE( aValues, MIN( LEN(aValues), nMaxValues ) )
   //////////////////////////////////////////////////////////////////////////////////////                         

   //AEVAL( aStr , {|cVal,nPos|IF( cVal==NIL,aStr[nPos]:="", aStr[nPos]:=ALLTRIM(aStr[nPos]))} )
   AEVAL( aStr , {|cVal,nPos|IF( cVal==NIL,aStr[nPos]:="", aStr[nPos]:=ALLTRIM(PADR(aStr[nPos],16)))} )
   AEVAL( aValues, {|cVal,nPos|IF( cVal==NIL,aValues[nPos]:=0 , )} )

/*
   // calcolo il numero di decimali da usare nella scala Y
   // massimo 3 decimali
   nMax    := ABS(INT( dfAMax(aValues) ))
   nDec:=0
   IF nMax <> 0
     DO WHILE nDec < 3 .AND. nMax < 10
        nDec++
        nMax*=10
     ENDDO
   ENDIF

   // Massimo valore rappresentato
   nMax    := INT( dfAMax(aValues) )
   nMax    := nMax/5*6
*/

   /*
    * Draw x and y axis
    */
   GraLine( oPS, {nX0, nY0}, {nX0+nXmax, nY0} )
   GraLine( oPS, {nX0, nY0}, {nX0      , nY0+nYMax} )

   aAttr := ARRAY( GRA_AM_COUNT )
   aAttr [ GRA_AM_SYMBOL ] := GRA_MARKSYM_PLUS
   GraSetAttrMarker( oPS, aAttr )

   aAttr := ARRAY( GRA_AS_COUNT )
   aAttr [ GRA_AS_HORIZALIGN ] := GRA_HALIGN_RIGHT
   aAttr [ GRA_AS_VERTALIGN ]  := GRA_VALIGN_HALF
   GraSetAttrString( oPS, aAttr )

   // Massimo valore rappresentato
   nMax    := INT( dfAMax(aValues) )
   nMaxGrf := VAL("1" + REPLICATE("0", LEN(ALLTRIM(STR(nMax)))))

   // Massimo valore grafico rappresentato
   IF nMaxGrf / 10 >= nMax
      nMax := nMaxGrf / 10
   ELSEIF nMaxGrf / 5 >= nMax
      nMax := nMaxGrf / 5
   ELSEIF nMaxGrf / 4 >= nMax
      nMax := nMaxGrf / 4
   ELSEIF nMaxGrf / 2 >= nMax
      nMax := nMaxGrf / 2
   ELSE
      nMax := nMaxGrf
   ENDIF

   // se il valore massimo è 0 NON visualizzo la scala Y
   IF ABS(nMax) > 0
      // Draw vertical scale
   FOR i:=1 TO 4
        nRow := (nYMax*INT(nMax/5)*i)/nMax
        GraMarker  ( oPS, { nX0   , nY0 +nRow } )
        GraStringAt( oPS, { nX0- 5, nY0 +nRow }, ALLTRIM(Str(INT(nMax/5)*i)) )
        // riga orizzontale in background
        GraLine( oPS, {nX0, nY0+nRow}, {nX0+nXmax, nY0+nRow} )
   NEXT

      // riga del valore massimo
      nRow := nYMax
      GraMarker  ( oPS, { nX0   , nY0 +nRow } )
      GraStringAt( oPS, { nX0- 5, nY0 +nRow }, ALLTRIM(Str(INT(nMax))) )
      // riga orizzontale in background
      GraLine( oPS, {nX0, nY0+nRow}, {nX0+nXmax, nY0+nRow} )
   ENDIF

/*
   // se il valore massimo è 0 NON visualizzo la scala Y
   IF ABS(nMax) > 0
      // Draw vertical scale
      FOR i:=1 TO 6
         nRow := ROUND(nYMax/6*i,0)
         GraMarker  ( oPS, { nX0, nY0 +nRow } )
         GraStringAt( oPS, { nX0-5, nY0 +nRow }, ALLTRIM(Str(ROUND(nMax/6*i,nDec))) )
         // riga orizzontale in background
         GraLine( oPS, {nX0, nY0+nRow}, {nX0+nXmax, nY0+nRow} )
      NEXT
   ENDIF
*/
   aAttr [ GRA_AS_HORIZALIGN ] := GRA_HALIGN_CENTER
   aAttr [ GRA_AS_VERTALIGN ]  := GRA_VALIGN_TOP
   GraSetAttrString( oPS, aAttr )

   aAttr := Array( GRA_AA_COUNT )
   imax  := Len( aValues )

   FOR i:=1 TO imax
      /*
       * Draw horizontal scale
       */
      nX := nX0 + ( i*nStep )
      GraMarker  ( oPS, { nX-(nWidth/2), nY0 } )
      IF i%2==1
         GraStringAt( oPS, { nX-(nWidth/2), nY0-nFontHeight }, aStr[i] )
      ELSE
         GraStringAt( oPS, { nX-(nWidth/2), nY0-nFontHeight*2 }, aStr[i] )
      ENDIF

      // nMax : aValues[i] = nYMax-nY0-10 : X
      //nBarH = ((nYMax-nY0-10)*aValues[i])/nMax
      nBarH = ROUND(aValues[i]*nYMax/nMax,0)

      /*
       * Draw bars using different fill patterns
       */
      // Ombra
      aAttr[ GRA_AA_COLOR     ] := GRA_CLR_BLACK
      aAttr[ GRA_AA_BACKCOLOR ] := GRA_CLR_BLACK
      GraSetAttrArea( oPS, aAttr )

      GraBox( oPS,;
              { nX-nWidth+2, nY0+2 },;
              { nX+2, nY0 +nBarH +2 }, ;
              GRA_FILL )

      // Ripieno
      aAttr[ GRA_AA_COLOR ]     := i-1
      aAttr[ GRA_AA_BACKCOLOR ] := i-1
      GraSetAttrArea( oPS, aAttr )

      GraBox( oPS,;
              { nX-nWidth, nY0 },;
              { nX, nY0 +nBarH  }, ;
              GRA_OUTLINEFILL )
   NEXT

   // stampo intestazioe
   IF ! EMPTY(cHeader)
     IF ! EMPTY(oHeaderFont)
        GraSetFont(oPS,oHeaderFont)
     ENDIF
     aAttr := ARRAY( GRA_AS_COUNT )
     aAttr [ GRA_AS_HORIZALIGN ] := GRA_HALIGN_CENTER
     aAttr [ GRA_AS_VERTALIGN ]  := GRA_VALIGN_HALF
     GraSetAttrString( oPS, aAttr )
     GraStringAt( oPS, { nX0+ROUND(nXmax/2,0), nY0 +nYMax+(nFontHeight*2) }, cHeader )
   ENDIF

RETURN
