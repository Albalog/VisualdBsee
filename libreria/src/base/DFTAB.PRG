/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/

#include "Common.ch"
#include "dfWin.ch"
#include "dfset.ch"
#include "dftab.ch"
#include "dfctrl.ch"
#include "dfnet.ch"
#include "dfMsg.ch"

#ifdef __XPP__
   // simone 5/11/04 per correzione problema DBGOTO(0)
   // vedi DBGOTO_XPP
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif

MEMVAR Act, Envid

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dBTabFrm( jjTabId ,; // Nome tabella
                   cState  ,; // operazione add - mod - awc ( add without codify )
                   jjTabPk  ) // Chiave primaria eventualmente predigitata
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL jjTabKey, jjFieNam, jjIoMode, jjFieCnt, bFunChk
LOCAL cInt, jjTabData, jjTabRow, nTabCol
LOCAL aForm := {}, bGet, jjTabCode, cPicSay, cPicGet, nMaxScrool
LOCAL nOld, nPos

MEMVAR EndId
PRIVATE EnvId

DEFAULT jjTabPk TO ""

IF !(cState $ DE_STATE_ADD+DE_STATE_MOD+DE_TAB_WITHOUT_CODIFY )
   RETURN .F.
ENDIF

// Lock del record in modifica
IF cState == DE_STATE_MOD                // In modifica
   IF !dbtabd->(dfNet( NET_RECORDLOCK )) // se non riesce il blocco record
      RETURN .F.                         // Sospende
   ENDIF
ENDIF

EnvId = TRIM(jjTabId)
jjTabId  = Upper(PadR(jjTabId, 8))

DO CASE
   CASE cState == DE_STATE_ADD
        jjIoMode = "def"

   CASE cState == DE_TAB_WITHOUT_CODIFY
        jjIoMode = "def"

   CASE cState == DE_STATE_MOD
        jjIoMode = "rea"
ENDCASE

// Array x informazioni tabella
dbdd->(dbSeek( "DBF"+jjTabId ))

cInt    := ALLTRIM(dbdd->Field_des) // descrizione della tabella

nTabCol := MIN( dbdd->TabFieWos+2, 32 ) // Larghezza delle say con 32 di
                                        // minimo dato dalla larghezza del
                                        // dbdd

// Inizializzazione variabili di memoria x supportare il data entry
jjTabKey = "FIE"+jjTabId
dbdd->(dbSeek( jjTabKey ))
IF dbdd->(eof())
   RETURN .F.
ENDIF

// Valorizzo il codice
jjFieNam = trim(dbdd->Field_name)
PRIVATE &jjFieNam
IF cState == DE_TAB_WITHOUT_CODIFY
   &jjFieNam := jjTabPk
ELSE
   &jjFieNam := dbStrFie(jjIoMode         ,; // operazione
                         dbdd->field_Name ,; // nome campo
                         dbdd->field_type ,; // tipo campo
                         dbdd->field_len  ,; // lunghezza
                         dbdd->field_dec  ,; // decimali
                         1                ,; // Inizio
                         dbtabd->TabCode   ) // Stringa dei dati
ENDIF

// Leggo la stringa dei dati della tabella
jjTabData = dbTabd->TabData
dbdd->(dbskip())
nPos := 0
WHILE UPPER(dbdd->RecTyp+dbdd->File_Name) = jjTabKey .and. !dbdd->(eof())
   nPos++
   jjFieNam = trim(dbdd->Field_name)
   PRIVATE &jjFieNam
   &jjFieNam := dbStrFie(jjIoMode         ,; // operazione
                         dbdd->field_Name ,; // nome campo
                         dbdd->field_type ,; // tipo campo
                         dbdd->field_len  ,; // lunghezza
                         dbdd->field_dec  ,; // decimali
                         dbdd->TabFieSod  ,; // Inizio
                         @jjTabData       ,;   // Stringa dei dati
                         nPos              )
   dbdd->(dbskip())
ENDDO

jjTabRow := 0
dbdd->(dbSeek( jjTabKey ))
WHILE UPPER(dbdd->RecTyp+dbdd->File_Name) = jjTabKey .and. !dbdd->(eof())

   ATTACH "100" TO aForm SAY ALLTRIM(dbdd->Field_des) AT jjTabRow++, 1

   dbdd->(dbskip())
ENDDO

jjTabRow := 0
jjFieCnt := 0
dbdd->(dbSeek(jjTabKey))
if cState $ DE_STATE_MOD+DE_TAB_WITHOUT_CODIFY // se entro in modifica, salto il primo campo
   bGet := &("{|x|IF(x==NIL," +dbdd->Field_name +"," +dbdd->Field_name +":=X)}")
   ATTACH STR(jjFieCnt) TO aForm  GET bGet ;
                                  AT jjTabRow++, nTabCol               ;
                                  PICTUREGET ALLTRIM(dBdd->field_pic)  ;
                                  PICTURESAY ALLTRIM(dBdd->field_pico) ;
                                  CONDITION  {||.F.}

   // L'attach per default crea un codeblock di get su bGet
   // la cosa deve essere corretta
   ATAIL(aForm)[FORM_GET_VAR]       := bGet

   dbdd->(dbskip())
endif
do while UPPER(dbdd->RecTyp+dbdd->File_Name) = jjTabKey .and. !(dbdd->(eof()))

   jjFieCnt++
   IF jjFieCnt = 1 .AND. cState == DE_STATE_ADD
      bFunChk := '{|ab|dbTabDeChk( ab, "'+ jjTabId +'",M->' +dbdd->Field_name
      IF SUBSTR(dbdd->Field_Chk,1,1)=="1"
         bFunChk += ",.T."
      ENDIF
      bFunChk += ")"
   ELSE
      IF SUBSTR(dbdd->Field_Chk,1,1)=="1"
         bFunChk := "{|ab| !(EMPTY(M->" +TRIM(dbdd->Field_name) +").AND.ab!=" +STR(FORM_PREGET) +")"
      ELSE
         bFunChk := "{|ab|.T."
      ENDIF
   ENDIF
   bFunChk += ".AND."
   bFunChk += "EVAL( dfSet(" +ALLTRIM(STR(AI_TABLECHECKCB)) +"), ab, [" +UPPER(ALLTRIM(jjTabKey)) +"], [" +UPPER(ALLTRIM(dbdd->Field_name)) +"])"
   bFunChk += "}"

   bFunChk := &bFunChk

   bGet := &("{|x|IF(x==NIL," +dbdd->Field_name +"," +dbdd->Field_name +":=X)}")

   cPicGet := ALLTRIM(dBdd->field_pic)
   cPicSay := ALLTRIM(dbdd->Field_pico)

   nMaxScrool := MAXCOL()-2-nTabCol

   IF LEFT(cPicSay,2)=="@S" .AND. VAL(SUBSTR(cPicSay,3))>nMaxScrool
      cPicSay := "@S" +ALLTRIM(STR(nMaxScrool))
   ENDIF
   IF LEFT(cPicGet,2)=="@S" .AND. VAL(SUBSTR(cPicGet,3))>nMaxScrool
      cPicGet := "@S" +ALLTRIM(STR(nMaxScrool))
   ENDIF

   IF LEN(cPicSay)+nTabCol > MAXCOL()-2
      cPicSay := "@S" +ALLTRIM(STR(nMaxScrool))
   ENDIF
   IF LEN(cPicGet)+nTabCol > MAXCOL()-2
      cPicGet := cPicSay
   ENDIF

   ATTACH STR(jjFieCnt) TO aForm GET bGet                ;
                                 AT jjTabRow++, nTabCol  ;
                                 PICTUREGET cPicGet      ;
                                 PICTURESAY cPicSay      ;
                                 CONDITION  bFunChk      ;
                                 MESSAGE dbDd->Field_msg

   // L'attach per default crea un codeblock di get su bGet
   // la cosa deve essere corretta
   ATAIL(aForm)[FORM_GET_VAR]       := bGet
   ATAIL(aForm)[FORM_GET_CONDITION] := bFunChk

   dbdd->(dbskip())
ENDDO

//Luca Mantis 1639
// Simone 05/11/07
// mantis 0001320: errore su tabelle tipo CATANA,ATTANA
// c'Š errore perche le variabili sono private e nel thread separato non ci pu• accedere
// come workaround disabilito tooltip caratteri rimanenti
nOld := MagicHelp():nMinChars 
MagicHelp():nMinChars := 0

dfAutoForm( NIL, NIL, aForm, cInt, IF(cState==DE_TAB_WITHOUT_CODIFY,DE_STATE_ADD,cState) )

// riabilita tooltip caratteri rimanenti
MagicHelp():nMinChars := nOld

if Act # "esc"
   dbdd->(dbSeek( jjTabKey))
   jjTabCode = SPACE( len(dbTabd->TabCode))
   * ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   * ³Valorizzo il codice³
   * ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   jjFieNam = trim(dbdd->Field_name)
   private &jjFieNam
   jjTabCode=dbStrFie("wri"            ,; && operazione
                      dbdd->field_Name ,; && nome campo
                      dbdd->field_type ,; && tipo campo
                      dbdd->field_len  ,; && lunghezza
                      dbdd->field_dec  ,; && decimali
                      1                ,; && Inizio
                      jjTabCode         ) && Stringa dei dati
   * ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   * ³Compongo la stringa dei dati³
   * ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   jjTabData = SPACE(len(dbTabd->TabData))
   *sele dbdd  && seleziono il secondo campo
   dbdd->(dbSkip())       && della tabella
   nPos := 1
   do while UPPER(dbdd->RecTyp+dbdd->File_Name) = jjTabKey .and. !(dbdd->(eof()))
      nPos++  

      *
      dbStrFie("wri"            ,; && operazione
               dbdd->field_Name ,; && nome campo
               dbdd->field_type ,; && tipo campo
               dbdd->field_len  ,; && lunghezza
               dbdd->field_dec  ,; && decimali
               dbdd->TabFieSod  ,; && Inizio
               @jjTabData       ,; && Stringa dei dati
               nPos)
      *
      *sele dbdd
      dbdd->(dbskip())
   enddo
   * ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   * ³ Controlli di rete in inserimento record ³
   * ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   if cState $ DE_STATE_ADD+DE_TAB_WITHOUT_CODIFY
      *
      ddFileLock( DD_LOCK, jjTabId )
      *
      *sele dbTabd
      dbtabd->(dbSeek( jjTabId+TAB_PRK+jjTabCode))
      if !(dbtabd->(eof()))
         ddFileLock( DD_UNLOCK, jjTabId )
         dbMsgErr( dfStdMsg(MSG_DFTABFRM03) )
         retu .f.
         *
      endif
      * ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      * ³           Aggiungo un record            ³
      * ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      IF !( dbtabd->(dfNet( NET_APPEND )))  // Se non riesce append record
         ddFileLock( DD_UNLOCK, jjTabId )   // Sospende
         RETURN .F.
      ENDIF
      *
   endif
   * ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   * ³Scrittura dei campi³
   * ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   dbtabd->TabID      := jjTabID
   dbtabd->TabPrk     := ""
   dbtabd->TabCode    := jjTabCode
   dbtabd->Tabdeleted := [*]
   dbtabd->TabData    := jjTabData
   dbtabd->Tabupdtime := time()
   dbtabd->Tabupddate := date()
   dbtabd->Tabusrlock := ""

   *-------- valorizza alla giusta lunghezza il codice tabella
   dbdd->(dbSeek( jjTabKey ))
   jjTabCode=substr( jjTabCode, 1, dbdd->field_len)
   *
endif
* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
* ³Sblocco del record            ³
* ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbtabd->(DBCOMMIT())
dbtabd->(dfNet( NET_RECORDUNLOCK ))
if cState $ DE_STATE_ADD+DE_TAB_WITHOUT_CODIFY .AND. Act # "esc"
   ddFileLock( DD_UNLOCK, jjTabId )
endif
RETURN .T.

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dbTabDeChk( nAB, jjTabId, cTabCode, lEmpty )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T., jjCodDes, jjDesDes, jjDesData, jjTabDes, nOldRec

DEFAULT lEmpty TO .F.

IF nAB!=FORM_PREGET
   nOldRec  := dbTabd->(recno())
   cTabCode := PADR( dfAny2Str(cTabCode), LEN(dbTabd->TabCode) )
   dbTabd->(dbSeek( jjTabId+TAB_PRK+cTabCode))
   if !dbTabd->(eof())
      dbdd->(dbSeek( "DBF"+jjTabId))
      jjTabDes  := trim(dbdd->field_des)
      dbdd->(dbSeek( "FIE"+jjTabId))
      jjCodDes  := trim(dbdd->field_des)
      dbdd->(dbSkip())
      jjDesDes  := trim(dbdd->field_des)
      jjDesData := LEFT(dbTabd->TabData, dbdd->field_len)

      // simone 15/6/07 sostituite le vecchie dbFrame
      dbMsgErr(dfStdMsg(MSG_DFTABFRM04) +jjTabDes+"//"+;
               jjCodDes +": "+cTabCode+"//"+;
               dfStdMsg(MSG_DFTABFRM06)+"//"+;
               jjDesDes +": "+jjDesData )

//      dbFrameOn(10,10,20,70, dfStdMsg(MSG_DFTABFRM04) +jjTabDes)
//      dbFrameBox( dfStdMsg(MSG_DFTABFRM05) )
//      dbFrameLine("Ä")
//      dbFrameDis( jjCodDes +": "+cTabCode     )
//      dbFrameDis( ""  )
//      dbFrameDis( dfStdMsg(MSG_DFTABFRM06) )
//      dbFrameDis( ""  )
//      dbFrameDis( jjDesDes +": "+jjDesData )
//      dbInk()
//      dbFrameOff()

      lRet := .F.
   ENDIF
   dbtabd->(DBGOTO(nOldRec))
   IF lEmpty .AND. EMPTY(cTabCode)
      lRet := .F.
   ENDIF
ENDIF
RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dBStrFie( jjOpr    ,; // operazione : def - rea - wri - rel
                          jjFieNam ,; // nome campo
                          jjtyp    ,; // typo campo
                          jjlen    ,; // len campo
                          jjdec    ,; // decimali campo
                          jjstart  ,; // inizio campo
                          jjStr    ,; // stringa ove risiede il record a lunghezza fissa
                          nPOS   ) 
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL jjMemNam, jjData, uRet
LOCAL aStr
LOCAL lNewMethod := .F.
uRet := ""
DEFAULT nPOS TO 1

jjMemNam = [M->]+jjFieNam
DO CASE
   CASE jjOpr = "def"
        DO CASE
           CASE jjTyp=[C]
                uRet = space(jjLen)
           CASE jjTyp=[N]
                uRet = 0
           CASE jjTyp=[D]
                uRet = ctod("  -  -  ")
           CASE jjTyp=[L]
                uRet = .T.
        ENDCASE

   CASE jjOpr = "rea"
        aStr  := dfStr2arr(jjStr,TAB_SEPARATORE )
        IF LEN(aStr) > 1
           jjData = aStr[nPos] 
        ELSE
           jjData = substr(jjStr,jjstart,jjLen)
        ENDIF 
        uRet := dbTabConv( jjData, jjTyp )
        /*
        DO CASE
           CASE jjTyp=[C]
                uRet = jjData
           CASE jjTyp=[N]
                uRet = val(jjData)
           CASE jjTyp=[D]
                // Se il 3 char non Š un numero la gestione Š quella nuova
                IF SUBSTR( jjData, 3, 1 )$"0123456789 "
                   uRet = dfNtoD( VAL(SUBSTR(jjData,7,2)) ,;
                                  VAL(SUBSTR(jjData,5,2)) ,;
                                  VAL(SUBSTR(jjData,1,4))  )
                ELSE
                   uRet = ctod(jjData)
                ENDIF
           CASE jjTyp=[L]
                uRet = (UPPER(jjData)=="T")
        ENDCASE
        */

   CASE jjOpr = "wri"
        jjData = &jjMemNam
        DO CASE
           CASE jjTyp=[C]
                uRet = jjData
           CASE jjTyp=[N]
                uRet = STR(jjData,jjLen,jjDec)
           CASE jjTyp=[D]
                uRet = DTOS(jjData)
           CASE jjTyp=[L]
                uRet = IF(jjData,"T","F")
        ENDCASE

        aStr          := dfStr2arr(dbtabd->TabData,TAB_SEPARATORE )
        lNewMethod    := LEN(aStr) > 1

        IF lNewMethod .AND. nPOS > 1
           jjStr      := stuff(jjStr,jjstart + (nPOS - 2) ,jjLen,uRet+ TAB_SEPARATORE) 
        ELSE 
           jjStr      := stuff(jjStr,jjstart,jjLen,uRet) //+ TAB_SEPARATORE
        ENDIF 
        uRet := jjStr

   CASE jjOpr = "rel"
        RELEASE &jjMemNam
ENDCASE

RETURN uRet
