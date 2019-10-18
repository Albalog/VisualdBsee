/******************************************************************************
 Progetto       : Esempio Crystal Report
 Sottoprogetto  : Esempio Crystal Report
 Programma      : C:\PROGRA~1\VISUAL~1\SAMPLES\CRYSTAL\source\artFrm.prg
 Template       : C:\Programmi\VisualdBsee\bin\..\tmp\xbase\form.tmp
 Descrizione    : Gestione Articoli
 Programmatore  :
 Data           : 12-10-04
 Ora            : 16.03.00
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
#INCLUDE "dfWin.ch"                                  //   "       "     "  oggetti dBsee
* #COD OITOP0 * #END Punto di dichiarazione file INCLUDE *.ch per file sorgente


MEMVAR Act, Sa, A, EnvId, SubId, BackFun           //  Variabili di ambiente dBsee

STATIC  codart                                    ,; // Cod. articolo
        dexart                                    ,; // Descr. articolo
        image                                        // Immagine

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
FUNCTION artFrmExe(                                ; // [ 01 ]  ESECUTORE OPERAZIONI
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

PRIVATE  EnvId:="artFrm" ,SubId:=""                  // Identificativi per help


nWin++
IF nWin==1

   aInh   := arrInh                                  // Riassegna array campi ereditati
   cState := cMode                                   // Riassegna lo stato sulla modalit… operativa

   * #COD OIEXE5 * #END Dopo i settaggi dell'oggetto


   IF artFrmDbf()                                    // Apre la base dati

      artFrmAct()                                    // Attivazione oggetto

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
      artFrmInk() ;artFrmEnd(cClose) ;lRet := .T.

   END
   dfClose( aFile, .T., .F. )                        // Chiusura base dati ( vedere Norton Guide )

ENDIF
nWin--

* #COD OAEXE0 * #END //  Esegue le operazioni di base per attivazione oggetto FORM

RETURN lRet

*******************************************************************************
FUNCTION artFrmDbf()                                 // [ 02 ] APERTURA DATABASE
*******************************************************************************
* #COD OBDBF0 * #END //  Apertura della base dati

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³  MASTER FILE   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !dfUse( "articol" ,NIL ,aFile ) ;RETU .F. ;END    // Funzione di apertura file (vedere Norton Guide)



* #COD OADBF0 * #END //  Apertura della base dati

RETURN .T.

*******************************************************************************
FUNCTION artFrmAct()                                 // [ 03 ] INIZIALIZZA OGGETTO
*******************************************************************************
LOCAL aPfkItm

* #COD OBACT0 * #END //  Inizializzazione oggetto oWin

lBreak := .F.                                        // Condizione di break su oggetto posta a FALSE

IF oWin!=NIL ;RETURN oWin ;END                       // Si ritorna l'oggetto se gi… inizializzato

M_Cless()                                            // Stato di attesa con mouse a clessidra

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Inizializza oggetto ( vedere Norton Guide ) ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

oWin := articol->(TbBrwNew( 952                   ,; // Prima  Riga
                        32                        ,; // Prima  Colonna
                       384                        ,; // Ultima Riga
                       504                        ,; // Ultima Colonna
                      W_OBJ_FRM                             ,; // Tipo oggetto ( form )
                      NIL ,; // Label
                      W_COORDINATE_PIXEL                    )) // Gestione in Pixel

oWin:W_TITLE     := "Gestione Articoli"              // Titolo oggetto
oWin:W_KEY       := NIL                              // Non esegue la seek
oWin:W_FILTER    := {||.T.}                          // CodeBlock per il filtro
oWin:W_BREAK     := {||.F.}                          // CodeBlock per il break
oWin:W_PAGELABELS:= {}                               // Array delle pagine
ATTACH PAGE LABEL "Pagina Nø1" TO oWin:W_PAGELABELS
oWin:W_MENUHIDDEN:= .F.                              // Stato attivazione barra azioni
oWin:W_COLORARRAY[AC_FRM_BACK  ] := "B+/G"           // Colore di FONDO
oWin:W_COLORARRAY[AC_FRM_BOX   ] := "B+/G"           // Colore di BOX
oWin:W_COLORARRAY[AC_FRM_HEADER] := "RB+/B*"         // Colore di HEADER ON
oWin:W_COLORARRAY[AC_FRM_OPTION] := "W+/BG"          // Colore di ICONE

oWin:W_BG_TOP ++
oWin:W_RP_TOP ++ ;oWin:nTop++

#ifdef __XPP__
oWin:lCenter := .T.
oWin:icon := APPLICATION_ICON
#endif
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Control                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oWin:W_MOUSEMETHOD := W_MM_PAGE + W_MM_ESCAPE+ W_MM_MOVE    // Inizializzazione ICONE per mouse
* #COD OIACT1 * #END Dopo inizializzazioni oggetto oWin Browse

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Inizializza menu e azioni   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
ATTACH "1" TO MENU oWin:W_MENUARRAY AS MN_LABEL    ; // ACTMNU.TMP
        BLOCK    {||if( (cState$"iam") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^File"                           ; // Etichetta
        EXECUTE  {||dbMsgErr( dfStdMsg( MSG_ADDMENUUND ) )}  ; // Funzione
        MESSAGE  "Operazioni su file corrente"     ; // Messaggio utente
        ID "0014000024"
ATTACH "11" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {||if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Inserimento"                    ; // Etichetta
        SHORTCUT "add"                             ; // Shortcut
        EXECUTE  {||artFrmGet(DE_STATE_ADD)}  ; // Funzione
        MESSAGE  "Inserimento nuovo record"        ; // Messaggio utente
        ID "0014000025"
ATTACH "12" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {||if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Modifica"                       ; // Etichetta
        SHORTCUT "mod"                             ; // Shortcut
        EXECUTE  {||artFrmGet(DE_STATE_MOD)}  ; // Funzione
        MESSAGE  "Modifica record corrente"        ; // Messaggio utente
        ID "0014000026"
ATTACH "13" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {||if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "C^ancellazione"                  ; // Etichetta
        SHORTCUT "del"                             ; // Shortcut
        EXECUTE  {||artFrmDel(.T.)}                ; // Funzione
        MESSAGE  "Cancellazione record corrente"   ; // Messaggio utente
        ID "0014000027"
ATTACH "14" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {||if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Ricerca su chiavi"              ; // Etichetta
        SHORTCUT "win"                             ; // Shortcut
        EXECUTE  {||articol->(ddKey())}            ; // Funzione
        MESSAGE  "Ricerca su chiavi"               ; // Messaggio utente
        ID "0014000028"
ATTACH "15" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {||if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Finestra di ricerca"            ; // Etichetta
        SHORTCUT "A07"                             ; // Shortcut
        EXECUTE  {||articol->(ddWin())}            ; // Funzione
        MESSAGE  "Apre una finestra per consultazione records"  ; // Messaggio utente
        ID "0014000029"
ATTACH "16" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {||if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "Record ^successivo"              ; // Etichetta
        SHORTCUT "skn"                             ; // Shortcut
        EXECUTE  {||tbDown(oWin)}                  ; // Funzione
        MESSAGE  "Muove al record successivo"      ; // Messaggio utente
        ID "0014000030"
ATTACH "17" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {||if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "Record pr^ecedente"              ; // Etichetta
        SHORTCUT "skp"                             ; // Shortcut
        EXECUTE  {||tbUp(oWin)}                    ; // Funzione
        MESSAGE  "Muove al record precedente"      ; // Messaggio utente
        ID "0014000031"
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
* #COD OIACT2 * #END Dopo dichiarazione ATTACH del menu per oggetto oWin

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³INIZIALIZZA ARRAY CON STRUTTURA CAMPI CHIAVE PRIMARIA³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
ATTACH KEY "globalexp" TO oWin:W_PRIMARYKEY
ATTACH KEY "CODART"  TO oWin:W_PRIMARYKEY          ; // Campo chiave
       KEYTYPE    2                                ; // Tipo  campo chiave
       BLOCK      {|x|IF(x==NIL,codart ,codart:=x) }  ; // Valorizza la chiave
       VARTYPE    "C"                              ; // Tipo dato
       VARLEN     6                                ; // Lunghezza campo chiave
       EXPRESSION "codart"                           // Espressione

* #COD OIACT3 * #END Dopo inizializzazione array  con campi chiave primaria

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Control                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
ATTACH "box0015" TO oWin:W_CONTROL BOX 01          ; // ATTBOX.TMP
                 AT  210,   0,  88, 482            ; // Coordinate
                 BOXTEXT ""                        ; // BOX Text
                 COORDINATE  W_COORDINATE_PIXEL    ; // Tipo Coordinate
                 BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                 COLOR {"W+/G","B+/G","N/G"}         // Array dei colori
ATTACH "say0016" TO oWin:W_CONTROL SAY "Articoli" AT  286,   8  ; // ATTSAY.TMP
                 SIZE       {  76,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // SAY ALIGNMENT
                 COLOR    {"N/G"}                    // Array dei colori
ATTACH "img0018" TO oWin:W_CONTROL FUNCTION IMAGE AT   70,  10, 119, 415  ; // ATTEXP.TMP
                 COORDINATE  W_COORDINATE_PIXEL  ; // Coordinate in Pixel
                 COLOR     {NIL,NIL,"N/N",NIL,NIL}  ; // Array dei colori
                 BITMAPOPTION FUN_BMP_NORMAL + FUN_BMP_CENTER   // Bitmap (XBASE)
ATTACH "but0001" TO oWin:W_CONTROL GET AS PUSHBUTTON ""  ; // ATTBUT.TMP
                 AT   22,   0,  22,  24            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||tbTop(oWin)}          ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 BITMAP    BUT_BMP_YES             ; // Bitmap (XBASE)
                 BITMAPID  1100                    ; // Bitmap ID (XBASE)
                 MESSAGE "Muove al primo record"     // Messaggio utente
ATTACH "but0002" TO oWin:W_CONTROL GET AS PUSHBUTTON ""  ; // ATTBUT.TMP
                 AT   22,  32,  22,  16            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||tbUp(oWin)}           ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 BITMAP    BUT_BMP_YES             ; // Bitmap (XBASE)
                 BITMAPID  1102                    ; // Bitmap ID (XBASE)
                 MESSAGE "Muove al record precedente"    // Messaggio utente
ATTACH "but0003" TO oWin:W_CONTROL GET AS PUSHBUTTON ""  ; // ATTBUT.TMP
                 AT   22,  56,  22,  16            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||tbDown(oWin)}         ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 BITMAP    BUT_BMP_YES             ; // Bitmap (XBASE)
                 BITMAPID  1103                    ; // Bitmap ID (XBASE)
                 MESSAGE "Muove al record successivo"    // Messaggio utente
ATTACH "but0004" TO oWin:W_CONTROL GET AS PUSHBUTTON ""  ; // ATTBUT.TMP
                 AT   22,  80,  22,  24            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||tbBottom(oWin)}       ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 BITMAP    BUT_BMP_YES             ; // Bitmap (XBASE)
                 BITMAPID  1101                    ; // Bitmap ID (XBASE)
                 MESSAGE "Muove all'ultimo record"    // Messaggio utente
ATTACH "but0005" TO oWin:W_CONTROL GET AS PUSHBUTTON "~Ins."  ; // ATTBUT.TMP
                 AT   22, 112,  22,  40            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||artFrmGet(DE_STATE_ADD)}  ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 MESSAGE "Inserimento nuovo record"    // Messaggio utente
ATTACH "but0006" TO oWin:W_CONTROL GET AS PUSHBUTTON "~Mod."  ; // ATTBUT.TMP
                 AT   22, 160,  22,  40            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||artFrmGet(DE_STATE_MOD)}  ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 MESSAGE "Modifica record corrente"    // Messaggio utente
ATTACH "but0007" TO oWin:W_CONTROL GET AS PUSHBUTTON "C~anc."  ; // ATTBUT.TMP
                 AT   22, 208,  22,  48            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||artFrmDel(.T.)}       ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 MESSAGE "Cancellazione record corrente"    // Messaggio utente
ATTACH "but0008" TO oWin:W_CONTROL GET AS PUSHBUTTON "~Ric."  ; // ATTBUT.TMP
                 AT   22, 264,  22,  40            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||articol->(ddKey())}  ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 MESSAGE "Ricerca record su chiavi"    // Messaggio utente
ATTACH "but0017" TO oWin:W_CONTROL GET AS PUSHBUTTON "~Stampa"  ; // ATTBUT.TMP
                 AT   22, 312,  22,  56            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||artPr1Exe(PRINT_CURRENT, NIL, NIL, NIL, .F.)}  ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 MESSAGE ""                          // Messaggio utente
ATTACH "but0009" TO oWin:W_CONTROL GET AS PUSHBUTTON "O~k"  ; // ATTBUT.TMP
                 AT   22, 376,  22,  24            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||dbAct2Kbd("wri")}     ; // Funzione di controllo
                 ACTIVE   {||cState $ "am"}        ; // Stato di attivazione
                 MESSAGE "Registra e chiude"         // Messaggio utente
ATTACH "but0010" TO oWin:W_CONTROL GET AS PUSHBUTTON "A~bbandona"  ; // ATTBUT.TMP
                 AT   22, 408,  22,  80            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||dbAct2Kbd("esc")}     ; // Funzione di controllo
                 ACTIVE   {||cState $ "iam"}       ; // Stato di attivazione
                 MESSAGE "Abbandona"                 // Messaggio utente
ATTACH "codart" TO oWin:W_CONTROL GET codart AT  264, 136  ; // ATTGET.TMP
                 SIZE       {  56,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // GET ALIGNMENT
                 COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT   "Cod. articolo"          ; // Prompt
                 PROMPTAT  264 ,  24               ; // Coordinate prompt
                 PICTURESAY "!!!!!!"               ; // Picture in say
                 CONDITION {|ab|codart(ab)}        ; // Funzione When/Valid
                 MESSAGE "Cod. articolo"           ; // Messaggio
                 VARNAME "codart"                  ; //
                 REFRESHID "articol"               ; // Appartiene ai gruppi di refresh
                 ACTIVE {||cState $ "am" }          // Stato di attivazione
ATTACH "dexart" TO oWin:W_CONTROL GET dexart AT  242, 136  ; // ATTGET.TMP
                 SIZE       { 328,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // GET ALIGNMENT
                 COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT   "Descr. articolo"        ; // Prompt
                 PROMPTAT  242 ,   8               ; // Coordinate prompt
                 PICTURESAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  ; // Picture in say
                 MESSAGE "Descr. articolo"         ; // Messaggio
                 VARNAME "dexart"                  ; //
                 REFRESHID "articol"               ; // Appartiene ai gruppi di refresh
                 ACTIVE {||cState $ "am" }          // Stato di attivazione
ATTACH "image" TO oWin:W_CONTROL GET image AT  220, 136  ; // ATTGET.TMP
                 SIZE       { 328,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // GET ALIGNMENT
                 COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT   "Immagine"               ; // Prompt
                 PROMPTAT  220 ,  64               ; // Coordinate prompt
                 PICTURESAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  ; // Picture in say
                 MESSAGE "Nome file immagine"      ; // Messaggio
                 VARNAME "image"                   ; //
                 REFRESHID "articol"               ; // Appartiene ai gruppi di refresh
                 ACTIVE {||cState $ "am" }          // Stato di attivazione


M_Normal()                                           // Stato mouse normale

* #COD OAACT0 * #END //  Inizializzazione oggetto oWin

RETURN oWin

*******************************************************************************
FUNCTION artFrmUpw(        ;                         // [ 04 ]  UPDATE WINDOW  Aggiornamento oggetto
                    cDisGrp )                        //  Id. gruppo di visualizzazione
                                                     //  "#" = aggiorna tutti i control
*******************************************************************************
* #COD OBUPW0 * #END //  Update window oggetto oWin

tbDisItm( oWin ,cDisGrp )                            //  funzione di aggiornamento control (vedere Norton Guide)

* #COD OAUPW0 * #END //  Update window oggetto oWin

RETURN NIL

*******************************************************************************
FUNCTION artFrmInk()                                 // [ 05 ] INTERAZIONE CON L'UTENTE
*******************************************************************************
LOCAL cCho

* #COD OBINK0 * #END //  Interazione con l'utente o inkey di tastiera

IF cState!=DE_STATE_INK
   RETURN artFrmGet(cState)
ENDIF

WHILE( !lBreak )

   artFrmGet(cState)                                 //  Visualizza i dati

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
FUNCTION artFrmBrk()                                 // [ 06 ] COMANDA UN BREAK SULL'OGGETTO
*******************************************************************************
* #COD OBBRK0 * #END //  Comanda un break sull'oggetto
lBreak := .T.
* #COD OABRK0 * #END //  Comanda un break sull'oggetto
RETURN NIL

*******************************************************************************
FUNCTION artFrmEnd(         ;                        // [ 07 ] OPERAZIONI DI CHIUSURA
                     cClose  ;                       // Modalita' chiusura oggetto:
                             ;                       // W_OC_RESTORE =  Restore dello screen
                             )                       // W_OC_DESTROY =  Rilascio dell'oggetto
*******************************************************************************
* #COD OBEND0 * #END //  Chiusura e rilascio oggetto oWin

oWin:=tbEnd( oWin , cClose )                         // ( vedere Norton Guide )

* #COD OAEND0 * #END //  Chiusura e rilascio oggetto oWin

RETURN NIL

*******************************************************************************
FUNCTION artFrmGet(           ;                      // [ 08 ]  METODO PER L'INPUT DEI DATI
                    nGetState  ;                     //  Operazione richiesta:
                               ;                     //  DE_STATE_INK =  Consultazione
                               ;                     //  DE_STATE_ADD =  Inserimento
                               )                     //  DE_STATE_MOD =  Modifica
*******************************************************************************
LOCAL  lRet    := .F.                                //  Flag di registrazione dati se .T.
LOCAL  a121Fld := {}                                 //  Array per controllo somma contenuto campi 1:1

* #COD OBGET0 * #END //  Data-entry o ciclo di get


cState := nGetState                                  //  Riassegna statica stato data entry


nRec := articol->(Recno())                           //  Memorizza il record corrente

IF     cState==DE_STATE_ADD
   articol->(dbGoBottom()) ;articol->(dbSkip(1))
ELSEIF cState==DE_STATE_MOD
   IF articol->(EOF()) ;cState:=DE_STATE_INK ;END
ENDIF

* #COD OIGETA * #END Prima della valorizzazione delle variabili

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ VALORIZZAZIONE VARIABILI DI DATA ENTRY  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

codart     := articol->codart                       // Cod. articolo
dexart     := articol->dexart                       // Descr. articolo
image      := articol->image                        // Immagine
* #COD OIGET2 * #END Dopo la valorizzazione delle variabili

IF cState==DE_STATE_ADD
              /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                ³ VALORIZZA I CAMPI EREDITATI DA RELAZIONI 1:N        ³
                ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
   tbInh( oWin ,aInh ,INH_DEF )

ENDIF
* #COD OIGET3 * #END Dopo la valorizzazione dei campi ereditati per 1:1 ed 1:N

artFrmUpw( "#" )                                     //  Visualizza i dati da MEMORIA

IF cState==DE_STATE_INK ;RETU .T. ;END               //  Uscita in stato consultazione dati
IF cState==DE_STATE_ADD ;tbGetTop(oWin) ;END
IF cState==DE_STATE_MOD ;tbGetTop(oWin,.T.) ;END
* #COD OIGET4 * #END Prima della chiamata al modulo gestore delle get " tBget() "

WHILE( .T. )

   IF ! tbGet( oWin ,{||artFrmDcc() } ,cState )      //  Modulo gestore delle get
      * #COD OIGET5 * #END Rinuncia registrazione dati prima di uscire da DO WHILE get
      EXIT
   END

   * #COD OIGET6 * #END Prima della scrittura campi su disco alla conferma dati

   IF cState==DE_STATE_ADD

      * #COD OIGETB * #END Prima calcolo chiavi primarie / univoche


      articol->(dbAppend())
      * #COD OIGETC * #END Dopo calcolo chiavi primarie / univoche

      nRec := articol->(Recno())                     //  Memorizza il nuovo record

      tbInh( oWin ,aInh ,INH_WRI )                   //  Scrive su disco i campi ereditati ( vedere Norton Guide )

   END

   * #COD OIGETD * #END Dopo la scrittura campi ereditati


     /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       ³             REPLACE DEI CAMPI              ³
       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
   articol->(dbGoto(nRec))                           //  Riposiziona prima di scrivere

   articol->codart     := codart                    // Cod. articolo
   articol->dexart     := dexart                    // Descr. articolo
   articol->image      := image                     // Immagine

   * #COD OIGET7 * #END Dopo la scrittura campi su disco alla conferma dati

   articol->(dbCommit())                             //  Aggiorna il record su disco

   * #COD OIGET8 * #END Dopo la scrittura campi da relazioni 1:1

   * #COD OIGET9 * #END Dopo la scrittura transazioni e sblocco semaforo di rete
   lRet := .T.
   EXIT                                              //  Uscita dopo aggiornamento dati

ENDDO
articol->(dbGoto(nRec))                              //  Riposiziona il record


cState := DE_STATE_INK                               //  Imposta stato di consultazione

* #COD OAGET0 * #END //  Data-entry o ciclo di get

RETURN lRet

*******************************************************************************
FUNCTION artFrmDcc()                                 // [ 09 ]  CONTROLLI CONGRUENZA DATI
*******************************************************************************
LOCAL  lRet := .T.

* #COD OBDCC0 * #END //  Controlli di congruenza dati

* #COD OADCC0 * #END //  Controlli di congruenza dati

RETURN lRet

*******************************************************************************
FUNCTION artFrmDel(       ;                          // [ 10 ] CANCELLAZIONE RECORD
                    lAsk   )                         //  .T. chiede conferma prima della cancellazione
*******************************************************************************
* #COD OBDEL0 * #END //  Cancellazione record corrente

DEFAULT lAsk    TO .F.
DEFAULT oWin    TO artFrmAct()

IF lAsk
   IF !dfYesNo( dfStdMsg(MSG_DE_DEL) ,.F.) ;RETURN .F. ;END
ENDIF

* #COD OIDEL1 * #END Prima della cancellazione record corrente

IF articolDid()                                      // Delete integrity Data (dbRid.prg)
                                                     // Funzione di cancellazione su file
   TbEtr( oWin )                                     // Stabilizza la TBrowse corrente
ENDIF

* #COD OADEL0 * #END //  Cancellazione record corrente
RETURN .T.

*******************************************************************************
STATIC FUNCTION codart( nPrePost ) // codart    , C,   6,   0
*******************************************************************************
LOCAL aDbL ,lRet:=.T.
* #COD IIGSF10011 * #END
DO CASE
   CASE nPrePost == FORM_PREGET

        * #COD IIEDTB0011 * #END
        IF cState==DE_STATE_MOD
           RETURN .F.
        ENDIF

        * #COD IIEDTA0011 * #END

   CASE nPrePost == FORM_POSTGET .OR. nPrePost == FORM_CHKGET

        * #COD IICHKB0011 * #END
        IF !articol->(ddPkChk(  1 ,tbPkExp(oWin), NIL, cState ))
           RETURN .F.
        ENDIF

        * #COD IICHKA0011 * #END

        IF nPrePost == FORM_POSTGET
           * #COD IIGSF50011 * #END
        ENDIF

ENDCASE
* #COD IIGSF90011 * #END

RETURN lRet


* #COD OIBOT1 * #END Fine file sorgente per oggetto form

