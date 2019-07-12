//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"
#INCLUDE "dfCtrl.ch"
#INCLUDE "dfWin.ch"
#INCLUDE "dfMsg.ch"

#ifdef __XPP__
   #include "Xbp.ch"
   STATIC FUNCTION MAXCOL() 
   RETURN 80
   STATIC FUNCTION MAXROW() 
   RETURN 25
#endif



* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfAutoForm( nRow, nCol, aCTRL, cTit, cState, cID, lEscCheck, aLabel, bPre, bDCC,aSize)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL b, nRet

   b := dfSet({AI_XBASESTDFUNCTIONS,  AI_STDFUNC_DFAUTOFORM})
   IF VALTYPE(b)=="B"
      // simone 27/3/08
      // mantis 0001803: dare la possibilit… di sostituire le funzioni standard dfArrwin() e dfAutoForm()
      nRet := EVAL(b, nRow, nCol, aCTRL, cTit, cState, cID, lEscCheck, aLabel, bPre, bDCC,aSize)
   ELSE
      nRet := dfAutoForm1( nRow, nCol, aCTRL, cTit, cState, cID, lEscCheck, aLabel, bPre, bDCC,aSize)
   ENDIF
RETURN nRet

// SD 25/2/03 MODIFICATO aKbd in bPre (codeblock)
// SD 8/1/03 GERR 3607 aggiunto aKbd e bDCC
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Mantis 639
//FUNCTION dfAutoForm( nRow, nCol, aCTRL, cTit, cState, cID, lEscCheck, aLabel, bPre, bDCC)
FUNCTION dfAutoForm1( nRow, nCol, aCTRL, cTit, cState, cID, lEscCheck, aLabel, bPre, bDCC,aSize)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos, nTop, nLeft, nBottom, nRight, lRet, aActCTRL, oTbr, nButLen
LOCAL nLenWri, nLenEsc, nMaxPage := 1, nPage, oTbr1
LOCAL lFirstDisp := .F.
#ifdef __XPP__
LOCAL cSetOld1 := dfSet("XbaseGetFixTwoCharLength")
LOCAL cSetOld2 := dfSet("XbaseGetFixThreeCharLength")
LOCAL cSetOld3 := dfSet("XbaseGPrAutoSize")

//Mantis 1640
LOCAL cFix1320 := dfSet("XbaseAutoFormShowRemainingChars") 
LOCAL nOld
//Corretto per segnalazione eleonora de 11/12/2009
LOCAL cXbaseGetFont       := dfSet("XbasedfFormGetFont")       // ***inAzienda***
LOCAL cXbasePromptGetFont := dfSet("XbasedfFormPromptGetFont") // ***inAzienda***
#endif

nTop := nLeft := nBottom := nRight := 0 // inizializzo le variabili

DEFAULT nRow   TO -1
DEFAULT nCol   TO -1
DEFAULT cTit   TO ""
DEFAULT aLabel TO {}

cTit := PADR( cTit, MIN( LEN(cTit), MAXCOL() ) )


//Mantis 1640
// Simone 05/11/07
// mantis 0001320: errore su tabelle tipo CATANA,ATTANA
// c'Š errore perche le variabili sono private e nel thread separato non ci pu• accedere
// come workaround disabilito tooltip caratteri rimanenti
nOld := MagicHelp():nMinChars 
DEFAULT cFix1320 TO "YES"
IF UPPER(ALLTRIM(cFix1320)) == "NO"
   MagicHelp():nMinChars := 0
ENDIF

// SD 28/06/2002 GERR 3255
#ifdef __XPP__
// il desktop Š senza nessuna form dell'applicazione?
// SD 25/02/2003 GERR 3371
lFirstDisp := ! S2XbpIsValid()

dfSet("XbaseGetFixTwoCharLength","YES") //FIX per get che non visualizzano 2 caratteri larghi es. "WW"
dfSet("XbaseGetFixThreeCharLength","YES") //FIX per get che non visualizzano 2 caratteri larghi es. "WW"

// simone 09/01/08
// mantis   	 0001551: nel menu di stampa correggere le finestre di selez. pagine ecc
dfSet("XbaseGPrAutoSize", "YES")          // FIX per attivare prompt con AUTOSIZE

IF lFirstDisp
   oTbr := tbBrwNew( 1001, 1001, 1005, 1005, W_OBJ_FRM, NIL,W_COORDINATE_ROW_COLUMN  ) // nuovo form con valori simbolici
ELSE
   oTbr := tbBrwNew( 1, 1, 5, 5, W_OBJ_FRM ,NIL,W_COORDINATE_ROW_COLUMN) // nuovo form con valori simbolici
ENDIF

#else
oTbr := tbBrwNew( 1, 1, 5, 5, W_OBJ_FRM ) // nuovo form con valori simbolici
#endif

oTbr:W_TITLE       := cTit                // Titolo
oTbr:W_CONTROL     := aCTRL               // opzioni
oTbr:W_MOUSEMETHOD := W_MM_ESCAPE +W_MM_MOVE

#ifdef __XPP__
IF ! EMPTY(bPre)                      // SD 25/2/03 per compatibilit… ma comunque
   IF VALTYPE(bPre)=="A"              // non dovrebbe mai essere un array
      oTbr:W_KEYBOARDMETHODS := bPre // e quindi non dovrebbe mai essere usato
   ELSEIF VALTYPE(bPre)=="B"
      EVAL(bPre, oTbr, 0)
   ENDIF
ENDIF
#endif
//Corretto per segnalazione eleonora de 11/12/2009
//**** INIZIO BLOCCO
//Corregge i Font sulla base delle impostazioni del dBstart.ini
IF !Empty(cXbasePromptGetFont) .OR. !Empty(cXbaseGetFont) //Questa riga serve solo a saltare il ciclo se i Font non sono stati ridefiniti
  FOR nPos := 1 TO LEN(aCTRL)
    IF aCTRL[nPos][FORM_CTRL_TYP] == CTRL_GET
      IF Empty(aCTRL[nPos][FORM_GET_PFONTCOMPOUNDNAME]) .AND. !Empty(cXbasePromptGetFont)
         aCTRL[nPos][FORM_GET_PFONTCOMPOUNDNAME] := cXbasePromptGetFont
      ENDIF
      IF Empty(aCTRL[nPos][FORM_GET_FONTCOMPOUNDNAME])  .AND. !Empty(cXbaseGetFont)
         aCTRL[nPos][FORM_GET_FONTCOMPOUNDNAME] := cXbaseGetFont
      ENDIF 
    ENDIF
  NEXT
ENDIF
//***** FINE BLOCCO

tbConfig( oTbr, .F. )                                     // Configuro

FOR nPos := 1 TO LEN(aCTRL)
   aActCTRL := aCTRL[nPos]
   nMaxPage := MAX( aActCTRL[FORM_CTRL_PAGE], nMaxPage )
   DO CASE
      CASE aActCTRL[FORM_CTRL_TYP] == CTRL_SAY
           nBottom := MAX( nBottom, aActCTRL[FORM_SAY_ROW] )
           nRight  := MAX( nRight , aActCTRL[FORM_SAY_COL]+;
                                    LEN(dfAny2Str(aActCTRL[FORM_SAY_VAR])))

      CASE aActCTRL[FORM_CTRL_TYP] == CTRL_BOX
           nBottom := MAX( nBottom, aActCTRL[FORM_BOX_BOTTOM] )
           nRight  := MAX( nRight , aActCTRL[FORM_BOX_RIGHT]  )

      CASE aActCTRL[FORM_CTRL_TYP] == CTRL_FUNCTION
           nBottom := MAX( nBottom, aActCTRL[FORM_FUN_TOP]    )
           nBottom := MAX( nBottom, aActCTRL[FORM_FUN_BOTTOM] )
           nRight  := MAX( nRight , aActCTRL[FORM_FUN_RIGHT]  )
           nRight  := MAX( nRight , aActCTRL[FORM_FUN_LEFT]+;
                      LEN(dfAny2Str(EVAL(aActCTRL[FORM_FUN_VAR]),aActCTRL[FORM_FUN_PICTURE])))

      CASE aActCTRL[FORM_CTRL_TYP] == CTRL_CMB
           nBottom := MAX( nBottom, aActCTRL[FORM_CMB_ROW]    )
           nBottom := MAX( nBottom, aActCTRL[FORM_CMB_PROW]   )
           //IF VALTYPE( aActCTRL[FORM_CMB_LISTBOX] )=="O"
              //nBottom := MAX( nBottom, TBREALBOTTOM( aActCTRL[FORM_CMB_LISTBOX] ) )
           //ENDIF

           nRight  := MAX( nRight , aActCTRL[FORM_CMB_PCOL]+LEN( dfAny2Str(aActCTRL[FORM_CMB_PROMPT]) ) )
           nRight  := MAX( nRight , aActCTRL[FORM_CMB_COL]+;
                      LEN(dfAny2Str(EVAL(aActCTRL[FORM_CMB_VAR]),aActCTRL[FORM_CMB_PICTUREGET])))
           IF VALTYPE( aActCTRL[FORM_CMB_LISTBOX] )=="O"
              nRight := MAX( nBottom, TBREALRIGHT( aActCTRL[FORM_CMB_LISTBOX] ) )
           ENDIF

      //CASE aActCTRL[FORM_CTRL_TYP] == CTRL_SPIN

      CASE aActCTRL[FORM_CTRL_TYP] == CTRL_GET
           nBottom := MAX( nBottom, aActCTRL[FORM_GET_ROW] )
           nRight  := MAX( nRight , aActCTRL[FORM_GET_COL]+;
                      LEN( dfAny2Str( EVAL(aActCTRL[FORM_GET_VAR])    ,;
                                      aActCTRL[FORM_GET_PICTURESAY])) +;
               IF(aActCTRL[FORM_GET_COMBO],aActCTRL[FORM_GET_GAP]+2,0) )

      CASE aActCTRL[FORM_CTRL_TYP] == CTRL_TEXT
           nBottom := MAX( nBottom, aActCTRL[FORM_TXT_BOTTOM] )
           nRight  := MAX( nRight , aActCTRL[FORM_TXT_RIGHT]  )

      CASE aActCTRL[FORM_CTRL_TYP] == CTRL_CHECK .OR. ;
           aActCTRL[FORM_CTRL_TYP] == CTRL_RADIO
           nBottom := MAX( nBottom, aActCTRL[FORM_CHK_ROW] )
           nRight  := MAX( nRight , aActCTRL[FORM_CHK_COL]+;
                                    LEN(aActCTRL[FORM_CHK_PROMPT])+3)

      CASE aActCTRL[FORM_CTRL_TYP] == CTRL_BUTTON
           nBottom := MAX( nBottom, aActCTRL[FORM_BUT_BOTTOM])
           nRight  := MAX( nRight , aActCTRL[FORM_BUT_RIGHT] )

      CASE aActCTRL[FORM_CTRL_TYP] == CTRL_LISTBOX
           nBottom := MAX( nBottom, TBREALBOTTOM(aActCTRL[FORM_LIST_OBJECT]) )
           nRight  := MAX( nRight , TBREALRIGHT(aActCTRL[FORM_LIST_OBJECT])  )
   ENDCASE
NEXT

IF nMaxPage>1
   oTbr:W_MOUSEMETHOD += W_MM_PAGE +W_MM_HSCROLLBAR
   ASIZE( oTbr:W_PAGELABELS, nMaxPage )
   AFILL( oTbr:W_PAGELABELS, cTit +" " )
   FOR nPage := 1 TO nMaxPage
      IF LEN(aLabel)>=nPage
         oTbr:W_PAGELABELS[nPage] := aLabel[nPage] +" "
      ELSE
         oTbr:W_PAGELABELS[nPage] += ALLTRIM(STR(nPage))+" "
      ENDIF
   NEXT
   oTbr:W_PAGEMAX := nMaxPage
ENDIF

nLenWri := LEN(dfStdMsg(MSG_DFAUTOFORM01))
nLenEsc := LEN(dfStdMsg(MSG_DFAUTOFORM02))
nButLen := nLenWri+nLenEsc+4

IF nRow == -1
   nRow := MAX( INT((MAXROW()-(nBottom+2+IF(dfIsBut( aCTRL ),0,3) -nTop))/2)-1, 0)
ENDIF
nRight := MAX(nRight,LEN(cTit))
nRight := MAX(nRight,nButLen)
IF nCol == -1
   nCol := INT( (MAXCOL()- (nRight+2 -nLeft) )/2 )
ENDIF

// Copiato in dfgetparam
IF !dfIsBut( aCTRL )
   nPos := INT((nRight-nLeft-nButLen)/2)+1
   ATTACH "__WRI" TO aCTRL GET AS PUSHBUTTON dfStdMsg(MSG_DFAUTOFORM01) ;
                         AT  nBottom+1, nLeft+nPos, nBottom+3, nLeft+nPos+nLenWri     ; // Coordinate
                         PAGE 0                        ; // Pagina 0
                         FUNCTION {||dbAct2Kbd("wri")}   // Funzione di controllo

   ATTACH "__ESC" TO aCTRL GET AS PUSHBUTTON dfStdMsg(MSG_DFAUTOFORM02) ;
                         AT  nBottom+1, nLeft+nPos+nLenWri+2, nBottom+3, nLeft+nPos+nButLen-2  ; // Coordinate
                         PAGE 0                        ; // Pagina 0
                         FUNCTION {||dbAct2Kbd("esc")}   // Funzione di controllo
   nBottom += 3
   tbConfig( oTbr, .F. )                                     // Configuro
ENDIF // evito di riattaccare i bottoni

nTop    += nRow
nBottom += nRow+2
nLeft   += nCol
nRight  += nCol+2

oTbr:nTop    := nTop    +oTbr:W_BG_TOP
oTbr:nLeft   := nLeft   +oTbr:W_BG_LEFT
oTbr:nBottom := nBottom -oTbr:W_BG_BOTTOM
oTbr:nRight  := nRight  -oTbr:W_BG_RIGHT

oTbr:W_RELATIVEPOS := { oTbr:nTop    ,;
                        oTbr:nLeft   ,;
                        oTbr:nBottom ,;
                        oTbr:nRight   } // coordinate relative

IF dBsee45win()
   oTbr:nTop    *=16
   oTbr:nLeft   *= 8
   oTbr:nBottom *=16
   oTbr:nRight  *= 8
ENDIF

#ifdef __XPP__

// SD 28/06/2002 GERR 3255
IF lFirstDisp
   tbDisItm(oTbr)
ENDIF

// Se c'Š un menu visibile ingrandisco leggermente la finestra
IF ! EMPTY(oTbr:W_MENUARRAY) .AND. ! oTbr:W_MENUHIDDEN .AND. ;
   oTbr:menuBar():numItems() > 0

   oTbr:nTop    -= .3
   oTbr:nBottom += .3
ENDIF   
////////////////////////////////////////////////////
//Mantis 639
IF !EMPTY(aSize) .AND. VALTYPE(aSize) == "A"
aSize[1] := MAX(aSize[1],oTbr:nRight-oTbr:nLeft )
oTbr:nLeft  -=  (aSize[1] -  (oTbr:nRight-oTbr:nLeft+1))/2
oTbr:nRight +=  (aSize[1] -  (oTbr:nRight-oTbr:nLeft+1))/2
ENDIF
////////////////////////////////////////////////////

oTbr1 := tbBrwNew( oTbr:nTop-oTbr:W_BG_TOP,;
                   oTbr:nLeft-oTbr:W_BG_LEFT,;
                   oTbr:nBottom+oTbr:W_BG_BOTTOM,;
                   oTbr:nRight+oTbr:W_BG_RIGHT,;
                   W_OBJ_FRM ,NIL,W_COORDINATE_ROW_COLUMN) // nuovo form con valori simbolici

oTbr1:W_TITLE       := oTbr:W_TITLE
oTbr1:W_CONTROL     := oTbr:W_CONTROL
oTbr1:W_MOUSEMETHOD := oTbr:W_MOUSEMETHOD
oTbr1:W_PAGELABELS  := oTbr:W_PAGELABELS
oTbr1:W_PAGEMAX     := oTbr:W_PAGEMAX

IF ! EMPTY(bPre)                      // SD 25/2/03 per compatibilit… ma comunque
   IF VALTYPE(bPre)=="A"              // non dovrebbe mai essere un array
      oTbr1:W_KEYBOARDMETHODS := bPre // e quindi non dovrebbe mai essere usato
   ELSEIF VALTYPE(bPre)=="B"
      EVAL(bPre, oTbr1, 1)
   ENDIF
ENDIF

oTbr := tbEnd( oTbr, W_OC_RESTORE +W_OC_DESTROY )    // del obj d'appoggio
oTbr := oTbr1
tbConfig( oTbr )                                     // Configuro
#endif

tbDisItm( oTbr )                                     // Valori
IF cID#NIL
   tbGetGoto( oTbr, cID )
ENDIF
lRet := tbGet( oTbr, bDCC, cState, lEscCheck )            // get
oTbr := tbEnd( oTbr, W_OC_RESTORE +W_OC_DESTROY )    // del obj


#ifdef __XPP__
dfSet("XbaseGetFixTwoCharLength", cSetOld1 , .T.) // imposto anche se NIL
dfSet("XbaseGetFixThreeCharLength", cSetOld2 , .T.) // imposto anche se NIL
dfSet("XbaseGPrAutoSize", cSetOld3 , .T.) // imposto anche se NIL
#endif


// riabilita tooltip caratteri rimanenti
MagicHelp():nMinChars := nOld

RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfIsBut( aCTRL )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN ASCAN(aCTRL, {|aSub|aSub[FORM_CTRL_TYP]==CTRL_BUTTON .AND. ;
                           aSub[FORM_CTRL_ID] =="__WRI"           })!=0
