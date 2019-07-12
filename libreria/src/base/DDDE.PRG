/******************************************************************************
Progetto       : dBsee 4.1
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/
#include "Common.CH"
#include "dfCTRL.CH"
#include "dfNet.CH"
#include "dfMsg.CH"

#ifdef __XPP__
   // simone 5/11/04 per correzione problema DBGOTO(0)
   // vedi DBGOTO_XPP
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddDe( cState ,;  // i=Inserimento m=Modifica
               aVar, ;    // Valori precaricati delle variabili
               lRawData ) // .T. = Mostra Tutti i campi della tabella   (COMPORTAMENTO DA AMMINISTRATORE)
                          // .F. = Mostra solo i dati definiti nel dbdd (FUNZIONAMENTO STANDARD e DEFAULT)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aTheKey := {}          // Array Chiave primaria
LOCAL nNdx    := 0
LOCAL nCount
LOCAL nOrd    := INDEXORD()  // Nø indice corrente su file master
LOCAL nRec    := recno()     // Nø record file master
LOCAL cSeekExp := "" ,;          // Valore della chiave primaria per la seek
      cTit           ,;          // Titolo quadro
      cFile    := UPPER(ALLTRIM(ALIAS()))

LOCAL numPk    := 0    // numero campi chiave primaria rilevati
LOCAL num      := 0
LOCAL thevar, jjVarVal ,TheKey, TheFun, nVal, aForm := {}, bGet, aGet := {}
LOCAL lRet     := .T.
LOCAL lTrn     := dfIsFun( cFile +"trn()" ) // Decido se chiamare le tran
LOCAL uRet
LOCAL nPage    := 1
LOCAL cPicGet, cPicSay, nMaxScrool
LOCAL nOld
/* ---------------------------------------------------------------------------------------------------------
   Nuove LOCAL
   --------------------------------------------------------------------------------------------------------- */
   LOCAL cField                      // definizione del campo che verra' usata come PROMPT        
   LOCAL aMemo    := {}              // Array dei campi memo che saranno aggiunti su una nuova pagina
   LOCAL aPageLabel                  // Array delle LABEL delle pagine, utilizzato nel caso Len(aMemo)>0
   LOCAL nMaxRow  := 0               // Mi conservo in numero massimo di campi presenti in una pagina per  
                                     // dimensionare l'altezza del TEXFIELD che conterra' il MEMO
   LOCAL nMemo                       // Variabile di servizio
/* --------------------------------------------------------------------------------------------------------- */   

DEFAULT cState   TO DE_STATE_MOD  // default modifica data-entry
DEFAULT aVar     TO {}            // default ID ambiente chiamante
DEFAULT lRawdata TO .F.           // default per compatibilità col funzionamento standard

dbCfgOpen( "dbDD" )                    // Apro il dizionario
dbdd->(DBSEEK( "DBF"+cFile )) ; cTit := TRIM(dbdd->Field_des)
IF ! lRawData .AND. !EMPTY(dbdd->FILE_DEFRM) .AND. dfIsFun(ALLTRIM(dbdd->FILE_DEFRM)+"EXE()")
   EVAL( &("{|aInh|" +ALLTRIM(dbdd->FILE_DEFRM) +"EXE([" +cState +"],,,,,,aInh)}"),aVar )
   dbSelectArea( cFile )
   RETURN !M->Act=="esc" // E' uno schifo, ma per ora non c'e' di meglio
ENDIF

dbdd->(DBSEEK( "NDX"+cFile ))
WHILE "NDX"+cFile = UPPER(TRIM(dbdd->RecTyp+dbdd->file_name)) .AND.;
      !dbdd->(EOF())

   IF dbdd->File_mode == "P"          // E' CHIAVE PRIMARIA
      cSeekExp := ddIndexExp()
              // Riformatto per WIN400
      nNdx := VAL(STR(DBDD->NdxIncN)) // Memorizzo indice
      dbdd->(dbSeek( "KEY"+ PADR(cFile,8) +STR(nNdx,3) ))  // Composizione KEY

      WHILE "KEY" +PadR(cFile,8) +STR(nNdx,3) == ;
            UPPER(dbdd->RecTyp +dbdd->file_name +STR(dbdd->NdxIncN,3)) .AND.;
            !dbdd->(EOF())
         AADD( aTheKey, ALLTRIM(UPPER(dbdd->Field_Name)) )
         dbdd->(DBSKIP())
      END

      EXIT
   ENDIF
   dbdd->(DBSKIP())
ENDDO

IF cState==DE_STATE_ADD   // In inserimento mando in eof() il Master
   (cFile)->(DBGOTO(0))   // per inizializzare blank le variabini in get
ENDIF

dbdd->( DBSEEK("FIE" +cFile) )
WHILE "FIE"+cFile == UPPER(TRIM(dbdd->RecTyp+dbdd->file_name)) .and.;
      !dbdd->(eof())

   IF lRawData .OR. dbdd->Field_Frm = "1" // Se e' nel FORM inizializza le variabili

      cField   := " ["+dbdd->FIELD_NAME+" | "+ dbdd->FIELD_TYPE+ " "+dfAny2Str(dbdd->FIELD_LEN, 3, "999")+" "+dfAny2Str(dbdd->FIELD_DEC, 3, "999")+"] "
      TheKey   := .F.
      TheVar   := UPPER(ALLTRIM(dBdd->field_name))
      IF ! lRawData .AND. SUBSTR(dbdd->Field_Chk,1,1)=="1"
         TheFun:= &("{|x| ddDeChk(M->" +TheVar +", x)}")
      ELSE
         TheFun:= {||.T.}
      ENDIF

      jjVarVal := (cFile)->( FIELDGET(FIELDPOS(TheVar)) )
      bGet     := &("{|x|IF(x==NIL, M->" +TheVar +",M->" +TheVar +":=x)}")

      IF ASCAN( aTheKey ,TheVar ) # 0              // Chiave primaria
         numPk++
         TheKey  := .T.
      ENDIF

      IF cState==DE_STATE_ADD .AND. ;          // Inserimento e variabile passata
         (nVal := ASCAN( aVar, {|aSub|UPPER(aSub[1])==TheVar} )) >0
         jjVarVal = EVAL( aVar[nVal][2] )
         IF TheKey           .AND. ; // Chiave primaria
            !EMPTY(jjVarVal)         // Campo ereditato non vuoto
            TheFun := {||.F.}        // Ne salto l'edit
         ENDIF
      ENDIF
                 // NOME  ,BLOCK, BUFFER VALORE
      AADD( aGet, TheVar ) // Array sul quale fare le get
      PRIVATE &TheVar
      &TheVar := jjVarVal

      ATTACH STR(100+LEN(aGet)) TO aForm SAY IIF(lRawData, cField,"")+PADR(dBdd->field_des,20) AT Num, 0 PAGE nPage
      
      /* -----------------------------------------
         Evidenzio i campi della chiave primaria
         ----------------------------------------- */
         IF TheKey   
      	    aTail(aForm)[FORM_SAY_CLRID] := DFXPPCLRSELECT({"[10]/",NIL,"N/W*",NIL},{"N/G","G+/G","N/W*","W+/BG"}) 
         ENDIF	
      /* ----------------------------------------- */   
      
      cPicGet := ALLTRIM(dBdd->field_pic)
      cPicSay := ALLTRIM(dbdd->Field_pico)

      nMaxScrool := MAXCOL()-46

      IF LEFT(cPicSay,2)=="@S" .AND. VAL(SUBSTR(cPicSay,3))>nMaxScrool
         cPicSay := "@S" +ALLTRIM(STR(nMaxScrool))
      ENDIF
      IF LEFT(cPicGet,2)=="@S" .AND. VAL(SUBSTR(cPicGet,3))>nMaxScrool
         cPicGet := "@S" +ALLTRIM(STR(nMaxScrool))
      ENDIF

      IF LEN(cPicSay)+24 > MAXCOL()-2
         cPicSay := "@S" +ALLTRIM(STR(nMaxScrool))
      ENDIF
      IF LEN(cPicGet)+24 > MAXCOL()-2
         cPicGet := cPicSay
      ENDIF
      IF dbdd->Field_Type == "D"
      	 cPicGet := "99/99/9999"
      	 cPicSay := "99/99/9999"
      ENDIF	 

      IF cState==DE_STATE_MOD .AND. ! lRawData .AND. TheKey // La chiave primaria non e' editata in MOD. Lo salto se lRawData
         ATTACH STR(100+LEN(aGet)) TO aForm SAY jjVarVal AT Num, 22 PAGE nPage
      ELSE
         IF dbdd->FIELD_TYPE == "M"                    
         	      aRemove(aForm, len(aForm), 1)
         	      ATTACH STR(LEN(aGet)) TO aMemo GET AS TEXTFIELD &theVar ;
                                      AT  1,  0,12,90                        ;  //x, y, Ydim, XDim
                                      SYSFUNCTION "dfMemo"                   ; // Funzione di sys
                                      VARNAME TheVar                         ;
                                      PROMPT cField+dBdd->field_des         
  
                ATAIL(aMemo)[FORM_TXT_MESSAGE] := dbdd->Field_msg       // Setto il messaggio altrimenti va in errore
                ATAIL(aMemo)[FORM_GET_VAR]     := bGet
                Num --
         ELSEIF dbdd->FIELD_TYPE == "L"             
	              ATTACH STR(LEN(aGet)) TO aForm GET AS CHECKBOX &TheVar ;
                                               PROMPT ""          ;
                                               AT Num, 46         ;
                                               SIZE    {100,30}   ;
                                               VALUEON  .T.       ;
                                               VALUEOFF .F.       ;
                                               GAP     1          ;
                                               PAGE    nPage      ;
                                               MESSAGE dbDd->Field_msg;
                                               VARNAME TheVar
                ATAIL(aForm)[FORM_CHK_VAR]   := bGet                                
                ATAIL(aForm)[FORM_CHK_ACTIVE] := TheFun

         ELSE 
                ATTACH STR(LEN(aGet)) TO aForm GET bGet ;
                                               AT Num, 46              ;
                                               PAGE nPage              ;
                                               PICTUREGET cPicGet      ;
                                               PICTURESAY cPicSay      ;
                                               CONDITION  TheFun       ;
                                               MESSAGE dbDd->Field_msg
                ATAIL(aForm)[FORM_GET_CONDITION] := TheFun
                ATAIL(aForm)[FORM_GET_VAR]       := bGet                                
         ENDIF
         
      ENDIF

      nMaxRow := max(nMaxRow, num)
      IF ++num>MAXROW()-12
         nPage++
         num:=0
      ENDIF
   ENDIF
   dbdd->(DBSKIP())
ENDDO

/* ------------------------------------------------------------------ 
   Aggiungo i campi memo, ognuno su una pagina diversa
   e assegno le etichette alle pagine
   ------------------------------------------------------------------ */
   IF Len(aMemo) >0
     nMaxRow := max(nMaxRow, 12)         //Controllo sull'altezza minima di un campo memo
   	  aPageLabel := array(nPage+len(aMemo))
   	  aFill(aPageLabel, "Campi")
   ENDIF	
   FOR nMemo := 1 TO Len(aMemo)
       aPageLabel[nPage+nMemo]      := alltrim(right(aMemo[nMemo, FORM_TXT_PROMPT],30))

       aMemo[nMemo, FORM_CTRL_PAGE] := nMemo+nPage                                   // Assegno il campo memo alla pagina
       aMemo[nMemo, FORM_TXT_BOTTOM]:= nMaxRow                                       // Dimensiono l'altezza del campo memo

       aAdd(aForm, aMemo[nMemo])                                                     // Aggiungo il campo memo all'array dei control  
   NEXT	 
/* ------------------------------------------------------------------- */
DO CASE
   CASE num<1 .AND. nPage==1
        dbmsgerr( dfStdMsg(MSG_DDDE01) +cTit +dfStdMsg(MSG_DDDE02) )
        lRet := .F.

   CASE ( numPk < len(aTheKey) ) .AND. ( !EMPTY( aTheKey[1] ) )
        dbmsgerr( dfStdMsg(MSG_DDDE03) +cTit +dfStdMsg(MSG_DDDE04) )
        lRet := .F.

   OTHERWISE

        // Lock del record in modifica
        IF cState==DE_STATE_MOD                   // In modifica
           IF !(cFile)->(dfNet( NET_RECORDLOCK )) // Se non riesce il blocco
              dbSelectArea( cFile )
              RETURN .F.                          // Record Sospende
           ENDIF
        ENDIF

        // Simone 30/08/07
        // mantis 0001320: errore su tabelle tipo CATANA,ATTANA
        // c'Š errore perche le variabili sono private e nel thread separato non ci pu• accedere
        // come workaround disabilito tooltip caratteri rimanenti
        nOld := MagicHelp():nMinChars 
        MagicHelp():nMinChars := 0

        DO WHILE .T.
           IF (cFile)->(dfAutoForm( NIL, NIL,;
                                    aForm,;
                                    dfStdMsg(MSG_DDDE05) +cTit +" (a)", cState, NIL, NIL, aPageLabel))
              // CONFERMA REGISTRAZIONE

              IF cState==DE_STATE_ADD           // INSERIMENTO

                 // Controlli di rete in inserimento record
                 ddFileLock( DD_LOCK, cFile )  // Lock file da modificare

                 IF !EMPTY(nNdx)         // Se ho un'indice
                    (cFile)->(ORDSETFOCUS( nNdx )) // Controllo non duplicazione
                    (cFile)->(dbSeek( 0->(&cSeekExp) )) // chiave primaria
                    (cFile)->(ORDSETFOCUS( nOrd )) // Resetto indice corrente
                    IF !(cFile)->(Eof())
                       ddFileLock( DD_UNLOCK, cFile )
                       dbmsgerr( dfStdMsg(MSG_DDDE06) +PADR(&cSeekExp,30)+ dfStdMsg(MSG_DDDE07) )
                       LOOP
                    ENDIF

                 ENDIF

                 // Aggiungo un record
                 IF !(cFile)->(dfNet( NET_APPEND )) // Se non riesce append
                    ddFileLock( DD_UNLOCK, cFile )  // record Sospende
                    dbSelectArea( cFile )
                    MagicHelp():nMinChars := nOld
                    RETURN .F.
                 ENDIF

              ENDIF

              IF cState==DE_STATE_MOD
                 (cFile)->(DBGOTO(nRec))
                 IF lTrn
                    IF !&(ALLTRIM(cFile) +"trn( [ltr], [" +cState +"])")
                       (cFile)->(dfNet( NET_RECORDUNLOCK ))
                       MagicHelp():nMinChars := nOld
                       RETURN .F.
                    ENDIF
                    uRet := &(ALLTRIM(cFile) +"trn( [rtt] )")
                    uRet := &(ALLTRIM(cFile) +"trn( [utr], [" +cState +"] )")
                 ENDIF
              ENDIF

              // REPLACE
              FOR nCount := 1 TO LEN(aGet)
                 TheVar  := aGet[nCount]
                 IF ASCAN( aTheKey ,TheVar ) # 0   .and. ; // Chiave primaria
                    cState # DE_STATE_ADD                  // se non sono in
                 ELSE
                    (cFile)->(FIELDPUT(FIELDPOS(TheVar), 0->(&TheVar) ))
                 ENDIF                                     // salto..........
              NEXT

              IF lTrn
                 uRet := &(ALLTRIM(cFile) +"trn( [ltr], [" +cState +"], .F. )")
                 uRet := &(ALLTRIM(cFile) +"trn( [ptt] )")
                 uRet := &(ALLTRIM(cFile) +"trn( [ltt], [" +cState +"] )")
                 uRet := &(ALLTRIM(cFile) +"trn( [utr], [" +cState +"] )")
              ENDIF

              IF cState==DE_STATE_ADD
                 ddFileLock( DD_UNLOCK, cFile )
              ENDIF
           ELSE

              IF cState==DE_STATE_ADD     // In inserimento se non ho appeso
                 (cFile)->(dbGoto(nRec))  // riposiziono record master
              ENDIF

           ENDIF

           (cFile)->(DBCOMMIT())
           (cFile)->(dfNet( NET_RECORDUNLOCK ))

           EXIT

        ENDDO

        // riabilita tooltip caratteri rimanenti
        MagicHelp():nMinChars := nOld
ENDCASE
dbSelectArea( cFile )
RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddDeChk( uVar, nPrePost )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T.
IF nPrePost != FORM_PREGET
   lRet := !EMPTY(uVar)
   IF !lRet
      dbMsgErr( dfStdMsg(MSG_DDDE08) )
   ENDIF
ENDIF
RETURN lRet
