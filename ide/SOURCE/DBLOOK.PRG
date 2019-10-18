// *****************************************************************************
// Copyright (C) Albalog s.r.l.
// Description : Centralised Automatic Lookup function
// *****************************************************************************
#include "Common.ch"
#include "dfWin.ch"
#include "dfLook.ch"
#include "dfMsg.CH"
#include "dfSet.CH"

#ifdef __XPP__
   // 04-nov-05 Correct DBGOTO(0) problem
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dbLook(        ; // Auto-LookUp function
                 aLook  ) // Parameters array
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
// LK_ORDER  aLook[1]  := Order                 (Number)
// LK_SEEK   aLook[2]  := Prim.Position.Key     (CODEBLOCK)
// LK_VAL    aLook[3]  := Inherited fields      (Array)
// LK_FIELD  aLook[4]  := Key for DBDD          (Seek on DBDD)
// LK_WIN    aLook[5]  := Window
// LK_KEY    aLook[6]  := Key for Window
// LK_FILTER aLook[7]  := Filter on Window
// LK_BREAK  aLook[8]  := Break on Window
// LK_TYPE   aLook[9]  := Type of LookUp
//                           LT_NOTMANDATORY
//                           LT_MANDATORY
//                           LT_FREE         (Query)
// LK_EDIT   aLook[10] := Edit LookUp object. If empty, read from ddde
// LK_INS    aLook[11] := Allow adding from LookUp           (CODEBLOCK)
// LK_KBD    aLook[12] := Skip to next control
// LK_KEYORDER
// LK_WINDOWORDER

MEMVAR Act

LOCAL cFieDes, cFieTyp, cCode, cFleDes
LOCAL lFound    := .T.
LOCAL lEsc      := .F.
LOCAL nInd      := INDEXORD()
LOCAL cAct      := Act
LOCAL cAlias    := PADR(UPPER(ALIAS()),8)
LOCAL cOldState := ""
LOCAL lCase2    := .F.
LOCAL cKey

IF Act $ "uar-esc-Stb"         // These actions transform a LookUp
   RETURN .T.                  // to a free LookUp
ENDIF                          // Save the mask ALWAYS
                               // checks the data

DEFAULT aLook[LK_KEYORDER]     TO aLook[LK_ORDER]
DEFAULT aLook[LK_WINDOWORDER]  TO aLook[LK_ORDER]

// Simone 14/6/06 mantis 0001082: abilitare impostazione generale per disabilitare inserimento da lookup
DEFAULT aLook[LK_INS]          TO dfSet(AI_LOOKINSERTCB)  

cOldState := dfUsrState()      // Save current state
SET ORDER TO aLook[LK_ORDER]

// ------------------------------------------------------
// simone 9/6/2006 
// mantis 0001085: La dblook() per GET con lookup non funziona correttamente nel caso di settaggio NOT Mandatory per chiave con prefisso
// Fix per lookup NOT MANDATORY su tabelle con pre-codice (es "C"+CODANA)
//
// simula la seguente
// modifica al template VALIDSTD.TMP
/*
   // Aggiunto S2000 Standard per LookUp con chiave vuota
   IF Empty(ÛAllTrim(dd_sym->SYM_NAM)Û)
      aDbl[LK_SEEK] := Space(Len(aDbl[LK_SEEK]))
   ENDIF

*/
IF ! EMPTY(aLook[LK_KEY]) .AND. ! EMPTY(aLook[LK_SEEK]) .AND. ;
   dfSet("XbaseDbLookFix_EmptyKey") != "NO"

   cKey := NIL
   IF VALTYPE(aLook[LK_KEY]) == "B"
      cKey := EVAL(aLook[LK_KEY])
   ELSEIF VALTYPE(aLook[LK_KEY]) $ "CM"
      cKey := aLook[LK_KEY]
   ENDIF

   //////////////////////////////////////////////////////////////
   //Luca and Simone
   //Modifica Fix per lookup su variaible del 9/03/2007
   //Accade che il wizard di creazione lookup su variaible non imposta correttamente la chiave di relazione
   //quindi permette in ogni caso di selezioanre il campo del record voluto ma si ottiene 
   //alla fine un fenomeno di sbiancamnto della variabile quando perde il Focus.
   //IF PADR(cKey, LEN(aLook[LK_SEEK])) == aLook[LK_SEEK]
   //   aLook[LK_SEEK] := SPACE(LEN(aLook[LK_SEEK]))
   //ENDIF
   IF VALTYPE(cKey) $ "CM"            .AND. ;
      VALTYPE(aLook[LK_SEEK]) $ "CM"  .AND. ;
      LEN(aLook[LK_SEEK]) > LEN(cKey) .AND. ;
      PADR(cKey, LEN(aLook[LK_SEEK])) == aLook[LK_SEEK]

      aLook[LK_SEEK] := SPACE(LEN(aLook[LK_SEEK]))
   ENDIF
   //////////////////////////////////////////////////////////////
ENDIF
// FINE
// ------------------------------------------------------


DO CASE
   CASE Act=="Cho"; dfTop(    , aLook[LK_FILTER], aLook[LK_BREAK] );Act:="rep"
   CASE Act=="Cen"; dfBottom( , aLook[LK_FILTER], aLook[LK_BREAK] );Act:="rep"
   CASE Act=="Cra"; dfSkip( 1 , aLook[LK_FILTER], aLook[LK_BREAK] );Act:="rep"
   CASE Act=="Cla"; dfSkip( -1, aLook[LK_FILTER], aLook[LK_BREAK] );Act:="rep"

        // Window
   CASE Act == "Ada" .OR.;
        ( dfSet(AI_LOOKAUTOWIN)  .AND.;
          Act=="ret"             .AND.;
          EMPTY(aLook[LK_SEEK])  .AND.;
          aLook[LK_TYPE]==LT_MANDATORY )

        IF !EMPTY(aLook[LK_SEEK])
           (cAlias)->(DBSEEK( aLook[LK_SEEK], .T. ))
        ENDIF
        IF aLook[LK_WIN] # NIL     // Window name
           // Generated window
           EVAL( aLook[LK_WIN]          ,; // Window name
                 aLook[LK_WINDOWORDER]  ,; // Order
                 aLook[LK_KEY]          ,; // Key
                 aLook[LK_FILTER]       ,; // Filter
                 aLook[LK_BREAK]         ) // Break

        ELSE
           // Run-time Window
           ddWin( aLook[LK_WINDOWORDER] ,; // Order
                  aLook[LK_KEY]         ,; // Key
                  aLook[LK_FILTER]      ,; // Filter
                  aLook[LK_BREAK]        ) // Break
        ENDIF
        IF (lEsc:=Act=="esc")
           lFound := .F.
        ENDIF

   CASE Act == "Cda"               // Keys
        lEsc := !ddKey( 2                  ,; // Starter row
                        3                  ,; // Starter column
                        aLook[LK_KEYORDER] ,; // Current index order
                        aLook[LK_KEY]      ,; // Key    on Window
                        aLook[LK_FILTER]   ,; // Filter on Window
                        aLook[LK_BREAK]    )  // Break  on Window
        IF lEsc
           lFound := .F.
        ENDIF

   OTHERWISE
        lFound := .F.
ENDCASE

IF (!EMPTY(aLook[LK_SEEK]) .OR. !lFound) .AND. !lEsc  // Positioning
   IF !lFound
      lFound:=(cAlias)->(DBSEEK( aLook[LK_SEEK] ))
   ENDIF
   IF (cAlias)->(EOF())
      lFound := .F.
   ENDIF
ENDIF

lCase2 := LEN(aLook[LK_VAL])==1             .AND.; // Only one value
          VALTYPE(EVAL(aLook[LK_VAL][1][2]))=="N".AND.; // Numeric
          VALTYPE(aLook[LK_SEEK])=="C"           .AND.; // Seeked like character
          VAL(aLook[LK_SEEK])==0                 .AND.;
          aLook[LK_TYPE]==LT_NOTMANDATORY        .AND.; // Not Mandatory
          !lFound                                .AND.;
          !lEsc

DO CASE
   CASE aLook[LK_TYPE] == LT_FREE           // Free
        IF !lEsc
           lFound := .T.                       // Returns always .T.
        ENDIF

   CASE EMPTY( aLook[LK_SEEK] ) .AND.;
        !lFound                 .AND.;
        !lEsc                               // Seeked value

        DO CASE
           CASE aLook[LK_TYPE] == LT_MANDATORY    // Mandatory field

                dbdd->(ORDSETFOCUS(2))
                dbdd->(dbSeek("FIE"+ cAlias+ UPPER(aLook[LK_FIELD])))
                dbdd->(ORDSETFOCUS(1))

                cFieDes := TRIM(dbdd->field_des)
                dbMsgErr( dfStdMsg(MSG_DBLOOK01)+ cFieDes +" " +dfStdMsg(MSG_DBLOOK02) )

           CASE aLook[LK_TYPE] == LT_NOTMANDATORY // Empty field ok
                (cAlias)->(DBGOTO(0))             // Force EOF()
                lFound := .T.
        ENDCASE

   CASE lCase2
//   CASE LEN(aLook[LK_VAL])==1                  .AND.; // Only one value
//        VALTYPE(EVAL(aLook[LK_VAL][1][2]))=="N".AND.; // Numeric
//        VALTYPE(aLook[LK_SEEK])=="C"           .AND.; // Seeked like character
//        VAL(aLook[LK_SEEK])==0                 .AND.;
//        aLook[LK_TYPE]==LT_NOTMANDATORY        .AND.; // Not Mandatory
//        !lFound                                .AND.;
//        !lEsc

        // Value numeric, seeked like a character

        (cAlias)->(DBGOTO(0))             // Force EOF()
        lFound := .T.

   CASE !lFound .AND. !lEsc                 // May continue with data entry

        dbdd->(ORDSETFOCUS(2))
        dbdd->(DBSEEK("DBF"+ cAlias))
        cFleDes := strtran(TRIM(dbdd->Field_Des),":","")

        dbdd->(ORDSETFOCUS(1))
        dbdd->(DBSEEK("NDX"+ cAlias+str(aLook[LK_WINDOWORDER],3)))
        cFleDes += ":" +strtran(TRIM(dbdd->Field_Des),":","")

        dbdd->(ORDSETFOCUS(2))
        dbdd->(dbSeek("FIE"+ cAlias+ UPPER(aLook[LK_FIELD])))
        dbdd->(ORDSETFOCUS(1))
        cFieDes := TRIM(dbdd->Field_Des)
        cFieTyp := dbdd->Field_Type
        cCode   := TRIM(PADR( aLook[LK_SEEK], 45))

        IF cFieTyp=="D" .AND. LEN(aLook[LK_VAL])==1  // Date type field
           cCode := DTOC(EVAL(aLook[LK_VAL][1][2]))
        ENDIF

        IF !EVAL( aLook[LK_INS] ) .OR. ;             // Insertion Not allowed
           !EVAL( dfSet( AI_FILEINSERTCB ), ALLTRIM(cAlias) )
           dbMsgErr( dfStdMsg(MSG_DBLOOK03)+;
                     strtran(cFieDes,":","")+": (" +cCode +")" +;
                     dfStdMsg(MSG_DBLOOK04) )
        ELSE                                         // Insertion allowed
           IF dfYesNo( dfStdMsg(MSG_DBLOOK05)               +;
                       strtran(cFieDes,":","") +": (" +cCode +")"           +;
                       dfStdMsg(MSG_DBLOOK06) +" " +cFleDes +;
                       dfStdMsg(MSG_DBLOOK07), .F. )

              dfPushAct()   // Avoiding F10
              IF aLook[LK_EDIT] # NIL      // If a data entry frame
                 EVAL( aLook[LK_EDIT] )    // has been activated
                 IF Act # "esc"
                    lFound := .T.
                 ENDIF
              ELSE                 // Otherwise automatic data entry form
                 lFound := ddDe( DE_STATE_ADD, aLook[LK_VAL] )
              ENDIF
              dfPopAct()

           ENDIF
        ENDIF
ENDCASE

IF !EVAL( aLook[LK_FILTER] ) .AND. !EOF() .AND.; // Record is not within filter range
   !(aLook[LK_TYPE]==LT_FREE)             .AND.; // Key NOT free
   !(aLook[LK_TYPE]==LT_NOTMANDATORY.AND.EMPTY(aLook[LK_SEEK]))  // Key NOT
                                                 // Empty
   lFound := .F.
ENDIF

IF (cAct == "Cda" .OR. cAct == "Ada") .AND. lFound
   Act := "rep"
   IF aLook[LK_KBD]
      dbAct2Kbd( "tab" )  // Simulate pressing "Tab"
   ENDIF
ENDIF

(cAlias)->(ORDSETFOCUS( nInd ))  // Restoring index
dfUsrState( cOldState  )         // Restore old state

RETURN lFound
