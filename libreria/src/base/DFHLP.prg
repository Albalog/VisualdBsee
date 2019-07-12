//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per HELP
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"
#INCLUDE "dfMove.ch"
#INCLUDE "dfSet.ch"
#INCLUDE "dfWin.ch"
#INCLUDE "dfMsg.ch"
#INCLUDE "dfStd.ch"
#INCLUDE "dfMenu.ch"
#INCLUDE "dfCtrl.ch"
#INCLUDE "dfNet.ch"

#ifdef __XPP__
   // simone 5/11/04 per correzione problema DBGOTO(0)
   // vedi DBGOTO_XPP
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif

#define HLP_BUT_ROW      1
#define HLP_BUT_COL      2
#define HLP_BUT_STRING   3

#define HLP_CTRL_MENU    1
#define HLP_CTRL_PRE     2
***#define HLP_CTRL_FIND    3

#ifndef __XPP__
FUNCTION dfHlp(cForm, cId)
   _dfHlp(cForm, cId)
RETURN NIL
#endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE _dfHlp( EnvId, SubId ) // Help 4.0
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC nHelp := 0, aColor := NIL
MEMVAR __RealTime
LOCAL aPos := {}   // Nell'array delle posizioni e' memorizzato il RECNO+TIPO
LOCAL oTbr, nActual := 1, aBut, bRealTime, aMenu, cCho, cKey, cPos, oCol, aWinPos
LOCAL nTop    := 0
LOCAL nLeft   := 0
LOCAL nBottom := MAXROW()-1
LOCAL nRight  := MAXCOL(), cMsg, aCTRL, nRec, nRow, cLine, lDel

#ifdef __XPP__
LOCAL cFont
#endif

DEFAULT aColor TO dfColor( "Help" )

DEFAULT EnvId TO MEMVAR->EnvID
DEFAULT SubId TO MEMVAR->SubID

EnvId := UPPER(PADR(EnvId,10)) // Normalizzo EnvId
SubId := UPPER(PADR(SubId,10)) // Normalizzo SubId

dfPushArea()
nHelp++
IF !dbCfgOpen( "dbHlp" ) .OR. ; // Se Non riesco ad aprire l'help
   nHelp>1                      // o se sono in ricorsione
   nHelp--
   dfPopArea()
   RETURN
ENDIF

dfPushCursor()
tbAddObj()
SET CURSOR OFF
dbScrSav( "dfHlp" )
IF TYPE( "__RealTime" ) # "U"
   bRealTime  := __RealTime
   __RealTime := NIL
ENDIF

#ifdef __XPP__
oTbr:=tbBrwNew( nTop+5, nLeft+1, nBottom-1, nRight-1, W_OBJ_BRW )
oTbr:W_MENUHIDDEN := .T.

oTbr:showToolBar     := .F.
oTbr:showMessageArea := .F.

cFont := dfSet("XbaseArrWinFont")
IF !EMPTY(cFont)
   oTbr:setFontCompoundName(dfFontCompoundNameNormalize(cFont))
ENDIF

#else
oTbr:=tbBrwNew( nTop+5, nLeft+1, nBottom-1, nRight-1, W_OBJ_BROWSEBOX )
#endif
oTbr:W_MOUSEMETHOD := W_MM_EDIT

#ifdef __XPP__
ATTACH COLUMN "HELP" TO oTbr                               ; // ATTCOL.TMP
                       BLOCK     {|| IF(LEFT(dbHlp->TxtLine,1)==CHR(255), SUBSTR(dbHlp->TxtLine,2), dbHlp->TxtLine) }       ;
                       PROMPT ""                             ; // Etichetta
                       WIDTH     MAXCOL()-4                  ; // Larghezza colonna
                       COLOR  {aColor[AC_HLP_HEADER], ;
                               aColor[AC_HLP_NORMAL], ;
                               aColor[AC_HLP_SELECT]}  ; // Array dei colori
                       MESSAGE ""                              // Messaggio

                       //PICTURE "!X"                         ; // Picture visualizzazione dato
#else
oCol := TBCOLUMNNEW( "", {|| IF(LEFT(dbHlp->TxtLine,1)==CHR(255), SUBSTR(dbHlp->TxtLine,2), dbHlp->TxtLine) })
oCol:COLORBLOCK := {||IF(LEFT(dbHlp->TxtLine,1)==CHR(255),{3,2},{1,2})}
oCol:WIDTH      := MAXCOL()-4
oTbr:ADDCOLUMN( oCol )
#endif

oTbr:W_COLORARRAY[AC_FRM_BACK  ] := aColor[AC_HLP_BRWBACK]
oTbr:W_COLORARRAY[AC_FRM_BOX   ] := aColor[AC_HLP_BRWBOX]
oTbr:W_COLORARRAY[AC_FRM_HEADER] := aColor[AC_HLP_BRWHEAD]
oTbr:W_COLORARRAY[AC_FRM_OPTION] := aColor[AC_HLP_OPTION]
oTbr:COLORSPEC    := aColor[AC_HLP_NORMAL] +"," +;
                     aColor[AC_HLP_SELECT] +"," +;
                     aColor[AC_HLP_HEADER]
oTbr:W_BORDERTYPE := W_BT_NONE
oTbr:W_MOUSEMETHOD:= W_MM_VSCROLLBAR +W_MM_EDIT

aBut  := dfHlpBut()                // Carico i Bottoni
aMenu := dfHlpMnu( aPos, oTbr )    // Carico il Menu

DFDISPBEGIN()

#ifndef __XPP__
dfHelpBorder( nTop, nLeft, nBottom, nRight, aColor, aBut, aMenu )
#endif

DO CASE
   CASE LEFT(EnvId, 3)=="SUT"   // Posiziono su un Help di Sistema
        dfHlpSystem( aPos, oTbr, EnvId )
   OTHERWISE                    // Mette al TOP il menu
        // Guardo se esiste un testo sull'oggetto
        IF dbHlp->(DBSEEK("TO"+EnvId))

           IF dfSet( AI_PROGRAMMINGHELP )
              IF !dbHlp->(DBSEEK("TI"+EnvId+SubId)) .AND. !EMPTY(SubId)
                 dbHlp->(dfNet( NET_APPEND ))
                 dbhlp->RecId   := "TI"
                 dbhlp->EnvId   := EnvId
                 dbhlp->SubId   := SubId
                 dbhlp->TXTLine := "-- NO HELP --"
                 dbHlp->(DBCOMMIT())
                 dbHlp->(dfNet( NET_RECORDUNLOCK ))
              ENDIF
           ENDIF

           IF dbHlp->(DBSEEK("TI"+EnvId+SubId))
              #ifdef __XPP__
              cKey := "'TI" +EnvId +SubId +"'"
              #else
              cKey := "[TI" +EnvId +SubId +"]"
              #endif
              tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
                        DFCOMPILE( cKey ) , {||.T.} ,;
                        DFCOMPILE( cKey + "!=UPPER(dbHlp->RecId)+UPPER(dbHlp->EnvId)+UPPER(dbHlp->SubId)" )  )
              dfHlpSkip( oTbr, aPos )
           ELSE
              #ifdef __XPP__
              cKey := "'TO" +EnvId +"'"
              #else
              cKey := "[TO" +EnvId +"]"
              #endif
              tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
                        DFCOMPILE( cKey ) , {||.T.} ,;
                        DFCOMPILE( cKey + "!=UPPER(dbHlp->RecId)+UPPER(dbHlp->EnvId)" )  )
              tbTop( oTbr )
           ENDIF
        ELSE
           dfHlpMain( aPos, oTbr )
        ENDIF
ENDCASE
#ifdef __XPP__

ATTACH "Z1" TO MENU oTbr:W_MENUARRAY AS MN_LABEL   ; //
      BLOCK {||MN_SECRET}                          ; // Condizione di attivazione
      SHORTCUT "-A_p-esc-ret-mcr-"                     ; // Shortcut
      EXECUTE  {||NIL}                               // Funzione

tbConfig( oTbr )
tbReset( oTbr )
#endif
tbStab( oTbr )
DFDISPEND()

ASIZE( aPos, 0 )
WHILE .T.
   tbStab( oTbr )
   tbInk( oTbr )
   //dbInk()
   DO CASE
      CASE M->Act=="esc" .AND. LEN(aPos)>0
           dbAct2Kbd("A_p")

      CASE M->Act=="esc" .OR. ;
           M->Act=="mou" .AND. M_PosY()==nTop .AND. M_PosX()>=nLeft .AND. M_PosX()<=nLeft+1
           EXIT

      CASE M->Act=="mou" .AND. M_PosY()==nTop .AND. M_PosX()>=nLeft+2 .AND. M_PosX()<=nRight
           aWinPos := { nTop, nLeft, nBottom, nRight }
           dfMove( aWinPos )
           nTop         := aWinPos[POS_TOP   ]
           nLeft        := aWinPos[POS_LEFT  ]
           nBottom      := aWinPos[POS_BOTTOM]
           nRight       := aWinPos[POS_RIGHT ]
           oTbr:nTop    := nTop+6
           oTbr:nLeft   := nLeft+2
           oTbr:nBottom := nBottom-2
           oTbr:nRight  := nRight-3
           DFDISPBEGIN()
              oTbr:W_BACKGROUND := .T.
              oTbr:INVALIDATE()
              dbScrRes( "dfHlp" )
              dfHelpBorder( nTop, nLeft, nBottom, nRight, aColor, aBut, aMenu )
           DFDISPEND()

      CASE M->Act=="ret" // Operazione da effettuare in base al contesto
           dfHlpNext( aPos, oTbr )

      CASE LEFT(M->Act,2)=="A_" .AND. !EMPTY(nActual:=dfHlpHot( aBut ))
           dfOptBut( aPos, oTbr, nActual )

      CASE dfMtdEval( oTbr:W_KEYBOARDMETHODS,, oTbr )

      CASE M->Act=="mou" .AND. tbDefOpt( oTbr, DE_STATE_INK )

      CASE M->Act=="mou"
           nActual := dfHlpMou( aBut, nTop, nLeft )
           dfOptBut( aPos, oTbr, nActual )
           IF !EMPTY(cPos:=dfMenuScan( aMenu, M_PosY(), M_PosX() ))
              cCho := dfMenu( aMenu, nTop+1, nLeft, nBottom, nRight,,cPos )
              IF !EMPTY(cCho)
                 EVAL( dfMenuBlock( aMenu, cCho ) )
              ENDIF
           ENDIF

      CASE M->Act=="ush"
           dfUsrHelp( oTbr:W_KEYBOARDMETHODS, DE_STATE_INK )

      CASE M->Act=="smp"
           cCho := dfMenu( aMenu, nTop+1, nLeft, nBottom, nRight )
           IF !EMPTY(cCho)
              EVAL( dfMenuBlock( aMenu, cCho ) )
           ENDIF

      CASE LEFT(M->Act,2)=="A_"
           cCho := dfMenuAct( aMenu, M->Act )
           IF !EMPTY(cCho)
              cCho := dfMenu( aMenu, nTop+1, nLeft, nBottom, nRight,,cCho )
              IF !EMPTY(cCho)
                 EVAL( dfMenuBlock( aMenu, cCho ) )
              ENDIF
           ENDIF

      CASE dfSet( AI_PROGRAMMINGHELP ) .AND. ;
           M->Act=="mcr"               .AND. ;
           ( "-"+dbHlp->RecID+"-"$"-TS-TF-FF-SC-TI-"                      .OR.;
             EMPTY( dbhlp->RecId+dbhlp->EnvId+dbhlp->SubId+dbhlp->FieId ) .OR.;
             (dbHlp->RecID=="TO") )//.AND. !EMPTY(dbHlp->SubId))                  )

           cMsg := ""
           cKey := EVAL( oTbr:W_KEY )
           lDel := .F.
           IF dbHlp->RecID=="TI" .AND. LEN(cKey)==12
              lDel := .T.
              IF ALLTRIM(UPPER(dbHlp->FieId))=="LSB"
                 #ifdef __XPP__
                 cKey := UPPER("'TI" +dbHlp->EnvId +dbHlp->SubId +dbHlp->FieId +"'")
                 #else
                 cKey := UPPER("[TI" +dbHlp->EnvId +dbHlp->SubId +dbHlp->FieId +"]")
                 #endif
                 tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
                           DFCOMPILE( cKey ) , {||.T.} ,;
                           DFCOMPILE( cKey + "!=UPPER(dbHlp->RecId)+UPPER(dbHlp->EnvId)+UPPER(dbHlp->SubId)+UPPER(dbHlp->FieId)" )  )
                 dfHlpSkip( oTbr, aPos )
                 cKey := SUBSTR( cKey, 2, 32 )
              ELSE
                 #ifdef __XPP__
                 cKey := UPPER("'TI" +dbHlp->EnvId +dbHlp->SubId +"'")
                 #else
                 cKey := UPPER("[TI" +dbHlp->EnvId +dbHlp->SubId +"]")
                 #endif
                 tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
                           DFCOMPILE( cKey ) , {||.T.} ,;
                           DFCOMPILE( cKey + "!=UPPER(dbHlp->RecId)+UPPER(dbHlp->EnvId)+UPPER(dbHlp->SubId)" )  )
                 dfHlpSkip( oTbr, aPos )
                 cKey := SUBSTR( cKey, 2, 22 )
              ENDIF
           ELSE
              tbTop( oTbr )
           ENDIF
           IF dbhlp->( dfNet( NET_RECORDLOCK ) )
              tbEval( oTbr, {||cMsg+=RTRIM(IF( LEFT(dbHlp->TxtLine,1)==CHR(255),"<BOLD>"+SUBSTR(dbHlp->TxtLine,2),dbHlp->TxtLine))+CHR(13)+CHR(10)} )
              cMsg := LEFT( cMsg, MAX(LEN(cMsg)-2,0) )
              aCTRL := {}

              ATTACH "TxtLine" TO aCTRL GET AS TEXTFIELD cMsg AT 0, 0, MAXROW()-8, 76 ; // ATTGET.TMP
                               COLOR {"RB+/G","G+/G","N/W*","W+/N","N/G","BG/G"}  ; // Array dei colori
                               PROMPT "Text Line"                          ; // Prompt
                               NOINKEY MEMOWIDTH 90

              IF dfAutoForm(,,aCTRL)
                 tbEval( oTbr, {||dbhlp->(dfNet( NET_RECORDLOCK   )) ,;
                                  dbhlp->(DBDELETE())                ,;
                                  dbhlp->(dfNet( NET_RECORDUNLOCK )) })

                 nRow := MLCOUNT(cMsg,78)
                 FOR nRec := 1 TO nRow
                    cLine := MEMOLINE( cMsg, 78, nRec )
                    IF UPPER(LEFT(cLine,6))=="<BOLD>"
                       cLine := CHR(255)+SUBSTR(cLine,7)
                    ENDIF
                    dbhlp->( dfNet( NET_APPEND, 0 ) )
                    IF LEN(cKey)>=2
                       dbhlp->RecId := SUBSTR(cKey, 1, 2)
                    ENDIF
                    IF LEN(cKey)>=12
                       dbhlp->EnvId := SUBSTR(cKey, 3,10)
                    ENDIF
                    IF LEN(cKey)>=22
                       dbhlp->SubId := SUBSTR(cKey,13,10)
                    ENDIF
                    IF LEN(cKey)>=32
                       dbhlp->FieId := SUBSTR(cKey,23,10)
                    ENDIF
                    dbhlp->TXTLine  := cLine
                    dbhlp->( dfNet( NET_RECORDUNLOCK ) )
                 NEXT
              ENDIF

              CLOSE dbhlp
              dbCfgOpen( "dbHlp" )
              IF lDel
                 #ifdef __XPP__
                 cKey := UPPER( "'" +SUBSTR(cKey,1,12) +"'" )
                 #else
                 cKey := UPPER( "[" +SUBSTR(cKey,1,12) +"]" )
                 #endif
                 tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
                           DFCOMPILE( cKey ) , {||.T.} ,;
                           DFCOMPILE( cKey + "!=UPPER(dbHlp->RecId)+UPPER(dbHlp->EnvId)" )  )
                 dfHlpSkip( oTbr, aPos )
              ELSE
                 tbTop( oTbr )
              ENDIF
           ENDIF
   ENDCASE
ENDDO

#ifdef __XPP__
tbEnd(oTbr)
#endif

dfPopArea(); dbScrResDel( "dfHlp" ); nHelp--
IF bRealTime#NIL
   __RealTime := bRealTime
ENDIF
tbDelObj()
dfPopCursor()
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfHelpBorder( nTop, nLeft, nBottom, nRight, aColor, aBut, aMenu )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
dfSayBorder( nTop, nLeft, nBottom, nRight, aColor[AC_HLP_BACK], aColor[AC_HLP_BACK] )
@ nTop, nLeft   SAY dfFontStr( "SystemMenuIcon" )               COLOR aColor[AC_HLP_OPTION]
@ nTop, nLeft+2 SAY PADC( dfStdMsg(MSG_HLP16), nRight-nLeft-1 ) COLOR aColor[AC_HLP_TITLE]
dfMenuSay( aMenu, nTop+1, nLeft, nBottom, nRight )
dfHlpSayBut( aBut, nTop, nLeft )
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfHlpHot( aBut )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nRet:=0, nActual, cInside := dfHot()+UPPER(RIGHT(M->Act,1))
FOR nActual:=1 TO LEN(aBut)
   IF cInside$UPPER(aBut[nActual][HLP_BUT_STRING])
      nRet:=nActual
   ENDIF
NEXT
RETURN nRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfHlpmou( aBut, nTop, nLeft )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nRow:=M_PosY(), nCol:=M_PosX(), nBut, nActual:=0
FOR nBut:=1 TO LEN(aBut)
   IF nRow==aBut[nBut][HLP_BUT_ROW]+1+nTop .AND.;
      nCol>=aBut[nBut][HLP_BUT_COL]+nLeft   .AND.;
      nCol<=aBut[nBut][HLP_BUT_COL]+nLeft+dfLen(aBut[nBut][HLP_BUT_STRING],dfHot())+1
      nActual:=nBut
   ENDIF
NEXT
RETURN nActual

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfHlpSayBut( aBut, nTop, nLeft )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nBut
M_CurOff()
FOR nBut := 1 TO LEN(aBut)
   dfSayBut( aBut[nBut][HLP_BUT_ROW]+nTop , aBut[nBut][HLP_BUT_COL]+nLeft,;
             aBut[nBut][HLP_BUT_STRING]   , AC_BUT_SAYNORMAL )
NEXT
M_CurOn()
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfHlpNext( aPos, oTbr )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cKey
DO CASE
   CASE EOF(); dbSouErr()
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE dbHlp->RecID == "HH"            // Help MASTER
        dfHlpPushA( aPos, oTbr )
        cKey := ALLTRIM(UPPER(dbHlp->SubId))
        DO CASE
           CASE cKey == "INFO"   ; dfHlpInfo( aPos, oTbr )
           CASE cKey == "SYSTEM" ; dfHlpSystem( aPos, oTbr )
           CASE cKey == "MENU"   ; dfHlpMenu( aPos, oTbr )
           CASE cKey == "FILE"   ; dfHlpFile( aPos, oTbr )
           CASE cKey == "OBJECT" ; dfHlpObj( aPos, oTbr )
           CASE cKey == "HELP"   ; dfHlpHlp( aPos, oTbr )
        ENDCASE

   CASE dbHlp->RecID == "HS"            // Help di sistema
        dfHlpPushA( aPos, oTbr )
        #ifdef __XPP__
        cKey := "'TS" +UPPER(dbHlp->FieId) +SPACE(10) +"'"
        #else
        cKey := "[TS" +UPPER(dbHlp->FieId) +SPACE(10) +"]"
        #endif
        tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
                  DFCOMPILE( cKey ) , {||.T.} ,;
                  DFCOMPILE( cKey + "!=UPPER(dbHlp->RecId)+UPPER(dbHlp->EnvId)+UPPER(dbHlp->SubId)" )  )
        tbTop( oTbr )

   CASE dbHlp->RecID == "TS"            // Help sulla singola voce
        tbStab( oTbr, .T. )
        dbSouErr()
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE dbHlp->RecID == "HF"            // Help sui FILE
        dfHlpPushA( aPos, oTbr )
        #ifdef __XPP__
        cKey := "'TF" +UPPER(dbHlp->FieId) +"'"
        #else
        cKey := "[TF" +UPPER(dbHlp->FieId) +"]"
        #endif
        tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
                  DFCOMPILE( cKey ) , {||.T.} ,;
                  DFCOMPILE( cKey + "!=UPPER(dbHlp->RecId)+UPPER(dbHlp->EnvId)" )  )
        dfHlpSkip( oTbr, aPos )

   CASE dbHlp->RecID == "TF" .AND.;
        EMPTY(dbHlp->SubId)  .AND.;
        EMPTY(dbHlp->FieId)         // Help sui CAMPI
        dfHlpPushA( aPos, oTbr )
        #ifdef __XPP__
        cKey := "'FF" +UPPER(dbHlp->EnvId) +"'"
        #else
        cKey := "[FF" +UPPER(dbHlp->EnvId) +"]"
        #endif
        tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
                  DFCOMPILE( cKey ) , {||.T.} ,;
                  DFCOMPILE( cKey + "!=UPPER(dbHlp->RecId)+UPPER(dbHlp->EnvId)" )  )
        dfHlpSkip( oTbr, aPos )

   CASE dbHlp->RecID == "TF"           // Help sull'help del file
        tbStab( oTbr, .T. )
        dbSouErr()

   CASE dbHlp->RecID == "FF"           // Help sull'help dei campi
        tbStab( oTbr, .T. )
        dbSouErr()
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CASE dbHlp->RecID == dfHlpSet() .AND. !EMPTY(dbHlp->SubId)  // Help sul Menu
        dfHlpPushA( aPos, oTbr )
        IF !EMPTY(dbHlp->EnvId) .AND.;
           UPPER(ALLTRIM(dbHlp->EnvID))#"OBJ" // Help su voce di menu
           #ifdef __XPP__
           cKey := "'TL" +PADR( dfHlpSet(), 10 ) +UPPER(dbHlp->EnvId) +"'"
           #else
           cKey := "[TL" +PADR( dfHlpSet(), 10 ) +UPPER(dbHlp->EnvId) +"]"
           #endif
           tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
                  DFCOMPILE( cKey ) , {||.T.} ,;
                  DFCOMPILE( cKey + "!=UPPER(dbHlp->RecId)+UPPER(dbHlp->EnvId)+UPPER(dbHlp->SubId)" )  )
        ELSE // Help su oggetto
           #ifdef __XPP__
           cKey := "'TO" +UPPER(dbHlp->SubId) +"'"
           #else
           cKey := "[TO" +UPPER(dbHlp->SubId) +"]"
           #endif
           tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
                  DFCOMPILE( cKey ) , {||.T.} ,;
                  DFCOMPILE( cKey + "!=UPPER(dbHlp->RecId)+UPPER(dbHlp->EnvId)" )  )
        ENDIF
        dfHlpSkip( oTbr, aPos )

   CASE dbHlp->RecID == dfHlpSet()     // Help sull'help del menu
        tbStab( oTbr, .T. )
        dbSouErr()

   CASE dbHlp->RecID == "TL" .AND. !EMPTY(dbHlp->FieId)  // Help sull'oggetto
        dfHlpPushA( aPos, oTbr )
        #ifdef __XPP__
        cKey := "'TO" +UPPER(dbHlp->FieId) +"'"
        #else
        cKey := "[TO" +UPPER(dbHlp->FieId) +"]"
        #endif
        tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
                  DFCOMPILE( cKey ) , {||.T.} ,;
                  DFCOMPILE( cKey + "!=UPPER(dbHlp->RecId)+UPPER(dbHlp->EnvId)" )  )
        dfHlpSkip( oTbr, aPos )

   CASE dbHlp->RecID == "TL"    // Help sull'help della voce di menu
        tbStab( oTbr, .T. )
        dbSouErr()

   CASE dbHlp->RecID == "TO" .AND.; // Help sul control
        EMPTY(dbHlp->SubId)
        dfHlpPushA( aPos, oTbr )
        #ifdef __XPP__
        cKey := "'TI" +UPPER(dbHlp->EnvId) +"'"
        #else
        cKey := "[TI" +UPPER(dbHlp->EnvId) +"]"
        #endif
        tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
                  DFCOMPILE( cKey ) , {||UPPER(ALLTRIM(dbHlp->FieId))!="COL"} ,;
                  DFCOMPILE( cKey + "!=UPPER(dbHlp->RecId)+UPPER(dbHlp->EnvId)" )  )
        dfHlpSkip( oTbr, aPos )

   CASE dbHlp->RecID == "TO"    // Help sull'help dell'oggetto
        tbStab( oTbr, .T. )
        dbSouErr()

   CASE dbHlp->RecID == "TI" .AND.; // Help sulle colonne di una listbox
        UPPER(ALLTRIM(dbHlp->FieId))=="LSB"
        dfHlpPushA( aPos, oTbr )
        #ifdef __XPP__
        cKey := "'SC" +UPPER(dbHlp->EnvId) +UPPER(dbHlp->SubId) +"'"
        #else
        cKey := "[SC" +UPPER(dbHlp->EnvId) +UPPER(dbHlp->SubId) +"]"
        #endif
        tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
                  DFCOMPILE( cKey ) , {||.T.} ,;
                  DFCOMPILE( cKey + "!=UPPER(dbHlp->RecId)+UPPER(dbHlp->EnvId)+UPPER(dbHlp->SubId)" )  )
        tbTop( oTbr )

   CASE dbHlp->RecID == "TI"    // Help sull'help dell'oggetto
        tbStab( oTbr, .T. )
        dbSouErr()

   CASE dbHlp->RecID == "SC"    // Help sull'help del control dell'oggetto
        tbStab( oTbr, .T. )
        dbSouErr()
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

ENDCASE
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfHlpHlp( aPos, oTbr )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cKey

dfHlpPushA( aPos, oTbr )
#ifdef __XPP__
cKey := "'TS" +UPPER(PADR("SUTHLP",10)) +SPACE(10) +"'"
#else
cKey := "[TS" +UPPER(PADR("SUTHLP",10)) +SPACE(10) +"]"
#endif
tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
          DFCOMPILE( cKey ) , {||.T.} ,;
          DFCOMPILE( cKey + "!=UPPER(dbHlp->RecId)+UPPER(dbHlp->EnvId)+UPPER(dbHlp->SubId)" )  )
tbTop( oTbr )

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfHlpMain( aPos, oTbr )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cKey

dfHlpPushA( aPos, oTbr )
#ifdef __XPP__
cKey := "'HH'"
#else
cKey := "[HH]"
#endif
tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
          DFCOMPILE( cKey ) , {||.T.} ,;
          DFCOMPILE( cKey + "!=UPPER(dbHlp->RecID)" )  )
tbTop( oTbr )

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfHlpMenu( aPos, oTbr )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cKey

dfHlpPushA( aPos, oTbr )
#ifdef __XPP__
cKey := "'" +dfHlpSet() +"'"
#else
cKey := "[" +dfHlpSet() +"]"
#endif
tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
          DFCOMPILE( cKey ) ,{|| !EMPTY(dbHlp->EnvID+dbHlp->SubID) .AND. ;
                                 UPPER(ALLTRIM(dbHlp->EnvID))#"OBJ" } ,;
          DFCOMPILE( cKey + "!=UPPER(dbHlp->RecID)" )  )
tbTop( oTbr )

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfHlpObj( aPos, oTbr )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cKey

dfHlpPushA( aPos, oTbr )
#ifdef __XPP__
cKey := "'" +dfHlpSet() +"'"
#else
cKey := "[" +dfHlpSet() +"]"
#endif
tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
          DFCOMPILE( cKey ) ,{|| UPPER(ALLTRIM(dbHlp->EnvID))=="OBJ" } ,;
          DFCOMPILE( cKey + "!=UPPER(dbHlp->RecID)" )  )
tbTop( oTbr )

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfHlpSystem( aPos, oTbr, cEnvId )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cKey

dfHlpPushA( aPos, oTbr )
IF cEnvId#NIL
   #ifdef __XPP__
   cKey := "'TS" +UPPER(cEnvId) +SPACE(10) +"'"
   #else
   cKey := "[TS" +UPPER(cEnvId) +SPACE(10) +"]"
   #endif
   tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
             DFCOMPILE( cKey ) , {||.T.} ,;
             DFCOMPILE( cKey + "!=UPPER(dbHlp->RecId)+UPPER(dbHlp->EnvId)+UPPER(dbHlp->SubId)" )  )
ELSE
   #ifdef __XPP__
   cKey := "'HS'"
   #else
   cKey := "[HS]"
   #endif
   tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
             DFCOMPILE( cKey ) , {||.T.} ,;
             DFCOMPILE( cKey + "!=UPPER(dbHlp->RecID)" )  )
ENDIF
tbTop( oTbr )

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfHlpFile( aPos, oTbr )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cKey

dfHlpPushA( aPos, oTbr )
#ifdef __XPP__
cKey := "'HF'"
#else
cKey := "[HF]"
#endif
tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
          DFCOMPILE( cKey ) , {||.T.} ,;
          DFCOMPILE( cKey + "!=UPPER(dbHlp->RecID)" )  )
tbTop( oTbr )

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfHlpInfo( aPos, oTbr )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cKey

dfHlpPushA( aPos, oTbr )
#ifdef __XPP__
cKey := "'" +dfHlpSet() +SPACE(20) +"'"
#else
cKey := "[" +dfHlpSet() +SPACE(20) +"]"
#endif
tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
          DFCOMPILE( cKey ) , {||.T.} ,; // Vuoto EnvId
          DFCOMPILE( cKey + "!=UPPER(dbHlp->RecID+dbHlp->EnvID+dbHlp->SubID)"))
tbTop( oTbr )

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfHlpPushA( aPos, oTbr )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
AADD( aPos, { oTbr:ROWPOS, dbHlp->(RECNO()), oTbr:W_KEY, oTbr:W_FILTER, oTbr:W_BREAK } )
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfHlpPopA( aPos, oTbr )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF LEN(aPos)>0
   tbSetKey( oTbr, NIL, aTail(aPos)[3], aTail(aPos)[4], aTail(aPos)[5] )

   //#ifdef __XPP__
   //oTbr:dehilite()
   //#endif

   oTbr:ROWPOS := aTail(aPos)[1]

   //#ifdef __XPP__
   //oTbr:hilite()
   //#endif

   dbHlp->(DBGOTO(aTail(aPos)[2]))
   tbCONFIGURE(oTbr)
   tbStab( oTbr, .T. )
   ASIZE( aPos, LEN(aPos)-1 )
ELSE
   dbSouErr()
ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfOptBut( aPos, oTbr, nActual )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

DO CASE
   CASE nActual==HLP_CTRL_MENU   ; dfHlpMain( aPos, oTbr )
   CASE nActual==HLP_CTRL_PRE    ; dfHlpPopA( aPos, oTbr )
***   CASE nActual==HLP_CTRL_FIND   ; dfHlpFind( aPos, oTbr )
ENDCASE

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfhlpbut()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nLen, aBut:={}
// Array dei bottoni ridotto per HELP
// le lunghezze sono create sull'lemento precedente dell'array per evitare
// Che le traduzioni facciano dei pasticci con i bottoni
nLen:=1
AADD( aBut, {2,                                     nLen, dfStdMsg(MSG_HLP07) })
AADD( aBut, {2, nLen+=LEN(ATAIL(aBut)[HLP_BUT_STRING])+1, dfStdMsg(MSG_HLP08) })
***AADD( aBut, {2, nLen+=LEN(ATAIL(aBut)[HLP_BUT_STRING])+1, dfStdMsg(MSG_HLP09) })
RETURN aBut

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfHlpMnu( aPos, oTbr )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aMenu:={}

ATTACH "1"  TO MENU aMenu PROMPT   dfStdMsg(MSG_HLP10)

ATTACH "11" TO MENU aMenu PROMPT   dfStdMsg(MSG_HLP11) ;
                          EXECUTE  {||tbPrnWin( oTbr )}

ATTACH "12" TO MENU aMenu AS MN_LINE

ATTACH "13" TO MENU aMenu PROMPT   dfStdMsg(MSG_HLP12) ;
                          EXECUTE  {||dbAct2Kbd("esc")}

ATTACH "2"  TO MENU aMenu PROMPT   dfHot()+"?"

ATTACH "21" TO MENU aMenu PROMPT   dfStdMsg(MSG_HLP13) ;
                          EXECUTE  {||dfHlpHlp( aPos, oTbr )}

RETURN aMenu

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfHlpSkip( oTbr, aPos )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF tbRowCount( oTbr )==1
   dfHlpNext( aPos, oTbr )
   ASIZE( aPos, LEN(aPos)-1 )
ELSE
   tbTop( oTbr )
ENDIF
RETURN

** ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*STATIC PROCEDURE dfHlpFind( aPos, oTbr )
** ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*LOCAL cWord := SPACE(30), nRec:=RECNO()
*dfGetW( MAXROW()/2-1, 1, dfStdMsg(MSG_HLP14), {|x|IF(x==NIL,cWord,cWord:=x)}, "@X" )
*IF M->Act#"esc"
*   dbScrSav( "FIND", MAXROW() )
*   DBGOTOP()
*   WHILE !EOF() .AND. !UPPER(ALLTRIM(cWord))$UPPER(dbHlp->TxtLine)
*      DBSKIP()
*   ENDIF
*   IF !EOF()
*      DO CASE
*         CASE dbHlp->RecID == "HH"            // Help MASTER
*              dfHlpMain( aPos, oTbr )
*
*         CASE dbHlp->RecID == "HS"            // Help di sistema
*              dfHlpPushA( aPos, oTbr )
*              cKey := "[HS" +UPPER(dbHlp->RecId) +"]"
*              tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
*                        DFCOMPILE( cKey ) , {||.T.} ,;
*                        DFCOMPILE( cKey + "!=UPPER(dbHlp->RecId)" )  )
*              tbTop( oTbr )
*
*         CASE dbHlp->RecID == "TS"            // Help sulla singola voce
*              tbStab( oTbr, .T. )
*              dbSouErr()
*      //ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*
*      //ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*         CASE dbHlp->RecID == "HF"            // Help sui FILE
*              dfHlpFile( aPos, oTbr )
*
*         CASE dbHlp->RecID == "TF" .AND.;
*              EMPTY(dbHlp->SubId)  .AND.;
*              EMPTY(dbHlp->FieId)         // Help sui CAMPI
*              dfHlpPushA( aPos, oTbr )
*              cKey := "[FF" +UPPER(dbHlp->EnvId) +"]"
*              tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
*                        DFCOMPILE( cKey ) , {||.T.} ,;
*                        DFCOMPILE( cKey + "!=UPPER(dbHlp->RecId)+UPPER(dbHlp->EnvId)" )  )
*              dfHlpSkip( oTbr, aPos )
*
*         CASE dbHlp->RecID == "TF"           // Help sull'help del file
*              tbStab( oTbr, .T. )
*              dbSouErr()
*
*         CASE dbHlp->RecID == "FF"           // Help sull'help dei campi
*              tbStab( oTbr, .T. )
*              dbSouErr()
*      //ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*
*      //ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*         CASE dbHlp->RecID == dfHlpSet() .AND. !EMPTY(dbHlp->SubId)  // Help sul Menu
*              dfHlpPushA( aPos, oTbr )
*              IF !EMPTY(dbHlp->EnvId) .AND.;
*                 UPPER(ALLTRIM(dbHlp->EnvID))#"OBJ" // Help su voce di menu
*                 cKey := "[TL" +PADR( dfHlpSet(), 10 ) +UPPER(dbHlp->EnvId) +"]"
*                 tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
*                        DFCOMPILE( cKey ) , {||.T.} ,;
*                        DFCOMPILE( cKey + "!=UPPER(dbHlp->RecId)+UPPER(dbHlp->EnvId)+UPPER(dbHlp->SubId)" )  )
*              ELSE // Help su oggetto
*                 cKey := "[TO" +UPPER(dbHlp->SubId) +"]"
*                 tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
*                        DFCOMPILE( cKey ) , {||.T.} ,;
*                        DFCOMPILE( cKey + "!=UPPER(dbHlp->RecId)+UPPER(dbHlp->EnvId)" )  )
*              ENDIF
*              dfHlpSkip( oTbr, aPos )
*
*         CASE dbHlp->RecID == dfHlpSet()     // Help sull'help del menu
*              tbStab( oTbr, .T. )
*              dbSouErr()
*
*         CASE dbHlp->RecID == "TL" .AND. !EMPTY(dbHlp->FieId)  // Help sull'oggetto
*              dfHlpPushA( aPos, oTbr )
*              cKey := "[TO" +UPPER(dbHlp->FieId) +"]"
*              tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
*                        DFCOMPILE( cKey ) , {||.T.} ,;
*                        DFCOMPILE( cKey + "!=UPPER(dbHlp->RecId)+UPPER(dbHlp->EnvId)" )  )
*              dfHlpSkip( oTbr, aPos )
*
*         CASE dbHlp->RecID == "TL"    // Help sull'help della voce di menu
*              tbStab( oTbr, .T. )
*              dbSouErr()
*
*         CASE dbHlp->RecID == "TO" .AND.; // Help sul control
*              EMPTY(dbHlp->SubId)
*              dfHlpPushA( aPos, oTbr )
*              cKey := "[TI" +UPPER(dbHlp->EnvId) +"]"
*              tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
*                        DFCOMPILE( cKey ) , {||UPPER(ALLTRIM(dbHlp->FieId))!="COL"} ,;
*                        DFCOMPILE( cKey + "!=UPPER(dbHlp->RecId)+UPPER(dbHlp->EnvId)" )  )
*              dfHlpSkip( oTbr, aPos )
*
*         CASE dbHlp->RecID == "TO"    // Help sull'help dell'oggetto
*              tbStab( oTbr, .T. )
*              dbSouErr()
*
*         CASE dbHlp->RecID == "TI" .AND.; // Help sul control del control
*              UPPER(ALLTRIM(dbHlp->FieId))=="LSB"
*              dfHlpPushA( aPos, oTbr )
*              cKey := "[SC" +UPPER(dbHlp->EnvId) +UPPER(dbHlp->SubId) +"]"
*              tbSetKey( oTbr, NIL,; // Setto le chiavi sull'indice corrente
*                        DFCOMPILE( cKey ) , {||.T.} ,;
*                        DFCOMPILE( cKey + "!=UPPER(dbHlp->RecId)+UPPER(dbHlp->EnvId)+UPPER(dbHlp->SubId)" )  )
*              tbTop( oTbr )
*
*         CASE dbHlp->RecID == "TI"    // Help sull'help dell'oggetto
*              tbStab( oTbr, .T. )
*              dbSouErr()
*
*         CASE dbHlp->RecID == "SC"    // Help sull'help del control dell'oggetto
*              tbStab( oTbr, .T. )
*              dbSouErr()
*      ENDCASE
*   ELSE
*      dbMsgErr( dfStdMsg(MSG_HLP15) )
*      GOTO nRec
*   ENDIF
*   dbScrResDel( "FIND" )
*ENDIF
*RETURN

