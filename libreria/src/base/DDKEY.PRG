/******************************************************************************
Progetto       : dBsee 4.1
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/

#include "Common.ch"
#include "Inkey.ch"
#include "dfset.ch"
#include "dfMsg.ch"
#include "dftab.ch"
#include "dfWin.ch"
#include "dfStd.ch"
#include "dfCtrl.ch"

#ifdef __XPP__
   #include "dfMenu.ch"
   #include "dmlb.ch"
#endif
#ifdef __XPP__
   // simone 5/11/04 per correzione problema DBGOTO(0)
   // vedi DBGOTO_XPP
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif

#DEFINE NDX_PROG aKey[nNdx][1]
#DEFINE NDX_GET  aKey[nNdx][2]
#DEFINE NDX_REC  aKey[nNdx][3]
#DEFINE NDX_PIC  aKey[nNdx][4]
#DEFINE NDX_DES  aKey[nNdx][5]
#DEFINE NDX_DEC  aKey[nNdx][6]
#DEFINE NDX_LEN  aKey[nNdx][7]

#DEFINE GET_REC    1
#DEFINE GET_NAME   2
#DEFINE GET_TYPE   3
#DEFINE GET_BUFFER 4
#DEFINE GET_DES    5
#DEFINE GET_PICO   6
#DEFINE GET_PIC    7
#DEFINE GET_LEN    8
#DEFINE GET_SLOT   9
#DEFINE GET_SIG   10
#DEFINE GET_FILE  11
#DEFINE GET_LOOK  12
#DEFINE GET_ERE   13

STATIC aColor                          // Array of working colours
////////////////////////////////////////////////////////////////////
//MANTIS 906
FUNCTION ddKey( nRow      ,;  // riga inizio box descrizioni
                nCol      ,;  // colonna inizio box descrizioni
                nOrd      ,;  // Numero indice corrente
                bKey      ,;  // Chiave
                bFilter   ,;  // Filtro
                bBreak    ,;  // Break
                bEval     ,;  // Eval before seek
                lLockIndex )  // Abilita solo l'indice corrente
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet 
LOCAL nIndex           := (ALIAS())->(OrdNumber())
LOCAL cALIAS           := ALIAS()
/////////////////////////////////////////////////////////////////////
//Mantis 937
LOCAL lDisableSetOrder := dfSet("XbaseDisableDDKEYSetOrder") == "YES"
/////////////////////////////////////////////////////////////////////
LOCAL b

/////////////////////////////////////////////////////////////////////
//Mantis 2154 Luca 6/05/2011
LOCAL cOldSetGetAutofill := dfSet("XbaseGetAutoFill", "NO") 
/////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////
LOCAL nCoordModeOLD := dfSet("VdBseeCoordinateMode") 
/////////////////////////////////////////////////////////////////////

b := dfSet({AI_XBASESTDFUNCTIONS,  AI_STDFUNC_DDKEY})
IF VALTYPE(b)=="B"
   // simone 19/4/06
   // mantis 0001040: implementare nuova finestra di ricerca dati
   lRet := EVAL(b, nOrd    ,; //<<000037>> Indice
                   bKey    ,; //<<000038>> Chiave
                   bFilter ,; //<<000039>> Filtro
                   bBreak  ,; //<<000040>> Break
                   bEval     ,;  // Eval before seek
                   lLockIndex )  // Abilita solo l'indice corrente
ELSE

   ////////////////////////////////////////////////////////////////
   dfSet("VdBseeCoordinateMode", "ROW")
   ////////////////////////////////////////////////////////////////

   lRet := ddKey1( nRow      ,;  // riga inizio box descrizioni
                nCol      ,;  // colonna inizio box descrizioni
                nOrd      ,;  // Numero indice corrente
                bKey      ,;  // Chiave
                bFilter   ,;  // Filtro
                bBreak    ,;  // Break
                bEval     ,;  // Eval before seek
                lLockIndex )  // Abilita solo l'indice corrente

   ////////////////////////////////////////////////////////////////
   dfSet("VdBseeCoordinateMode", nCoordModeOLD) 
   ////////////////////////////////////////////////////////////////

ENDIF
   //Mantis 937
   IF ! lDisableSetOrder
      //(ALIAS())->(DbSetOrder( nIndex )) 
      (cALIAS)->(DbSetOrder( nIndex )) 
   ENDIF
   /////////////////////////////////////////////////////////////////////
   //Mantis 2154 Luca 6/05/2011
   IF !EMPTY(cOldSetGetAutofill)
      dfSet("XbaseGetAutoFill", cOldSetGetAutofill) 
   ENDIF 
   /////////////////////////////////////////////////////////////////////

RETURN  lRet


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddKey1( nRow      ,;  // riga inizio box descrizioni
                nCol      ,;  // colonna inizio box descrizioni
                nOrd      ,;  // Numero indice corrente
                bKey      ,;  // Chiave
                bFilter   ,;  // Filtro
                bBreak    ,;  // Break
                bEval     ,;  // Eval before seek
                lLockIndex )  // Abilita solo l'indice corrente
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
////////////////////////////////////////////////////////////////////

#ifndef __XPP__
LOCAL aKey := {}                       // Main Key Array
#endif
LOCAL aKeyPar := ARRAY(17)             // Array of screen/other parameters
LOCAL cScr                             // Save Screen
LOCAL GetList := {}                    // Get Array
LOCAL cAlias                           // Current Alias
LOCAL nNdx                             // index number
LOCAL i                                // general for/next index
LOCAL cOpe                             // Main cicle operation
LOCAL nArrLen                          // lenght of aKey
LOCAL nGet, nMaxGet                    // Get Number for key input
LOCAL nGetCol                          // Get column Position
LOCAL uKeyVal                          // Key value to seek
LOCAL cVarName                         // Private expression
LOCAL cFlt                             // Filter
LOCAL nRecno
LOCAL cType, cFile, lOpen, lFound, lRet, nPos, nFieldPos
LOCAL cRealAlias



//Corretto per segnalazione eleonora de 11/12/2009
#ifdef __XPP__                                                // ***inAzienda***
LOCAL cXbaseGetFont       := dfSet("XbaseddKeyGetFont")       // ***inAzienda***
LOCAL cXbasePromptGetFont := dfSet("XbaseddKeyPromptGetFont") // ***inAzienda***
#endif                                                        // ***inAzienda***

#ifdef __XPP__
LOCAL aIndex := {}
LOCAL aLabel := {}
LOCAL bGet
LOCAL nMax
LOCAL nOldNdx
LOCAL nLenWri
LOCAL nLenEsc
LOCAL nBtnOffset := 0
LOCAL nStyle:= dfSet(AI_XBASEDDKEYMODE) // Stile ddKey
LOCAL lChgPage := dfSet("XbaseAutoChangePage") == "YES"
LOCAL nColl
#endif

MEMVAR EnvId, SubId, cKeyExp, ACT

#ifdef __XPP__
MEMVAR aKey, _mKey, _mGet
PRIVATE aKey := {}                       // Main Key Array
PRIVATE _mKey := ""
PRIVATE _mGet := 1
#endif

PRIVATE EnvId:="sutkey", SubId:=""
PRIVATE cKeyExp    // Compound key expression need private for type()

DEFAULT nRow       TO 2
DEFAULT nCol       TO 2
DEFAULT nOrd       TO INDEXORD()
DEFAULT aColor     TO dfColor( "KeyColor" )
DEFAULT lLockIndex TO .f.

cAlias := UPPER(PADR(               ALIAS()  , 8))
nRecno := RECNO()
IF EOF()
   nRecno := 0
ENDIF

//Corretto per segnalazione eleonora de 11/12/2009
//**** INIZIO BLOCCO
//Corregge i Font sulla base delle impostazioni del dBstart.ini
IF EMPTY(cXbaseGetFont)      
   cXbaseGetFont := dfSet("XbaseGetFont")
ENDIF                                           
IF EMPTY(cXbaseGetFont)      
   cXbaseGetFont := dfSet("XbaseCtrlFont")
ENDIF                                           
IF EMPTY(cXbasePromptGetFont)
   cXbasePromptGetFont := dfSet("XbasePromptGetFont")
ENDIF 
IF EMPTY(cXbasePromptGetFont)
   cXbasePromptGetFont := dfSet("XbaseCtrlFont")
ENDIF 

// 1' tentativo  ALIAS sul generato == FILE (In dBsee)
LoadArr(cAlias, nRow, nCol, aKey, aKeyPar, lLockIndex, nOrd )
cRealAlias := NIL

// Se non ci sono chiavi,
// 2' tentativo  ALIAS sul generato == FILE (In dBsee)
// accade quando apro il file con un alias diverso, in questo caso provo
// comunque a far andare le ricerche
IF EMPTY( aKey )
   cRealAlias := UPPER(PADR( dfAlias2Name( ALIAS() ), 8))
   LoadArr( cRealAlias, nRow, nCol, aKey, aKeyPar, lLockIndex, nOrd )
ENDIF

IF EMPTY( aKey ) // Non ci sono chiavi
   dbmsgerr( dfStdMsg(MSG_DDKEY01) +cAlias +dfStdMsg(MSG_DDKEY02) )
   RETURN .F.
ENDIF

#ifdef __XPP__
   // disabilito autochangepage altrimenti
   // i pulsanti sulle pag>0 non sono attivi
   IF lChgPage
      dfSet("XbaseAutoChangePage", "NO")
   ENDIF
#endif

tbAddObj()
nArrLen := LEN(aKey)

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³Working variables³
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nNdx := MAX( ASCAN( aKey, {|aNdx| aNdx[1]==nOrd} ), 1 )
IF !EMPTY( dfSet(AI_DDKEYMESSAGE) )
   dfUsrInfo( dfSet(AI_DDKEYMESSAGE) )
ENDIF

M_CUROFF()
cScr := SAVESCREEN(0,0,MAXROW(), MAXCOL())
M_CURON()
cOpe := "ntx"
nGet := 1                      // Current get element
WHILE .T.

   aKeyPar[3] := nRow                        // Ä¿
   aKeyPar[4] := nCol                        //  ³ Coordinate video
   aKeyPar[5] := aKeyPar[3] + aKeyPar[2] + 1 //  ³ elenco indici
   aKeyPar[6] := aKeyPar[4] + aKeyPar[1] + 1 // ÄÙ

   (cAlias)->(ORDSETFOCUS(NDX_PROG))

   DO CASE
      CASE cOpe = "ntx"
           #ifndef __XPP__
           DFDISPBEGIN()
           RESTSCREEN(0,0, MAXROW(), MAXCOL(), cScr)
           // intestazione
           dfSayBorder( aKeyPar[3] ,; // Coordinate zona video
                        aKeyPar[4] ,;
                        aKeyPar[5] ,;
                        aKeyPar[6] ,;
                        aColor[AC_KEY_BOX] )

           @ aKeyPar[3], aKeyPar[4]   SAY dfFontStr( "SystemMenuIcon" ) COLOR aColor[AC_KEY_BOX]
           @ aKeyPar[3], aKeyPar[6]-1 SAY dfFontStr( "minimizeicon"   ) COLOR aColor[AC_KEY_BOX]

           dfShade( aKeyPar[3], aKeyPar[4], aKeyPar[5], aKeyPar[6], dfCol2Num(dfSet(AI_SHADOWCOLOR)) )

           FOR i := 1 TO nArrLen
               IF i == nNdx
                  @ nRow+i, nCol+1 SAY  PADR( aKey[i][5] , aKeyPar[1] ) ;
                                        COLOR aColor[AC_KEY_KEYSELECTED]
               ELSE
                  @ nRow+i, nCol+1 SAY  PADR( aKey[i][5] , aKeyPar[1] ) ;
                                        COLOR aColor[AC_KEY_KEYNORMAL]
               ENDIF
           NEXT

           aKeyPar[15] := NDX_DEC      // Numero chiavi
           aKeyPar[16] := NDX_LEN      // Massima lunghezza descrizione chiavi

           // Coordinate zona video occupata dagli elementi della chiave

           aKeyPar[7] := aKeyPar[3] + nNdx - 1 // Get First Row
           aKeyPar[8] := aKeyPar[6] + 3        // Get First Column
           aKeyPar[9] := aKeyPar[7] + aKeyPar[15] + 1
           aKeyPar[10]:= aKeyPar[8] + aKeyPar[16] + 3

           IF aKeyPar[10] > MAXCOL()-2
              aKeyPar[10] := MAXCOL()-2
           ENDIF

           *ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
           *³Display Key Elements³
           *ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
           @ aKeyPar[7]+1, aKeyPar[8]-2 SAY dfFontStr( "ScrollDownArrow" );
                                            COLOR aColor[AC_KEY_BOX]

           dfSayBorder( aKeyPar[7]       ,;
                        aKeyPar[8]       ,;
                        aKeyPar[9]       ,;
                        aKeyPar[10]      ,;
                        aColor[AC_KEY_BOX] ,;
                        aColor[AC_KEY_BOX]  ) // colore interno, come bordo

           dfSHade(aKeyPar[7], aKeyPar[8], aKeyPar[9], aKeyPar[10], dfCol2Num(dfSet(AI_SHADOWCOLOR)) )

           nMaxGet := Len(NDX_GET)
           FOR i = 1 to nMaxGet

              @ aKeyPar[7]+i, aKeyPar[8]+1 SAY NDX_GET[i][GET_DES]+NDX_GET[i][GET_SIG] ;
                                               COLOR aColor[AC_KEY_SAY]

              nGetCol := aKeyPar[8]+1+LEN(NDX_GET[i][GET_DES]+NDX_GET[i][GET_SIG])+1

              IF nGetCol +LEN( dfAny2Str(NDX_GET[i][GET_BUFFER],;
                                         NDX_GET[i][GET_PIC]) ) > aKeyPar[10]
                 NDX_GET[i][GET_PIC] := "@S" +ALLTRIM(STR(aKeyPar[10]-nGetCol)) +RIGHT(NDX_GET[i][GET_PIC],1)
              ENDIF

              @ aKeyPar[7]+i, nGetCol   SAY     NDX_GET[i][GET_BUFFER]     ;
                                        PICTURE NDX_GET[i][GET_PIC]        ;
                                        COLOR   aColor[AC_KEY_GETNORMAL]
           NEXT

           DFDISPEND()

           nGetCol := aKeyPar[8]+1+len(NDX_GET[nGet][GET_DES]+NDX_GET[nGet][GET_SIG])+1

           dfSet( AI_FASTMENUALT, .F. ) // Disattivo il tasto sul menu
           dfGet( aKeyPar[7]+nGet                                                            ,;
                  nGetCol                                                                    ,;
                  {|X|IF( X==NIL, NDX_GET[nGet][GET_BUFFER], NDX_GET[nGet][GET_BUFFER]:=X )} ,;
                  NDX_GET[nGet][GET_PIC]                                                     ,;
                  aColor[AC_KEY_GETNORMAL] +"," +aColor[AC_KEY_GETSELECTED]                  ,;
                  "dar-uar-win-wis-Aua-Ada-Ala-Ara-Crt-S07-C07-S08-C08-ush-mou" )
           dfSet( AI_FASTMENUALT, .T. ) // Attivo il tasto sul menu
           #endif

           #ifdef __XPP__

           aLabel := {}
           aIndex := {}
           nMax   := 1
           nOldNdx := nNdx
           FOR nNdx := 1 TO nArrLen
              AADD( aLabel, aKey[nNdx][5] )
              nMaxGet := Len(NDX_GET)
              nMax := MAX( nMax, nMaxGet )

              // Descrizione indice
              //@ 0, 1 SAY aKey[nNdx][5] PICTURE "@X"
              ATTACH "__desc__" TO aIndex SAY aKey[nNdx][5] AT 0, 0 PAGE nNdx ;
                     FONT cXbasePromptGetFont // ***inAzienda***

              // Devo fare una form con tutti i campi
              FOR i = 1 to nMaxGet
                 bGet := "{|x|IF(x==NIL,aKey[" +ALLTRIM(STR(nNdx)) +"][2][" +ALLTRIM(STR(i)) +"][" +ALLTRIM(STR(GET_BUFFER)) +"],aKey[" +ALLTRIM(STR(nNdx)) +"][2][" +ALLTRIM(STR(i)) +"][" +ALLTRIM(STR(GET_BUFFER)) +"]:=X)}"
                 bGet := "{|x|m->_mGet:=" +ALLTRIM(STR(i)) +",EVAL(" +bGet +",x)}"
                 bGet := &bGet

                 nGetCol := aKeyPar[8]+1+len(NDX_GET[i][GET_DES]+NDX_GET[i][GET_SIG])+1

                 IF ! EMPTY(NDX_GET[i][GET_SIG])
                    ATTACH "exp"+ALLTRIM(STR(nNdx)) TO aIndex FUNCTION BTN_NEXT AT  i+.2, nGetCol-1.2, 0, 0 ; // ATTEXP.TMP
                                     BITMAP                            ; // Bitmap (XBASE)
                                     PAGE nNdx ;
                                     PICTURESAY ""                       // Picture in say
                                     
/*
                    ATTACH "but"+ALLTRIM(STR(nNdx)) TO aIndex GET AS PUSHBUTTON ""  ; // ATTBUT.TMP
                                     AT  i-1,  nGetCol-2, i+1, nGetCol-.4      ; // Coordinate
                                     FUNCTION {||dbAct2Kbd("C07")}     ; // Funzione di controllo
                                     PAGE nNdx ;
                                     ACTIVE   {||.T.}         ; // Stato di attivazione
                                     BITMAP    BUT_BMP_YES  ; // Bitmap (XBASE)
                                     BITMAPID  BTN_NEXT     ; // Bitmap ID (XBASE)
                                     MESSAGE dfStdMsg(MSG_DDKEY07)+;
                                             IIF(EMPTY(dbAct2Mne("C07")), "", ;
                                                 " ("+dbAct2Mne("C07")+")")                          // Messaggio utente
*/
                 ENDIF

                 ATTACH ALLTRIM(STR(nNdx)) TO aIndex GET bGet AT i, nGetCol ;
                                     PROMPT  NDX_GET[i][GET_DES] ; //+NDX_GET[i][GET_SIG] ;
                                     PROMPTAT i, aKeyPar[8]+1 ;
                                     PAGE nNdx ;
                                     CONDITION IIF(EMPTY(NDX_GET[i][GET_SIG]), ;
                                                   {|ab| _chkGet(ab, .F.) }, ;
                                                   {|ab| _chkGet(ab, .T.) }) ;
                                     COMBO                             ; // Icona combo
                                     MESSAGE NDX_GET[i][GET_DES] ; //+NDX_GET[i][GET_SIG] ;
                                     PICTURE NDX_GET[i][GET_PIC]   ; 
                                     FONT       cXbaseGetFont      ; // ***inAzienda***
                                     PROMPTFONT cXbasePromptGetFont  // ***inAzienda***

                 // L'attach per default crea un codeblock di get su bGet
                 // la cosa deve essere corretta
                 ATAIL(aIndex)[FORM_GET_VAR]       := bGet


              NEXT
           NEXT

           nLenWri := LEN(dfStdMsg(MSG_DFAUTOFORM01))
           nLenEsc := LEN(dfStdMsg(MSG_DFAUTOFORM02))

           IF nStyle == AI_DDKEYMODE_STD
              nBtnOffset:=4  // Stile standard, sposto i pulsanti di OK pi— in basso
           ELSE
              nBtnOffset:=0
           ENDIF


           ATTACH "__WRI" TO aIndex GET AS PUSHBUTTON dfStdMsg(MSG_DFAUTOFORM01) ;
                                 AT  nMax+2+nBtnOffset, 1, nMax+4+nBtnOffset, 1+nLenWri     ; // Coordinate
                                 PAGE 0                        ; // Pagina 0
                                 FUNCTION {||nNdx := tbPgActual( tbGetObj() ),_mKey:="ret",dbAct2Kbd("wri")}  // Funzione di controllo
                                 //AT  nMax+6, 1, nMax+8, 1+nLenWri     ; // Coordinate

           ATTACH "__ESC" TO aIndex GET AS PUSHBUTTON dfStdMsg(MSG_DFAUTOFORM02) ;
                                 AT  nMax+2+nBtnOffset, 1+nLenWri+2, nMax+4+nBtnOffset, 1+nLenWri+2+nLenEsc  ; // Coordinate
                                 PAGE 0                        ; // Pagina 0
                                 FUNCTION {||dbAct2Kbd("esc")}   // Funzione di controllo
                                 //AT  nMax+6, 1+nLenWri+2, nMax+8, 1+nLenWri+2+nLenEsc  ; // Coordinate

           //i := 1+nLenWri+2+nLenEsc

           IF nStyle == AI_DDKEYMODE_STD
              _addButtons(aIndex, nMax)  // aggiunge i pulsanti
           ENDIF

           _mKey := ""
           _mGet := 1
           //Mantis 639
           nColl := MAX(45,25+nNdx*7 )
           //Per evitare che si troppo grande
           nColl := MIN(nColl,85) 


           //nColl := MIN(nColl,95) 
           // SD 8/1/03 GERR 3607 aggiunto bDCC
           //Mantis 639
           //IF dfAutoForm( NIL, NIL, aIndex, dfStdMsg(MSG_DDWIT04), NIL, ;
           //               ALLTRIM(STR(nOldNdx)) , NIL, aLabel, {|o| addKeys(o, nStyle, @nNdx, @_mKey)}, ;
           //               {||_Dcc(@nNdx, @_mKey)})
           IF dfAutoForm( NIL, NIL, aIndex, dfStdMsg(MSG_DDWIT04), NIL, ;
                          ALLTRIM(STR(nOldNdx)) , NIL, aLabel, {|o| addKeys(o, nStyle, @nNdx, @_mKey)}, ;
                          {||_Dcc(@nNdx, @_mKey)},{nColl,20 })
              Act :="ret"
           ELSE
              Act := "esc"
           ENDIF
           IF LEN( _mKey )>0
              Act := _mKey
           ENDIF
           IF nNdx>nArrLen .OR. nNdx<1
              nNdx := nOldNdx
           ENDIF

           // 12:26:32 marted 04 luglio 2000
           // Imposto l'indice corretto
           // Con Xbase++, avendo una form, occorre reimpostare tale valore
           // all'uscita della form, altrimenti le seek e le finestre sono
           // aperte sull'indice sbagliato
           (cAlias)->(ORDSETFOCUS(NDX_PROG))
           // -------------------------------

           nMaxGet := Len(NDX_GET)
           nGet    := _mGet
           #endif

           #ifndef __XPP__
           IF dfASDriver( (cAlias)->(RDDNAME()) ) .AND.;
              VALTYPE( NDX_GET[nGet][GET_BUFFER] )=="C"
              NDX_GET[nGet][GET_BUFFER] := dfRemChr( NDX_GET[nGet][GET_BUFFER], "." )
           ENDIF
           #endif

           DO CASE
              #ifndef __XPP__
              CASE Act == "dar"         // Down arrow = Next key
                   if nNdx < aKeyPar[12]
                      nNdx++
                   else
                      nNdx := 1
                   endif
                   nGet := 1

              CASE Act == "uar"         // Up   arrow = Previous key
                   IF nNdx >1
                      nNdx--
                   ELSE
                      nNdx := aKeyPar[12]
                   ENDIF
                   nGet := 1

              case Act == "esc" .AND. nGet > 1
                   nGet--

              case Act == "ret" .AND. nGet < nMaxGet
                   nGet++

              CASE Act == "Aua"        // Alt+Up Arrow
                   IF nRow > 0
                      nRow--
                   ENDIF

              CASE Act == "Ada"        // Alt+Down Arrow
                   IF aKeyPar[5]+2 < MAXROW()
                      nRow++
                   ENDIF

              CASE Act == "Ala"        // Alt+Left Arrow
                   IF nCol > 0
                      nCol--
                   ENDIF

              CASE Act == "Ara"        // Alt+Right Arrow
                   IF aKeyPar[10]+2 < MAXCOL()
                      nCol++
                   ENDIF
              #endif

              CASE Act = "esc" .OR.;
                   (Act == "mou"           .AND.;
                    M_PosY()==aKeyPar[3]   .AND.;
                    ( M_PosX()==aKeyPar[4] .OR. M_PosX()==aKeyPar[4]+1 ))
                   cOpe := "eop"

              #ifndef __XPP__
              CASE Act == "ush"
                   ddKeyHlp()

              CASE Act == "mou"           .AND.;
                   M_PosY()==aKeyPar[7]+1 .AND.;
                   ( M_PosX()==aKeyPar[8]-2 .OR. M_PosX()==aKeyPar[8]-1 )
                   dbAct2Kbd("win")

              CASE Act == "mou"        .AND.;
                   M_PosY()>aKeyPar[3] .AND.;
                   M_PosX()>aKeyPar[4] .AND.;
                   M_PosY()<aKeyPar[5] .AND.;
                   M_PosX()<aKeyPar[6]
                   nNdx := M_PosY() -aKeyPar[3]

              CASE Act == "mou" .AND.;
                   M_PosY()==aKeyPar[3] .AND.;
                   ( M_PosX()==aKeyPar[6]-1 .OR. M_PosX()==aKeyPar[6] )
                   dbAct2Kbd("C08")

              CASE Act == "mou" .AND.;
                   LEFT(SAVESCREEN( M_PosY(), M_PosX(), M_PosY(), M_PosX() ),1)==""
                   dbAct2Kbd("C07")

              CASE Act == "mou"
              #endif

              OTHERWISE
                   FOR i = 1 to nMaxGet
                       cVarName  := NDX_GET[i][GET_NAME]
                       PRIVATE &cVarName
                       &cVarName := NDX_GET[i][GET_BUFFER]
                   NEXT
                   cKeyExp := NDX_PIC
                   cType   := "-" +TYPE(cKeyExp) +"-"
                   IF cType $ "-UI-C-D-L-M-N-"
                      uKeyVal := 0->(&cKeyExp)
                      IF cType=="-C-"
                         uKeyVal := RTRIM(uKeyVal)
                      ENDIF
                   ELSE
                      dbMsgErr( dfStdMsg(MSG_DDKEY03) +cKeyExp )
                      LOOP
                   ENDIF

                   // EX
                   //
                   // bEval == {|value,cindexexp|dfDecode(value)}
                   //
                   IF bEval!=NIL .AND. cType=="-C-"
                      uKeyVal := (cAlias)->(EVAL( bEval, uKeyVal, cKeyExp ))
                   ENDIF

                   lFound := (cAlias)->(DBSEEK(uKeyVal, .T.))
                   IF Act == "ret"
                      DO CASE
                         CASE EMPTY(uKeyVal)
                              (cAlias)->(DBGOTO(nRecno))

                         CASE (cAlias)->(&cKeyExp)!=uKeyVal .OR. (cAlias)->(EOF())
                              dbMsgErr( dfStdMsg(MSG_DDKEY09) +dfAny2Str(uKeyVal) +dfStdMsg(MSG_DDKEY10) )
                              IF dfSet( AI_IFNOKEYREPEATGET )
                                 LOOP
                              ENDIF
                              IF (cAlias)->(EOF())
                                 (cAlias)->(DBGOTO(nRecno))
                              ELSEIF dfSet( AI_EXACTKEYFOUND )
                                 lFound := .F.
                              ENDIF

                         OTHERWISE
                              // Ricerca record piu' vicino alla seek
                              WHILE (bFilter!=NIL .AND. !EVAL(bFilter)) .OR.;
                                    (bBreak !=NIL .AND.  EVAL(bBreak) )
                                 IF (cAlias)->(EOF())
                                    EXIT
                                 ELSE
                                    IF (cAlias)->(&(ORDKEY(INDEXORD())))=uKeyVal
                                       (cAlias)->(DBSKIP())
                                    ELSE
                                       (cAlias)->(DBGOTO(0))
                                    ENDIF
                                 ENDIF
                              ENDDO
                              IF (cAlias)->(EOF())
                                 (cAlias)->(DBGOTO(nRecno))
                              ENDIF
                      ENDCASE
                      IF dfSet( AI_GOTOWINAFTERRETURN )
                         Act := "win"
                      ENDIF
                   ENDIF

                   DO CASE
                      CASE Act = "C07" .and. !EMPTY(NDX_GET[nGet][GET_SIG]) //<----- Controllare
                           IF NDX_GET[nGet][GET_FILE]=="LT"
                              ddWit( NDX_GET[nGet][GET_LOOK]   ,;
                                     TAB_PRK                   ,;
                                     NDX_GET[nGet][GET_BUFFER] ,;
                                     dfSet( AI_TABMODIFY )      )
                              IF Act=="ret"
                                 NDX_GET[nGet][GET_BUFFER] :=;
                                    dbTabConv( SUBSTR(dbTabD->TabCode  ,;
                                                                    1  ,;
                            LEN(dfAny2Str(NDX_GET[nGet][GET_BUFFER]))) ,;
                                     VALTYPE(NDX_GET[nGet][GET_BUFFER]) )
                              ENDIF
                           ELSE
                              cFile := NDX_GET[nGet][GET_LOOK]
                              lOpen := .F.
                              IF !DFISSELECT( cFile )
                                 lOpen := ddUse(cFile)
                              ENDIF
                              (cFile)->(ddKey(nRow+2, nCol+2, 1))
                              IF Act=="ret"
                                 // Purtroppo per un baco non risolvibile in dBsee
                                 // I campi da ereditare sono scaricati Male sul DBDD
                                 // Pertanto l'unico modo di ereditare i campi in modo
                                 // corretto e' l'approssimazione

                                 // Sistemazione Trigger, che Š corretto nel caso di
                                 // lookup singoli, ma sbagliato in caso di lookup su piu' campi
                                 NDX_GET[nGet][GET_BUFFER] :=;
                                        (NDX_GET[nGet][GET_LOOK])->(&(NDX_GET[nGet][GET_ERE]))

                                 // Provo a sistemare gli altri per approssimazione
                                 // Questo giro Š necessario nel caso di lookup su piu'
                                 // campi
                                 FOR nPos := 1 TO LEN(NDX_GET)
                                     nFieldPos := (NDX_GET[nGet][GET_LOOK])->(FIELDPOS(NDX_GET[nPos][GET_NAME]))
                                     IF nFieldPos > 0
                                        NDX_GET[nPos][GET_BUFFER] :=;
                                           (NDX_GET[nGet][GET_LOOK])->(FIELDGET( nFieldPos ))
                                     ENDIF
                                 NEXT
                              ENDIF
                              IF lOpen
                                 CLOSE (cFile)
                              ENDIF
                           ENDIF
                           Act := "rep"

                      CASE Act = "wis"  //<----- Controllare
                           (cAlias)->(DBGOTOP())
                           cVarName   := NDX_GET[nGet][GET_NAME]
                           IF !TYPE(cVarName)$"CN"
                              dbMsgErr( dfStdMsg(MSG_DDKEY04) )
                              LOOP
                           ENDIF

                           cFlt := NIL
                           IF !EMPTY(0->(&cVarName))
                              IF TYPE(cVarName)="C"
                                 IF !EMPTY( ALLTRIM(NDX_GET[nGet][GET_BUFFER]) )
                                    IF dfAsDriver( (cAlias)->(RDDNAME()) )
                                       cFlt := "'" +ALLTRIM(NDX_GET[nGet][GET_BUFFER]) +"'$" +cVarName
                                    ELSE
                                       cFlt := ALLTRIM(NDX_GET[nGet][GET_BUFFER])
                                       cFlt := "AT([" +UPPER(cFlt) +"]," +"UPPER(" +ALLTRIM(cAlias) +"->" +cVarName +"))#0"
                                    ENDIF
                                 ENDIF
                              ELSE
                                 cFlt := dfAny2Str(NDX_GET[nGet][GET_BUFFER])
                                 cFlt := ALLTRIM(cAlias) +"->" +cVarName +"==" +cFlt
                              ENDIF
                           ENDIF
                           (cAlias)->(ddKeyWin( nOrd, bKey, bFilter, bBreak, cFlt, cRealAlias ))

                      CASE Act = "C08"
                           cFlt:=(cAlias)->(ddQry())
                           IF !EMPTY(cFlt)
                              (cAlias)->(ddKeyWin( nOrd, bKey, bFilter, bBreak, cFlt, cRealAlias ))
                           ENDIF
                           IF Act=="esc"; Act:="rep"; ENDIF

                      CASE Act $ "win-S07-C07-S08"
                           (cAlias)->(ddKeyWin( nOrd, bKey, bFilter, bBreak, NIL, cRealAlias ))
                   ENDCASE

                   IF Act#"rep"
                      cOpe := "eop"
                   ENDIF

           ENDCASE

      CASE cOpe = "eop"
           M_CUROFF()
           RESTSCREEN(0,0,MAXROW(), MAXCOL(), cScr)
           M_CURON()
           EXIT
   ENDCASE
ENDDO
tbDelObj()

IF Act=="esc" .OR. (cAlias)->(EOF())  // In caso di abbandono o EOF
   lRet := .F.
   (cAlias)->(DBGOTO(nRecno))         // Riposiziono il file
ELSE
   IF dfSet( AI_EXACTKEYFOUND )
      lRet := lFound // Ritorna .T. se trova chiave precisa
   ELSE
      /////////////////////////////////////////////////////////////////////////////////////////////////////////
      //suggerimento di un cliente:Inserito questo codice in quanto il controllo non Š necessario
      // Mantis 2181
      //* norissoftware
      //* lRet := nRecno#(cAlias)->(RECNO()) // Cambiando record ho avuto un      
      lRet := .T.
      /////////////////////////////////////////////////////////////////////////////////////////////////////////
   ENDIF
ENDIF                                 // posizionamento

#ifdef __XPP__
   IF lChgPage
      dfSet("XbaseAutoChangePage", "YES")
   ENDIF
#endif

RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION ddKeyWin( nOrd       ,; // Finestra sul file e indice corrente
                           bKey       ,;
                           bFilter    ,;
                           bBreak     ,;
                           cNewFilter ,;
                           cRealAlias  )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cKey, nInd := INDEXORD(), nMaxInd, aInd := {}, cFile, nRec
LOCAL cAlias := ALIAS(), lCond, nEvery, nViewIndex, nRealIndex
LOCAL lKey := (bKey!=NIL .AND. EVAL(bKey)!=NIL) // Ho un filtro
LOCAL lREt := .T.

#ifdef __XPP__
LOCAL cPath := ""
#endif

//## In caso di indici filtrati bisogna prendere anche il filtro dell'indice
//   Per creare il sottoindice

// Se ho un filtro e NON ho disabilitato il sotto indice
// abilito la creazione dell'indice ON THE FLY
lCond := (cNewFilter!=NIL .AND. !dfSet( AI_DISABLEKEYINDEX ))

// Non creo l'indice su File AS/400
lCond := lCond                                  .AND.; // Se devo fare l'indice
         !dfAsDriver( RDDNAME() )               .AND.; // NON e' AS
         !(ALLTRIM(UPPER(RDDNAME()))=="DBFNDX")        // NON e' DBFNDX

#ifdef __XPP__
// Creo l'indice solo sui DBFNTX
//lCond := lCond                                  .AND.; // Se devo fare l'indice
//         ALLTRIM(UPPER(RDDNAME()))=="DBFNTX"           // E' DBFCDX
#endif

IF lCond

  #ifdef __XPP__
   // Simone 25/3/03 GERR 3723
   // Se uso ADS creo il file temporaneo nella cartella
   // che contiene il DBF
   IF dfAxsIsLoaded( ALIAS() )
      cFile := dfFNameSplit( DbInfo( DBO_FILENAME ) )
      cFile := dfNameUnique(cFile[1]+cFile[2], dfIndExt(RDDNAME()))
      IF ! EMPTY(cFile)
         // Simone 23/8/04 GERR 4048
         // con ADS e indici CDX ho errore di runtime su creazione indice
         // se il file esiste gia', quindi lo cancello!
         FERASE(cFile)
      ENDIF
   ELSE
      cFile := dfNameUnique(,dfIndExt(RDDNAME()))
   ENDIF
  #else
   cFile := dfNameUnique(,dfIndExt(RDDNAME()))
  #endif
  //Mantis 1779
  ////////////////////////////////////////////////
  // Luca 26/08/2009
  //Inserita soluzione per problema crash utilizzo indici temporanei comix CDX.
  ////////////////////////////////////////////////
  IF !EMPTY(cFile) .AND. ;
     File(cFile)
     FERASE(cFile)
  ENDIF 
  ////////////////////////////////////////////////
  ////////////////////////////////////////////////
   IF lKey
      cKey  := ORDKEY(nOrd)
   ELSE
      cKey  := ORDKEY(nInd)
   ENDIF
 #ifdef __XPP__
   aInd  := dfOrdList_XPP()
 #else
   aInd  := dfOrdList()
 #endif
   nEvery := MAX(RECCOUNT()/MAXCOL()-1,1)

   #ifdef __XPP__
      // 13/12/2002 Simone
      // Tolto perche con nomi di file lunghi da problemi.
      // Š stata aggiunta la dfOrdList_XPP()

      // 13:49:32 marted 04 luglio 2000
      // Aggiorno l'array degli indici mettendoci il path
      // In clipper FORSE non serve, ma devo controllare
      //ddFilePos( dfAlias2Name( ALIAS() ) )
      //cPath := ddFilePath()
      //
      //AEVAL( aInd, {|cSub,nPos| aInd[nPos] := cPath+cSub } )
   #endif

   #ifdef __XPP__
      _dfMakeIndInit()
   #endif

   dfWorkBar(.F.,RECCOUNT())


   // Questa piccola ottimizzazione in caso di Key e Break puo'
   // migliorare anche fino a 100 volte il tempo di elaborazione
   IF lKey .AND. !dfSet( AI_DISABLEKEYOPT )
      DBSETORDER(nOrd)
      DBSEEK( EVAL(bKey) )
      #ifdef __XPP__
      _dfMakeIndCreate(cFile,RECCOUNT())




//         IF UPPER(ALLTRIM(cRdd)) $ "DBFCDX,COMIX"
//           bExp := &( "{|| _dfMakeIndPB(), STRTRAN("+cExp+",'"+'"'+ "',' ' ) }" )
//         ELSE
//           bExp := &( "{|| _dfMakeIndPB()," + cExp + "}" )
//         ENDIF

      // Simone 09/12/02 GERR 3579
      // L'indice temporaneo non veniva usato in Xbase
      lRet := dfMakeIndSub( RDDNAME(),;
                            NIL,;
                            1,;
                            RECNO(),;
                            .T.,;
                            cFile,;
                            dfFindName( cFile ),;
                            cKey,;
                            &( "{|| _dfMakeIndPB(), "+cKey+" }" ),;
                            .F., ;
                            {||!EVAL(bBreak)}, ;
                            DFCOMPILE(cNewFilter), ;
                            cNewFilter, ;
                            NIL, NIL, NIL, ; 
                            .T. )  // simone 16/12/09 fix per creazione indici temp con diz. dati ADS 
      #else
      INDEX ON &cKey TO (cFile) FOR &cNewFilter WHILE !EVAL(bBreak) EVAL dfWorkBar(.T.) EVERY nEvery
      #endif
   ELSE
      ORDLISTCLEAR()
      #ifdef __XPP__
      _dfMakeIndCreate(cFile,RECCOUNT())

      // Simone 09/12/02 GERR 3579
      // L'indice temporaneo non veniva usato in Xbase
      lRet :=  dfMakeIndSub( RDDNAME(),;
                             NIL,;
                             1,;
                             RECNO(),;
                             .T.,;
                             cFile,;
                             dfFindName( cFile ),;
                             cKey,;
                             &( "{|| _dfMakeIndPB(), "+cKey+" }" ),;
                             .F. , ;
                             NIL, ;
                             DFCOMPILE(cNewFilter), ;
                             cNewFilter, ;
                             NIL, NIL, NIL, ; 
                             .T. )  // simone 16/12/09 fix per creazione indici temp con diz. dati ADS 

      #else
      INDEX ON &cKey TO (cFile) FOR &cNewFilter                     EVAL dfWorkBar(.T.) EVERY nEvery
      #endif
   ENDIF

   ////////////////////////////
   //SE CI Š STATO UN ERRRORE IN CREAZIONE INDICE ALLORA Esco dalla procedura 
   ////////////////////////////
   IF !lRet 
      RETURN lRet
   ENDIF 
   ////////////////////////////


   ORDLISTCLEAR()

   dfWorkBar(.F.)

   #ifdef __XPP__
      _dfMakeIndDestroy()
   #endif

   IF dfRddCanCompound( RDDNAME() )
      // 13/12/2002 SIMONE GERR 3582
      IF cRealAlias == NIL
         ORDLISTADD( aInd[1] )
      ELSE
         ORDLISTADD( SUBSTR( aInd[1], 1, RAT( "\", aInd[1] ) ) +ALLTRIM(cRealAlias) )
      ENDIF
   ELSE
      // Simone 26/10/2009 FIX per DIZIONARIO DATI ADS
      // apre "n" indici
      //AEVAL( aInd, {|cInd|ORDLISTADD(cInd)} )
      dfIndexesSet(aInd)
   ENDIF

   ORDLISTADD( cFile )
   ORDSETFOCUS(LEN(aInd)+1)
   DBGOTOP()

   ////////////////////////////////////////////////
   //Luca+Simone 19/01/2011
   //Inserito perchè si è notato con ADS 9.1 che se l'indice filtrato non aveva record allora 
   //la tabella rimaneva a BOF() = .T.  senza impostare il EOF() == .T.  .
   //La funzione DBGOTO_XPP(-1) forza la tabella ad andare a a EOF()
   ////////////////////////////////////////////////
   IF BOF() .AND. !EOF()
      DBGOTO_XPP(-1)
   ENDIF 
   ////////////////////////////////////////////////
   ////////////////////////////////////////////////



ELSE
   IF lKey
      DBSETORDER( nOrd )
   ENDIF
ENDIF

#ifndef __XPP__
IF dfAsDriver( RDDNAME() ) .AND.;
   !EMPTY(cNewFilter)
   //Win400 adds a new feature to filters, the skill of includeude a virtual
   //ordering to the database file  and the filter expression altogether; the
   //ordering expression is defined adding next to the filter expression the
   //clause ‘.AND. ORDERBY(FieldList)’ where FieldList is the list of fields that
   //define the ordering criteria all of them separated by ‘,’ (comma). The order
   //yet generated is activated as the order 0 not affecting the behavior of all
   //the other active indexes, in this way it is possible to search for records
   //using the normal method (SEEK command or DBSEEK() function

   cNewFilter := _dfASFilte( cNewFilter )

   dbMsgOn( dfStdMsg(MSG_DDKEY12) )
   DBSETFILTER( DFCOMPILE(cNewFilter), cNewFilter )
   DBGOTOP()
   dbMsgOff()
   cNewFilter := ".T."
ENDIF
#endif

// Se vuoto o NIL assogno qualcosa di valido
IF EMPTY cNewFilter ASSIGN ".T."
cNewFilter := DFCOMPILE( cNewFilter )

// Se ho attiva una KEY NON posso spostare l'indice
IF lKey
   nViewIndex := nOrd
ELSE
   nViewIndex := nInd
ENDIF

IF lCond
   nRealIndex := INDEXORD()
ELSE
   nRealIndex := NIL
ENDIF

DO CASE
   CASE bFilter==NIL
        IF bBreak!=NIL
           ddWin( nViewIndex, bKey, cNewFilter ,;
                              {||EVAL(bBreak ) .OR.  dfChkNext()},,nRealIndex)
        ELSE
           ddWin( nViewIndex, bKey, cNewFilter, {||dfChkNext()},,nRealIndex)
        ENDIF

   CASE bBreak ==NIL
        ddWin( nViewIndex, bKey, {||EVAL(bFilter) .AND. EVAL(cNewFilter)} ,;
                           {||dfChkNext()},,nRealIndex)
   OTHERWISE
        ddWin( nViewIndex, bKey, {||EVAL(bFilter) .AND. EVAL(cNewFilter)} ,;
                           {||EVAL(bBreak ) .OR. dfChkNext()},,nRealIndex)
ENDCASE

DBSELECTAREA( cAlias )
IF lCond
   nRec := RECNO()
   ORDLISTCLEAR()
   IF dfRddCanCompound( RDDNAME() )
      // 13/12/2002 SIMONE GERR 3582
      IF cRealAlias == NIL
         ORDLISTADD( aInd[1] )
      ELSE
         ORDLISTADD( SUBSTR( aInd[1], 1, RAT( "\", aInd[1] ) ) +ALLTRIM(cRealAlias) )
      ENDIF
   ELSE
      // Simone 26/10/2009 FIX per DIZIONARIO DATI ADS
      // apre "n" indici
      //AEVAL( aInd, {|cInd|ORDLISTADD(cInd)} )
      dfIndexesSet(aInd)
   ENDIF
   FERASE( cFile )
   SET ORDER TO nInd
   DBGOTO( nRec )
ENDIF

IF dfAsDriver( RDDNAME() )
   SET FILTER TO
ENDIF

IF M->Act=="esc"; M->Act:="rep"; ENDIF

RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfChkNext()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .F.
IF NEXTKEY()!=0
   IF NEXTKEY()==K_ESC
      lRet := .T.
   ENDIF
   dfClearType() //FW
ENDIF
RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION LoadArr(cAlias, nRow, nCol, aKey, aKeyPar, lLockIndex, nOrd )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nRec                             // General record number
LOCAL cName                            // General field name
LOCAL cSig                             // Get lookup sign
LOCAL i                                // general for/next index
LOCAL nArrLen                          // lenght of aKey
LOCAL uDmm                             // unknown type variable for get value
LOCAL cLook
LOCAL cFile
LOCAL cEre, nMaxLen
LOCAL nRemove := 0
LOCAL cToken

ASIZE(aKey, 0)

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³Load Main Array³
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbdd->(ORDSETFOCUS(1))                       // posiziono dbdd
dbdd->(DBSEEK( "NDX"+cAlias))
WHILE "NDX"+cAlias == UPPER(dbDD->rectyp+dbDD->file_name) .AND. ;
      !dbdd->(EOF())
   IF UPPER(dbDD->Field_type)#"S" // if not Search Key
      dbdd->(DBSKIP())
      LOOP
   ENDIF

   IF lLockIndex
      IF DBDD->NdxIncN!=nOrd
         nRemove++
         dbdd->(DBSKIP())
         LOOP
      ENDIF
   ENDIF

                 // Riformatto per WIN400
   AADD( aKey, { VAL(STR(DBDD->NdxIncN))  ,; // Numero idx
                 {}                       ,; // Campi
                 dbdd->(RECNO())          ,; // Recno
                 ddIndexExp()             ,; // Picture
                 ALLTRIM(DBDD->FIELD_DES) ,; // Des
                 DBDD->FIELD_DEC          ,; // Decimal
                 DBDD->FIELD_LEN          }) // Len

   dbdd->(DBSKIP())
ENDDO

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³Load GET parameters³
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nArrLen := LEN(aKey)
FOR i := 1 TO nArrLen                            // per ogni key
   nMaxLen := 0
   dbdd->(ORDSETFOCUS(1))
   dbdd->(DBSEEK("KEY" +cAlias +STR( aKey[i][1],3)))   // Valorizzo var

   WHILE UPPER(dBdd->RecTyp+dBdd->file_name)+str(dBdd->NdxIncN,3) = ;
               "KEY"       +cAlias          +str(   aKey[i][1],3)   ;
               .AND. !(dbdd->(EOF()))
      uDmm := NIL
      DO CASE
         CASE DBDD->FIELD_TYPE = [M]
              uDmm := " "

         CASE DBDD->FIELD_TYPE = [C]
              uDmm := SPACE( DBDD->FIELD_LEN )

         CASE DBDD->FIELD_TYPE = [D]
              uDmm := CTOD("  /  /  ")

         CASE DBDD->FIELD_TYPE = [L]
              uDmm := .F.

         CASE DBDD->FIELD_TYPE = [N]
              uDmm := 0

      ENDCASE

      // test se esiste un file di decodifica
      // e se il file di decodifica e' diverso
      // dal file corrente

      nRec  := dbdd->(RECNO())
      cName := UPPER(ALLTRIM(DBDD->FIELD_NAME))

      dbdd->(ORDSETFOCUS(2))
      dbdd->(DBSEEK( "FIE" +cAlias +cName) )

      cSig  := " "
      cLook := ""
      cEre  := ""
      cFile := ddFldLOOK()
      IF cFile $ "LF/LT" .AND. ddFldFLLOOK() # TRIM(cAlias)
         cLook := ddFldFLLOOK()
         cEre  := ddFldFLInh()
         #ifdef __XPP__
         cSig  := ">"
         #else
         cSig  := ""
         #endif
      ENDIF

      dbdd->(ORDSETFOCUS(1))
      dbdd->(DBGOTO(nRec))

      nMaxLen := MAX( nMaxLen, LEN(ALLTRIM(DBDD->FIELD_DES))+ LEN(cSig) )

      cToken := CHR(177) // ±
      #ifdef __XPP__
      // Solo per Xbase++
      IF !EMPTY(DBDD->FIELD_PICO) .AND. !(cToken$DBDD->FIELD_PICO)
         cToken := CHR(221) // Con ADS il 177 Š modificato in 221
      ENDIF
      #endif

      IF !EMPTY(ddGetSlot(DBDD->FIELD_PICO,cToken,1))
         uDmm := (ALIAS())->(&(ddGetSlot(DBDD->FIELD_PICO,cToken,1)))
      ENDIF

      AADD( aKey[i][2], { nRec                     ,; // GET_REC    1
                          cName                    ,; // GET_NAME   2
                          DBDD->FIELD_TYPE         ,; // GET_TYPE   3
                          uDmm                     ,; // GET_BUFFER 4
                          ALLTRIM(DBDD->FIELD_DES) ,; // GET_DES    5
                          DBDD->FIELD_PICO         ,; // GET_PICO   6
                          ALLTRIM(DBDD->FIELD_PIC) ,; // GET_PIC    7
                          DBDD->FIELD_LEN          ,; // GET_LEN    8
                          DBDD->SLOT               ,; // GET_SLOT   9
                          cSig                     ,; // GET_SIG   10
                          cFile                    ,; // GET_FILE  11
                          cLook                    ,; // GET_LOOK  12
                          cEre                     }) // GET_ERE   13
      dbdd->(DBSKIP())
   ENDDO
   AEVAL( aKey[i][2], {|aSub|aSub[5]:=PAD(aSub[5],nMaxLen) })
   aKey[i][7] := 0
   AEVAL( aKey[i][2], {|aSub|aKey[i][7]:=;
                         MAX(aKey[i][7],LEN(dfAny2Str(aSub[4],aSub[7]))) })
   aKey[i][7] += nMaxLen
NEXT
* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
* ³Creazione array operativa³
* ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*
dbdd->(ORDSETFOCUS(1))
dBdd->(dbSeek("DBF"+cAlias))
*
//aKeyPar[1] := MAX( dBdd->FIELD_LEN, LEN( TRIM(dBdd->Field_des) )+3)
aKeyPar[1] := dBdd->FIELD_LEN          // Descrizione massima dei nomi degli indici

aKeyPar[2] := dBdd->File_nCnt -nRemove // Numero di indici TOGLIERE (copia in 12)

aKeyPar[3] := nRow                        // Ä¿
aKeyPar[4] := nCol                        //  ³ Coordinate video
aKeyPar[5] := aKeyPar[3] + aKeyPar[2] + 1 //  ³ elenco indici
aKeyPar[6] := aKeyPar[4] + aKeyPar[1] + 1 // ÄÙ

aKeyPar[7] := 0                        // Ä¿
aKeyPar[8] := 0                        //  ³ Coordinate video
aKeyPar[9] := 0                        //  ³ elenco chiavi
aKeyPar[10]:= 0                        // ÄÙ

aKeyPar[11] := NIL                     // Variabile di SaveScreen TOGLIERE
aKeyPar[12] := aKeyPar[2]              // numero indici
aKeyPar[13] := VAL(ddGetSlot(dBdd->Slot,"±±",1)) // massima lunghezza des. indici

aKeyPar[14] := 0                       // Lunghezza get chiave TOGLIERE
aKeyPar[15] := 0                       // Numero chiavi
aKeyPar[16] := 0                       // Massima lunghezza descrizione chiavi

aKeyPar[17] := NIL                     // Finestra su indice corrente
RETURN .T.

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE ddKeyHlp() // Help sulle chiavi
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aOpt := {}

ADDKEY "win" TO aOpt MESSAGE dfStdMsg(MSG_DDKEY05)
ADDKEY "wis" TO aOpt MESSAGE dfStdMsg(MSG_DDKEY06)
ADDKEY "C07" TO aOpt MESSAGE dfStdMsg(MSG_DDKEY07)
ADDKEY "C08" TO aOpt MESSAGE dfStdMsg(MSG_DDKEY08)

dfUsrHelp( aOpt, DE_STATE_INK )

RETURN

#ifdef __XPP__

   // SD 8/1/03 GERR 3607 aggiunto bDCC
   STATIC FUNCTION _dcc(nNdx, _mKey)
   IF _mKey == ""
       nNdx := tbPgActual( tbGetObj() )
      _mKey:="ret"
   ENDIF
   RETURN .T.

   // Aggiunge shortcut di tastiera, icone nella toolbar e menu
   STATIC FUNCTION AddKeys(o, nStyle, nNdx, _mKey)
       LOCAL aMnu  := o:W_MENUARRAY
       LOCAL nMenu := IIF(nStyle == AI_DDKEYMODE_STD, MN_SECRET, MN_ON)
       LOCAL oCtrl, nInd, oXbp

       // Aggiunge icone nella toolbar
       IF LEN(o:W_PAGELABELS) > 1
          o:aToolBar := { ;
               { "win", {TOOLBAR_FIND     , TOOLBAR_FIND     }, NIL }, ;
               { "wis", {TOOLBAR_FIND_ALPHA , TOOLBAR_FIND_ALPHA }, NIL }, ;
               { "C07", {TOOLBAR_FIND_WIN , TOOLBAR_FIND_WIN }, NIL }, ;
               { "C08", {TOOLBAR_FIND_CONTEXT,TOOLBAR_FIND_CONTEXT}, NIL }, ;
               { "*--", NIL }, ;              
               { "Cst", {TOOLBAR_PG_PREV  , TOOLBAR_PG_PREV  }, NIL }, ;
               { "Ctb", {TOOLBAR_PG_NEXT  , TOOLBAR_PG_NEXT  }, NIL }, ;
               { "*--", NIL }, ;
               { "wri", {TOOLBAR_WRITE_H  , TOOLBAR_WRITE_H  }, NIL }, ;
               { "esc", {TOOLBAR_ESC_H    , TOOLBAR_ESC_H    }, NIL }, ;
               { "*--", NIL }, ;
               { "hlp", {TOOLBAR_HELP_H   , TOOLBAR_HELP_H   }, NIL }, ;
               { "ush", {TOOLBAR_KEYHELP_H, TOOLBAR_KEYHELP_H}, NIL } }
       ELSE
          o:aToolBar := { ;
               { "win", {TOOLBAR_FIND     , TOOLBAR_FIND     }, NIL }, ;
               { "wis", {TOOLBAR_FIND_ALPHA , TOOLBAR_FIND_ALPHA }, NIL }, ;
               { "C07", {TOOLBAR_FIND_WIN , TOOLBAR_FIND_WIN }, NIL }, ;
               { "C08", {TOOLBAR_FIND_CONTEXT,TOOLBAR_FIND_CONTEXT}, NIL }, ;
               { "*--", NIL }, ;
               { "wri", {TOOLBAR_WRITE_H  , TOOLBAR_WRITE_H  }, NIL }, ;
               { "esc", {TOOLBAR_ESC_H    , TOOLBAR_ESC_H    }, NIL }, ;
               { "*--", NIL }, ;
               { "hlp", {TOOLBAR_HELP_H   , TOOLBAR_HELP_H   }, NIL }, ;
               { "ush", {TOOLBAR_KEYHELP_H, TOOLBAR_KEYHELP_H}, NIL } }
       ENDIF

       // Aggiunge il menu, nascosto se standard o 
       // visibile se lo stile Š Enhanced
       ATTACH "1" TO MENU aMnu AS MN_LABEL    ; // ACTMNU.TMP
               BLOCK    {||nMenu }  ; // Condizione di stato di attivazione
               PROMPT   dfStdMsg(MSG_DDWIT04)                           ; // Etichetta
               EXECUTE  {||dbMsgErr( dfStdMsg( MSG_ADDMENUUND ) )}  ; // Funzione
               ID "0015000045"

       ATTACH "11" TO MENU aMnu AS MN_LABEL   ; // ACTMNU.TMP
               BLOCK    {||nMenu}  ; // Condizione di stato di attivazione
               PROMPT   dfStdMsg(MSG_DDKEY05)      ; // Etichetta
               SHORTCUT "win"                             ; // Shortcut
               EXECUTE  {||nNdx := tbPgActual( tbGetObj() ),_mKey:="win",dbAct2Kbd("wri")}  ; // Funzione
               MESSAGE  dfStdMsg(MSG_DDKEY05)        ; // Messaggio utente
               ID "0015000046"

       ATTACH "12" TO MENU aMnu AS MN_LABEL   ; // ACTMNU.TMP
               BLOCK    {||nMenu}  ; // Condizione di stato di attivazione
               PROMPT   dfStdMsg(MSG_DDKEY06)      ; // Etichetta
               SHORTCUT "wis"                             ; // Shortcut
               EXECUTE  {||nNdx := tbPgActual( tbGetObj() ),_mKey:="wis",dbAct2Kbd("wri")}  ; // Funzione
               MESSAGE  dfStdMsg(MSG_DDKEY06)        ; // Messaggio utente
               ID "0015000047"

       ATTACH "13" TO MENU aMnu AS MN_LABEL   ; // ACTMNU.TMP
               BLOCK    {||nMenu}  ; // Condizione di stato di attivazione
               PROMPT   dfStdMsg(MSG_DDKEY07)      ; // Etichetta
               SHORTCUT "C07"                             ; // Shortcut
               EXECUTE  {||nNdx := tbPgActual( tbGetObj() ),_mKey:="C07",dbAct2Kbd("wri")}  ; // Funzione
               MESSAGE  dfStdMsg(MSG_DDKEY07)        ; // Messaggio utente
               ID "0015000048"

       ATTACH "14" TO MENU aMnu AS MN_LABEL   ; // ACTMNU.TMP
               BLOCK    {||nMenu}  ; // Condizione di stato di attivazione
               PROMPT   dfStdMsg(MSG_DDKEY08)      ; // Etichetta
               SHORTCUT "C08"                             ; // Shortcut
               EXECUTE  {||nNdx := tbPgActual( tbGetObj() ),_mKey:="C08",dbAct2Kbd("wri")}  ; // Funzione
               MESSAGE  dfStdMsg(MSG_DDKEY08)        ; // Messaggio utente
               ID "0015000049"

   RETURN NIL

   // Aggiunge i pulsanti
   STATIC FUNCTION _addButtons(aIndex, nMax)
      LOCAL cDex

      // Pulsante 1
      // ----------
      cDex := dbAct2Mne("win")
      IF ! EMPTY(cDex)
         cDex := " ("+cDex+")"
      ENDIF
      cDex := dfStdMsg(MSG_DDKEY05)+cDex
      nMax++
      ATTACH "__WRI" TO aIndex GET AS PUSHBUTTON cDex ;
                           AT  nMax, 1, nMax+2, 1+LEN(cDex)   ; // Coordinate
                           PAGE 0                        ; // Pagina 0
                           FUNCTION {|| dbAct2Kbd("win") }   // Funzione di controllo
                           //FUNCTION {||nNdx := tbPgActual( tbGetObj() ),_mKey:="win",dbAct2Kbd("wri")}   // Funzione di controllo
 
      // Pulsante 2
      // ----------
      cDex := dbAct2Mne("wis")
      IF ! EMPTY(cDex)
         cDex := " ("+cDex+")"
      ENDIF
      cDex := dfStdMsg(MSG_DDKEY06)+cDex
      nMax++
      ATTACH "__WRI" TO aIndex GET AS PUSHBUTTON cDex ;
                          AT  nMax, 1, nMax+2, 1+LEN(cDex)   ; // Coordinate
                          PAGE 0                        ; // Pagina 0
                          FUNCTION {||dbAct2Kbd("wis")}   // Funzione di controllo
                          //FUNCTION {||nNdx := tbPgActual( tbGetObj() ),_mKey:="wis",dbAct2Kbd("wri")}   // Funzione di controllo

      // Pulsante 3
      // ----------
      cDex := dbAct2Mne("C07")
      IF ! EMPTY(cDex)
         cDex := " ("+cDex+")"
      ENDIF
      cDex := dfStdMsg(MSG_DDKEY07)+cDex
      nMax++
      ATTACH "__WRI" TO aIndex GET AS PUSHBUTTON cDex ;
                          AT  nMax, 1, nMax+2, 1+LEN(cDex)   ; // Coordinate
                          PAGE 0                        ; // Pagina 0
                          FUNCTION {||dbAct2Kbd("C07")}   // Funzione di controllo
                          //FUNCTION {||nNdx := tbPgActual( tbGetObj() ),_mKey:="C07",dbAct2Kbd("wri")}   // Funzione di controllo
 
      // Pulsante 4
      // ----------
      cDex := dbAct2Mne("C08")
      IF ! EMPTY(cDex)
         cDex := " ("+cDex+")"
      ENDIF
      cDex := dfStdMsg(MSG_DDKEY08)+cDex
      nMax++
      ATTACH "__WRI" TO aIndex GET AS PUSHBUTTON cDex ;
                          AT  nMax, 1, nMax+2, 1+LEN(cDex)   ; // Coordinate
                          PAGE 0                        ; // Pagina 0
                          FUNCTION {||dbAct2Kbd("C08")}   // Funzione di controllo
                          //FUNCTION {||nNdx := tbPgActual( tbGetObj() ),_mKey:="C08",dbAct2Kbd("wri")}   // Funzione di controllo
   RETURN NIL

   STATIC FUNCTION _chkGet(ab, lC07)
      IF ab == FORM_POSTGET
         IF M->ACT == "Ada"
            dbAct2Kbd("win")
         ELSEIF M->ACT == "Cda"
            dfMenuPopUp(S2FormCurr(), dfGetMousePos(S2FormCurr()), PopUpMenu(lC07))
            //dbAct2Kbd("wis")
         ENDIF
      ENDIF
   RETURN .T.

   STATIC FUNCTION PopupMenu(lC07)
       LOCAL aMnu := {}
       LOCAL nMenu := MN_ON
       ATTACH "1" TO MENU aMnu AS MN_LABEL   ; // ACTMNU.TMP
               BLOCK    {||nMenu}  ; // Condizione di stato di attivazione
               PROMPT   dfStdMsg(MSG_DDKEY05)      ; // Etichetta
               SHORTCUT "win"                             ; // Shortcut
               EXECUTE  {||dbAct2Kbd("win")}  ; // Funzione
               MESSAGE  dfStdMsg(MSG_DDKEY05)        ; // Messaggio utente
               ID "0015000046"

       ATTACH "2" TO MENU aMnu AS MN_LABEL   ; // ACTMNU.TMP
               BLOCK    {||nMenu}  ; // Condizione di stato di attivazione
               PROMPT   dfStdMsg(MSG_DDKEY06)      ; // Etichetta
               SHORTCUT "wis"                             ; // Shortcut
               EXECUTE  {||dbAct2Kbd("wis")}  ; // Funzione
               MESSAGE  dfStdMsg(MSG_DDKEY06)        ; // Messaggio utente
               ID "0015000047"
       IF lC07
          ATTACH "3" TO MENU aMnu AS MN_LABEL   ; // ACTMNU.TMP
                  BLOCK    {||nMenu}  ; // Condizione di stato di attivazione
                  PROMPT   dfStdMsg(MSG_DDKEY07)      ; // Etichetta
                  SHORTCUT "C07"                             ; // Shortcut
                  EXECUTE  {||dbAct2Kbd("C07")}  ; // Funzione
                  MESSAGE  dfStdMsg(MSG_DDKEY07)        ; // Messaggio utente
                  ID "0015000048"
       ENDIF
       ATTACH "4" TO MENU aMnu AS MN_LABEL   ; // ACTMNU.TMP
               BLOCK    {||nMenu}  ; // Condizione di stato di attivazione
               PROMPT   dfStdMsg(MSG_DDKEY08)      ; // Etichetta
               SHORTCUT "C08"                             ; // Shortcut
               EXECUTE  {||dbAct2Kbd("C08")}  ; // Funzione
               MESSAGE  dfStdMsg(MSG_DDKEY08)        ; // Messaggio utente
               ID "0015000049"
   RETURN aMnu

#endif
