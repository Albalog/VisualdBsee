/******************************************************************************
 Progetto       : Tutorial
 Sottoprogetto  : Tutorial
 Programma      : V:\SAMPLES\TUTORIAL\source\BolEdb.prg
 Template       : V:\bin\..\tmp\xbase\form.tmp
 Descrizione    : Edit Riga Bolle
 Programmatore  : Demo
 Data           : 13-07-06
 Ora            : 16.44.02
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


MEMVAR Act, Sa, A, EnvId, SubId, BackFun           //  Variabili di ambiente dBsee

STATIC  codbol                                    ,; // Codice Bolla
        numrigbol                                 ,; // Numero riga Bolla
        codart                                    ,; // Codice Articolo
        przart                                    ,; // Prezzo
        qtaart                                       // Quantit…

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
FUNCTION BolEdbExe(                                ; // [ 01 ]  ESECUTORE OPERAZIONI
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

PRIVATE  EnvId:="BolEdb" ,SubId:=""                  // Identificativi per help

nWin++
IF nWin==1

   aInh   := arrInh                                  // Riassegna array campi ereditati
   cState := cMode                                   // Riassegna lo stato sulla modalit… operativa

   * #COD OIEXE5 * #END Dopo i settaggi dell'oggetto


   IF BolEdbDbf()                                    // Apre la base dati

      BolEdbAct()                                    // Attivazione oggetto

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
      BolEdbInk() ;BolEdbEnd(cClose) ;lRet := .T.

   END
   dfClose( aFile, .T., .F. )                        // Chiusura base dati ( vedere Norton Guide )

ENDIF
nWin--

* #COD OAEXE0 * #END //  Esegue le operazioni di base per attivazione oggetto FORM

RETURN lRet

*******************************************************************************
FUNCTION BolEdbDbf()                                 // [ 02 ] APERTURA DATABASE
*******************************************************************************
* #COD OBDBF0 * #END //  Apertura della base dati

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³  MASTER FILE   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !dfUse( "R_Bolle" ,NIL ,aFile ) ;RETU .F. ;END    // Funzione di apertura file (vedere Norton Guide)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³  LOOK-UP FILE  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !dfUse( "Articoli" ,NIL ,aFile ) ;RETU .F. ;END
IF !dfUse( "Categ" ,NIL ,aFile ) ;RETU .F. ;END
IF !dfUse( "T_Bolle" ,NIL ,aFile ) ;RETU .F. ;END

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³TRANSACTION FILE³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !dfUse( "Articoli" ,NIL ,aFile ) ;RETU .F. ;END
IF !dfUse( "Clienti" ,NIL ,aFile ) ;RETU .F. ;END

* #COD OADBF0 * #END //  Apertura della base dati

RETURN .T.

*******************************************************************************
FUNCTION BolEdbAct()                                 // [ 03 ] INIZIALIZZA OGGETTO
*******************************************************************************
LOCAL aPfkItm

* #COD OBACT0 * #END //  Inizializzazione oggetto oWin

lBreak := .F.                                        // Condizione di break su oggetto posta a FALSE

IF oWin!=NIL ;RETURN oWin ;END                       // Si ritorna l'oggetto se gi… inizializzato

M_Cless()                                            // Stato di attesa con mouse a clessidra

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Inizializza oggetto ( vedere Norton Guide ) ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

oWin := R_Bolle->(TbBrwNew( 472                   ,; // Prima  Riga
                         0                        ,; // Prima  Colonna
                       440                        ,; // Ultima Riga
                       450                        ,; // Ultima Colonna
                      W_OBJ_FRM                             ,; // Tipo oggetto ( form )
                      NIL ,; // Label
                      W_COORDINATE_PIXEL                    )) // Gestione in Pixel

oWin:W_TITLE     := "Edit Riga Bolle"                // Titolo oggetto
oWin:W_KEY       := NIL                              // Non esegue la seek
oWin:W_FILTER    := {||.T.}                          // CodeBlock per il filtro
oWin:W_BREAK     := {||.F.}                          // CodeBlock per il break
oWin:W_PAGELABELS:= {}                               // Array delle pagine
oWin:W_PAGERESIZE:= {}
ATTACH PAGE LABEL "Pagina n.1" TO oWin:W_PAGELABELS
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
        ID "0015000048"
ATTACH "11" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Inserimento"                    ; // Etichetta
        SHORTCUT "add"                             ; // Shortcut
        EXECUTE  {||BolEdbGet('a')}                ; // Funzione
        MESSAGE  "Inserimento nuovo record"        ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0015000049"
ATTACH "12" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Modifica"                       ; // Etichetta
        SHORTCUT "mod"                             ; // Shortcut
        EXECUTE  {||BolEdbGet('m')}                ; // Funzione
        MESSAGE  "Modifica record corrente"        ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0015000050"
ATTACH "13" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "C^ancellazione"                  ; // Etichetta
        SHORTCUT "del"                             ; // Shortcut
        EXECUTE  {||BolEdbDel(.T.)}                ; // Funzione
        MESSAGE  "Cancellazione record corrente"   ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0015000051"
ATTACH "14" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Ricerca su chiavi"              ; // Etichetta
        SHORTCUT "win"                             ; // Shortcut
        EXECUTE  {||R_Bolle->(ddKey())}            ; // Funzione
        MESSAGE  "Ricerca su chiavi"               ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0015000052"
ATTACH "15" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Finestra di ricerca"            ; // Etichetta
        SHORTCUT "A07"                             ; // Shortcut
        EXECUTE  {||R_Bolle->(ddWin())}            ; // Funzione
        MESSAGE  "Apre una finestra per consultazione records"  ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0015000053"
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
        ID "0015000145"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("mod")}               ; //
        WHEN    {|| (cState $ "i") }               ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Modifica"                        ; //
        TOOLTIP "Modifica  (F4)"                   ; //
        IMAGES  TOOLBAR_MOD                        ; //
        ID "0015000146"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("del")}               ; //
        WHEN    {|| (cState $ "i") }               ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Cancellazione"                   ; //
        TOOLTIP "Cancellazione  (F6)"              ; //
        IMAGES  TOOLBAR_DEL                        ; //
        ID "0015000147"
ATTACH TOOLSEPARATOR TO oWin                         // ACTTBR.TMP
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("win")}               ; //
        WHEN    {|| (cState $ "i") }               ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Ricerca su chiavi"               ; //
        TOOLTIP "Ricerca su chiavi  (F7)"  ; //
        IMAGES  TOOLBAR_FIND                       ; //
        ID "0015000149"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("A07")}               ; //
        WHEN    {|| (cState $ "i") }               ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Finestra di ricerca"             ; //
        TOOLTIP "Finestra di ricerca  (Alt-F7)"  ; //
        IMAGES  TOOLBAR_FIND_WIN                   ; //
        ID "0015000150"
ATTACH TOOLSEPARATOR TO oWin                         // ACTTBR.TMP
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("wri")}               ; //
        WHEN    {|| (cState $ "am") }              ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Conferma i dati (F10)"           ; //
        TOOLTIP "Conferma i dati (F10)"  ; //
        IMAGES  TOOLBAR_WRITE_H                    ; //
        ID "0015000152"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("esc")}               ; //
        WHEN    {|| (cState $ "iam") }             ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Fine operazioni (Esc)"           ; //
        TOOLTIP "Fine operazioni (Esc)"  ; //
        IMAGES  TOOLBAR_ESC_H                      ; //
        ID "0015000153"
ATTACH TOOLSEPARATOR TO oWin                         // ACTTBR.TMP
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("hlp")}               ; //
        WHEN    {|| (cState $ "iam") }             ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Aiuto (F1)"                      ; //
        TOOLTIP "Aiuto (F1)"                       ; //
        IMAGES  TOOLBAR_HELP_H                     ; //
        ID "0015000155"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("ush")}               ; //
        WHEN    {|| (cState $ "iam") }             ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Aiuto (Shift-F1)"                ; //
        TOOLTIP "Aiuto (Shift-F1)"                 ; //
        IMAGES  TOOLBAR_KEYHELP_H                  ; //
        ID "0015000156"
* #COD OIACT2 * #END Dopo dichiarazione ATTACH del menu per oggetto oWin

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³INIZIALIZZA ARRAY CON STRUTTURA CAMPI CHIAVE PRIMARIA³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
ATTACH KEY "globalexp" TO oWin:W_PRIMARYKEY
ATTACH KEY "CODBOL"  TO oWin:W_PRIMARYKEY          ; // Campo chiave
       KEYTYPE    0                                ; // Tipo  campo chiave
       BLOCK      {|x|IF(x==NIL,CodBol ,CodBol:=x) }  ; // Valorizza la chiave
       VARTYPE    "C"                              ; // Tipo dato
       VARLEN     3                                ; // Lunghezza campo chiave
       EXPRESSION "CodBol"                           // Espressione
ATTACH KEY "NUMRIGBOL"  TO oWin:W_PRIMARYKEY       ; // Campo chiave
       KEYTYPE    1                                ; // Tipo  campo chiave
       BLOCK      {|x|IF(x==NIL,str(NumRigBol, 4, 0) ,NumRigBol:=x) }  ; // Valorizza la chiave
       VARTYPE    "N"                              ; // Tipo dato
       VARLEN     4                                ; // Lunghezza campo chiave
       EXPRESSION "str(NumRigBol, 4, 0)"    // Espressione

* #COD OIACT3 * #END Dopo inizializzazione array  con campi chiave primaria

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Control                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
ATTACH "box0021" TO oWin:W_CONTROL BOX 01          ; // ATTBOX.TMP
                 AT   50,  10, 191, 203            ; // Coordinate
                 BOXTEXT ""                        ; // BOX Text
                 COORDINATE  W_COORDINATE_PIXEL    ; // Tipo Coordinate
                 BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                 COLOR {"W+/G","B+/G","N/G"}         // Array dei colori
ATTACH "box0025" TO oWin:W_CONTROL BOX 01          ; // ATTBOX.TMP
                 AT   50, 230,  74, 200            ; // Coordinate
                 BOXTEXT "Totale Riga Bolla"       ; // BOX Text
                 COORDINATE  W_COORDINATE_PIXEL    ; // Tipo Coordinate
                 BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                 COLOR {"W+/G","B+/G","N/G"}         // Array dei colori
ATTACH "box0012" TO oWin:W_CONTROL BOX 01          ; // ATTBOX.TMP
                 AT  128, 230, 110, 200            ; // Coordinate
                 BOXTEXT ""                        ; // BOX Text
                 COORDINATE  W_COORDINATE_PIXEL    ; // Tipo Coordinate
                 BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                 COLOR {"W+/G","B+/G","N/G"}         // Array dei colori
ATTACH "box0011" TO oWin:W_CONTROL BOX 01          ; // ATTBOX.TMP
                 AT  180,  30,  50, 160            ; // Coordinate
                 BOXTEXT ""                        ; // BOX Text
                 COORDINATE  W_COORDINATE_PIXEL    ; // Tipo Coordinate
                 BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                 COLOR {"W+/G","B+/G","N/G"}         // Array dei colori
ATTACH "box0014" TO oWin:W_CONTROL BOX 01          ; // ATTBOX.TMP
                 AT  240,  10, 110, 420            ; // Coordinate
                 BOXTEXT ""                        ; // BOX Text
                 COORDINATE  W_COORDINATE_PIXEL    ; // Tipo Coordinate
                 BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                 COLOR {"W+/G","B+/G","N/G"}         // Array dei colori
ATTACH "say0024" TO oWin:W_CONTROL SAY "Totale Sconto:" AT   60,  20  ; // ATTSAY.TMP
                 SIZE       {  80,  30}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // SAY ALIGNMENT
                 COLOR    {"N/G"}                    // Array dei colori
ATTACH "say0009" TO oWin:W_CONTROL SAY "Totale:" AT   90,  60  ; // ATTSAY.TMP
                 SIZE       {  40,  30}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // SAY ALIGNMENT
                 COLOR    {"N/G"}                    // Array dei colori
ATTACH "say0013" TO oWin:W_CONTROL SAY "Quantit… Rimanente a magazzino:" AT  178, 250  ; // ATTSAY.TMP
                 SIZE       { 170,  45}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_WORDBREAK      ; // SAY ALIGNMENT
                 FONT      "12.Arial Bold"         ; // Font Name (XBASE)
                 COLOR    {"N/G"}                    // Array dei colori
ATTACH "say0022" TO oWin:W_CONTROL SAY "%" AT  190, 160  ; // ATTSAY.TMP
                 SIZE       {  20,  18}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // SAY ALIGNMENT
                 FONT      "14.Arial Black"        ; // Font Name (XBASE)
                 COLOR    {"N/G"}                    // Array dei colori
ATTACH "exp0008" TO oWin:W_CONTROL FUNCTION QtaArt*PrzArt AT   90, 100,  29,  80  ; // ATTEXP.TMP
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // FUNCTION ALIGNMENT
                 COLOR    {NIL,NIL,"GR+/G",NIL,NIL}  ; // Array dei colori
                 REFRESHID "-Totali"               ; // Appartiene ai gruppi di refresh
                 PICTURESAY "@ZE 999,999.99"         // Picture in say
ATTACH "exp0019" TO oWin:W_CONTROL FUNCTION CalcMaga(cState) AT  140, 310,  38, 110  ; // ATTEXP.TMP
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_LEFT + XBPALIGN_VCENTER  ; // FUNCTION ALIGNMENT
                 COLOR    DFXPPCLRSELECT({NIL,NIL,"10/",NIL},{NIL,NIL,"GR+/G",NIL,NIL})  ; // Array dei colori
                 REFRESHID "-Totali-Articoli"      ; // Appartiene ai gruppi di refresh
                 FONT      "20.Courier New"        ; // Font Name (XBASE)
                 PICTURESAY "@ZE 99,999"             // Picture in say
ATTACH "DesArt" TO oWin:W_CONTROL FUNCTION Articoli->DesArt AT  290, 210,  22, 213  ; // ATTREL.TMP
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // FUNCTION ALIGNMENT
                 COLOR {"N/G","G+/G","B+/G",NIL,NIL}  ; // Array dei colori
                 PICTURESAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  ; // Picture in say
                 BEFORE {||Articoli->(dfS(1,CodArt))  }  ; // dfS() funzione di allineamento (vedere Norton Guide)
                 REFRESHID "R_Bolle-CodArt"        ; // Gruppo di refresh
                 DISPLAYIF {||.T.}                   // Display condizionale
ATTACH "CodCat" TO oWin:W_CONTROL FUNCTION Articoli->CodCat AT  259, 130,  19,  39  ; // ATTREL.TMP
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // FUNCTION ALIGNMENT
                 COLOR {"N/G","G+/G","B+/G",NIL,NIL}  ; // Array dei colori
                 PICTURESAY "!!"                   ; // Picture in say
                 BEFORE {||Articoli->(dfS(1,CodArt))  }  ; // dfS() funzione di allineamento (vedere Norton Guide)
                 REFRESHID "R_Bolle-CodArt"        ; // Gruppo di refresh
                 PROMPT   "Codice Categoria:"      ; // Prompt
                 PROMPTAT  259 , -14               ; // Coordinate prompt
                 DISPLAYIF {||.T.}                   // Display condizionale
ATTACH "DesCat" TO oWin:W_CONTROL FUNCTION Categ->DesCat AT  260, 160,  22, 240  ; // ATTREL.TMP
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // FUNCTION ALIGNMENT
                 COLOR {"N/G","G+/G","B+/G",NIL,NIL}  ; // Array dei colori
                 PICTURESAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  ; // Picture in say
                 BEFORE {||Articoli->(dfS(1,CodArt)) ,  ; // dfS() funzione di allineamento (vedere Norton Guide)
                 Articoli->(dfS(1,R_Bolle->CodArt)) ,  ; // dfS() funzione di allineamento (vedere Norton Guide)
                 Categ->(dfS(1,Articoli->CodCat))  }  ; // dfS() funzione di allineamento (vedere Norton Guide)
                 REFRESHID "R_Bolle-CodArt"        ; // Gruppo di refresh
                 DISPLAYIF {||.T.}                   // Display condizionale
ATTACH "ScnBol" TO oWin:W_CONTROL FUNCTION T_Bolle->ScnBol AT  190, 119,  24,  36  ; // ATTREL.TMP
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR {"N/G","G+/G","W+/G",NIL,NIL}  ; // Array dei colori
                 PICTURESAY "@ZE 99"               ; // Picture in say
                 REFRESHID "T_Bolle"               ; // Gruppo di refresh
                 PROMPT   "     Sconto:"           ; // Prompt
                 PROMPTAT  190 ,  15               ; // Coordinate prompt
                 FONT       "13.Arial Black"       ; // Font Name (XBASE)
                 PROMPTFONT "13.Arial Black"       ; // Prompt Font Name (XBASE)
                 DISPLAYIF {||.T.}                   // Display condizionale
ATTACH "exp0023" TO oWin:W_CONTROL FUNCTION QtaArt*PrzArt*(T_Bolle->ScnBol/100) AT   60, 100,  30,  84  ; // ATTEXP.TMP
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // FUNCTION ALIGNMENT
                 COLOR    {NIL,NIL,"GR+/G",NIL,NIL}  ; // Array dei colori
                 REFRESHID "-Totali"               ; // Appartiene ai gruppi di refresh
                 PICTURESAY "@ZE 99,999.99"          // Picture in say
ATTACH "exp0026" TO oWin:W_CONTROL FUNCTION QtaArt*PrzArt*(1-(T_Bolle->ScnBol/100)) AT   60, 250,  45, 170  ; // ATTEXP.TMP
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // FUNCTION ALIGNMENT
                 COLOR    {NIL,NIL,"GR+/G",NIL,NIL}  ; // Array dei colori
                 REFRESHID "-Totali"               ; // Appartiene ai gruppi di refresh
                 FONT      "20.Arial Black"        ; // Font Name (XBASE)
                 PICTURESAY "@ZE 999,999.99"         // Picture in say
ATTACH "but0001" TO oWin:W_CONTROL GET AS PUSHBUTTON "O^k"  ; // ATTBUT.TMP
                 AT   10,  10,  32,  40            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||dbAct2Kbd("wri")}     ; // Funzione di controllo
                 ACTIVE   {||cState $ "iam"}       ; // Stato di attivazione
                 MESSAGE "Registra e chiude"         // Messaggio utente
ATTACH "but0002" TO oWin:W_CONTROL GET AS PUSHBUTTON "A^bbandona"  ; // ATTBUT.TMP
                 AT   10, 350,  32,  80            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||dbAct2Kbd("esc")}     ; // Funzione di controllo
                 ACTIVE   {||cState $ "iam"}       ; // Stato di attivazione
                 MESSAGE "Abbandona"                 // Messaggio utente
ATTACH "NumRigBol" TO oWin:W_CONTROL GET NumRigBol AT  312, 120  ; // ATTGET.TMP
                 SIZE       {  48,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // GET ALIGNMENT
                 COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT   "Numero riga Bolla:"     ; // Prompt
                 PROMPTAT  312 , -32               ; // Coordinate prompt
                 PICTURESAY "@ZE 9,999"            ; // Picture in say
                 CONDITION {|ab|NumRigBol(ab)}     ; // Funzione When/Valid
                 MESSAGE "Numero riga Bolla"       ; // Messaggio
                 VARNAME "NumRigBol"               ; //
                 REFRESHID "R_Bolle"               ; // Appartiene ai gruppi di refresh
                 ACTIVE {||cState $ "am" }          // Stato di attivazione
ATTACH "CodArt" TO oWin:W_CONTROL GET CodArt AT  290, 120  ; // ATTGET.TMP
                 SIZE       {  90,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // GET ALIGNMENT
                 COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT   "Codice Articolo:"       ; // Prompt
                 PROMPTAT  290 , -16               ; // Coordinate prompt
                 PICTURESAY "!!!!!!!!"             ; // Picture in say
                 CONDITION {|ab|CodArt(ab)}        ; // Funzione When/Valid
                 MESSAGE "Codice Articolo"         ; // Messaggio
                 VARNAME "CodArt"                  ; //
                 REFRESHID "R_Bolle"               ; // Appartiene ai gruppi di refresh
                 REFRESHGRP "Totali"               ; // Esegue il gruppo di refresh
                 COMBO                             ; // Icona combo
                 ACTIVE {||cState $ "a" }           // Stato di attivazione
ATTACH "QtaArt" TO oWin:W_CONTROL GET QtaArt AT  150, 100  ; // ATTGET.TMP
                 SIZE       {  90,  23}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // GET ALIGNMENT
                 COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT   "Quantit…:"              ; // Prompt
                 PROMPTAT  150 ,  20               ; // Coordinate prompt
                 PICTURESAY "@ZE 999,999.99"       ; // Picture in say
                 MESSAGE "Quantit…"                ; // Messaggio
                 VARNAME "QtaArt"                  ; //
                 REFRESHID "R_Bolle-Totali"        ; // Appartiene ai gruppi di refresh
                 REFRESHGRP "Totali"               ; // Esegue il gruppo di refresh
                 ACTIVE {||cState $ "a" }           // Stato di attivazione
ATTACH "PrzArt" TO oWin:W_CONTROL GET PrzArt AT  120, 100  ; // ATTGET.TMP
                 SIZE       {  88,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // GET ALIGNMENT
                 COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT   "Prezzo:"                ; // Prompt
                 PROMPTAT  120 ,  36               ; // Coordinate prompt
                 PICTURESAY "@ZE 999,999.99"       ; // Picture in say
                 MESSAGE "Prezzo"                  ; // Messaggio
                 VARNAME "PrzArt"                  ; //
                 REFRESHID "R_Bolle-Totali"        ; // Appartiene ai gruppi di refresh
                 REFRESHGRP "Totali"               ; // Esegue il gruppo di refresh
                 ACTIVE {||cState $ "a" }           // Stato di attivazione


M_Normal()                                           // Stato mouse normale

* #COD OAACT0 * #END //  Inizializzazione oggetto oWin

RETURN oWin

*******************************************************************************
FUNCTION BolEdbUpw(        ;                         // [ 04 ]  UPDATE WINDOW  Aggiornamento oggetto
                    cDisGrp )                        //  Id. gruppo di visualizzazione
                                                     //  "#" = aggiorna tutti i control
*******************************************************************************
* #COD OBUPW0 * #END //  Update window oggetto oWin

tbDisItm( oWin ,cDisGrp )                            //  funzione di aggiornamento control (vedere Norton Guide)

* #COD OAUPW0 * #END //  Update window oggetto oWin

RETURN NIL

*******************************************************************************
FUNCTION BolEdbInk()                                 // [ 05 ] INTERAZIONE CON L'UTENTE
*******************************************************************************
LOCAL cCho

* #COD OBINK0 * #END //  Interazione con l'utente o inkey di tastiera

IF cState!=DE_STATE_INK
   RETURN BolEdbGet(cState)
ENDIF

WHILE( !lBreak )

   BolEdbGet(cState)                                 //  Visualizza i dati

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
FUNCTION BolEdbBrk()                                 // [ 06 ] COMANDA UN BREAK SULL'OGGETTO
*******************************************************************************
* #COD OBBRK0 * #END //  Comanda un break sull'oggetto
lBreak := .T.
* #COD OABRK0 * #END //  Comanda un break sull'oggetto
RETURN NIL

*******************************************************************************
FUNCTION BolEdbEnd(         ;                        // [ 07 ] OPERAZIONI DI CHIUSURA
                     cClose  ;                       // Modalita' chiusura oggetto:
                             ;                       // W_OC_RESTORE =  Restore dello screen
                             )                       // W_OC_DESTROY =  Rilascio dell'oggetto
*******************************************************************************
* #COD OBEND0 * #END //  Chiusura e rilascio oggetto oWin

oWin:=tbEnd( oWin , cClose )                         // ( vedere Norton Guide )

* #COD OAEND0 * #END //  Chiusura e rilascio oggetto oWin

RETURN NIL

*******************************************************************************
FUNCTION BolEdbGet(           ;                      // [ 08 ]  METODO PER L'INPUT DEI DATI
                    nGetState  ;                     //  Operazione richiesta:
                               ;                     //  DE_STATE_INK =  Consultazione
                               ;                     //  DE_STATE_ADD =  Inserimento
                               )                     //  DE_STATE_MOD =  Modifica
*******************************************************************************
LOCAL  lRet    := .F.                                //  Flag di registrazione dati se .T.
LOCAL  a121Fld := {}                                 //  Array per controllo somma contenuto campi 1:1

* #COD OBGET0 * #END //  Data-entry o ciclo di get


cState := nGetState                                  //  Riassegna statica stato data entry


nRec := R_Bolle->(Recno())                           //  Memorizza il record corrente

IF     cState==DE_STATE_ADD
   R_Bolle->(dbGoBottom()) ;R_Bolle->(dbSkip(1))
ELSEIF cState==DE_STATE_MOD
   IF R_Bolle->(EOF()) ;cState:=DE_STATE_INK ;END
ENDIF

* #COD OIGETA * #END Prima della valorizzazione delle variabili

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ VALORIZZAZIONE VARIABILI DI DATA ENTRY  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

CodBol     := R_Bolle->CodBol                       // Codice Bolla
NumRigBol  := R_Bolle->NumRigBol                    // Numero riga Bolla
CodArt     := R_Bolle->CodArt                       // Codice Articolo
PrzArt     := R_Bolle->PrzArt                       // Prezzo
QtaArt     := R_Bolle->QtaArt                       // Quantit…
* #COD OIGET2 * #END Dopo la valorizzazione delle variabili

IF cState==DE_STATE_ADD
              /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                ³ VALORIZZA I CAMPI EREDITATI DA RELAZIONI 1:N        ³
                ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
   tbInh( oWin ,aInh ,INH_DEF )

ENDIF
* #COD OIGET3 * #END Dopo la valorizzazione dei campi ereditati per 1:1 ed 1:N

BolEdbUpw( "#" )                                     //  Visualizza i dati da MEMORIA

IF cState==DE_STATE_INK ;RETU .T. ;END               //  Uscita in stato consultazione dati
IF cState==DE_STATE_ADD ;tbGetTop(oWin) ;END
IF cState==DE_STATE_MOD ;tbGetTop(oWin,.T.) ;END
* #COD OIGET4 * #END Prima della chiamata al modulo gestore delle get " tBget() "

WHILE( .T. )

   IF ! tbGet( oWin ,{||BolEdbDcc() } ,cState )      //  Modulo gestore delle get
      * #COD OIGET5 * #END Rinuncia registrazione dati prima di uscire da DO WHILE get
      EXIT
   END

   * #COD OIGET6 * #END Prima della scrittura campi su disco alla conferma dati

   IF cState==DE_STATE_ADD

      * #COD OIGETB * #END Prima calcolo chiavi primarie / univoche

      R_Bolle->(dfPkNew( {|x|if(x==NIL,NumRigBol,NumRigBol:=x)},  1 ,"NumRigBol" ,oWin:W_PRIMARYKEY ,1) )

      R_Bolle->(dbAppend())
      * #COD OIGETC * #END Dopo calcolo chiavi primarie / univoche

      nRec := R_Bolle->(Recno())                     //  Memorizza il nuovo record

      tbInh( oWin ,aInh ,INH_WRI )                   //  Scrive su disco i campi ereditati ( vedere Norton Guide )

   END

   * #COD OIGETD * #END Dopo la scrittura campi ereditati

   R_Bolle->(dbGoto(nRec))                           //  Riposiziona il record
   IF cState==DE_STATE_MOD
     /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       ³          RIMUOVE  LE TRANSAZIONI           ³
       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
      R_Bolle->(BolEdbRtt())
   END

     /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       ³             REPLACE DEI CAMPI              ³
       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
   R_Bolle->(dbGoto(nRec))                           //  Riposiziona prima di scrivere

   R_Bolle->CodBol     := CodBol                    // Codice Bolla
   R_Bolle->NumRigBol  := NumRigBol                 // Numero riga Bolla
   R_Bolle->CodArt     := CodArt                    // Codice Articolo
   R_Bolle->PrzArt     := PrzArt                    // Prezzo
   R_Bolle->QtaArt     := QtaArt                    // Quantit…

   * #COD OIGET7 * #END Dopo la scrittura campi su disco alla conferma dati

   R_Bolle->(dbCommit())                             //  Aggiorna il record su disco

   * #COD OIGET8 * #END Dopo la scrittura campi da relazioni 1:1

     /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       ³          METTE    LE TRANSAZIONI           ³
       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
   R_Bolle->(BolEdbPtt())
   * #COD OIGET9 * #END Dopo la scrittura transazioni e sblocco semaforo di rete
   lRet := .T.
   EXIT                                              //  Uscita dopo aggiornamento dati

ENDDO
R_Bolle->(dbGoto(nRec))                              //  Riposiziona il record


cState := DE_STATE_INK                               //  Imposta stato di consultazione

* #COD OAGET0 * #END //  Data-entry o ciclo di get

RETURN lRet

*******************************************************************************
FUNCTION BolEdbDcc()                                 // [ 09 ]  CONTROLLI CONGRUENZA DATI
*******************************************************************************
LOCAL  lRet := .T.

* #COD OBDCC0 * #END //  Controlli di congruenza dati

* #COD OADCC0 * #END //  Controlli di congruenza dati

RETURN lRet

*******************************************************************************
FUNCTION BolEdbDel(       ;                          // [ 10 ] CANCELLAZIONE RECORD
                    lAsk   )                         //  .T. chiede conferma prima della cancellazione
*******************************************************************************
* #COD OBDEL0 * #END //  Cancellazione record corrente

DEFAULT lAsk    TO .F.

IF lAsk
   IF !dfYesNo( dfStdMsg(MSG_DE_DEL) ,.F.) ;RETURN .F. ;END
ENDIF

* #COD OIDEL1 * #END Prima della cancellazione record corrente

IF R_BolleDid()                                      // Delete integrity Data (dbRid.prg)
                                                     // Funzione di cancellazione su file
ENDIF

* #COD OADEL0 * #END //  Cancellazione record corrente
RETURN .T.

*******************************************************************************
FUNCTION BolEdbPtt()                                 // [ 12 ] METTE LA TRANSAZIONE
*******************************************************************************
* #COD OBPTT0 * #END //  Mette la transazione

R_BolleTrn( "ptt" )

* #COD OAPTT0 * #END //  Mette la transazione

RETURN .T.

*******************************************************************************
FUNCTION BolEdbRtt()                                 // [ 13 ] RIMUOVE LA TRANSAZIONE
*******************************************************************************
* #COD OBRTT0 * #END //  Rimuove la transazione

R_BolleTrn( "rtt" )

* #COD OARTT0 * #END //  Rimuove la transazione

RETURN .T.

*******************************************************************************
STATIC FUNCTION NumRigBol( nPrePost ) // NumRigBol , N,   4,   0
*******************************************************************************
LOCAL aDbL ,lRet:=.T.
* #COD IIGSF10027 * #END
DO CASE
   CASE nPrePost == FORM_PREGET

        * #COD IIEDTB0027 * #END
        IF cState==DE_STATE_MOD
           RETURN .F.
        ENDIF
        /*  CHIAVE AUTOMATICA PROGRESSIVA */
        R_Bolle->(dfPkNew( {|x|if(x==NIL,NumRigBol,NumRigBol:=x)},  1 ,"NumRigBol" ,oWin:W_PRIMARYKEY ,1) )
        BolEdbUpw( "-numrigbol-" )

        RETURN .F.

        * #COD IIEDTA0027 * #END

   CASE nPrePost == FORM_POSTGET .OR. nPrePost == FORM_CHKGET

        * #COD IICHKB0027 * #END
        IF !R_Bolle->(ddPkChk(  1 ,tbPkExp(oWin), NIL, cState ))
           RETURN .F.
        ENDIF

        * #COD IICHKA0027 * #END

        IF nPrePost == FORM_POSTGET
           * #COD IIGSF50027 * #END
        ENDIF

ENDCASE
* #COD IIGSF90027 * #END

RETURN lRet
*******************************************************************************
STATIC FUNCTION CodArt( nPrePost ) // CodArt    , C,   8,   0
*******************************************************************************
LOCAL aDbL ,lRet:=.T.
* #COD IIGSF10004 * #END
DO CASE
   CASE nPrePost == FORM_PREGET

        * #COD IIEDTB0004 * #END

        * #COD IIEDTA0004 * #END

   CASE nPrePost == FORM_POSTGET .OR. nPrePost == FORM_CHKGET

        * #COD IICHKB0004 * #END
        aDbl           := ARRAY(LK_ARRAYLEN)
        aDbl[LK_ORDER] := 1                          //  Order (numerico)
        aDbl[LK_SEEK]  := CodArt                     //  Chiave di ricerca
        aDbl[LK_VAL]   := {}                         //  Dati da ereditare nel file figlio
        AADD( aDbl[LK_VAL] , { "CodArt" ,{||CodArt } })
        aDbl[LK_FIELD] := "CodArt"                   //  Nome campo relazionato
        aDbl[LK_WIN]   := NIL                        //  Nome finestra
        aDbl[LK_KEY]   := NIL                        //  Chiave finestra
        aDbl[LK_FILTER]:= {||.T.}                    //  Filtro finestra
        aDbl[LK_BREAK] := {||.F.}                    //  Break finestra
        aDbl[LK_TYPE]  := LT_NOTMANDATORY            //  Modalita' Look-Up
        aDbl[LK_EDIT]  := NIL                        //  Nome quadro edit
        aDbl[LK_INS]   := NIL                        //  Abilita edit se...
        aDbl[LK_KBD]   := .T.                        //  Keyboard
        * #COD IIGSF40004 * #END

        IF ! Articoli->(dbLooK( aDbl ))
           lRet := .F.
        ELSE
           IF nPrePost == FORM_POSTGET
              CodArt     := Articoli->CodArt
              PrzArt     := Articoli->PrzArt
              tbDisRef( oWin ,"PrzArt" )
              tbDisItm( oWin ,"-PrzArt" )
              tbDisRef( oWin ,"CodArt" )
           END
        ENDIF


        * #COD IICHKA0004 * #END

        IF nPrePost == FORM_POSTGET
           * #COD IIGSF50004 * #END
        ENDIF

ENDCASE
* #COD IIGSF90004 * #END

RETURN lRet

*******************************************************************************
STATIC FUNCTION CalcMaga(                           ; // Calcola la quantit… di magazino
                         cState                     ) // Parametri
*******************************************************************************
* #COD FSFUNC000032    ###
//Questa funzione esegue ritorna la quantit… di articoli presenti in magazino e
// assegna il corretto valore alla campo EsiArt di Articol
Local nRet := 0
IF ARTICOLI->(dfs(1,CodArt))
   IF cState == DE_STATE_ADD
       nRet := Articoli->QtaArt - (QtaArt)* (IIF(T_Bolle->TipBol=="U",1,-1 ))
       // Imposto il check Box della presnza Articolo in magazino
       IF nRet>0
           IF ARTICOLI->(dfNet(NET_RECORDLOCK) )
               Articoli->EsiArt := "1"
               Articoli->(dfNet(NET_RECORDUNLOCK) )
           ENDIF
       ELSE
           IF ARTICOLI->(dfNet(NET_RECORDLOCK) )
               Articoli->EsiArt := "0"
               ARTICOLI->(dfNet(NET_RECORDUNLOCK))
           ENDIF
       ENDIF
   ELSE
       nRet := Articoli->QtaArt
   ENDIF
ENDIF
Return nRet
* #END



* #COD OIBOT1 * #END Fine file sorgente per oggetto form

