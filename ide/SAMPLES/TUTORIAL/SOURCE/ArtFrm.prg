/******************************************************************************
 Progetto       : Tutorial
 Sottoprogetto  : Tutorial
 Programma      : V:\SAMPLES\TUTORIAL\source\ArtFrm.prg
 Template       : V:\bin\..\tmp\xbase\form.tmp
 Descrizione    : Scheda Articoli
 Programmatore  : Demo
 Data           : 13-07-06
 Ora            : 16.43.57
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

STATIC  codart                                    ,; // Codice Articolo
        codcat                                    ,; // Codice Categoria
        desart                                    ,; // Descrizione Articolo
        przart                                    ,; // Prezzo
        qtaart                                    ,; // Quantit…
        arttip                                    ,; // Tipologia Articolo
        esiart                                    ,; // Esistenza Articolo
        colart                                    ,; // Colore Articolo
        notart                                       // Info Articolo

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
FUNCTION ArtFrmExe(                                ; // [ 01 ]  ESECUTORE OPERAZIONI
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

PRIVATE  EnvId:="ArtFrm" ,SubId:=""                  // Identificativi per help

nWin++
IF nWin==1

   aInh   := arrInh                                  // Riassegna array campi ereditati
   cState := cMode                                   // Riassegna lo stato sulla modalit… operativa

   * #COD OIEXE5 * #END Dopo i settaggi dell'oggetto


   IF ArtFrmDbf()                                    // Apre la base dati

      ArtFrmAct()                                    // Attivazione oggetto

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
      ArtFrmInk() ;ArtFrmEnd(cClose) ;lRet := .T.

   END
   dfClose( aFile, .T., .F. )                        // Chiusura base dati ( vedere Norton Guide )

ENDIF
nWin--

* #COD OAEXE0 * #END //  Esegue le operazioni di base per attivazione oggetto FORM

RETURN lRet

*******************************************************************************
FUNCTION ArtFrmDbf()                                 // [ 02 ] APERTURA DATABASE
*******************************************************************************
* #COD OBDBF0 * #END //  Apertura della base dati

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³  MASTER FILE   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !dfUse( "Articoli" ,NIL ,aFile ) ;RETU .F. ;END    // Funzione di apertura file (vedere Norton Guide)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³  LOOK-UP FILE  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !dfUse( "Categ" ,NIL ,aFile ) ;RETU .F. ;END


* #COD OADBF0 * #END //  Apertura della base dati

RETURN .T.

*******************************************************************************
FUNCTION ArtFrmAct()                                 // [ 03 ] INIZIALIZZA OGGETTO
*******************************************************************************
LOCAL aPfkItm

* #COD OBACT0 * #END //  Inizializzazione oggetto oWin

lBreak := .F.                                        // Condizione di break su oggetto posta a FALSE

IF oWin!=NIL ;RETURN oWin ;END                       // Si ritorna l'oggetto se gi… inizializzato

M_Cless()                                            // Stato di attesa con mouse a clessidra

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Inizializza oggetto ( vedere Norton Guide ) ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

oWin := Articoli->(TbBrwNew( 608                  ,; // Prima  Riga
                         0                        ,; // Prima  Colonna
                       472                        ,; // Ultima Riga
                       570                        ,; // Ultima Colonna
                      W_OBJ_FRM                             ,; // Tipo oggetto ( form )
                      NIL ,; // Label
                      W_COORDINATE_PIXEL                    )) // Gestione in Pixel

oWin:W_TITLE     := "Scheda Articoli"                // Titolo oggetto
oWin:W_KEY       := NIL                              // Non esegue la seek
oWin:W_FILTER    := {||.T.}                          // CodeBlock per il filtro
oWin:W_BREAK     := {||.F.}                          // CodeBlock per il break
oWin:W_PAGELABELS:= {}                               // Array delle pagine
oWin:W_PAGECODEBLOCK:= {}
oWin:W_PAGERESIZE:= {}
ATTACH PAGE LABEL "Informazioni Articolo" TO oWin:W_PAGELABELS
ATTACH PAGE CODEBLOCK {||.T.} TO oWin:W_PAGECODEBLOCK
ATTACH PAGE LABEL "Altre Informazioni" TO oWin:W_PAGELABELS
ATTACH PAGE CODEBLOCK {||.T.} TO oWin:W_PAGECODEBLOCK
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
        ID "0013000030"
ATTACH "11" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Inserimento"                    ; // Etichetta
        SHORTCUT "add"                             ; // Shortcut
        EXECUTE  {||ArtFrmGet('a')}                ; // Funzione
        MESSAGE  "Inserimento nuovo record"        ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0013000031"
ATTACH "12" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Modifica"                       ; // Etichetta
        SHORTCUT "mod"                             ; // Shortcut
        EXECUTE  {||ArtFrmGet('m')}                ; // Funzione
        MESSAGE  "Modifica record corrente"        ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0013000032"
ATTACH "13" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "C^ancellazione"                  ; // Etichetta
        SHORTCUT "del"                             ; // Shortcut
        EXECUTE  {||ArtFrmDel(.T.)}                ; // Funzione
        MESSAGE  "Cancellazione record corrente"   ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0013000033"
ATTACH "14" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Ricerca su chiavi"              ; // Etichetta
        SHORTCUT "win"                             ; // Shortcut
        EXECUTE  {||Articoli->(ddKey())}  ; // Funzione
        MESSAGE  "Ricerca su chiavi"               ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0013000034"
ATTACH "15" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Finestra di ricerca"            ; // Etichetta
        SHORTCUT "A07"                             ; // Shortcut
        EXECUTE  {||Articoli->(ddWin())}  ; // Funzione
        MESSAGE  "Apre una finestra per consultazione records"  ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0013000035"
ATTACH "16" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "Record ^successivo"              ; // Etichetta
        SHORTCUT "skn"                             ; // Shortcut
        EXECUTE  {||tbDown(oWin)}                  ; // Funzione
        MESSAGE  "Muove al record successivo"      ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0013000036"
ATTACH "17" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "Record pr^ecedente"              ; // Etichetta
        SHORTCUT "skp"                             ; // Shortcut
        EXECUTE  {||tbUp(oWin)}                    ; // Funzione
        MESSAGE  "Muove al record precedente"      ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0013000037"
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
        ID "0013000130"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("mod")}               ; //
        WHEN    {|| (cState $ "i") }               ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Modifica"                        ; //
        TOOLTIP "Modifica  (F4)"                   ; //
        IMAGES  TOOLBAR_MOD                        ; //
        ID "0013000131"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("del")}               ; //
        WHEN    {|| (cState $ "i") }               ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Cancellazione"                   ; //
        TOOLTIP "Cancellazione  (F6)"              ; //
        IMAGES  TOOLBAR_DEL                        ; //
        ID "0013000132"
ATTACH TOOLSEPARATOR TO oWin                         // ACTTBR.TMP
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("win")}               ; //
        WHEN    {|| (cState $ "i") }               ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Ricerca su chiavi"               ; //
        TOOLTIP "Ricerca su chiavi  (F7)"  ; //
        IMAGES  TOOLBAR_FIND                       ; //
        ID "0013000134"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("A07")}               ; //
        WHEN    {|| (cState $ "i") }               ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Finestra di ricerca"             ; //
        TOOLTIP "Finestra di ricerca  (Alt-F7)"  ; //
        IMAGES  TOOLBAR_FIND_WIN                   ; //
        ID "0013000135"
ATTACH TOOLSEPARATOR TO oWin                         // ACTTBR.TMP
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("wri")}               ; //
        WHEN    {|| (cState $ "am") }              ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Conferma i dati (F10)"           ; //
        TOOLTIP "Conferma i dati (F10)"  ; //
        IMAGES  TOOLBAR_WRITE_H                    ; //
        ID "0013000137"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("esc")}               ; //
        WHEN    {|| (cState $ "iam") }             ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Fine operazioni (Esc)"           ; //
        TOOLTIP "Fine operazioni (Esc)"  ; //
        IMAGES  TOOLBAR_ESC_H                      ; //
        ID "0013000138"
ATTACH TOOLSEPARATOR TO oWin                         // ACTTBR.TMP
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("skp")}               ; //
        WHEN    {|| (cState $ "i") }               ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Record precedente"               ; //
        TOOLTIP "Record precedente  (-)"  ; //
        IMAGES  TOOLBAR_PREV                       ; //
        ID "0013000140"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("skn")}               ; //
        WHEN    {|| (cState $ "i") }               ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Record successivo"               ; //
        TOOLTIP "Record successivo  (+)"  ; //
        IMAGES  TOOLBAR_NEXT                       ; //
        ID "0013000141"
ATTACH TOOLSEPARATOR TO oWin                         // ACTTBR.TMP
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("hlp")}               ; //
        WHEN    {|| (cState $ "iam") }             ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Aiuto (F1)"                      ; //
        TOOLTIP "Aiuto (F1)"                       ; //
        IMAGES  TOOLBAR_HELP_H                     ; //
        ID "0013000143"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("ush")}               ; //
        WHEN    {|| (cState $ "iam") }             ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Aiuto (Shift-F1)"                ; //
        TOOLTIP "Aiuto (Shift-F1)"                 ; //
        IMAGES  TOOLBAR_KEYHELP_H                  ; //
        ID "0013000144"
* #COD OIACT2 * #END Dopo dichiarazione ATTACH del menu per oggetto oWin

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³INIZIALIZZA ARRAY CON STRUTTURA CAMPI CHIAVE PRIMARIA³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
ATTACH KEY "globalexp" TO oWin:W_PRIMARYKEY
ATTACH KEY "CODART"  TO oWin:W_PRIMARYKEY          ; // Campo chiave
       KEYTYPE    0                                ; // Tipo  campo chiave
       BLOCK      {|x|IF(x==NIL,CodArt ,CodArt:=x) }  ; // Valorizza la chiave
       VARTYPE    "C"                              ; // Tipo dato
       VARLEN     8                                ; // Lunghezza campo chiave
       EXPRESSION "CodArt"                           // Espressione

* #COD OIACT3 * #END Dopo inizializzazione array  con campi chiave primaria

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Control                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
ATTACH "box0030" TO oWin:W_CONTROL BOX 01          ; // ATTBOX.TMP
                 AT   60,  10, 131, 370            ; // Coordinate
                 BOXTEXT "Colore Articolo"         ; // BOX Text
                 COORDINATE  W_COORDINATE_PIXEL    ; // Tipo Coordinate
                 BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                 COLOR {"W+/G","B+/G","N/G"}         // Array dei colori
ATTACH "box0037" TO oWin:W_CONTROL BOX 01          ; // ATTBOX.TMP
                 AT   60, 390,  70, 150            ; // Coordinate
                 BOXTEXT ""                        ; // BOX Text
                 COORDINATE  W_COORDINATE_PIXEL    ; // Tipo Coordinate
                 BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                 COLOR {"W+/G","B+/G","N/G"}         // Array dei colori
ATTACH "box0038" TO oWin:W_CONTROL BOX 01          ; // ATTBOX.TMP
                 AT  190,  10, 172, 370            ; // Coordinate
                 BOXTEXT "Dati Articolo"           ; // BOX Text
                 COORDINATE  W_COORDINATE_PIXEL    ; // Tipo Coordinate
                 BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                 COLOR {"W+/G","B+/G","N/G"}         // Array dei colori
ATTACH "box0036" TO oWin:W_CONTROL BOX 01          ; // ATTBOX.TMP
                 AT  190, 390,  56, 150            ; // Coordinate
                 BOXTEXT ""                        ; // BOX Text
                 COORDINATE  W_COORDINATE_PIXEL    ; // Tipo Coordinate
                 BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                 COLOR {"W+/G","B+/G","N/G"}         // Array dei colori
ATTACH "box0035" TO oWin:W_CONTROL BOX 01          ; // ATTBOX.TMP
                 AT  250, 390, 111, 150            ; // Coordinate
                 BOXTEXT ""                        ; // BOX Text
                 COORDINATE  W_COORDINATE_PIXEL    ; // Tipo Coordinate
                 BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                 COLOR {"W+/G","B+/G","N/G"}         // Array dei colori
ATTACH "box0040" TO oWin:W_CONTROL BOX 01          ; // ATTBOX.TMP
                 AT   60, 400, 126, 130            ; // Coordinate
                 BOXTEXT ""                        ; // BOX Text
                 COORDINATE  W_COORDINATE_PIXEL    ; // Tipo Coordinate
                 BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                 PAGE  2                           ; // Pagina
                 COLOR {"W+/G","B+/G","N/G"}         // Array dei colori
ATTACH "box0039" TO oWin:W_CONTROL BOX 01          ; // ATTBOX.TMP
                 AT  190,  10, 167, 520            ; // Coordinate
                 BOXTEXT "Articolo"                ; // BOX Text
                 COORDINATE  W_COORDINATE_PIXEL    ; // Tipo Coordinate
                 BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                 PAGE  2                           ; // Pagina
                 COLOR {"W+/G","B+/G","N/G"}         // Array dei colori
ATTACH "say0033" TO oWin:W_CONTROL SAY "Ora:" AT   80, 420  ; // ATTSAY.TMP
                 SIZE       {  30,  30}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // SAY ALIGNMENT
                 PAGE      0                       ; // Pagina
                 COLOR    {"N/G"}                    // Array dei colori
ATTACH "DesCat" TO oWin:W_CONTROL FUNCTION Categ->DesCat AT  320, 180,  22, 199  ; // ATTREL.TMP
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // FUNCTION ALIGNMENT
                 PAGE       0                      ; // Pagina
                 COLOR {"N/G","G+/G","B+/G",NIL,NIL}  ; // Array dei colori
                 PICTURESAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  ; // Picture in say
                 BEFORE {||Categ->(dfS(1,CodCat))  }  ; // dfS() funzione di allineamento (vedere Norton Guide)
                 REFRESHID "Articoli-CodCat"       ; // Gruppo di refresh
                 DISPLAYIF {||.T.}                   // Display condizionale
ATTACH "exp0032" TO oWin:W_CONTROL FUNCTION dftime() AT   80, 460,  30,  60  ; // ATTEXP.TMP
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // FUNCTION ALIGNMENT
                 PAGE        0                     ; // Pagina
                 COLOR    {NIL,NIL,"GR+/G",NIL,NIL}  ; // Array dei colori
                 REALTIME                          ; // Aggiornato in tempo reale
                 PICTURESAY ""                       // Picture in say
ATTACH "but0001" TO oWin:W_CONTROL GET AS PUSHBUTTON "|<"  ; // ATTBUT.TMP
                 AT   10,  10,  32,  40            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 PAGE        0                     ; // Pagina
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||tbTop(oWin)}          ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 MESSAGE "Muove al primo record"     // Messaggio utente
ATTACH "but0002" TO oWin:W_CONTROL GET AS PUSHBUTTON "<"  ; // ATTBUT.TMP
                 AT   10,  60,  32,  40            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 PAGE        0                     ; // Pagina
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||tbUp(oWin)}           ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 MESSAGE "Muove al record precedente"    // Messaggio utente
ATTACH "but0003" TO oWin:W_CONTROL GET AS PUSHBUTTON ">"  ; // ATTBUT.TMP
                 AT   10, 110,  32,  40            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 PAGE        0                     ; // Pagina
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||tbDown(oWin)}         ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 MESSAGE "Muove al record successivo"    // Messaggio utente
ATTACH "but0004" TO oWin:W_CONTROL GET AS PUSHBUTTON ">|"  ; // ATTBUT.TMP
                 AT   10, 160,  32,  40            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 PAGE        0                     ; // Pagina
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||tbBottom(oWin)}       ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 MESSAGE "Muove all'ultimo record"    // Messaggio utente
ATTACH "but0005" TO oWin:W_CONTROL GET AS PUSHBUTTON "^Inserim."  ; // ATTBUT.TMP
                 AT   10, 210,  32,  40            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 PAGE        0                     ; // Pagina
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||ArtFrmGet(DE_STATE_ADD)}  ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 MESSAGE "Inserimento nuovo record"    // Messaggio utente
ATTACH "but0006" TO oWin:W_CONTROL GET AS PUSHBUTTON "^Modif."  ; // ATTBUT.TMP
                 AT   10, 260,  32,  40            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 PAGE        0                     ; // Pagina
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||ArtFrmGet(DE_STATE_MOD)}  ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 MESSAGE "Modifica record corrente"    // Messaggio utente
ATTACH "but0007" TO oWin:W_CONTROL GET AS PUSHBUTTON "C^anc."  ; // ATTBUT.TMP
                 AT   10, 310,  32,  40            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 PAGE        0                     ; // Pagina
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||ArtFrmDel(.T.)}       ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 MESSAGE "Cancellazione record corrente"    // Messaggio utente
ATTACH "but0008" TO oWin:W_CONTROL GET AS PUSHBUTTON "^Ric."  ; // ATTBUT.TMP
                 AT   10, 360,  32,  40            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 PAGE        0                     ; // Pagina
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||Articoli->(ddKey())}  ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 MESSAGE "Ricerca record su chiavi"    // Messaggio utente
ATTACH "but0009" TO oWin:W_CONTROL GET AS PUSHBUTTON "O^k"  ; // ATTBUT.TMP
                 AT   10, 410,  32,  40            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 PAGE        0                     ; // Pagina
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||dbAct2Kbd("wri")}     ; // Funzione di controllo
                 ACTIVE   {||cState $ "iam"}       ; // Stato di attivazione
                 MESSAGE "Registra e chiude"         // Messaggio utente
ATTACH "but0010" TO oWin:W_CONTROL GET AS PUSHBUTTON "A^bbandona"  ; // ATTBUT.TMP
                 AT   10, 460,  32,  80            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 PAGE        0                     ; // Pagina
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||dbAct2Kbd("esc")}     ; // Funzione di controllo
                 ACTIVE   {||cState $ "iam"}       ; // Stato di attivazione
                 MESSAGE "Abbandona"                 // Messaggio utente
ATTACH "CodCat" TO oWin:W_CONTROL GET CodCat AT  320, 130  ; // ATTGET.TMP
                 SIZE       {  44,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // GET ALIGNMENT
                 PAGE        0                     ; // Pagina
                 COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT   "Codice Categoria:"      ; // Prompt
                 PROMPTAT  320 , -14               ; // Coordinate prompt
                 PICTURESAY "!!"                   ; // Picture in say
                 CONDITION {|ab|CodCat(ab)}        ; // Funzione When/Valid
                 MESSAGE "Codice Categoria"        ; // Messaggio
                 VARNAME "CodCat"                  ; //
                 REFRESHID "Articoli"              ; // Appartiene ai gruppi di refresh
                 COMBO                             ; // Icona combo
                 ACTIVE {||cState $ "am" }          // Stato di attivazione
ATTACH "CodArt" TO oWin:W_CONTROL GET CodArt AT  290, 130  ; // ATTGET.TMP
                 SIZE       {  70,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // GET ALIGNMENT
                 PAGE        0                     ; // Pagina
                 COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT   "Codice Articolo:"       ; // Prompt
                 PROMPTAT  290 ,  -6               ; // Coordinate prompt
                 PICTURESAY "!!!!!!!!"             ; // Picture in say
                 CONDITION {|ab|CodArt(ab)}        ; // Funzione When/Valid
                 MESSAGE "Codice Articolo"         ; // Messaggio
                 VARNAME "CodArt"                  ; //
                 REFRESHID "Articoli"              ; // Appartiene ai gruppi di refresh
                 ACTIVE {||cState $ "am" }          // Stato di attivazione
ATTACH "DesArt" TO oWin:W_CONTROL GET DesArt AT  260, 130  ; // ATTGET.TMP
                 SIZE       { 230,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // GET ALIGNMENT
                 PAGE        0                     ; // Pagina
                 COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT   "Descrizione Articolo:"  ; // Prompt
                 PROMPTAT  260 , -46               ; // Coordinate prompt
                 PICTURESAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  ; // Picture in say
                 CONDITION {|ab|DesArt(ab)}        ; // Funzione When/Valid
                 MESSAGE "Descrizione Articolo"    ; // Messaggio
                 VARNAME "DesArt"                  ; //
                 REFRESHID "Articoli"              ; // Appartiene ai gruppi di refresh
                 ACTIVE {||cState $ "am" }          // Stato di attivazione
ATTACH "PrzArt" TO oWin:W_CONTROL GET PrzArt AT  230, 130  ; // ATTGET.TMP
                 SIZE       {  88,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // GET ALIGNMENT
                 PAGE        0                     ; // Pagina
                 COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT   "Prezzo:"                ; // Prompt
                 PROMPTAT  230 ,  66               ; // Coordinate prompt
                 PICTURESAY "@ZE 999,999.99"       ; // Picture in say
                 MESSAGE "Prezzo"                  ; // Messaggio
                 VARNAME "PrzArt"                  ; //
                 REFRESHID "Articoli"              ; // Appartiene ai gruppi di refresh
                 ACTIVE {||cState $ "am" }          // Stato di attivazione
ATTACH "QtaArt" TO oWin:W_CONTROL GET QtaArt AT  200, 130  ; // ATTGET.TMP
                 SIZE       {  88,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // GET ALIGNMENT
                 PAGE        0                     ; // Pagina
                 COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT   "Quantit… in Magazino:"  ; // Prompt
                 PROMPTAT  200 , -46               ; // Coordinate prompt
                 PICTURESAY "@ZE 999,999.99"       ; // Picture in say
                 MESSAGE "Quantit…"                ; // Messaggio
                 VARNAME "QtaArt"                  ; //
                 REFRESHID "Articoli"              ; // Appartiene ai gruppi di refresh
                 ACTIVE {||cState $ "am" }          // Stato di attivazione
ATTACH "rdb0017" TO oWin:W_CONTROL GET AS RADIOBUTTON ArtTip  PROMPT "Hardware"  ; // ATTRDB.tmp
                 AT  320, 400                      ; // Coordinate
                 SIZE       { 100,  30}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 VALUE    "H"                      ; // Valore
                 GAP      1                        ; // Spazio ICONA / PROMPT
                 COLOR    {"N/G","G+/G","W+/BG","W+/G"}  ; // Array dei colori
                 ACTIVE  {||cState $ "am" }        ; // Stato di attivazione
                 VARNAME "ArtTip"                  ; //
                 MESSAGE ""                          // Messaggio utente
ATTACH "rdb0018" TO oWin:W_CONTROL GET AS RADIOBUTTON ArtTip  PROMPT "Software"  ; // ATTRDB.tmp
                 AT  290, 400                      ; // Coordinate
                 SIZE       { 100,  30}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 VALUE    "S"                      ; // Valore
                 GAP      1                        ; // Spazio ICONA / PROMPT
                 COLOR    {"N/G","G+/G","W+/BG","W+/G"}  ; // Array dei colori
                 ACTIVE  {||cState $ "am" }        ; // Stato di attivazione
                 VARNAME "ArtTip"                  ; //
                 MESSAGE ""                          // Messaggio utente
ATTACH "rdb0019" TO oWin:W_CONTROL GET AS RADIOBUTTON ArtTip  PROMPT "Altro"  ; // ATTRDB.tmp
                 AT  260, 400                      ; // Coordinate
                 SIZE       { 100,  30}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 VALUE    "A"                      ; // Valore
                 GAP      1                        ; // Spazio ICONA / PROMPT
                 COLOR    {"N/G","G+/G","W+/BG","W+/G"}  ; // Array dei colori
                 ACTIVE  {||cState $ "am" }        ; // Stato di attivazione
                 VARNAME "ArtTip"                  ; //
                 MESSAGE ""                          // Messaggio utente
ATTACH "ckb0020" TO oWin:W_CONTROL GET AS CHECKBOX EsiArt  PROMPT "In Magazzino"  ; // ATTCKB.TMP
                 AT  200, 400                      ; // Coordinate
                 SIZE       { 100,  30}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 VALUEON  "1"                      ; // Valore in ON
                 VALUEOFF "0"                      ; // Valore in OFF
                 GAP      1                        ; // Spazio ICONA / PROMPT
                 COLOR    {"N/G","G+/G","W+/BG","BG+/G"}  ; // Array dei colori
                 ACTIVE   {||cState $ "am" }       ; // Stato di attivazione
                 VARNAME "EsiArt"                  ; //
                 MESSAGE ""                          // Messaggio utente
ATTACH "rdb0021" TO oWin:W_CONTROL GET AS RADIOBUTTON ColArt  PROMPT "Verde Chiaro"  ; // ATTRDB.tmp
                 AT  140,  47                      ; // Coordinate
                 SIZE       { 100,  30}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 VALUE    001                      ; // Valore
                 GAP      1                        ; // Spazio ICONA / PROMPT
                 COLOR    DFXPPCLRSELECT({"7/",NIL,NIL,NIL},{"N/G","G+/G","W+/BG","W+/G"})  ; // Array dei colori
                 ACTIVE  {||cState $ "am" }        ; // Stato di attivazione
                 VARNAME "ColArt"                  ; //
                 MESSAGE "Selezionare il colore dell'Articolo"    // Messaggio utente
ATTACH "rdb0022" TO oWin:W_CONTROL GET AS RADIOBUTTON ColArt  PROMPT "Verde"  ; // ATTRDB.tmp
                 AT  111,  45                      ; // Coordinate
                 SIZE       { 100,  30}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 VALUE    002                      ; // Valore
                 GAP      1                        ; // Spazio ICONA / PROMPT
                 COLOR    DFXPPCLRSELECT({"7/",NIL,NIL,NIL},{"N/G","G+/G","W+/BG","W+/G"})  ; // Array dei colori
                 ACTIVE  {||cState $ "am" }        ; // Stato di attivazione
                 VARNAME "ColArt"                  ; //
                 MESSAGE "Selezionare il colore dell'Articolo"    // Messaggio utente
ATTACH "rdb0023" TO oWin:W_CONTROL GET AS RADIOBUTTON ColArt  PROMPT "Verde Scuro"  ; // ATTRDB.tmp
                 AT   80,  45                      ; // Coordinate
                 SIZE       { 100,  30}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 VALUE    003                      ; // Valore
                 GAP      1                        ; // Spazio ICONA / PROMPT
                 COLOR    DFXPPCLRSELECT({"6/",NIL,NIL,NIL},{"N/G","G+/G","W+/BG","W+/G"})  ; // Array dei colori
                 ACTIVE  {||cState $ "am" }        ; // Stato di attivazione
                 VARNAME "ColArt"                  ; //
                 MESSAGE "Selezionare il colore dell'Articolo"    // Messaggio utente
ATTACH "rdb0024" TO oWin:W_CONTROL GET AS RADIOBUTTON ColArt  PROMPT "Rosso chiaro"  ; // ATTRDB.tmp
                 AT  140, 160                      ; // Coordinate
                 SIZE       { 100,  30}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 VALUE    004                      ; // Valore
                 GAP      1                        ; // Spazio ICONA / PROMPT
                 COLOR    DFXPPCLRSELECT({"11/",NIL,NIL,NIL},{"N/G","G+/G","W+/BG","W+/G"})  ; // Array dei colori
                 ACTIVE  {||cState $ "am" }        ; // Stato di attivazione
                 VARNAME "ColArt"                  ; //
                 MESSAGE "Selezionare il colore dell'Articolo"    // Messaggio utente
ATTACH "rdb0025" TO oWin:W_CONTROL GET AS RADIOBUTTON ColArt  PROMPT "Rosso"  ; // ATTRDB.tmp
                 AT  110, 160                      ; // Coordinate
                 SIZE       { 100,  30}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 VALUE    005                      ; // Valore
                 GAP      1                        ; // Spazio ICONA / PROMPT
                 COLOR    DFXPPCLRSELECT({"10/",NIL,NIL,NIL},{"N/G","G+/G","W+/BG","W+/G"})  ; // Array dei colori
                 ACTIVE  {||cState $ "am" }        ; // Stato di attivazione
                 VARNAME "ColArt"                  ; //
                 MESSAGE "Selezionare il colore dell'Articolo"    // Messaggio utente
ATTACH "rdb0026" TO oWin:W_CONTROL GET AS RADIOBUTTON ColArt  PROMPT "Rosso scuro"  ; // ATTRDB.tmp
                 AT   80, 160                      ; // Coordinate
                 SIZE       { 100,  30}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 VALUE    006                      ; // Valore
                 GAP      1                        ; // Spazio ICONA / PROMPT
                 COLOR    DFXPPCLRSELECT({"9/",NIL,NIL,NIL},{"N/G","G+/G","W+/BG","W+/G"})  ; // Array dei colori
                 ACTIVE  {||cState $ "am" }        ; // Stato di attivazione
                 VARNAME "ColArt"                  ; //
                 MESSAGE "Selezionare il colore dell'Articolo"    // Messaggio utente
ATTACH "rdb0027" TO oWin:W_CONTROL GET AS RADIOBUTTON ColArt  PROMPT "Blu chiaro"  ; // ATTRDB.tmp
                 AT  140, 270                      ; // Coordinate
                 SIZE       { 100,  30}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 VALUE    007                      ; // Valore
                 GAP      1                        ; // Spazio ICONA / PROMPT
                 COLOR    DFXPPCLRSELECT({"5/",NIL,NIL,NIL},{"N/G","G+/G","W+/BG","W+/G"})  ; // Array dei colori
                 ACTIVE  {||cState $ "am" }        ; // Stato di attivazione
                 VARNAME "ColArt"                  ; //
                 MESSAGE "Selezionare il colore dell'Articolo"    // Messaggio utente
ATTACH "rdb0028" TO oWin:W_CONTROL GET AS RADIOBUTTON ColArt  PROMPT "Blu"  ; // ATTRDB.tmp
                 AT  110, 270                      ; // Coordinate
                 SIZE       { 100,  30}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 VALUE    008                      ; // Valore
                 GAP      1                        ; // Spazio ICONA / PROMPT
                 COLOR    DFXPPCLRSELECT({"4/",NIL,NIL,NIL},{"N/G","G+/G","W+/BG","W+/G"})  ; // Array dei colori
                 ACTIVE  {||cState $ "am" }        ; // Stato di attivazione
                 VARNAME "ColArt"                  ; //
                 MESSAGE "Selezionare il colore dell'Articolo"    // Messaggio utente
ATTACH "rdb0029" TO oWin:W_CONTROL GET AS RADIOBUTTON ColArt  PROMPT "Blu scuro"  ; // ATTRDB.tmp
                 AT   80, 270                      ; // Coordinate
                 SIZE       { 100,  30}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 VALUE    009                      ; // Valore
                 GAP      1                        ; // Spazio ICONA / PROMPT
                 COLOR    DFXPPCLRSELECT({"3/",NIL,NIL,NIL},{"N/G","G+/G","W+/BG","W+/G"})  ; // Array dei colori
                 ACTIVE  {||cState $ "am" }        ; // Stato di attivazione
                 VARNAME "ColArt"                  ; //
                 MESSAGE "Selezionare il colore dell'Articolo"    // Messaggio utente
ATTACH "NotArt" TO oWin:W_CONTROL GET AS TEXTFIELD NotArt AT   60,  10, 130, 380  ; // ATTGET.TMP
                 COORDINATE  W_COORDINATE_PIXEL ; // Coordinate in Formato Pixel
                 PAGE        2                     ; // Pagina
                 COLOR {"W+/G","G+/G","N/W*","W+/BG","N/G","BG/G"}  ; // Array dei colori
                 CONDITION {|ab|.T.}               ; // Funzione When/Valid
                 SYSFUNCTION "dfMemo"              ; // Funzione di sys
                 MESSAGE "Info Articolo"           ; // Messaggio
                 VARNAME "NotArt"                  ; //
                 REFRESHID "Articoli"              ; // Appartiene ai gruppi di refresh
                 PROMPT "Informazioni Articolo"    ; // Prompt
                 BOX   01                          ; // Tipo Box
                 ACTIVE   {||cState $ "am" }         // Stato di attivazione


M_Normal()                                           // Stato mouse normale

* #COD OAACT0 * #END //  Inizializzazione oggetto oWin

RETURN oWin

*******************************************************************************
FUNCTION ArtFrmUpw(        ;                         // [ 04 ]  UPDATE WINDOW  Aggiornamento oggetto
                    cDisGrp )                        //  Id. gruppo di visualizzazione
                                                     //  "#" = aggiorna tutti i control
*******************************************************************************
* #COD OBUPW0 * #END //  Update window oggetto oWin

tbDisItm( oWin ,cDisGrp )                            //  funzione di aggiornamento control (vedere Norton Guide)

* #COD OAUPW0 * #END //  Update window oggetto oWin

RETURN NIL

*******************************************************************************
FUNCTION ArtFrmInk()                                 // [ 05 ] INTERAZIONE CON L'UTENTE
*******************************************************************************
LOCAL cCho

* #COD OBINK0 * #END //  Interazione con l'utente o inkey di tastiera

IF cState!=DE_STATE_INK
   RETURN ArtFrmGet(cState)
ENDIF

WHILE( !lBreak )

   ArtFrmGet(cState)                                 //  Visualizza i dati

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
FUNCTION ArtFrmBrk()                                 // [ 06 ] COMANDA UN BREAK SULL'OGGETTO
*******************************************************************************
* #COD OBBRK0 * #END //  Comanda un break sull'oggetto
lBreak := .T.
* #COD OABRK0 * #END //  Comanda un break sull'oggetto
RETURN NIL

*******************************************************************************
FUNCTION ArtFrmEnd(         ;                        // [ 07 ] OPERAZIONI DI CHIUSURA
                     cClose  ;                       // Modalita' chiusura oggetto:
                             ;                       // W_OC_RESTORE =  Restore dello screen
                             )                       // W_OC_DESTROY =  Rilascio dell'oggetto
*******************************************************************************
* #COD OBEND0 * #END //  Chiusura e rilascio oggetto oWin

oWin:=tbEnd( oWin , cClose )                         // ( vedere Norton Guide )

* #COD OAEND0 * #END //  Chiusura e rilascio oggetto oWin

RETURN NIL

*******************************************************************************
FUNCTION ArtFrmGet(           ;                      // [ 08 ]  METODO PER L'INPUT DEI DATI
                    nGetState  ;                     //  Operazione richiesta:
                               ;                     //  DE_STATE_INK =  Consultazione
                               ;                     //  DE_STATE_ADD =  Inserimento
                               )                     //  DE_STATE_MOD =  Modifica
*******************************************************************************
LOCAL  lRet    := .F.                                //  Flag di registrazione dati se .T.
LOCAL  a121Fld := {}                                 //  Array per controllo somma contenuto campi 1:1

* #COD OBGET0 * #END //  Data-entry o ciclo di get


cState := nGetState                                  //  Riassegna statica stato data entry


nRec := Articoli->(Recno())                          //  Memorizza il record corrente

IF     cState==DE_STATE_ADD
   Articoli->(dbGoBottom()) ;Articoli->(dbSkip(1))
ELSEIF cState==DE_STATE_MOD
   IF Articoli->(EOF()) ;cState:=DE_STATE_INK ;END
ENDIF

* #COD OIGETA * #END Prima della valorizzazione delle variabili

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ VALORIZZAZIONE VARIABILI DI DATA ENTRY  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

CodArt     := Articoli->CodArt                      // Codice Articolo
CodCat     := Articoli->CodCat                      // Codice Categoria
DesArt     := Articoli->DesArt                      // Descrizione Articolo
PrzArt     := Articoli->PrzArt                      // Prezzo
QtaArt     := Articoli->QtaArt                      // Quantit…
ArtTip     := IF(cState==DE_STATE_ADD,"H",Articoli->ArtTip)   // Tipologia Articolo
EsiArt     := IF(cState==DE_STATE_ADD,"1",Articoli->EsiArt)   // Esistenza Articolo
ColArt     := IF(cState==DE_STATE_ADD,001,Articoli->ColArt)   // Colore Articolo
NotArt     := Articoli->NotArt                      // Info Articolo
* #COD OIGET2 * #END Dopo la valorizzazione delle variabili

IF cState==DE_STATE_ADD
              /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                ³ VALORIZZA I CAMPI EREDITATI DA RELAZIONI 1:N        ³
                ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
   tbInh( oWin ,aInh ,INH_DEF )

ENDIF
* #COD OIGET3 * #END Dopo la valorizzazione dei campi ereditati per 1:1 ed 1:N

ArtFrmUpw( "#" )                                     //  Visualizza i dati da MEMORIA

IF cState==DE_STATE_INK ;RETU .T. ;END               //  Uscita in stato consultazione dati
IF cState==DE_STATE_ADD ;tbGetTop(oWin) ;END
IF cState==DE_STATE_MOD ;tbGetTop(oWin,.T.) ;END
* #COD OIGET4 * #END Prima della chiamata al modulo gestore delle get " tBget() "

WHILE( .T. )

   IF ! tbGet( oWin ,{||ArtFrmDcc() } ,cState )      //  Modulo gestore delle get
      * #COD OIGET5 * #END Rinuncia registrazione dati prima di uscire da DO WHILE get
      EXIT
   END

   * #COD OIGET6 * #END Prima della scrittura campi su disco alla conferma dati

   IF cState==DE_STATE_ADD

      * #COD OIGETB * #END Prima calcolo chiavi primarie / univoche


      Articoli->(dbAppend())
      * #COD OIGETC * #END Dopo calcolo chiavi primarie / univoche

      nRec := Articoli->(Recno())                    //  Memorizza il nuovo record

      tbInh( oWin ,aInh ,INH_WRI )                   //  Scrive su disco i campi ereditati ( vedere Norton Guide )

   END

   * #COD OIGETD * #END Dopo la scrittura campi ereditati


     /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       ³             REPLACE DEI CAMPI              ³
       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
   Articoli->(dbGoto(nRec))                          //  Riposiziona prima di scrivere

   Articoli->CodArt     := CodArt                   // Codice Articolo
   Articoli->CodCat     := CodCat                   // Codice Categoria
   Articoli->DesArt     := DesArt                   // Descrizione Articolo
   Articoli->PrzArt     := PrzArt                   // Prezzo
   Articoli->QtaArt     := QtaArt                   // Quantit…
   Articoli->ArtTip     := ArtTip                   // Tipologia Articolo
   Articoli->EsiArt     := EsiArt                   // Esistenza Articolo
   Articoli->ColArt     := ColArt                   // Colore Articolo
   Articoli->NotArt     := NotArt                   // Info Articolo

   * #COD OIGET7 * #END Dopo la scrittura campi su disco alla conferma dati

   Articoli->(dbCommit())                            //  Aggiorna il record su disco

   * #COD OIGET8 * #END Dopo la scrittura campi da relazioni 1:1

   * #COD OIGET9 * #END Dopo la scrittura transazioni e sblocco semaforo di rete
   lRet := .T.
   EXIT                                              //  Uscita dopo aggiornamento dati

ENDDO
Articoli->(dbGoto(nRec))                             //  Riposiziona il record


cState := DE_STATE_INK                               //  Imposta stato di consultazione

* #COD OAGET0 * #END //  Data-entry o ciclo di get

RETURN lRet

*******************************************************************************
FUNCTION ArtFrmDcc()                                 // [ 09 ]  CONTROLLI CONGRUENZA DATI
*******************************************************************************
LOCAL  lRet := .T.

* #COD OBDCC0 * #END //  Controlli di congruenza dati

* #COD OADCC0 * #END //  Controlli di congruenza dati

RETURN lRet

*******************************************************************************
FUNCTION ArtFrmDel(       ;                          // [ 10 ] CANCELLAZIONE RECORD
                    lAsk   )                         //  .T. chiede conferma prima della cancellazione
*******************************************************************************
* #COD OBDEL0 * #END //  Cancellazione record corrente

DEFAULT lAsk    TO .F.
DEFAULT oWin    TO ArtFrmAct()

IF lAsk
   IF !dfYesNo( dfStdMsg(MSG_DE_DEL) ,.F.) ;RETURN .F. ;END
ENDIF

* #COD OIDEL1 * #END Prima della cancellazione record corrente

IF ArticoliDid()                                     // Delete integrity Data (dbRid.prg)
                                                     // Funzione di cancellazione su file
   TbEtr( oWin )                                     // Stabilizza la TBrowse corrente
ENDIF

* #COD OADEL0 * #END //  Cancellazione record corrente
RETURN .T.

*******************************************************************************
STATIC FUNCTION CodCat( nPrePost ) // CodCat    , C,   2,   0
*******************************************************************************
LOCAL aDbL ,lRet:=.T.
* #COD IIGSF10011 * #END
DO CASE
   CASE nPrePost == FORM_PREGET

        * #COD IIEDTB0011 * #END

        * #COD IIEDTA0011 * #END

   CASE nPrePost == FORM_POSTGET .OR. nPrePost == FORM_CHKGET

        * #COD IICHKB0011 * #END
        aDbl           := ARRAY(LK_ARRAYLEN)
        aDbl[LK_ORDER] := 1                          //  Order (numerico)
        aDbl[LK_SEEK]  := CodCat                     //  Chiave di ricerca
        aDbl[LK_VAL]   := {}                         //  Dati da ereditare nel file figlio
        AADD( aDbl[LK_VAL] , { "CodCat" ,{||CodCat } })
        aDbl[LK_FIELD] := "CodCat"                   //  Nome campo relazionato
        aDbl[LK_WIN]   := NIL                        //  Nome finestra
        aDbl[LK_KEY]   := NIL                        //  Chiave finestra
        aDbl[LK_FILTER]:= {||.T.}                    //  Filtro finestra
        aDbl[LK_BREAK] := {||.F.}                    //  Break finestra
        aDbl[LK_TYPE]  := LT_NOTMANDATORY            //  Modalita' Look-Up
        aDbl[LK_EDIT]  := NIL                        //  Nome quadro edit
        aDbl[LK_INS]   := NIL                        //  Abilita edit se...
        aDbl[LK_KBD]   := .T.                        //  Keyboard
        * #COD IIGSF40011 * #END

        IF ! Categ->(dbLooK( aDbl ))
           lRet := .F.
        ELSE
           IF nPrePost == FORM_POSTGET
              CodCat     := Categ->CodCat
              tbDisRef( oWin ,"CodCat" )
           END
        ENDIF


        * #COD IICHKA0011 * #END

        IF nPrePost == FORM_POSTGET
           * #COD IIGSF50011 * #END
        ENDIF

ENDCASE
* #COD IIGSF90011 * #END

RETURN lRet
*******************************************************************************
STATIC FUNCTION CodArt( nPrePost ) // CodArt    , C,   8,   0
*******************************************************************************
LOCAL aDbL ,lRet:=.T.
* #COD IIGSF10012 * #END
DO CASE
   CASE nPrePost == FORM_PREGET

        * #COD IIEDTB0012 * #END
        IF cState==DE_STATE_MOD
           RETURN .F.
        ENDIF

        * #COD IIEDTA0012 * #END

   CASE nPrePost == FORM_POSTGET .OR. nPrePost == FORM_CHKGET

        * #COD IICHKB0012 * #END
        IF !Articoli->(ddPkChk(  1 ,tbPkExp(oWin), NIL, cState ))
           RETURN .F.
        ENDIF

        * #COD IICHKA0012 * #END

        IF nPrePost == FORM_POSTGET
           * #COD IIGSF50012 * #END
        ENDIF

ENDCASE
* #COD IIGSF90012 * #END

RETURN lRet
*******************************************************************************
STATIC FUNCTION DesArt( nPrePost ) // DesArt    , C,  30,   0
*******************************************************************************
LOCAL aDbL ,lRet:=.T.
* #COD IIGSF10013 * #END
DO CASE
   CASE nPrePost == FORM_PREGET

        * #COD IIEDTB0013 * #END

        * #COD IIEDTA0013 * #END

   CASE nPrePost == FORM_POSTGET .OR. nPrePost == FORM_CHKGET

        * #COD IICHKB0013 * #END
        IF !Articoli->(ddPkChk(  2 ,Upper(DesArt), NIL, cState ))
           RETURN .F.
        ENDIF

        * #COD IICHKA0013 * #END

        IF nPrePost == FORM_POSTGET
           * #COD IIGSF50013 * #END
        ENDIF

ENDCASE
* #COD IIGSF90013 * #END

RETURN lRet


* #COD OIBOT1 * #END Fine file sorgente per oggetto form

