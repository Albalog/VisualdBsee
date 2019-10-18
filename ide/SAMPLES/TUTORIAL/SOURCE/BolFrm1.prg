/******************************************************************************
 Progetto       : Tutorial
 Sottoprogetto  : Tutorial
 Programma      : V:\SAMPLES\TUTORIAL\source\BolFrm1.prg
 Template       : V:\bin\..\tmp\xbase\form.tmp
 Descrizione    : Piede Bolla
 Programmatore  : Demo
 Data           : 13-07-06
 Ora            : 16.44.03
******************************************************************************/

                                                     // File include del programma
#INCLUDE "Common.ch"                                 // Include define comunemente utilizzate
#INCLUDE "dfCtrl.ch"                                 //   "       "    per control
#INCLUDE "dfGenMsg.ch"                               //   "       "     "  messaggi
#INCLUDE "dfIndex.ch"                                //   "       "     "  ddIndex()
#INCLUDE "dfLook.ch"                                 //   "       "     "  dbLook()
#INCLUDE "dfMenu.ch"                                 //   "       "     "  menu di oggetto
#INCLUDE "dfNet.ch"                                  //   "       "     "  network
#INCLUDE "dfSet.ch"                                  //   "       "     "  settaggi di ambiente
#INCLUDE "dfWin.ch"                                  //   "       "     "  oggetti Visual dBsee
* #COD OITOP0 * #END Punto di dichiarazione file INCLUDE *.ch per file sorgente


REQUEST dfMemo

MEMVAR Act, Sa, A, EnvId, SubId, BackFun           //  Variabili di ambiente dBsee

STATIC  codbol                                    ,; // Codice Bolla
        codvet                                    ,; // Codice Vettore
        notpie                                       // Info Piede Bolle

STATIC lBreak := .F.                              ,; // Uscita  form
       oWin   := NIL                              ,; // Oggetto form
       aInh   := {}                               ,; // Array con campi ereditati da oggetto
       aInhSon:= NIL                              ,; // Array con campi ereditati da ListBox
       aFile  := {}                               ,; // Array dei file aperti dall' oggetto
       nRec   := 0                                ,; // Record corrente
       cState := DE_STATE_INK                     ,; // Stato della gestione
       cDmmVar:= ""                               ,; // Variabile di utilit… per Radio/Check
       nWin   := 0                                   // Flag per evitare la ricorsione dell'oggetto

* #COD OITOP1 * #END Punto di dichiarazione STATICHE a livello di file sorgente

         /* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            ³           TABELLA METODI DELL'OGGETTO FORM             ³
            ÃÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
            ³ nø ³ mtd.³ Descrizione                                 ³
            ÃÄÄÄÄÅÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
            ³  1 ³ exe ³ Esecutore                                   ³
            ³  2 ³ dbf ³ Apre la base dati                           ³
            ³  3 ³ act ³ Attivazione oggetto                         ³
            ³  4 ³ upw ³ Update window ( aggiornamento oggetto )     ³
            ³  5 ³ ink ³ Inkey su tasti e pulsanti                   ³
            ³  6 ³ brk ³ Break  ( forza l'uscita da inkey )          ³
            ³  7 ³ end ³ Fine operazioni                             ³
            ÃÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
            ³          METODI PRESENTI SOLO SE UTILIZZATI            ³
            ÃÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
            ³  8 ³ get ³ Immissione dati                             ³
            ³  9 ³ dcc ³ Validazione generale sui dati immessi       ³
            ³ 10 ³ del ³ Eliminazione record                         ³
            ³ 11 ³ ltt ³ Log the transaction  (transazione append)   ³
            ³ 12 ³ ptt ³ Put the transaction  (transazione replace)  ³
            ³ 13 ³ rtt ³ Remove the transaction ( eliminazione t.)   ³
            ÃÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
            ³           METODI GENERATI SOLO IN CASO DI              ³
            ³    PRESENZA DI CONTROL LISTBOX  OPERANTI SU FILE       ³
            ÃÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
            ³ 14 ³ anr ³ Add New Row        INS   = inserimento riga ³
            ³ 15 ³ mcr ³ Modify Current Row BARRA = modifica    riga ³
            ³ 16 ³ ecr ³ Erase Current row  CANC  = elimina     riga ³
            ÀÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

*******************************************************************************
FUNCTION BolFrm1Exe(                               ; // [ 01 ]  ESECUTORE OPERAZIONI
                     cMode                        ,; // Modalita' operativa oggetto
                     nTbOrd                       ,; // Indice
                     bTbKey                       ,; // Chiave
                     bTbFlt                       ,; // Filtro
                     bTbBrk                       ,; // Break
                     cClose                       ,; // Modalita' chiusura  oggetto
                     arrInh                        ) // Array dei campi ereditati
*******************************************************************************
LOCAL  lRet    := .F.                                // Valore ritornato

* #COD OBEXE0 * #END //  Esegue le operazioni di base per attivazione oggetto FORM

DEFAULT cMode  TO DE_STATE_INK                       // Modalit… operativa completa
DEFAULT cClose TO W_OC_RESTORE                       // Modalit… chiusura  restore
DEFAULT arrInh TO {}                                 // Array dei campi ereditati

PRIVATE  EnvId:="BolFrm1" ,SubId:=""                 // Identificativi per help

nWin++
IF nWin==1

   aInh   := arrInh                                  // Riassegna array campi ereditati
   cState := cMode                                   // Riassegna lo stato sulla modalit… operativa

   * #COD OIEXE5 * #END Dopo i settaggi dell'oggetto


   IF BolFrm1Dbf()                                   // Apre la base dati

      BolFrm1Act()                                   // Attivazione oggetto

      IF cMode==DE_STATE_INK
         tbSetKey(         ;                         // Attiva le condizioni di filtro su oggetto ( vedere Norton Guide )
                   oWin   ,;                         // Oggetto
                   nTbOrd ,;                         // Ordine
                   bTbKey ,;                         // Key
                   bTbFlt ,;                         // Filtro
                   bTbBrk  )                         // Break
      ENDIF

      tbConfig( oWin )                               // Riconfigura i parametri interni dell'oggetto ( vedere Norton Guide )
      * #COD OIEXE7 * #END Dopo caricamento e setup oggetto, prima del display oggetto
      BolFrm1Ink() ;BolFrm1End(cClose) ;lRet := .T.

   END
   dfClose( aFile, .T., .F. )                        // Chiusura base dati ( vedere Norton Guide )

ENDIF
nWin--

* #COD OAEXE0 * #END //  Esegue le operazioni di base per attivazione oggetto FORM

RETURN lRet

*******************************************************************************
FUNCTION BolFrm1Dbf()                                // [ 02 ] APERTURA DATABASE
*******************************************************************************
* #COD OBDBF0 * #END //  Apertura della base dati

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³  MASTER FILE   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !dfUse( "P_Bolle" ,NIL ,aFile ) ;RETU .F. ;END    // Funzione di apertura file (vedere Norton Guide)



* #COD OADBF0 * #END //  Apertura della base dati

RETURN .T.

*******************************************************************************
FUNCTION BolFrm1Act()                                // [ 03 ] INIZIALIZZA OGGETTO
*******************************************************************************
LOCAL aPfkItm

* #COD OBACT0 * #END //  Inizializzazione oggetto oWin

lBreak := .F.                                        // Condizione di break su oggetto posta a FALSE

IF oWin!=NIL ;RETURN oWin ;END                       // Si ritorna l'oggetto se gi… inizializzato

M_Cless()                                            // Stato di attesa con mouse a clessidra

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Inizializza oggetto ( vedere Norton Guide ) ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

oWin := P_Bolle->(TbBrwNew( 569                   ,; // Prima  Riga
                         0                        ,; // Prima  Colonna
                       343                        ,; // Ultima Riga
                       380                        ,; // Ultima Colonna
                      W_OBJ_FRM                             ,; // Tipo oggetto ( form )
                      NIL ,; // Label
                      W_COORDINATE_PIXEL                    )) // Gestione in Pixel

oWin:W_TITLE     := "Piede Bolla"                    // Titolo oggetto
oWin:W_KEY       := NIL                              // Non esegue la seek
oWin:W_FILTER    := {||.T.}                          // CodeBlock per il filtro
oWin:W_BREAK     := {||.F.}                          // CodeBlock per il break
oWin:W_PAGELABELS:= {}                               // Array delle pagine
oWin:W_PAGERESIZE:= {}
ATTACH PAGE LABEL "Pagina n.1" TO oWin:W_PAGELABELS
oWin:W_MENUHIDDEN:= .F.                              // Stato attivazione barra azioni
oWin:W_COLORARRAY[AC_FRM_BACK  ] := "B+/G"           // Colore di FONDO
oWin:W_COLORARRAY[AC_FRM_BOX   ] := "B+/G"           // Colore di BOX
oWin:W_COLORARRAY[AC_FRM_HEADER] := "RB+/B*"         // Colore di HEADER ON
oWin:W_COLORARRAY[AC_FRM_OPTION] := "W+/BG"          // Colore di ICONE

oWin:W_BG_TOP ++
oWin:W_RP_TOP ++ ;oWin:nTop++

oWin:border      := XBPDLG_DLGBORDER
oWin:lCenter := .T.
oWin:icon := APPLICATION_ICON
oWin:sysMenu  := .T.
oWin:minButton:= .T.
oWin:maxButton:= .F.
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Control                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oWin:W_MOUSEMETHOD := W_MM_PAGE + W_MM_MOVE          // Inizializzazione ICONE per mouse
* #COD OIACT1 * #END Dopo inizializzazioni oggetto oWin Browse

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Inizializza menu e azioni   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
ATTACH "1" TO MENU oWin:W_MENUARRAY AS MN_LABEL    ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"iam") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^File"                           ; // Etichetta
        EXECUTE  {||dbMsgErr( dfStdMsg( MSG_ADDMENUUND ) )}  ; // Funzione
        MESSAGE  "Operazioni su file corrente"     ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0016000058"
ATTACH "11" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Inserimento"                    ; // Etichetta
        SHORTCUT "add"                             ; // Shortcut
        EXECUTE  {||BolFrm1Get('a')}               ; // Funzione
        MESSAGE  "Inserimento nuovo record"        ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0016000059"
ATTACH "12" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Modifica"                       ; // Etichetta
        SHORTCUT "mod"                             ; // Shortcut
        EXECUTE  {||BolFrm1Get('m')}               ; // Funzione
        MESSAGE  "Modifica record corrente"        ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0016000060"
ATTACH "13" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "C^ancellazione"                  ; // Etichetta
        SHORTCUT "del"                             ; // Shortcut
        EXECUTE  {||BolFrm1Del(.T.)}               ; // Funzione
        MESSAGE  "Cancellazione record corrente"   ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0016000061"
ATTACH "14" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Ricerca su chiavi"              ; // Etichetta
        SHORTCUT "win"                             ; // Shortcut
        EXECUTE  {||P_Bolle->(ddKey())}            ; // Funzione
        MESSAGE  "Ricerca su chiavi"               ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0016000062"
ATTACH "15" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Finestra di ricerca"            ; // Etichetta
        SHORTCUT "A07"                             ; // Shortcut
        EXECUTE  {||P_Bolle->(ddWin())}            ; // Funzione
        MESSAGE  "Apre una finestra per consultazione records"  ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0016000063"
ATTACH "16" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "Record ^successivo"              ; // Etichetta
        SHORTCUT "skn"                             ; // Shortcut
        EXECUTE  {||tbDown(oWin)}                  ; // Funzione
        MESSAGE  "Muove al record successivo"      ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0016000064"
ATTACH "17" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "Record pr^ecedente"              ; // Etichetta
        SHORTCUT "skp"                             ; // Shortcut
        EXECUTE  {||tbUp(oWin)}                    ; // Funzione
        MESSAGE  "Muove al record precedente"      ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0016000065"
ATTACH "Z1" TO MENU oWin:W_MENUARRAY AS MN_LABEL  ; //
        BLOCK    {||if((cState$"iam"),MN_SECRET,MN_OFF)}  ; // Condizione di stato di attivazione
        PROMPT   dfStdMsg( MSG_FORMESC )           ; // Label
        SHORTCUT "esc"                             ; // Azione (shortcut)
        EXECUTE  {||lBreak:=.T.}                   ; // Funzione
        MESSAGE  dfStdMsg( MSG_FORMESC )             // Message
ATTACH "Z2" TO MENU oWin:W_MENUARRAY AS MN_LABEL  ; //
        BLOCK    {||if((cState$"am"),MN_SECRET,MN_OFF)}  ; // Condizione di stato di attivazione
        PROMPT   dfStdMsg( MSG_FORMWRI )           ; // Label
        SHORTCUT "wri"                             ; // Azione (shortcut)
        EXECUTE  {||Act:="wri"}                    ; // Funzione
        MESSAGE  dfStdMsg( MSG_FORMWRI )             // Message
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("add")}               ; //
        WHEN    {|| (cState $ "i") }               ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Inserimento"                     ; //
        TOOLTIP "Inserimento  (F3)"                ; //
        IMAGES  TOOLBAR_ADD                        ; //
        ID "0016000157"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("mod")}               ; //
        WHEN    {|| (cState $ "i") }               ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Modifica"                        ; //
        TOOLTIP "Modifica  (F4)"                   ; //
        IMAGES  TOOLBAR_MOD                        ; //
        ID "0016000158"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("del")}               ; //
        WHEN    {|| (cState $ "i") }               ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Cancellazione"                   ; //
        TOOLTIP "Cancellazione  (F6)"              ; //
        IMAGES  TOOLBAR_DEL                        ; //
        ID "0016000159"
ATTACH TOOLSEPARATOR TO oWin                         // ACTTBR.TMP
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("win")}               ; //
        WHEN    {|| (cState $ "i") }               ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Ricerca su chiavi"               ; //
        TOOLTIP "Ricerca su chiavi  (F7)"  ; //
        IMAGES  TOOLBAR_FIND                       ; //
        ID "0016000161"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("A07")}               ; //
        WHEN    {|| (cState $ "i") }               ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Finestra di ricerca"             ; //
        TOOLTIP "Finestra di ricerca  (Alt-F7)"  ; //
        IMAGES  TOOLBAR_FIND_WIN                   ; //
        ID "0016000162"
ATTACH TOOLSEPARATOR TO oWin                         // ACTTBR.TMP
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("wri")}               ; //
        WHEN    {|| (cState $ "am") }              ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Conferma i dati (F10)"           ; //
        TOOLTIP "Conferma i dati (F10)"  ; //
        IMAGES  TOOLBAR_WRITE_H                    ; //
        ID "0016000164"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("esc")}               ; //
        WHEN    {|| (cState $ "iam") }             ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Fine operazioni (Esc)"           ; //
        TOOLTIP "Fine operazioni (Esc)"  ; //
        IMAGES  TOOLBAR_ESC_H                      ; //
        ID "0016000165"
ATTACH TOOLSEPARATOR TO oWin                         // ACTTBR.TMP
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("skp")}               ; //
        WHEN    {|| (cState $ "i") }               ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Record precedente"               ; //
        TOOLTIP "Record precedente  (-)"  ; //
        IMAGES  TOOLBAR_PREV                       ; //
        ID "0016000167"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("skn")}               ; //
        WHEN    {|| (cState $ "i") }               ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Record successivo"               ; //
        TOOLTIP "Record successivo  (+)"  ; //
        IMAGES  TOOLBAR_NEXT                       ; //
        ID "0016000168"
ATTACH TOOLSEPARATOR TO oWin                         // ACTTBR.TMP
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("hlp")}               ; //
        WHEN    {|| (cState $ "iam") }             ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Aiuto (F1)"                      ; //
        TOOLTIP "Aiuto (F1)"                       ; //
        IMAGES  TOOLBAR_HELP_H                     ; //
        ID "0016000170"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("ush")}               ; //
        WHEN    {|| (cState $ "iam") }             ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Aiuto (Shift-F1)"                ; //
        TOOLTIP "Aiuto (Shift-F1)"                 ; //
        IMAGES  TOOLBAR_KEYHELP_H                  ; //
        ID "0016000171"
* #COD OIACT2 * #END Dopo dichiarazione ATTACH del menu per oggetto oWin

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³INIZIALIZZA ARRAY CON STRUTTURA CAMPI CHIAVE PRIMARIA³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
ATTACH KEY "globalexp" TO oWin:W_PRIMARYKEY
ATTACH KEY "CODBOL"  TO oWin:W_PRIMARYKEY          ; // Campo chiave
       KEYTYPE    2                                ; // Tipo  campo chiave
       BLOCK      {|x|IF(x==NIL,CodBol ,CodBol:=x) }  ; // Valorizza la chiave
       VARTYPE    "C"                              ; // Tipo dato
       VARLEN     3                                ; // Lunghezza campo chiave
       EXPRESSION "CodBol"                           // Espressione

* #COD OIACT3 * #END Dopo inizializzazione array  con campi chiave primaria

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Control                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
ATTACH "box0007" TO oWin:W_CONTROL BOX 01          ; // ATTBOX.TMP
                 AT   47,  17, 203, 345            ; // Coordinate
                 BOXTEXT ""                        ; // BOX Text
                 COORDINATE  W_COORDINATE_PIXEL    ; // Tipo Coordinate
                 BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                 COLOR {"W+/G","B+/G","N/G"}         // Array dei colori
ATTACH "RagVet" TO oWin:W_CONTROL FUNCTION dbTabGet( "Vettore" ,CodVet ,"RagVet" ) AT  167, 167,  22, 184  ; // ATTREL.TMP
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // FUNCTION ALIGNMENT
                 COLOR {"N/G","G+/G","B+/G",NIL,NIL}  ; // Array dei colori
                 PICTURESAY "XXXXXXXXXXXXXXXXXXXX"  ; // Picture in say
                 REFRESHID "P_Bolle-CodVet"        ; // Gruppo di refresh
                 DISPLAYIF {||.T.}                   // Display condizionale
ATTACH "but0001" TO oWin:W_CONTROL GET AS PUSHBUTTON "O^k"  ; // ATTBUT.TMP
                 AT   10,  20,  32,  40            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||dbAct2Kbd("wri")}     ; // Funzione di controllo
                 ACTIVE   {||cState $ "iam"}       ; // Stato di attivazione
                 MESSAGE "Registra e chiude"         // Messaggio utente
ATTACH "but0002" TO oWin:W_CONTROL GET AS PUSHBUTTON "A^bbandona"  ; // ATTBUT.TMP
                 AT   10, 280,  32,  80            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||dbAct2Kbd("esc")}     ; // Funzione di controllo
                 ACTIVE   {||cState $ "iam"}       ; // Stato di attivazione
                 MESSAGE "Abbandona"                 // Messaggio utente
ATTACH "CodBol" TO oWin:W_CONTROL GET CodBol AT  201, 112  ; // ATTGET.TMP
                 SIZE       {  32,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // GET ALIGNMENT
                 COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT   "Codice Bolla:"          ; // Prompt
                 PROMPTAT  201 ,   0               ; // Coordinate prompt
                 PICTURESAY "!!!"                  ; // Picture in say
                 CONDITION {|ab|CodBol(ab)}        ; // Funzione When/Valid
                 MESSAGE "Codice Bolla"            ; // Messaggio
                 VARNAME "CodBol"                  ; //
                 REFRESHID "P_Bolle"               ; // Appartiene ai gruppi di refresh
                 ACTIVE {||cState $ "am" }          // Stato di attivazione
ATTACH "CodVet" TO oWin:W_CONTROL GET CodVet AT  171, 112  ; // ATTGET.TMP
                 SIZE       {  44,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // GET ALIGNMENT
                 COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT   "Codice Vettore:"        ; // Prompt
                 PROMPTAT  171 , -16               ; // Coordinate prompt
                 PICTURESAY "!!"                   ; // Picture in say
                 CONDITION {|ab|CodVet(ab)}        ; // Funzione When/Valid
                 MESSAGE "Codice Vettore"          ; // Messaggio
                 VARNAME "CodVet"                  ; //
                 REFRESHID "P_Bolle"               ; // Appartiene ai gruppi di refresh
                 COMBO                             ; // Icona combo
                 ACTIVE {||cState $ "am" }          // Stato di attivazione
ATTACH "NotPie" TO oWin:W_CONTROL GET AS TEXTFIELD NotPie AT   59,  27, 104, 320  ; // ATTGET.TMP
                 COORDINATE  W_COORDINATE_PIXEL ; // Coordinate in Formato Pixel
                 COLOR {"W+/G","G+/G","N/W*","W+/BG","N/G","BG/G"}  ; // Array dei colori
                 CONDITION {|ab|.T.}               ; // Funzione When/Valid
                 SYSFUNCTION "dfMemo"              ; // Funzione di sys
                 MESSAGE "Info Piede Bolle"        ; // Messaggio
                 VARNAME "NotPie"                  ; //
                 REFRESHID "P_Bolle"               ; // Appartiene ai gruppi di refresh
                 PROMPT "Info Piede Bolle"         ; // Prompt
                 BOX   01                          ; // Tipo Box
                 ACTIVE   {||cState $ "am" }         // Stato di attivazione


M_Normal()                                           // Stato mouse normale

* #COD OAACT0 * #END //  Inizializzazione oggetto oWin

RETURN oWin

*******************************************************************************
FUNCTION BolFrm1Upw(        ;                        // [ 04 ]  UPDATE WINDOW  Aggiornamento oggetto
                    cDisGrp )                        //  Id. gruppo di visualizzazione
                                                     //  "#" = aggiorna tutti i control
*******************************************************************************
* #COD OBUPW0 * #END //  Update window oggetto oWin

tbDisItm( oWin ,cDisGrp )                            //  funzione di aggiornamento control (vedere Norton Guide)

* #COD OAUPW0 * #END //  Update window oggetto oWin

RETURN NIL

*******************************************************************************
FUNCTION BolFrm1Ink()                                // [ 05 ] INTERAZIONE CON L'UTENTE
*******************************************************************************
LOCAL cCho

* #COD OBINK0 * #END //  Interazione con l'utente o inkey di tastiera

IF cState!=DE_STATE_INK
   RETURN BolFrm1Get(cState)
ENDIF

WHILE( !lBreak )

   BolFrm1Get(cState)                                //  Visualizza i dati

   cCho := tbink( oWin )                             //  Inkey di tastiera ( vedere Norton Guide )
   * #COD OIINK1 * #END Dopo inkey di tastiera " cCho:=tbInk( oWin ) "


   IF !Empty(cCho)                                   //  Esegue azione sul menu
      EVAL( dfMenuBlock(oWin:W_MENUARRAY,cCho) )    //  dfMenuBlock() ritorna il code block associato
   END    //  alla voce di menu (vedere Norton Guide )
   * #COD OIINK2 * #END Dopo esecuzione scelta di menu

ENDDO

* #COD OAINK0 * #END //  Interazione con l'utente o inkey di tastiera

RETURN NIL

*******************************************************************************
FUNCTION BolFrm1Brk()                                // [ 06 ] COMANDA UN BREAK SULL'OGGETTO
*******************************************************************************
* #COD OBBRK0 * #END //  Comanda un break sull'oggetto
lBreak := .T.
* #COD OABRK0 * #END //  Comanda un break sull'oggetto
RETURN NIL

*******************************************************************************
FUNCTION BolFrm1End(         ;                       // [ 07 ] OPERAZIONI DI CHIUSURA
                     cClose  ;                       // Modalita' chiusura oggetto:
                             ;                       // W_OC_RESTORE =  Restore dello screen
                             )                       // W_OC_DESTROY =  Rilascio dell'oggetto
*******************************************************************************
* #COD OBEND0 * #END //  Chiusura e rilascio oggetto oWin

oWin:=tbEnd( oWin , cClose )                         // ( vedere Norton Guide )

* #COD OAEND0 * #END //  Chiusura e rilascio oggetto oWin

RETURN NIL

*******************************************************************************
FUNCTION BolFrm1Get(           ;                     // [ 08 ]  METODO PER L'INPUT DEI DATI
                    nGetState  ;                     //  Operazione richiesta:
                               ;                     //  DE_STATE_INK =  Consultazione
                               ;                     //  DE_STATE_ADD =  Inserimento
                               )                     //  DE_STATE_MOD =  Modifica
*******************************************************************************
LOCAL  lRet    := .F.                                //  Flag di registrazione dati se .T.
LOCAL  a121Fld := {}                                 //  Array per controllo somma contenuto campi 1:1

* #COD OBGET0 * #END //  Data-entry o ciclo di get


cState := nGetState                                  //  Riassegna statica stato data entry


nRec := P_Bolle->(Recno())                           //  Memorizza il record corrente

IF     cState==DE_STATE_ADD
   P_Bolle->(dbGoBottom()) ;P_Bolle->(dbSkip(1))
ELSEIF cState==DE_STATE_MOD
   IF P_Bolle->(EOF()) ;cState:=DE_STATE_INK ;END
ENDIF

* #COD OIGETA * #END Prima della valorizzazione delle variabili

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ VALORIZZAZIONE VARIABILI DI DATA ENTRY  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

CodBol     := P_Bolle->CodBol                       // Codice Bolla
CodVet     := P_Bolle->CodVet                       // Codice Vettore
NotPie     := P_Bolle->NotPie                       // Info Piede Bolle
* #COD OIGET2 * #END Dopo la valorizzazione delle variabili

IF cState==DE_STATE_ADD
              /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                ³ VALORIZZA I CAMPI EREDITATI DA RELAZIONI 1:N        ³
                ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
   tbInh( oWin ,aInh ,INH_DEF )

ENDIF
* #COD OIGET3 * #END Dopo la valorizzazione dei campi ereditati per 1:1 ed 1:N

BolFrm1Upw( "#" )                                    //  Visualizza i dati da MEMORIA

IF cState==DE_STATE_INK ;RETU .T. ;END               //  Uscita in stato consultazione dati
IF cState==DE_STATE_ADD ;tbGetTop(oWin) ;END
IF cState==DE_STATE_MOD ;tbGetTop(oWin,.T.) ;END
* #COD OIGET4 * #END Prima della chiamata al modulo gestore delle get " tBget() "

WHILE( .T. )

   IF ! tbGet( oWin ,{||BolFrm1Dcc() } ,cState )     //  Modulo gestore delle get
      * #COD OIGET5 * #END Rinuncia registrazione dati prima di uscire da DO WHILE get
      EXIT
   END

   * #COD OIGET6 * #END Prima della scrittura campi su disco alla conferma dati

   IF cState==DE_STATE_ADD

      * #COD OIGETB * #END Prima calcolo chiavi primarie / univoche


      P_Bolle->(dbAppend())
      * #COD OIGETC * #END Dopo calcolo chiavi primarie / univoche

      nRec := P_Bolle->(Recno())                     //  Memorizza il nuovo record

      tbInh( oWin ,aInh ,INH_WRI )                   //  Scrive su disco i campi ereditati ( vedere Norton Guide )

   END

   * #COD OIGETD * #END Dopo la scrittura campi ereditati


     /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       ³             REPLACE DEI CAMPI              ³
       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
   P_Bolle->(dbGoto(nRec))                           //  Riposiziona prima di scrivere

   P_Bolle->CodBol     := CodBol                    // Codice Bolla
   P_Bolle->CodVet     := CodVet                    // Codice Vettore
   P_Bolle->NotPie     := NotPie                    // Info Piede Bolle

   * #COD OIGET7 * #END Dopo la scrittura campi su disco alla conferma dati

   P_Bolle->(dbCommit())                             //  Aggiorna il record su disco

   * #COD OIGET8 * #END Dopo la scrittura campi da relazioni 1:1

   * #COD OIGET9 * #END Dopo la scrittura transazioni e sblocco semaforo di rete
   lRet := .T.
   EXIT                                              //  Uscita dopo aggiornamento dati

ENDDO
P_Bolle->(dbGoto(nRec))                              //  Riposiziona il record


cState := DE_STATE_INK                               //  Imposta stato di consultazione

* #COD OAGET0 * #END //  Data-entry o ciclo di get

RETURN lRet

*******************************************************************************
FUNCTION BolFrm1Dcc()                                // [ 09 ]  CONTROLLI CONGRUENZA DATI
*******************************************************************************
LOCAL  lRet := .T.

* #COD OBDCC0 * #END //  Controlli di congruenza dati

* #COD OADCC0 * #END //  Controlli di congruenza dati

RETURN lRet

*******************************************************************************
FUNCTION BolFrm1Del(       ;                         // [ 10 ] CANCELLAZIONE RECORD
                    lAsk   )                         //  .T. chiede conferma prima della cancellazione
*******************************************************************************
* #COD OBDEL0 * #END //  Cancellazione record corrente

DEFAULT lAsk    TO .F.
DEFAULT oWin    TO BolFrm1Act()

IF lAsk
   IF !dfYesNo( dfStdMsg(MSG_DE_DEL) ,.F.) ;RETURN .F. ;END
ENDIF

* #COD OIDEL1 * #END Prima della cancellazione record corrente

IF P_BolleDid()                                      // Delete integrity Data (dbRid.prg)
                                                     // Funzione di cancellazione su file
   TbEtr( oWin )                                     // Stabilizza la TBrowse corrente
ENDIF

* #COD OADEL0 * #END //  Cancellazione record corrente
RETURN .T.

*******************************************************************************
STATIC FUNCTION CodBol( nPrePost ) // CodBol    , C,   3,   0
*******************************************************************************
LOCAL aDbL ,lRet:=.T.
* #COD IIGSF10003 * #END
DO CASE
   CASE nPrePost == FORM_PREGET

        * #COD IIEDTB0003 * #END
        IF cState==DE_STATE_MOD
           RETURN .F.
        ENDIF

        * #COD IIEDTA0003 * #END

   CASE nPrePost == FORM_POSTGET .OR. nPrePost == FORM_CHKGET

        * #COD IICHKB0003 * #END
        IF !P_Bolle->(ddPkChk(  1 ,tbPkExp(oWin), NIL, cState ))
           RETURN .F.
        ENDIF

        * #COD IICHKA0003 * #END

        IF nPrePost == FORM_POSTGET
           * #COD IIGSF50003 * #END
        ENDIF

ENDCASE
* #COD IIGSF90003 * #END

RETURN lRet
*******************************************************************************
STATIC FUNCTION CodVet( nPrePost ) // CodVet    , C,   2,   0
*******************************************************************************
LOCAL aDbL ,lRet:=.T.
* #COD IIGSF10004 * #END
DO CASE
   CASE nPrePost == FORM_PREGET

        * #COD IIEDTB0004 * #END

        * #COD IIEDTA0004 * #END

   CASE nPrePost == FORM_POSTGET .OR. nPrePost == FORM_CHKGET

        * #COD IICHKB0004 * #END
        IF !dBtabChk("Vettore" ,{|x|if(x==NIL,CodVet,CodVet:=x)}, LT_NOTMANDATORY  )
           lRet := .F.
        ELSE
           IF nPrePost == FORM_POSTGET
              tbDisRef( oWin ,"CodVet" )
           END
        ENDIF


        * #COD IICHKA0004 * #END

        IF nPrePost == FORM_POSTGET
           * #COD IIGSF50004 * #END
        ENDIF

ENDCASE
* #COD IIGSF90004 * #END

RETURN lRet


* #COD OIBOT1 * #END Fine file sorgente per oggetto form

