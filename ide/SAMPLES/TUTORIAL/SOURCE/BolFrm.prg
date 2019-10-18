/******************************************************************************
 Progetto       : Tutorial
 Sottoprogetto  : Tutorial
 Programma      : V:\SAMPLES\TUTORIAL\source\BolFrm.prg
 Template       : V:\bin\..\tmp\xbase\form.tmp
 Descrizione    : Scheda Testata Bolle
 Programmatore  : Demo
 Data           : 13-07-06
 Ora            : 16.43.58
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
        datbol                                    ,; // Data Bolla
        codcli                                    ,; // Codice Cliente
        scnbol                                    ,; // Sconto
        tipbol                                    ,; // Tipo Bolla
        lsb0016                                      // identificatore control list box

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
FUNCTION BolFrmExe(                                ; // [ 01 ]  ESECUTORE OPERAZIONI
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

PRIVATE  EnvId:="BolFrm" ,SubId:=""                  // Identificativi per help

nWin++
IF nWin==1

   aInh   := arrInh                                  // Riassegna array campi ereditati
   cState := cMode                                   // Riassegna lo stato sulla modalit… operativa

   * #COD OIEXE5 * #END Dopo i settaggi dell'oggetto


   IF BolFrmDbf()                                    // Apre la base dati

      BolFrmAct()                                    // Attivazione oggetto

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
      BolFrmInk() ;BolFrmEnd(cClose) ;lRet := .T.

   END
   dfClose( aFile, .T., .F. )                        // Chiusura base dati ( vedere Norton Guide )

ENDIF
nWin--

* #COD OAEXE0 * #END //  Esegue le operazioni di base per attivazione oggetto FORM

RETURN lRet

*******************************************************************************
FUNCTION BolFrmDbf()                                 // [ 02 ] APERTURA DATABASE
*******************************************************************************
* #COD OBDBF0 * #END //  Apertura della base dati

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³  MASTER FILE   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !dfUse( "T_Bolle" ,NIL ,aFile ) ;RETU .F. ;END    // Funzione di apertura file (vedere Norton Guide)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³  LOOK-UP FILE  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !dfUse( "Clienti" ,NIL ,aFile ) ;RETU .F. ;END
IF !dfUse( "Province" ,NIL ,aFile ) ;RETU .F. ;END
IF !dfUse( "R_Bolle" ,NIL ,aFile ) ;RETU .F. ;END

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³TRANSACTION FILE³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !dfUse( "P_Bolle" ,NIL ,aFile ) ;RETU .F. ;END

* #COD OADBF0 //  Apertura della base dati
IF !dfUse( "Articoli" ,NIL ,aFile ) ;RETU .F. ;END
* #END

RETURN .T.

*******************************************************************************
FUNCTION BolFrmAct()                                 // [ 03 ] INIZIALIZZA OGGETTO
*******************************************************************************
LOCAL aPfkItm

* #COD OBACT0 * #END //  Inizializzazione oggetto oWin

lBreak := .F.                                        // Condizione di break su oggetto posta a FALSE

IF oWin!=NIL ;RETURN oWin ;END                       // Si ritorna l'oggetto se gi… inizializzato

M_Cless()                                            // Stato di attesa con mouse a clessidra

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Inizializza oggetto ( vedere Norton Guide ) ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

oWin := T_Bolle->(TbBrwNew( 400                   ,; // Prima  Riga
                         0                        ,; // Prima  Colonna
                       512                        ,; // Ultima Riga
                       580                        ,; // Ultima Colonna
                      W_OBJ_FRM                             ,; // Tipo oggetto ( form )
                      NIL ,; // Label
                      W_COORDINATE_PIXEL                    )) // Gestione in Pixel

oWin:W_TITLE     := "Scheda Testata Bolle"           // Titolo oggetto
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
        ID "0017000066"
ATTACH "11" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Inserimento"                    ; // Etichetta
        SHORTCUT "add"                             ; // Shortcut
        EXECUTE  {||BolFrmGet('a')}                ; // Funzione
        MESSAGE  "Inserimento nuovo record"        ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0017000067"
ATTACH "12" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Modifica"                       ; // Etichetta
        SHORTCUT "mod"                             ; // Shortcut
        EXECUTE  {||BolFrmGet('m')}                ; // Funzione
        MESSAGE  "Modifica record corrente"        ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0017000068"
ATTACH "13" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "C^ancellazione"                  ; // Etichetta
        SHORTCUT "del"                             ; // Shortcut
        EXECUTE  {||BolFrmDel(.T.)}                ; // Funzione
        MESSAGE  "Cancellazione record corrente"   ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0017000069"
ATTACH "14" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Ricerca su chiavi"              ; // Etichetta
        SHORTCUT "win"                             ; // Shortcut
        EXECUTE  {||T_Bolle->(ddKey())}            ; // Funzione
        MESSAGE  "Ricerca su chiavi"               ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0017000070"
ATTACH "15" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Finestra di ricerca"            ; // Etichetta
        SHORTCUT "A07"                             ; // Shortcut
        EXECUTE  {||T_Bolle->(ddWin())}            ; // Funzione
        MESSAGE  "Apre una finestra per consultazione records"  ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0017000071"
ATTACH "16" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "Record ^successivo"              ; // Etichetta
        SHORTCUT "skn"                             ; // Shortcut
        EXECUTE  {||tbDown(oWin)}                  ; // Funzione
        MESSAGE  "Muove al record successivo"      ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0017000072"
ATTACH "17" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "Record pr^ecedente"              ; // Etichetta
        SHORTCUT "skp"                             ; // Shortcut
        EXECUTE  {||tbUp(oWin)}                    ; // Funzione
        MESSAGE  "Muove al record precedente"      ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0017000073"
ATTACH "18" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "Piede Bolla"                     ; // Etichetta
        EXECUTE  {||BolFrm1Exe(DE_STATE_INK)}  ; // Funzione
        MESSAGE  ""                                ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0017000078"
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
        ID "0017000172"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("mod")}               ; //
        WHEN    {|| (cState $ "i") }               ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Modifica"                        ; //
        TOOLTIP "Modifica  (F4)"                   ; //
        IMAGES  TOOLBAR_MOD                        ; //
        ID "0017000173"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("del")}               ; //
        WHEN    {|| (cState $ "i") }               ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Cancellazione"                   ; //
        TOOLTIP "Cancellazione  (F6)"              ; //
        IMAGES  TOOLBAR_DEL                        ; //
        ID "0017000174"
ATTACH TOOLSEPARATOR TO oWin                         // ACTTBR.TMP
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("win")}               ; //
        WHEN    {|| (cState $ "i") }               ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Ricerca su chiavi"               ; //
        TOOLTIP "Ricerca su chiavi  (F7)"  ; //
        IMAGES  TOOLBAR_FIND                       ; //
        ID "0017000176"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("A07")}               ; //
        WHEN    {|| (cState $ "i") }               ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Finestra di ricerca"             ; //
        TOOLTIP "Finestra di ricerca  (Alt-F7)"  ; //
        IMAGES  TOOLBAR_FIND_WIN                   ; //
        ID "0017000177"
ATTACH TOOLSEPARATOR TO oWin                         // ACTTBR.TMP
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("wri")}               ; //
        WHEN    {|| (cState $ "am") }              ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Conferma i dati (F10)"           ; //
        TOOLTIP "Conferma i dati (F10)"  ; //
        IMAGES  TOOLBAR_WRITE_H                    ; //
        ID "0017000179"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("esc")}               ; //
        WHEN    {|| (cState $ "iam") }             ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Fine operazioni (Esc)"           ; //
        TOOLTIP "Fine operazioni (Esc)"  ; //
        IMAGES  TOOLBAR_ESC_H                      ; //
        ID "0017000180"
ATTACH TOOLSEPARATOR TO oWin                         // ACTTBR.TMP
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("skp")}               ; //
        WHEN    {|| (cState $ "i") }               ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Record precedente"               ; //
        TOOLTIP "Record precedente  (-)"  ; //
        IMAGES  TOOLBAR_PREV                       ; //
        ID "0017000182"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("skn")}               ; //
        WHEN    {|| (cState $ "i") }               ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Record successivo"               ; //
        TOOLTIP "Record successivo  (+)"  ; //
        IMAGES  TOOLBAR_NEXT                       ; //
        ID "0017000183"
ATTACH TOOLSEPARATOR TO oWin                         // ACTTBR.TMP
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("hlp")}               ; //
        WHEN    {|| (cState $ "iam") }             ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Aiuto (F1)"                      ; //
        TOOLTIP "Aiuto (F1)"                       ; //
        IMAGES  TOOLBAR_HELP_H                     ; //
        ID "0017000185"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("ush")}               ; //
        WHEN    {|| (cState $ "iam") }             ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Aiuto (Shift-F1)"                ; //
        TOOLTIP "Aiuto (Shift-F1)"                 ; //
        IMAGES  TOOLBAR_KEYHELP_H                  ; //
        ID "0017000186"
* #COD OIACT2 * #END Dopo dichiarazione ATTACH del menu per oggetto oWin

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³INIZIALIZZA ARRAY CON STRUTTURA CAMPI CHIAVE PRIMARIA³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
ATTACH KEY "globalexp" TO oWin:W_PRIMARYKEY
ATTACH KEY "CODBOL"  TO oWin:W_PRIMARYKEY          ; // Campo chiave
       KEYTYPE    1                                ; // Tipo  campo chiave
       BLOCK      {|x|IF(x==NIL,CodBol ,CodBol:=x) }  ; // Valorizza la chiave
       VARTYPE    "C"                              ; // Tipo dato
       VARLEN     3                                ; // Lunghezza campo chiave
       EXPRESSION "CodBol"                           // Espressione

* #COD OIACT3 * #END Dopo inizializzazione array  con campi chiave primaria

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Control                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
ATTACH "box0021" TO oWin:W_CONTROL BOX 01          ; // ATTBOX.TMP
                 AT  280,  20,  98, 540            ; // Coordinate
                 BOXTEXT ""                        ; // BOX Text
                 COORDINATE  W_COORDINATE_PIXEL    ; // Tipo Coordinate
                 BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                 COLOR {"W+/G","B+/G","N/G"}         // Array dei colori
ATTACH "box0019" TO oWin:W_CONTROL BOX 01          ; // ATTBOX.TMP
                 AT  290, 200,  80, 350            ; // Coordinate
                 BOXTEXT ""                        ; // BOX Text
                 COORDINATE  W_COORDINATE_PIXEL    ; // Tipo Coordinate
                 BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                 COLOR {"W+/G","B+/G","N/G"}         // Array dei colori
ATTACH "box0018" TO oWin:W_CONTROL BOX 01          ; // ATTBOX.TMP
                 AT  379,  20,  51, 311            ; // Coordinate
                 BOXTEXT ""                        ; // BOX Text
                 COORDINATE  W_COORDINATE_PIXEL    ; // Tipo Coordinate
                 BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                 COLOR {"W+/G","B+/G","N/G"}         // Array dei colori
ATTACH "box0026" TO oWin:W_CONTROL BOX 01          ; // ATTBOX.TMP
                 AT  379, 337,  50, 223            ; // Coordinate
                 BOXTEXT ""                        ; // BOX Text
                 COORDINATE  W_COORDINATE_PIXEL    ; // Tipo Coordinate
                 BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                 COLOR {"W+/G","B+/G","N/G"}         // Array dei colori
ATTACH "say0029" TO oWin:W_CONTROL SAY "%" AT  300, 170  ; // ATTSAY.TMP
                 SIZE       {  20,  20}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_HCENTER + XBPALIGN_VCENTER  ; // SAY ALIGNMENT
                 COLOR    {"N/G"}                    // Array dei colori
ATTACH "RagCli" TO oWin:W_CONTROL FUNCTION Clienti->RagCli AT  340, 210,  20, 279  ; // ATTREL.TMP
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // FUNCTION ALIGNMENT
                 COLOR {"N/G","G+/G","B+/G",NIL,NIL}  ; // Array dei colori
                 PICTURESAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  ; // Picture in say
                 BEFORE {||Clienti->(dfS(1,CodCli))  }  ; // dfS() funzione di allineamento (vedere Norton Guide)
                 REFRESHID "T_Bolle-CodCli"        ; // Gruppo di refresh
                 DISPLAYIF {||.T.}                   // Display condizionale
ATTACH "IndCli" TO oWin:W_CONTROL FUNCTION Clienti->IndCli AT  320, 213,  18, 311  ; // ATTREL.TMP
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // FUNCTION ALIGNMENT
                 COLOR {"N/G","G+/G","B+/G",NIL,NIL}  ; // Array dei colori
                 PICTURESAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  ; // Picture in say
                 BEFORE {||Clienti->(dfS(1,CodCli))  }  ; // dfS() funzione di allineamento (vedere Norton Guide)
                 REFRESHID "T_Bolle-CodCli"        ; // Gruppo di refresh
                 DISPLAYIF {||.T.}                   // Display condizionale
ATTACH "CapCli" TO oWin:W_CONTROL FUNCTION Clienti->CapCli AT  300, 210,  15,  41  ; // ATTREL.TMP
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // FUNCTION ALIGNMENT
                 COLOR {"N/G","G+/G","B+/G",NIL,NIL}  ; // Array dei colori
                 PICTURESAY "!!!!!"                ; // Picture in say
                 BEFORE {||Clienti->(dfS(1,CodCli))  }  ; // dfS() funzione di allineamento (vedere Norton Guide)
                 REFRESHID "T_Bolle-CodCli"        ; // Gruppo di refresh
                 DISPLAYIF {||.T.}                   // Display condizionale
ATTACH "CitCli" TO oWin:W_CONTROL FUNCTION Clienti->CitCli AT  300, 250,  20,  91  ; // ATTREL.TMP
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // FUNCTION ALIGNMENT
                 COLOR {"N/G","G+/G","B+/G",NIL,NIL}  ; // Array dei colori
                 PICTURESAY "XXXXXXXXXXXXX"        ; // Picture in say
                 BEFORE {||Clienti->(dfS(1,CodCli))  }  ; // dfS() funzione di allineamento (vedere Norton Guide)
                 REFRESHID "T_Bolle-CodCli"        ; // Gruppo di refresh
                 DISPLAYIF {||.T.}                   // Display condizionale
ATTACH "DesPrv" TO oWin:W_CONTROL FUNCTION Province->DesPrv AT  300, 440,  20, 105  ; // ATTREL.TMP
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // FUNCTION ALIGNMENT
                 COLOR {"N/G","G+/G","B+/G",NIL,NIL}  ; // Array dei colori
                 PICTURESAY "XXXXXXXXXXXXXXXXXXXX"  ; // Picture in say
                 BEFORE {||Clienti->(dfS(1,CodCli)) ,  ; // dfS() funzione di allineamento (vedere Norton Guide)
                 Clienti->(dfS(1,T_Bolle->CodCli))  }  ; // dfS() funzione di allineamento (vedere Norton Guide)
                 REFRESHID "T_Bolle-CodCli"        ; // Gruppo di refresh
                 DISPLAYIF {||.T.}                   // Display condizionale
ATTACH "PrvCli" TO oWin:W_CONTROL FUNCTION Clienti->PrvCli AT  300, 400,  20,  17  ; // ATTREL.TMP
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // FUNCTION ALIGNMENT
                 COLOR {"N/G","G+/G","B+/G",NIL,NIL}  ; // Array dei colori
                 PICTURESAY "!!"                   ; // Picture in say
                 BEFORE {||Clienti->(dfS(1,CodCli))  }  ; // dfS() funzione di allineamento (vedere Norton Guide)
                 REFRESHID "T_Bolle-CodCli"        ; // Gruppo di refresh
                 PROMPT   "Provincia:"             ; // Prompt
                 PROMPTAT  300 , 312               ; // Coordinate prompt
                 DISPLAYIF {||.T.}                   // Display condizionale
ATTACH "but0002" TO oWin:W_CONTROL GET AS PUSHBUTTON "<"  ; // ATTBUT.TMP
                 AT   10,  20,  30,  70            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||tbUp(oWin)}           ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 MESSAGE "Muove al record precedente"    // Messaggio utente
ATTACH "but0003" TO oWin:W_CONTROL GET AS PUSHBUTTON ">"  ; // ATTBUT.TMP
                 AT   10,  95,  30,  70            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||tbDown(oWin)}         ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 MESSAGE "Muove al record successivo"    // Messaggio utente
ATTACH "but0010" TO oWin:W_CONTROL GET AS PUSHBUTTON "A^bbandona"  ; // ATTBUT.TMP
                 AT   10, 173,  30,  70            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||dbAct2Kbd("esc")}     ; // Funzione di controllo
                 ACTIVE   {||cState $ "iam"}       ; // Stato di attivazione
                 MESSAGE "Abbandona"                 // Messaggio utente
ATTACH "CodBol" TO oWin:W_CONTROL GET CodBol AT  390, 100  ; // ATTGET.TMP
                 SIZE       {  32,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // GET ALIGNMENT
                 COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT   "Codice Bolla:"          ; // Prompt
                 PROMPTAT  390 , -12               ; // Coordinate prompt
                 PICTURESAY "!!!"                  ; // Picture in say
                 CONDITION {|ab|CodBol(ab)}        ; // Funzione When/Valid
                 MESSAGE "Codice Bolla"            ; // Messaggio
                 VARNAME "CodBol"                  ; //
                 REFRESHID "T_Bolle"               ; // Appartiene ai gruppi di refresh
                 ACTIVE {||cState $ "am" }          // Stato di attivazione
ATTACH "DatBol" TO oWin:W_CONTROL GET DatBol AT  391, 220  ; // ATTGET.TMP
                 SIZE       {  72,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // GET ALIGNMENT
                 COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT   "Data Bolla:"            ; // Prompt
                 PROMPTAT  391 , 124               ; // Coordinate prompt
                 PICTURESAY "99/99/99"             ; // Picture in say
                 MESSAGE "Data Bolla"              ; // Messaggio
                 VARNAME "DatBol"                  ; //
                 REFRESHID "T_Bolle"               ; // Appartiene ai gruppi di refresh
                 ACTIVE {||cState $ "am" }          // Stato di attivazione
ATTACH "CodCli" TO oWin:W_CONTROL GET CodCli AT  327, 120  ; // ATTGET.TMP
                 SIZE       {  61,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // GET ALIGNMENT
                 COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT   "Codice Cliente:"        ; // Prompt
                 PROMPTAT  327 ,  -8               ; // Coordinate prompt
                 PICTURESAY "!!!!!!"               ; // Picture in say
                 CONDITION {|ab|CodCli(ab)}        ; // Funzione When/Valid
                 MESSAGE "Codice Cliente"          ; // Messaggio
                 VARNAME "CodCli"                  ; //
                 REFRESHID "T_Bolle"               ; // Appartiene ai gruppi di refresh
                 COMBO                             ; // Icona combo
                 ACTIVE {||cState $ "am" }          // Stato di attivazione
ATTACH "spb0013" TO oWin:W_CONTROL GET AS SPINBUTTON ScnBol  ; // ATTSPB.TMP
                 AT  300, 120                      ; // Coordinate
                 SIZE       {  50,  20}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR      {"N/G","G+/G","N/W*","W+/BG","N/W*"}  ; // Array dei colori
                 PROMPT   "Sconto:"                ; // Prompt
                 PROMPTAT  300 ,  56               ; // Coordinate prompt
                 PICTURESAY "99999"                ; // Picture in say
                 DISPLAYIF  {||.T.}                ; // Visualizza se...
                 MIN        5                      ; // Valore minimo
                 MAX        60                     ; // Valore massimo
                 ACTIVE   {||cState $ "am" }       ; // Stato di attivazione
                 VARNAME "ScnBol"                  ; //
                 MESSAGE ""                          // Messaggio utente
ATTACH "rdb0014" TO oWin:W_CONTROL GET AS RADIOBUTTON TipBol  PROMPT "In Entrata"  ; // ATTRDB.tmp
                 AT  394, 368                      ; // Coordinate
                 SIZE       {  80,  20}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 VALUE    "E"                      ; // Valore
                 GAP      1                        ; // Spazio ICONA / PROMPT
                 COLOR    {"N/G","G+/G","W+/BG","W+/G"}  ; // Array dei colori
                 ACTIVE  {||cState $ "am" }        ; // Stato di attivazione
                 VARNAME "TipBol"                  ; //
                 MESSAGE ""                          // Messaggio utente
ATTACH "rdb0015" TO oWin:W_CONTROL GET AS RADIOBUTTON TipBol  PROMPT "In Uscita"  ; // ATTRDB.tmp
                 AT  393, 464                      ; // Coordinate
                 SIZE       {  80,  20}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 VALUE    "U"                      ; // Valore
                 GAP      1                        ; // Spazio ICONA / PROMPT
                 COLOR    {"N/G","G+/G","W+/BG","W+/G"}  ; // Array dei colori
                 ACTIVE  {||cState $ "am" }        ; // Stato di attivazione
                 VARNAME "TipBol"                  ; //
                 MESSAGE ""                          // Messaggio utente
/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³ Inizializza List-Box su archivio (vedere Norton Guide) ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
lsb0016 := R_Bolle->(tbBrwNew(  50                ,; // Prima  Riga
                                   20             ,; // Prima  Colonna
                                  221             ,; // Ultima Riga
                                  539             ,; // Ultima Colonna
                                 W_OBJ_BROWSEBOX            ,; // List-Box su FILE
                                 NIL ,; // Label
                                 W_COORDINATE_PIXEL         )) // Gestione in Pixel

lsb0016:W_TITLE      := "Righe Bolla"                // Titolo oggetto browse
lsb0016:W_ORDER      := 1                            // Nø Indice di relazione
lsb0016:W_KEY        := {||T_Bolle->CodBol}          // CodeBlock per la seek
lsb0016:W_FILTER     := {||.T.}                      // CodeBlock per il filtro
lsb0016:W_BREAK      := {||R_Bolle->CodBol!=T_Bolle->CodBol}    // CodeBlock per il break
lsb0016:W_COLORARRAY[AC_LSB_BACK  ]      := "N/W*"    // Colore fondo
lsb0016:W_COLORARRAY[AC_LSB_TOPLEFT]     := "N/G"    //    "   bordo superiore
lsb0016:W_COLORARRAY[AC_LSB_BOTTOMRIGHT] := "BG/G"    //    "   bordo inferiore
lsb0016:W_COLORARRAY[AC_LSB_PROMPT]      := "GR+/G"    //    "   prompt
lsb0016:W_COLORARRAY[AC_LSB_HILITE]      := "W+/BG"    //    "   prompt selezionato
lsb0016:W_COLORARRAY[AC_LSB_HOTKEY]      := "G+/G"    //    "   hot key
lsb0016:COLORSPEC    := "N/W*"
ATTACH REFRESH GROUP "R_Bolle" TO lsb0016:W_R_GROUP
lsb0016:W_MOUSEMETHOD:= W_MM_EDIT + W_MM_HSCROLLBAR + W_MM_VSCROLLBAR
lsb0016:W_LINECURSOR:= .T.
lsb0016:W_ROWLINESEPARATOR := .T.
lsb0016:W_HEADERROWS := 1


ATTACH INH TO lsb0016:W_INHARRAY                   ; // Id
           INHFIELD "CodBol"                       ; // Nome campo ereditato
           INHBLOCK {||T_Bolle->CodBol }             // Espressione per ereditare

ADDKEY "anr" TO lsb0016:W_KEYBOARDMETHODS          ; // Tasto su List Box
       BLOCK   {||R_Bolle->(BolFrmAnr(lsb0016,{||BolEdbExe(DE_STATE_ADD,,,,,,aInhSon)} ))}  ; // Funzione sul tasto
       WHEN    {|s| (s $ "i") }                    ; // Condizione di stato di attivazione
       RUNTIME {|cCHILD,cLABEL,cID|.T.}            ; // Condizione di runtime
       MESSAGE "Inserimento"                         // Messaggio utente associato
ADDKEY "mcr" TO lsb0016:W_KEYBOARDMETHODS          ; // Tasto su List Box
       BLOCK   {||R_Bolle->(BolFrmMcr(lsb0016,{||BolEdbExe(DE_STATE_MOD)} ))}  ; // Funzione sul tasto
       WHEN    {|s| (s $ "i") }                    ; // Condizione di stato di attivazione
       RUNTIME {|cCHILD,cLABEL,cID|.T.}            ; // Condizione di runtime
       MESSAGE "Modifica"                            // Messaggio utente associato
ADDKEY "ecr" TO lsb0016:W_KEYBOARDMETHODS          ; // Tasto su List Box
       BLOCK   {||R_Bolle->(BolFrmEcr(lsb0016,{||BolEdbDel()} ))}  ; // Funzione sul tasto
       WHEN    {|s| (s $ "i") }                    ; // Condizione di stato di attivazione
       RUNTIME {|cCHILD,cLABEL,cID|.T.}            ; // Condizione di runtime
       MESSAGE "Cancella"                            // Messaggio utente associato
ATTACH COLUMN "CodArt" TO lsb0016                  ; // ATTCOL.TMP
                       BLOCK     {|| R_Bolle->CodArt }  ;
                       PICTURE "!!!!!!!!"          ; // Picture visualizzazione dato
                       PROMPT "Cod.Art."           ; // Etichetta
                       WIDTH     8                 ; // Larghezza colonna
                       COLOR  {"B+/W*","BG/W*","W+/BG"}  ; // Array dei colori
                       MESSAGE ""                    // Messaggio
ATTACH COLUMN "exp00160006" TO lsb0016             ; // ATTCOL.TMP
                       BLOCK     {|| IIF(ARTICOLI->(dfs(1,R_Bolle->CodArt)),Articoli->DesArt,"") }  ;
                       PICTURE "XXXXXXXXXXXXXXXXXXXXXX"  ; // Picture visualizzazione dato
                       PROMPT "Descrizione Articolo"  ; // Etichetta
                       WIDTH    22                 ; // Larghezza colonna
                       COLOR  {"B+/W*","BG/W*","W+/BG"}  ; // Array dei colori
                       MESSAGE ""                    // Messaggio
ATTACH COLUMN "QtaArt" TO lsb0016                  ; // ATTCOL.TMP
                       BLOCK     {|| R_Bolle->QtaArt }  ;
                       PICTURE "@ZE 99,999"        ; // Picture visualizzazione dato
                       PROMPT "Quantit…"           ; // Etichetta
                       WIDTH     8                 ; // Larghezza colonna
                       COLOR  {"B+/W*","BG/W*","W+/BG"}  ; // Array dei colori
                       MESSAGE ""                    // Messaggio
ATTACH COLUMN "PrzArt" TO lsb0016                  ; // ATTCOL.TMP
                       BLOCK     {|| R_Bolle->PrzArt }  ;
                       PICTURE "@ZE 9,999.99"      ; // Picture visualizzazione dato
                       PROMPT "Prezzo"             ; // Etichetta
                       WIDTH     8                 ; // Larghezza colonna
                       COLOR  {"B+/W*","BG/W*","W+/BG"}  ; // Array dei colori
                       MESSAGE ""                    // Messaggio
ATTACH COLUMN "exp00160005" TO lsb0016             ; // ATTCOL.TMP
                       BLOCK     {|| (R_Bolle->QtaArt * R_Bolle->PrzArt)*IIF(T_Bolle->ScnBol>0,1-(T_Bolle->ScnBol/100),1) }  ;
                       PICTURE "@ZE 99,999.99"     ; // Picture visualizzazione dato
                       PROMPT "Tot. - Sconto"      ; // Etichetta
                       WIDTH    13                 ; // Larghezza colonna
                       TOTAL     (R_Bolle->QtaArt * R_Bolle->PrzArt)*IIF(T_Bolle->ScnBol>0,1-(T_Bolle->ScnBol/100),1)  ; //
                       FPICTURE "@ZE 99,999.99"    ; // Picture Footer
                       COLOR  {"B+/W*","BG/W*","W+/BG"}  ; // Array dei colori
                       MESSAGE ""                    // Messaggio
ATTACH "lsb0016" TO oWin:W_CONTROL GET AS LISTBOX USING lsb0016  ; // ATTLSB.tmp
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                ACTIVE   {||cState $ "i" }           // Stato di attivazione
ATTACH "but0017" TO oWin:W_CONTROL GET AS PUSHBUTTON "Piede Bolla"  ; // ATTBUT.TMP
                 AT   10, 492,  30,  70            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||BolFrm1Exe(DE_STATE_MOD)}  ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 MESSAGE ""                          // Messaggio utente
ATTACH "but0024" TO oWin:W_CONTROL GET AS PUSHBUTTON "^OK"  ; // ATTBUT.TMP
                 AT   10, 250,  30,  70            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||dbAct2Kbd("wri")}     ; // Funzione di controllo
                 ACTIVE   {||cState $ "am"}        ; // Stato di attivazione
                 MESSAGE ""                          // Messaggio utente
ATTACH "but0025" TO oWin:W_CONTROL GET AS PUSHBUTTON "^Modifica"  ; // ATTBUT.TMP
                 AT   10, 326,  30,  70            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||dbAct2Kbd("mod")}     ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 MESSAGE ""                          // Messaggio utente
ATTACH "but0028" TO oWin:W_CONTROL GET AS PUSHBUTTON "C^anc."  ; // ATTBUT.TMP
                 AT   10, 404,  30,  70            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||BolfrmDel(.T.)}       ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 MESSAGE ""                          // Messaggio utente


M_Normal()                                           // Stato mouse normale

* #COD OAACT0 * #END //  Inizializzazione oggetto oWin

RETURN oWin

*******************************************************************************
FUNCTION BolFrmUpw(        ;                         // [ 04 ]  UPDATE WINDOW  Aggiornamento oggetto
                    cDisGrp )                        //  Id. gruppo di visualizzazione
                                                     //  "#" = aggiorna tutti i control
*******************************************************************************
* #COD OBUPW0 * #END //  Update window oggetto oWin

tbDisItm( oWin ,cDisGrp )                            //  funzione di aggiornamento control (vedere Norton Guide)

* #COD OAUPW0 * #END //  Update window oggetto oWin

RETURN NIL

*******************************************************************************
FUNCTION BolFrmInk()                                 // [ 05 ] INTERAZIONE CON L'UTENTE
*******************************************************************************
LOCAL cCho

* #COD OBINK0 * #END //  Interazione con l'utente o inkey di tastiera

IF cState!=DE_STATE_INK
   RETURN BolFrmGet(cState)
ENDIF

WHILE( !lBreak )

   BolFrmGet(cState)                                 //  Visualizza i dati

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
FUNCTION BolFrmBrk()                                 // [ 06 ] COMANDA UN BREAK SULL'OGGETTO
*******************************************************************************
* #COD OBBRK0 * #END //  Comanda un break sull'oggetto
lBreak := .T.
* #COD OABRK0 * #END //  Comanda un break sull'oggetto
RETURN NIL

*******************************************************************************
FUNCTION BolFrmEnd(         ;                        // [ 07 ] OPERAZIONI DI CHIUSURA
                     cClose  ;                       // Modalita' chiusura oggetto:
                             ;                       // W_OC_RESTORE =  Restore dello screen
                             )                       // W_OC_DESTROY =  Rilascio dell'oggetto
*******************************************************************************
* #COD OBEND0 * #END //  Chiusura e rilascio oggetto oWin

oWin:=tbEnd( oWin , cClose )                         // ( vedere Norton Guide )

* #COD OAEND0 * #END //  Chiusura e rilascio oggetto oWin

RETURN NIL

*******************************************************************************
FUNCTION BolFrmGet(           ;                      // [ 08 ]  METODO PER L'INPUT DEI DATI
                    nGetState  ;                     //  Operazione richiesta:
                               ;                     //  DE_STATE_INK =  Consultazione
                               ;                     //  DE_STATE_ADD =  Inserimento
                               )                     //  DE_STATE_MOD =  Modifica
*******************************************************************************
LOCAL  lRet    := .F.                                //  Flag di registrazione dati se .T.
LOCAL  a121Fld := {}                                 //  Array per controllo somma contenuto campi 1:1

* #COD OBGET0 * #END //  Data-entry o ciclo di get


cState := nGetState                                  //  Riassegna statica stato data entry


nRec := T_Bolle->(Recno())                           //  Memorizza il record corrente

IF     cState==DE_STATE_ADD
   T_Bolle->(dbGoBottom()) ;T_Bolle->(dbSkip(1))
ELSEIF cState==DE_STATE_MOD
   IF T_Bolle->(EOF()) ;cState:=DE_STATE_INK ;END
ENDIF

* #COD OIGETA * #END Prima della valorizzazione delle variabili

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ VALORIZZAZIONE VARIABILI DI DATA ENTRY  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

CodBol     := T_Bolle->CodBol                       // Codice Bolla
DatBol     := iif(cState==DE_STATE_ADD ,DATE() ,T_Bolle->DatBol)   // Data Bolla
CodCli     := T_Bolle->CodCli                       // Codice Cliente
ScnBol     := IF(cState==DE_STATE_ADD,5,T_Bolle->ScnBol)   // Sconto
TipBol     := IF(cState==DE_STATE_ADD,"U",T_Bolle->TipBol)   // Tipo Bolla
* #COD OIGET2 * #END Dopo la valorizzazione delle variabili

IF cState==DE_STATE_ADD
              /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                ³ VALORIZZA I CAMPI EREDITATI DA RELAZIONI 1:N        ³
                ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
   tbInh( oWin ,aInh ,INH_DEF )

ENDIF
* #COD OIGET3 * #END Dopo la valorizzazione dei campi ereditati per 1:1 ed 1:N

BolFrmUpw( "#" )                                     //  Visualizza i dati da MEMORIA

IF cState==DE_STATE_INK ;RETU .T. ;END               //  Uscita in stato consultazione dati
IF cState==DE_STATE_ADD ;tbGetTop(oWin) ;END
IF cState==DE_STATE_MOD ;tbGetTop(oWin,.T.) ;END
* #COD OIGET4 * #END Prima della chiamata al modulo gestore delle get " tBget() "

WHILE( .T. )

   IF ! tbGet( oWin ,{||BolFrmDcc() } ,cState )      //  Modulo gestore delle get
      * #COD OIGET5 * #END Rinuncia registrazione dati prima di uscire da DO WHILE get
      EXIT
   END

   * #COD OIGET6 * #END Prima della scrittura campi su disco alla conferma dati

   IF cState==DE_STATE_ADD

      * #COD OIGETB * #END Prima calcolo chiavi primarie / univoche

      T_Bolle->(dfPkNew( {|x|if(x==NIL,CodBol,CodBol:=x)},  1 ,"CodBol" ,oWin:W_PRIMARYKEY ,1) )

      T_Bolle->(dbAppend())
      * #COD OIGETC * #END Dopo calcolo chiavi primarie / univoche

      nRec := T_Bolle->(Recno())                     //  Memorizza il nuovo record

      tbInh( oWin ,aInh ,INH_WRI )                   //  Scrive su disco i campi ereditati ( vedere Norton Guide )

   END

   * #COD OIGETD * #END Dopo la scrittura campi ereditati

   T_Bolle->(dbGoto(nRec))                           //  Riposiziona il record
   IF cState==DE_STATE_MOD
   END

     /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       ³             REPLACE DEI CAMPI              ³
       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
   T_Bolle->(dbGoto(nRec))                           //  Riposiziona prima di scrivere

   T_Bolle->CodBol     := CodBol                    // Codice Bolla
   T_Bolle->DatBol     := DatBol                    // Data Bolla
   T_Bolle->CodCli     := CodCli                    // Codice Cliente
   T_Bolle->ScnBol     := ScnBol                    // Sconto
   T_Bolle->TipBol     := TipBol                    // Tipo Bolla

   * #COD OIGET7 * #END Dopo la scrittura campi su disco alla conferma dati

   T_Bolle->(dbCommit())                             //  Aggiorna il record su disco

   * #COD OIGET8 * #END Dopo la scrittura campi da relazioni 1:1

     /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       ³          METTE    LE TRANSAZIONI           ³
       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
   T_Bolle->(BolFrmLtt(cState))
   * #COD OIGET9 * #END Dopo la scrittura transazioni e sblocco semaforo di rete
   lRet := .T.
   EXIT                                              //  Uscita dopo aggiornamento dati

ENDDO
T_Bolle->(dbGoto(nRec))                              //  Riposiziona il record


cState := DE_STATE_INK                               //  Imposta stato di consultazione

* #COD OAGET0 * #END //  Data-entry o ciclo di get

RETURN lRet

*******************************************************************************
FUNCTION BolFrmDcc()                                 // [ 09 ]  CONTROLLI CONGRUENZA DATI
*******************************************************************************
LOCAL  lRet := .T.

* #COD OBDCC0 * #END //  Controlli di congruenza dati

* #COD OADCC0 * #END //  Controlli di congruenza dati

RETURN lRet

*******************************************************************************
FUNCTION BolFrmDel(       ;                          // [ 10 ] CANCELLAZIONE RECORD
                    lAsk   )                         //  .T. chiede conferma prima della cancellazione
*******************************************************************************
* #COD OBDEL0 * #END //  Cancellazione record corrente

DEFAULT lAsk    TO .F.
DEFAULT oWin    TO BolFrmAct()

IF lAsk
   IF !dfYesNo( dfStdMsg(MSG_DE_DEL) ,.F.) ;RETURN .F. ;END
ENDIF

* #COD OIDEL1 * #END Prima della cancellazione record corrente

IF T_BolleDid()                                      // Delete integrity Data (dbRid.prg)
                                                     // Funzione di cancellazione su file
   TbEtr( oWin )                                     // Stabilizza la TBrowse corrente
ENDIF

* #COD OADEL0 * #END //  Cancellazione record corrente
RETURN .T.

*******************************************************************************
FUNCTION BolFrmLtt()                                 // [ 11 ] LOG TRANSAZIONE
*******************************************************************************
* #COD OBLTT0 * #END //  Log transazione

T_BolleTrn( "ltt" ,cState )

* #COD OALTT0 * #END //  Log transazione

RETURN .T.

*******************************************************************************
FUNCTION BolFrmAnr( oLsb ,bBlk )                     // [ 14 ] INSERIMENTO RIGA LIST BOX
*******************************************************************************
LOCAL lRet:=.F.                                      // Flag avvenuto inserimento

* #COD OBANR0 * #END //  Chiamata ad oggetto edit riga per inserimento riga List Box
DEFAULT bBlk TO {||.F.}

IF !EMPTY(oWin:W_ALIAS) .AND. SELECT(oWin:W_ALIAS) > 0 .AND.(! oWin:W_ALIAS == oLsb:W_ALIAS)                    .AND.(( oWin:W_ALIAS)->(BOF())  .OR.   (oWin:W_ALIAS)->(EOF()))
   dbMsgErr( dfStdMsg(MSG_DE_NOTADD) + oWin:W_ALIAS )
   RETURN lRet
ENDIF


   aInhSon := oLsb:W_INHARRAY                        // Referenzia array campi ereditati
                                                     // della List box in edit
   EVAL( bBlk )                                      // Valuta code block inserimento riga
   IF M->Act $ "wri-new"                             // Se il record e' stato aggiunto
      TbAtr( oLsb )                                  // Aggiunge la riga nella browse
      tbIcv( oLsb )                                  // Incrementa e visualizza totali
      IF M->Act == "new"                             // Se la riga e' stata registrata
         dbact2kbd("anr")                            // F9 comanda un nuovo inserimento
      ENDIF
      lRet := .T.
   ELSE
      TbRtr( oLsb, oWin )
   ENDIF
   M->Act := "rep"
   aInhSon:= NIL


* #COD OAANR0 * #END //  Chiamata ad oggetto edit riga per inserimento riga List Box

RETURN lRet
*******************************************************************************
FUNCTION BolFrmMcr( oLsb ,bBlk )                     // [ 15 ] MODIFICA    RIGA LIST BOX
*******************************************************************************
LOCAL lRet := .F.

* #COD OBMCR0 * #END //  Chiamata ad oggetto edit riga per modifica riga List box
DEFAULT bBlk TO {||.F.}


   IF BOF() .OR. EOF()
      dbMsgErr( dfStdMsg(MSG_DE_NOTMOD) )
   ELSE
      tbDcv( oLsb )                                  // Decrementa totali di riga
      EVAL( bBlk )                                   // Valuta code block per modifica riga
      tbIcv( oLsb )                                  // Incrementa e visualizza totali di colonna
      TbRtr( oLsb, oWin )                            // Aggiorna la riga a video
      IF M->Act $ "wri-new"                          // Se il record e' stato aggiunto
         lRet:=.T.
      ENDIF
      M->Act := "rep"
   ENDIF

* #COD OAMCR0 * #END //  Chiamata ad oggetto edit riga per modifica riga List box

RETURN lRet
*******************************************************************************
FUNCTION BolFrmEcr( oLsb ,bBlk )                     // [ 16 ] ELIMINA LA RIGA LIST BOX
*******************************************************************************
LOCAL lRet:=.F., nPos                                // Flag avvenuta modifica

* #COD OBECR0 * #END //  Domanda di conferma per la cancellazione riga List box
DEFAULT bBlk TO {||.F.}


   IF BOF() .OR. EOF()
      dbMsgErr( dfStdMsg(MSG_DE_NOTDEL) )
   ELSE
      IF dfYesNo( dfStdMsg(MSG_DE_DEL) ,.F.)
         tbDcv( oLsb )                               // Decrementa totali di colonna
         nPos := (oLsb:W_ALIAS)->(RECNO())
         EVAL( bBlk )                                // Valuta code block di cancellazione riga
         (oLsb:W_ALIAS)->(DBGOTO(nPos))
         TbEtr( oLsb )                               // Stabilizza la TBrowse corrente
         lRet   := .T.
      ELSE
         TbRtr( oLsb, oWin )
      ENDIF
   ENDIF


* #COD OAECR0 * #END //  Domanda di conferma per la cancellazione riga List box

RETURN lRet
*******************************************************************************
STATIC FUNCTION CodBol( nPrePost ) // CodBol    , C,   3,   0
*******************************************************************************
LOCAL aDbL ,lRet:=.T.
* #COD IIGSF10004 * #END
DO CASE
   CASE nPrePost == FORM_PREGET

        * #COD IIEDTB0004 * #END
        IF cState==DE_STATE_MOD
           RETURN .F.
        ENDIF
        /*  CHIAVE AUTOMATICA PROGRESSIVA */
        T_Bolle->(dfPkNew( {|x|if(x==NIL,CodBol,CodBol:=x)},  1 ,"CodBol" ,oWin:W_PRIMARYKEY ,1) )
        BolFrmUpw( "-codbol-" )

        RETURN .F.

        * #COD IIEDTA0004 * #END

   CASE nPrePost == FORM_POSTGET .OR. nPrePost == FORM_CHKGET

        * #COD IICHKB0004 * #END
        IF !T_Bolle->(ddPkChk(  1 ,tbPkExp(oWin), NIL, cState ))
           RETURN .F.
        ENDIF

        * #COD IICHKA0004 * #END

        IF nPrePost == FORM_POSTGET
           * #COD IIGSF50004 * #END
        ENDIF

ENDCASE
* #COD IIGSF90004 * #END

RETURN lRet
*******************************************************************************
STATIC FUNCTION CodCli( nPrePost ) // CodCli    , C,   6,   0
*******************************************************************************
LOCAL aDbL ,lRet:=.T.
* #COD IIGSF10006 * #END
DO CASE
   CASE nPrePost == FORM_PREGET

        * #COD IIEDTB0006 * #END

        * #COD IIEDTA0006 * #END

   CASE nPrePost == FORM_POSTGET .OR. nPrePost == FORM_CHKGET

        * #COD IICHKB0006 * #END
        aDbl           := ARRAY(LK_ARRAYLEN)
        aDbl[LK_ORDER] := 1                          //  Order (numerico)
        aDbl[LK_SEEK]  := CodCli                     //  Chiave di ricerca
        aDbl[LK_VAL]   := {}                         //  Dati da ereditare nel file figlio
        AADD( aDbl[LK_VAL] , { "CodCli" ,{||CodCli } })
        aDbl[LK_FIELD] := "CodCli"                   //  Nome campo relazionato
        aDbl[LK_WIN]   := NIL                        //  Nome finestra
        aDbl[LK_KEY]   := NIL                        //  Chiave finestra
        aDbl[LK_FILTER]:= {||.T.}                    //  Filtro finestra
        aDbl[LK_BREAK] := {||.F.}                    //  Break finestra
        aDbl[LK_TYPE]  := LT_NOTMANDATORY            //  Modalita' Look-Up
        aDbl[LK_EDIT]  := NIL                        //  Nome quadro edit
        aDbl[LK_INS]   := NIL                        //  Abilita edit se...
        aDbl[LK_KBD]   := .T.                        //  Keyboard
        * #COD IIGSF40006 * #END

        IF ! Clienti->(dbLooK( aDbl ))
           lRet := .F.
        ELSE
           IF nPrePost == FORM_POSTGET
              CodCli     := Clienti->CodCli
              tbDisRef( oWin ,"CodCli" )
           END
        ENDIF


        * #COD IICHKA0006 * #END

        IF nPrePost == FORM_POSTGET
           * #COD IIGSF50006 * #END
        ENDIF

ENDCASE
* #COD IIGSF90006 * #END

RETURN lRet


* #COD OIBOT1 * #END Fine file sorgente per oggetto form

