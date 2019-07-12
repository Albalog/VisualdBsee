/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Window su File tabellari
Programmatore  : Baccan Matteo
******************************************************************************/

#INCLUDE "Common.CH"
#INCLUDE "dfWin.ch"
#INCLUDE "dfNet.CH"
#INCLUDE "dfMsg.CH"
#INCLUDE "dfStd.CH"
#INCLUDE "dfCTRL.CH"
#include "dfSet.CH"
#include "dfTab.ch"

#ifdef __XPP__
   // simone 5/11/04 per correzione problema DBGOTO(0)
   // vedi DBGOTO_XPP
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif

REQUEST dbTabConv

MEMVAR Act
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddWit( cTabName ,; // Nome array oggetto
                cTabPrk  ,; // Prechiave non gestita, passare stringa nulla
                uTabSeek ,; // Cosa cercare ( preposizionamento finestra )
                lEdit )     // Accesso all'edit del dato
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cTabTit, nLeft, nRight, aCol := {}, bRow, nTabWid // Array Oggetti Colonna
LOCAL cTabSeek, aMtd := {}, nRec, cTabCod, nTabLen, cTabPic, cActTab, cActPrk
LOCAL cTabSubCod, nPos, cSubStr, cTabTyp
LOCAL lNewMethod, aStr

MEMVAR EnvId, SubId
PRIVATE EnvId:="SutTab", SubId:=""

dbCfgOpen( "dbdd" )     // Apro dbdd
dbCfgOpen( "dbtabd" )   // apro file per tabelle

cActTab := UPPER(PADR( cTabName  ,LEN(dbTabD->TabId) ))
cActPrk := UPPER(PADR( cTabPrk   ,LEN(dbTabD->TabPrk)))
cTabSeek:= dfAny2Str(uTabSeek)

dbTabD->(DBSEEK( cActTab+cTabPrk+UPPER(cTabSeek) ))

aStr       := dfStr2arr(dbTabd->TabData,TAB_SEPARATORE )
lNewMethod := LEN(aStr) > 1

// Verifica il record trovato
dfTabLocate( cActTab+cTabPrk )

nRec := dbTabD->(RECNO())

dbdd->(dbSeek( "DBF"+cActTab ))

cTabTit := ALLTRIM(dbdd->Field_des)
nTabWid := 0

nPos := 1
dbdd->(dbSeek( "FIE"+cActTab ))
WHILE UPPER( dbdd->RecTyp+ dbdd->file_name ) == "FIE"+cActTab .AND. !dbdd->(eof())
   IF nPos==1
      *ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      *³Inizializzo la prima colonna³
      *ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      cTabCod := ALLTRIM(dbdd->field_des)
      nTabLen :=         dbdd->field_len
      cTabPic := ALLTRIM(dbdd->field_pic)
      cTabTyp :=         dbdd->FIELD_TYPE

      cTabSubCod := cTabCod
      cSubStr := "LEFT(DBTABD->TABCODE,"+ALLTRIM(STR( nTabLen ))+")"
   ELSE
      cTabSubCod := ALLTRIM(dBdd->field_des)
      IF lNewMethod
         cSubStr := "S2TabGetFie("+STR(nPOS,2,0)+")"
      ELSE 
         cSubStr := "SUBSTR(dbTabd->TabData," +ALLTRIM(STR(dbdd->TabFieSod)) +"," +ALLTRIM(STR(dbdd->field_len)) +")"
      ENDIF 
   ENDIF

   IF dbdd->FIELD_TYPE=="C"
      bRow := "dfAny2Str("           +cSubStr +",[" +ALLTRIM(dbdd->Field_Pico) +"])"
   ELSE
      bRow := "dfAny2Str(dbTabConv(" +cSubStr +",[" +dbdd->FIELD_TYPE +"]),[" +ALLTRIM(dbdd->Field_Pico) +"])"
   ENDIF

   bRow := DFCOMPILE( bRow )

   AADD( aCol, { cTabSubCod, bRow } )
   nTabWid += LEN(EVAL(bRow)) +1
   // 19/09/2005 
   // Errore nel calcolo della larghezza delle colonne
   //nTabWid += MAX( LEN(cTabSubCod), LEN(EVAL(bRow)) )//+1
   dbdd->(DBSKIP())
   nPos++
ENDDO

// 19/09/2005 
// Errore nel calcolo della larghezza delle colonne
//nTabWid := MAX( nTabWid, LEN(cTabTit)+4 )
nLeft   := INT( (80-2-nTabWid)/2 )
nRight  := nLeft + nTabWid +1.2

ADDKEY "anr" TO aMtd WHEN {||lEdit .AND. EVAL( dfSet( AI_TABLEINSERTCB ), ALLTRIM(cActTab) ) } ;
                     BLOCK {|oWin|ddWitAtr( oWin, cActTab )}                                   ;
                     MESSAGE dfStdMsg(MSG_DDWIT01)

ADDKEY "mcr" TO aMtd WHEN {||lEdit .AND. EVAL( dfSet( AI_TABLEINSERTCB ), ALLTRIM(cActTab) ) } ;
                     BLOCK {|oWin|ddWitMtr( oWin, cActTab )}                                   ;
                     MESSAGE dfStdMsg(MSG_DDWIT02)

ADDKEY "ecr" TO aMtd WHEN {||lEdit .AND. EVAL( dfSet( AI_TABLEINSERTCB ), ALLTRIM(cActTab) ) } ;
                     BLOCK {|oWin|ddWitEtr( oWin          )}                                   ;
                     MESSAGE dfStdMsg(MSG_DDWIT03)

ADDKEY "win" TO aMtd WHEN {||            EVAL( dfSet( AI_TABLEINSERTCB ), ALLTRIM(cActTab) ) }   ;
                     BLOCK {|oWin|ddWitWin( oWin, cTabTyp, cTabCod, nTabLen, cTabPic, cActTab, cActPrk )} ;
                     MESSAGE dfStdMsg(MSG_DDWIT04)

dbTabD->(dfWin( , nLeft, , nRight   ,; // Coordinate
                {|| cActTab+cActPrk                                     } ,; // Chiave Filtro Break
                dfSet( AI_TABLEFILTER )                                   ,;
                {||!Upper(dbTabd->TabId+dbTabd->TabPrk)==cActTab+cActPrk} ,;
                cTabTit             ,; // titolo
                aCol                ,;
                aMtd, {|nAct,oWin|ddWitSys(oWin,nAct,nRec)}  ))

RETURN dbTabD->TabCode

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION ddWitSys( oWin, nAct, nRec )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nActRec
IF nAct==WO_EVENT_ACTIVATE
   nActRec := dbTabD->(RECNO())
   dbTabD->(DBGOTO(nRec))
   IF dbTabD->(EOF())
      dbTabD->(DBGOTO(nActRec))
   ENDIF
ENDIF
RETURN .T.

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE ddWitWin( oWin, cTabTyp, cTabCod, nTabLen, cTabPic, cActTab, cActPrk )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL c2Seek  := SPACE( nTabLen )
LOCAL nCurTab := dbTabD->(Recno())

DO CASE
   CASE cTabTyp=="D"
        c2Seek := CTOD("")
   CASE cTabTyp=="N"
        c2Seek := 0
ENDCASE

dfPushAct()
dfGetW( 1,1, dfStdMsg(MSG_DDWIT08) +cTabCod , @c2Seek ,cTabPic )

DO CASE
   CASE cTabTyp=="D"
        c2Seek := DTOS(c2Seek)
   CASE cTabTyp=="N"
        c2Seek := PADL(ALLTRIM(dfAny2Str(c2Seek,cTabPic)),nTabLen)
ENDCASE

IF Act="ret" .AND. !Empty(c2Seek)
   dbTabD->(dbSeek( Upper(cActTab+cActPrk+trim(c2Seek) ) ))
   IF dbTabD->(EOF())
      dbMsgErr( dfStdMsg(MSG_DDWIT05)+ c2Seek+ dfStdMsg(MSG_DDWIT06) )
      dbTabD->(dbGoto( nCurTab ))
   ELSE
      oWin:RefreshAll()
      tbStab( oWin )
   ENDIF
ENDIF
dfPopAct()
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE ddWitEtr( oWin )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF dbTabd->(eof())
   dbSouErr()
ELSE
   dfPushAct()
   IF dfYesNo( dfStdMsg(MSG_DDWIT07), .F. )
      IF dbTabD->(dfNet( NET_RECORDLOCK ))
         dbTabD->(DBDELETE())
         dbTabD->(DBCOMMIT())
         dbTabD->(dfNet( NET_RECORDUNLOCK ))
      ENDIF
      tbEtr( oWin )
   ENDIF
   dfPopAct()
ENDIF

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE ddWitAtr( oWin, cActTab )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
dfPushAct()
DO WHILE .T.
   dbTabFrm( cActTab, DE_STATE_ADD )
   DO CASE
      CASE Act = "new"
           tbAtr( oWin )
      OTHERWISE
           EXIT
   ENDCASE
ENDDO
tbAtr( oWin )
dfPopAct()
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE ddWitMtr( oWin, cActTab )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
dfPushAct()
IF dbTabd->(EOF())
   dbSouErr()
ELSE
   dbTabFrm( cActTab, DE_STATE_MOD )
   tbRtr( oWin )
ENDIF
dfPopAct()
RETURN
