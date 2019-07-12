//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Funzioni per tabelle
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfState.ch"
#include "dfTab.ch"
#include "dfMsg.ch"
#include "dfSet.ch"
#include "dfLook.ch"

#ifdef __XPP__
   // simone 5/11/04 per correzione problema DBGOTO(0)
   // vedi DBGOTO_XPP
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dBTabChk( cTabId  ,; // id tabella
                   uTabCode,; // Campo di lookup ( passare con @ !!)
                   cTabMst  ) //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//STATIC aChk := {}
LOCAL nRec := 0, TabDes, lRet, cTabCode, bTabCode, lNum := .F.
MEMVAR Act

IF VALTYPE(uTabCode)=="B"
   bTabCode := uTabCode
ELSE
   bTabCode := {|x|IF(x==NIL,uTabCode,uTabCode:=x)}
ENDIF

dfPushArea()          // salvo la posizione del file in ingresso
dbCfgOpen( "dbdd" )   // apro file tabellari
dbCfgOpen( "dbtabd" ) // e dizionario

cTabId := UPPER(PADR(cTabId, 8))
lRet   := .T.

dbdd->(ORDSETFOCUS(1))
dbdd->(DBSEEk( "DBF"+cTabId ))
TabDes := Trim(dbdd->field_des)

dbdd->(ORDSETFOCUS(2))
dbdd->(DBSEEk( "FIE"+cTabId ))
WHILE dbdd->TabFieSod#-1 .AND. ;
      "FIE"+cTabId == UPPER(dbdd->RecTyp+dbdd->File_name) .AND. !dbdd->(EOF())
   dbdd->(DBSKIP(1))
ENDDO
IF dbdd->TabFieSod==-1                                 .AND.;
   "FIE"+cTabId == UPPER(dbdd->RecTyp+dbdd->File_name) .AND.;
   !dbdd->(EOF())
   nRec := dbdd->(RECNO())
ENDIF

///////////////////////////////////////////////////////////////////////
// Fare l'espressione secca   cTabChk := UPPER( dfAny2Str(cTabChk) ) //
// non funziona su AS400                                             //
///////////////////////////////////////////////////////////////////////
lNum := VALTYPE( EVAL(bTabCode) )=="N" .AND. nRec>0
IF lNum
   cTabCode := STR( EVAL(bTabCode), dbdd->field_len, dbdd->field_dec )
ELSE
   DO CASE
      CASE dbdd->field_type=="D"
           cTabCode := DTOS(EVAL(bTabCode))
      CASE dbdd->field_type=="L"
           cTabCode := IF(EVAL(bTabCode),"T","F")
      OTHERWISE
           cTabCode := dfAny2Str(EVAL(bTabCode))
   ENDCASE
ENDIF

IF nRec==0
   dbMsgErr( dfStdMsg(MSG_TABCHK13)+" " +cTabId +" " +dfStdMsg(MSG_TABCHK14) )
ENDIF
dbdd->(ORDSETFOCUS(1))

dbTabD->(DBSEEk(cTabId+TAB_PRK+UPPER(cTabCode)))  // posiziono il record dati

DO CASE
   CASE Act=="Ada" .OR.;
        ( dfSet(AI_LOOKAUTOWIN)  .AND.;
          Act=="ret"             .AND.;
          EMPTY(cTabCode)        .AND.;
          cTabMst==LT_MANDATORY       )

        // Verifica il record trovato
        dfTabLocate( cTabId+TAB_PRK )

        IF dbTabd->(eof()) .AND. ! dfSet( AI_TABMODIFY )
           dbMsgerr(  dfStdMsg(MSG_TABCHK01) +;
                      trim(TabDes)           +;
                      dfStdMsg(MSG_TABCHK02) +;
                      dfStdMsg(MSG_TABCHK03) +;
                      cTabId                 +;
                      dfStdMsg(MSG_TABCHK04) )
           dfPopArea()                        // ripristino la situazione
           RETURN .F.
        ENDIF

        ddWit(cTabId ,TAB_PRK ,cTabCode , dfSet( AI_TABMODIFY ) )

        IF Act=="ret"
           dbdd->(DBGOTO(nRec))
           EVAL( bTabCode, dbTabConv( SUBSTR(dbTabD->TabCode, 1, dbdd->field_len), dbdd->field_type ))
           Act := "tab"
        ELSE
           lRet = .f.
           Act := "rep"
        ENDIF

   CASE Act=="esc"            // entry point fittizio

   CASE Act=="uar"
        * lascio passare xche' l'utente sta tornando al campo precedente,

   CASE EMPTY(cTabCode) .and. cTabMst == LT_MANDATORY
        dbdd->(DBGOTO(nRec))
        dbMsgErr( dfStdMsg(MSG_TABCHK05) +trim(dbdd->field_des) +")" )
        lRet := .F.
        Act  := "rep"

   CASE EMPTY(cTabCode) .AND. cTabMst == LT_NOTMANDATORY
        lRet := .T.

   CASE lNum .AND. VAL(cTabCode)==0 .AND. cTabMst == LT_NOTMANDATORY
        lRet := .T.

   OTHERWISE
        DO CASE
           CASE cTabMst == LT_FREE  // All value are OK
                lRet := .T.

           CASE !(dbtabd->(eof()))  // If found it's OK
                lRet := .T.
                IF !EVAL( dfSet(AI_TABLEFILTER) )
                   lRet := .F.
                   Act  := "rep"
                ENDIF

           CASE dbtabd->(eof())       .AND. ;
                dfSet( AI_TABMODIFY ) .AND. ;
                EVAL( dfSet( AI_TABLEINSERTCB ), ALLTRIM(cTabId) )

                dbdd->(DBGOTO(nRec))
                IF dfYesNo( dfStdMsg(MSG_TABCHK06) +;
                            trim(dbdd->field_des)  +;
                            dfStdMsg(MSG_TABCHK07) +;
                            "("+cTabCode+")//"   +;
                            dfStdMsg(MSG_TABCHK08) +;
                            TabDes                 +;
                            dfStdMsg(MSG_TABCHK09) , .F.)

                   dbTabFrm( cTabId, DE_TAB_WITHOUT_CODIFY, EVAL(bTabCode) )

                   lRet := !(Act=="esc")
                   Act  := "rep" // in ogni caso torna sul campo corrente

                ELSE
                   lRet := .F.
                   Act  := "rep"
                ENDIF

           OTHERWISE
                dbdd->(DBGOTO(nRec))
                dBMsgW( dfStdMsg(MSG_TABCHK10) +;
                        trim(dbdd->field_des)  +;
                        dfStdMsg(MSG_TABCHK11) +;
                        "("+cTabCode+")//"   +;
                        dfStdMsg(MSG_TABCHK12)  )
                lRet := .F.
                Act  := "rep"
        ENDCASE
ENDCASE

dfPopArea()                        // ripristino la situazione

RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfTabLocate( cKey )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

IF dbTabd->(eof()) .OR. !EVAL(dfSet(AI_TABLEFILTER))
   dbtabd->(DBSEEk( cKey )) // posiziono il record dati
   IF !EVAL( dfSet(AI_TABLEFILTER) )
      // Non in filtro ... cerco un dato valido
      WHILE UPPER(dbTabd->TabId+dbTabd->TabPrk)==cKey .AND.;
            !dbtabd->(EOF())
            IF EVAL(dfSet(AI_TABLEFILTER))
               EXIT
            ENDIF
            dbtabd->(DBSKIP())
      ENDDO
      IF !UPPER(dbTabd->TabId+dbTabd->TabPrk)==cKey
         dbTabd->(DBGOTO(0))
      ENDIF
   ENDIF
ENDIF

RETURN
