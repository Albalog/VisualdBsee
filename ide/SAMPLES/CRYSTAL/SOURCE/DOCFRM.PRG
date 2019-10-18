/******************************************************************************
 Progetto       : Esempio Crystal Report
 Sottoprogetto  : Esempio Crystal Report
 Programma      : C:\PROGRA~1\VISUAL~1\SAMPLES\CRYSTAL\source\docFrm.prg
 Template       : C:\Programmi\VisualdBsee\bin\..\tmp\xbase\form.tmp
 Descrizione    : Gestione Documenti
 Programmatore  :
 Data           : 12-10-04
 Ora            : 16.03.13
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

STATIC  numdoc                                    ,; // Num. doc.
        lsb0001                                   ,; // identificatore control list box
        datdoc                                    ,; // Data doc.
        codcli                                       // Codice cliente

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
FUNCTION docFrmExe(                                ; // [ 01 ]  ESECUTORE OPERAZIONI
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

PRIVATE  EnvId:="docFrm" ,SubId:=""                  // Identificativi per help


nWin++
IF nWin==1

   aInh   := arrInh                                  // Riassegna array campi ereditati
   cState := cMode                                   // Riassegna lo stato sulla modalit… operativa

   * #COD OIEXE5 * #END Dopo i settaggi dell'oggetto


   IF docFrmDbf()                                    // Apre la base dati

      docFrmAct()                                    // Attivazione oggetto

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
      docFrmInk() ;docFrmEnd(cClose) ;lRet := .T.

   END
   dfClose( aFile, .T., .F. )                        // Chiusura base dati ( vedere Norton Guide )

ENDIF
nWin--

* #COD OAEXE0 * #END //  Esegue le operazioni di base per attivazione oggetto FORM

RETURN lRet

*******************************************************************************
FUNCTION docFrmDbf()                                 // [ 02 ] APERTURA DATABASE
*******************************************************************************
* #COD OBDBF0 * #END //  Apertura della base dati

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³  MASTER FILE   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !dfUse( "docven" ,NIL ,aFile ) ;RETU .F. ;END    // Funzione di apertura file (vedere Norton Guide)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³  LOOK-UP FILE  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !dfUse( "articol" ,NIL ,aFile ) ;RETU .F. ;END
IF !dfUse( "clienti" ,NIL ,aFile ) ;RETU .F. ;END
IF !dfUse( "docvend" ,NIL ,aFile ) ;RETU .F. ;END


* #COD OADBF0 * #END //  Apertura della base dati

RETURN .T.

*******************************************************************************
FUNCTION docFrmAct()                                 // [ 03 ] INIZIALIZZA OGGETTO
*******************************************************************************
LOCAL aPfkItm

* #COD OBACT0 * #END //  Inizializzazione oggetto oWin

lBreak := .F.                                        // Condizione di break su oggetto posta a FALSE

IF oWin!=NIL ;RETURN oWin ;END                       // Si ritorna l'oggetto se gi… inizializzato

M_Cless()                                            // Stato di attesa con mouse a clessidra

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Inizializza oggetto ( vedere Norton Guide ) ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

oWin := docven->(TbBrwNew( 774                    ,; // Prima  Riga
                         0                        ,; // Prima  Colonna
                       562                        ,; // Ultima Riga
                       632                        ,; // Ultima Colonna
                      W_OBJ_FRM                             ,; // Tipo oggetto ( form )
                      NIL ,; // Label
                      W_COORDINATE_PIXEL                    )) // Gestione in Pixel

oWin:W_TITLE     := "Gestione Documenti"             // Titolo oggetto
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
        ID "0017000038"
ATTACH "11" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {||if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Inserimento"                    ; // Etichetta
        SHORTCUT "add"                             ; // Shortcut
        EXECUTE  {||docFrmGet(DE_STATE_ADD)}  ; // Funzione
        MESSAGE  "Inserimento nuovo record"        ; // Messaggio utente
        ID "0017000039"
ATTACH "12" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {||if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Modifica"                       ; // Etichetta
        SHORTCUT "mod"                             ; // Shortcut
        EXECUTE  {||docFrmGet(DE_STATE_MOD)}  ; // Funzione
        MESSAGE  "Modifica record corrente"        ; // Messaggio utente
        ID "0017000040"
ATTACH "13" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {||if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "C^ancellazione"                  ; // Etichetta
        SHORTCUT "del"                             ; // Shortcut
        EXECUTE  {||docFrmDel(.T.)}                ; // Funzione
        MESSAGE  "Cancellazione record corrente"   ; // Messaggio utente
        ID "0017000041"
ATTACH "14" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {||if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Ricerca su chiavi"              ; // Etichetta
        SHORTCUT "win"                             ; // Shortcut
        EXECUTE  {||docven->(ddKey())}             ; // Funzione
        MESSAGE  "Ricerca su chiavi"               ; // Messaggio utente
        ID "0017000042"
ATTACH "15" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {||if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Finestra di ricerca"            ; // Etichetta
        SHORTCUT "A07"                             ; // Shortcut
        EXECUTE  {||docven->(ddWin())}             ; // Funzione
        MESSAGE  "Apre una finestra per consultazione records"  ; // Messaggio utente
        ID "0017000043"
ATTACH "16" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {||if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "Record ^successivo"              ; // Etichetta
        SHORTCUT "skn"                             ; // Shortcut
        EXECUTE  {||tbDown(oWin)}                  ; // Funzione
        MESSAGE  "Muove al record successivo"      ; // Messaggio utente
        ID "0017000044"
ATTACH "17" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {||if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "Record pr^ecedente"              ; // Etichetta
        SHORTCUT "skp"                             ; // Shortcut
        EXECUTE  {||tbUp(oWin)}                    ; // Funzione
        MESSAGE  "Muove al record precedente"      ; // Messaggio utente
        ID "0017000045"
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
ATTACH KEY "NUMDOC"  TO oWin:W_PRIMARYKEY          ; // Campo chiave
       KEYTYPE    1                                ; // Tipo  campo chiave
       BLOCK      {|x|IF(x==NIL,str(numdoc, 6, 0) ,numdoc:=x) }  ; // Valorizza la chiave
       VARTYPE    "N"                              ; // Tipo dato
       VARLEN     6                                ; // Lunghezza campo chiave
       EXPRESSION "str(numdoc, 6, 0)"    // Espressione

* #COD OIACT3 * #END Dopo inizializzazione array  con campi chiave primaria

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Control                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
ATTACH "ragsoc" TO oWin:W_CONTROL FUNCTION clienti->ragsoc AT  396, 192,  22, 330  ; // ATTREL.TMP
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // FUNCTION ALIGNMENT
                 COLOR {"N/G","G+/G","B+/G",NIL,NIL}  ; // Array dei colori
                 PICTURESAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  ; // Picture in say
                 BEFORE {||clienti->(dfS(1,codcli))  }  ; // dfS() funzione di allineamento (vedere Norton Guide)
                 REFRESHID "docven-codcli"         ; // Gruppo di refresh
                 DISPLAYIF {||.T.}                   // Display condiziona
/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³ Inizializza List-Box su archivio (vedere Norton Guide) ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
lsb0001 := docvend->(tbBrwNew(  88                ,; // Prima  Riga
                                    0             ,; // Prima  Colonna
                                  286             ,; // Ultima Riga
                                  616             ,; // Ultima Colonna
                                 W_OBJ_BROWSEBOX            ,; // List-Box su FILE
                                 NIL ,; // Label
                                 W_COORDINATE_PIXEL         )) // Gestione in Pixel

lsb0001:W_TITLE      := "Righe : Gestione Documenti"    // Titolo oggetto browse
lsb0001:W_ORDER      := 1                            // Nø Indice di relazione
lsb0001:W_KEY        := {||str(docven->numdoc, 6, 0)}    // CodeBlock per la seek
lsb0001:W_FILTER     := {||.T.}                      // CodeBlock per il filtro
lsb0001:W_BREAK      := {||str(docvend->numdoc, 6, 0)!=str(docven->numdoc, 6, 0)}    // CodeBlock per il break
lsb0001:W_COLORARRAY[AC_LSB_BACK  ]      := "N/W*"    // Colore fondo
lsb0001:W_COLORARRAY[AC_LSB_TOPLEFT]     := "N/G"    //    "   bordo superiore
lsb0001:W_COLORARRAY[AC_LSB_BOTTOMRIGHT] := "BG/G"    //    "   bordo inferiore
lsb0001:W_COLORARRAY[AC_LSB_PROMPT]      := "GR+/G"    //    "   prompt
lsb0001:W_COLORARRAY[AC_LSB_HILITE]      := "W+/BG"    //    "   prompt selezionato
lsb0001:W_COLORARRAY[AC_LSB_HOTKEY]      := "G+/G"    //    "   hot key
lsb0001:COLORSPEC    := "N/W*"
ATTACH REFRESH GROUP "docvend" TO lsb0001:W_R_GROUP
lsb0001:W_MOUSEMETHOD:= W_MM_EDIT + W_MM_HSCROLLBAR + W_MM_VSCROLLBAR


ATTACH INH TO lsb0001:W_INHARRAY                   ; // Id
           INHFIELD "numdoc"                       ; // Nome campo ereditato
           INHBLOCK {||docven->numdoc }              // Espressione per ereditare

ADDKEY "anr" TO lsb0001:W_KEYBOARDMETHODS          ; // Tasto su List Box
       BLOCK   {||docvend->(docFrmAnr(lsb0001,{||docEdbExe(DE_STATE_ADD,,,,,,aInhSon)} ))}  ; // Funzione sul tasto
       WHEN    {|s| (s $ "i") }                    ; // Condizione di stato di attivazione
       RUNTIME {||.T.}                             ; // Condizione di runtime
       MESSAGE "Inserimento"                         // Messaggio utente associato
ADDKEY "mcr" TO lsb0001:W_KEYBOARDMETHODS          ; // Tasto su List Box
       BLOCK   {||docvend->(docFrmMcr(lsb0001,{||docEdbExe(DE_STATE_MOD)} ))}  ; // Funzione sul tasto
       WHEN    {|s| (s $ "i") }                    ; // Condizione di stato di attivazione
       RUNTIME {||.T.}                             ; // Condizione di runtime
       MESSAGE "Modifica"                            // Messaggio utente associato
ADDKEY "ecr" TO lsb0001:W_KEYBOARDMETHODS          ; // Tasto su List Box
       BLOCK   {||docvend->(docFrmEcr(lsb0001,{||docEdbDel()} ))}  ; // Funzione sul tasto
       WHEN    {|s| (s $ "i") }                    ; // Condizione di stato di attivazione
       RUNTIME {||.T.}                             ; // Condizione di runtime
       MESSAGE "Cancella"                            // Messaggio utente associato
ATTACH COLUMN "codart" TO lsb0001                  ; // ATTCOL.TMP
                       BLOCK     {|| docvend->codart }  ;
                       PICTURE "!!!!!!"            ; // Picture visualizzazione dato
                       PROMPT "Cod."               ; // Etichetta
                       WIDTH     6                 ; // Larghezza colonna
                       COLOR  {"B+/W*","BG/W*","W+/BG"}  ; // Array dei colori
                       MESSAGE ""                    // Messaggio
ATTACH COLUMN "dexart" TO lsb0001                  ; // ATTCOL.TMP
                       BLOCK    {|| articol->(dfS(1 ,docvend->codart))  ,;
                                articol->dexart }  ;
                       PICTURE "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  ; // Picture visualizzazione dato
                       PROMPT "Descr. articolo"    ; // Etichetta
                       WIDTH    33                 ; // Larghezza colonna
                       COLOR  {"B+/W*","BG/W*","W+/BG"}  ; // Array dei colori
                       MESSAGE ""                    // Messaggio
ATTACH COLUMN "qtamov" TO lsb0001                  ; // ATTCOL.TMP
                       BLOCK     {|| docvend->qtamov }  ;
                       PICTURE "@ZE 999,999.99"    ; // Picture visualizzazione dato
                       PROMPT "Q.ta"               ; // Etichetta
                       WIDTH    10                 ; // Larghezza colonna
                       COLOR  {"B+/W*","BG/W*","W+/BG"}  ; // Array dei colori
                       MESSAGE ""                    // Messaggio
ATTACH COLUMN "valuni" TO lsb0001                  ; // ATTCOL.TMP
                       BLOCK     {|| docvend->valuni }  ;
                       PICTURE "@ZE 99,999.99"     ; // Picture visualizzazione dato
                       PROMPT "Val. unit."         ; // Etichetta
                       WIDTH    10                 ; // Larghezza colonna
                       LABEL     "Totale"          ; // Etichetta
                       COLOR  {"B+/W*","BG/W*","W+/BG"}  ; // Array dei colori
                       MESSAGE ""                    // Messaggio
ATTACH COLUMN "totrig" TO lsb0001                  ; // ATTCOL.TMP
                       BLOCK     {|| docvend->totrig }  ;
                       PICTURE "@ZE 9,999,999.99"  ; // Picture visualizzazione dato
                       PROMPT "Tot. riga"          ; // Etichetta
                       WIDTH    12                 ; // Larghezza colonna
                       TOTAL     docvend->totrig  ; //
                       FPICTURE "@ZE 9,999,999.99"  ; // Picture Footer
                       COLOR  {"B+/W*","BG/W*","W+/BG"}  ; // Array dei colori
                       MESSAGE ""                    // Messaggio
ATTACH "lsb0001" TO oWin:W_CONTROL GET AS LISTBOX USING lsb0001  ; // ATTLSB.tmp
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                ACTIVE   {||cState $ "i" }           // Stato di attivazione
ATTACH "but0002" TO oWin:W_CONTROL GET AS PUSHBUTTON ""  ; // ATTBUT.TMP
                 AT   22,   0,  22,  24            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||tbTop(oWin)}          ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 BITMAP    BUT_BMP_YES             ; // Bitmap (XBASE)
                 BITMAPID  1100                    ; // Bitmap ID (XBASE)
                 MESSAGE "Muove al primo record"     // Messaggio utente
ATTACH "but0003" TO oWin:W_CONTROL GET AS PUSHBUTTON ""  ; // ATTBUT.TMP
                 AT   22,  32,  22,  16            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||tbUp(oWin)}           ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 BITMAP    BUT_BMP_YES             ; // Bitmap (XBASE)
                 BITMAPID  1102                    ; // Bitmap ID (XBASE)
                 MESSAGE "Muove al record precedente"    // Messaggio utente
ATTACH "but0004" TO oWin:W_CONTROL GET AS PUSHBUTTON ""  ; // ATTBUT.TMP
                 AT   22,  56,  22,  16            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||tbDown(oWin)}         ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 BITMAP    BUT_BMP_YES             ; // Bitmap (XBASE)
                 BITMAPID  1103                    ; // Bitmap ID (XBASE)
                 MESSAGE "Muove al record successivo"    // Messaggio utente
ATTACH "but0005" TO oWin:W_CONTROL GET AS PUSHBUTTON ""  ; // ATTBUT.TMP
                 AT   22,  80,  22,  24            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||tbBottom(oWin)}       ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 BITMAP    BUT_BMP_YES             ; // Bitmap (XBASE)
                 BITMAPID  1101                    ; // Bitmap ID (XBASE)
                 MESSAGE "Muove all'ultimo record"    // Messaggio utente
ATTACH "but0006" TO oWin:W_CONTROL GET AS PUSHBUTTON "~Ins."  ; // ATTBUT.TMP
                 AT   22, 128,  22,  40            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||docFrmGet(DE_STATE_ADD)}  ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 MESSAGE "Inserimento nuovo record"    // Messaggio utente
ATTACH "but0007" TO oWin:W_CONTROL GET AS PUSHBUTTON "~Mod."  ; // ATTBUT.TMP
                 AT   22, 176,  22,  40            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||docFrmGet(DE_STATE_MOD)}  ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 MESSAGE "Modifica record corrente"    // Messaggio utente
ATTACH "but0008" TO oWin:W_CONTROL GET AS PUSHBUTTON "C~anc."  ; // ATTBUT.TMP
                 AT   22, 224,  22,  48            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||docFrmDel(.T.)}       ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 MESSAGE "Cancellazione record corrente"    // Messaggio utente
ATTACH "but0009" TO oWin:W_CONTROL GET AS PUSHBUTTON "~Ric."  ; // ATTBUT.TMP
                 AT   22, 280,  22,  40            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||docven->(ddKey())}    ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 MESSAGE "Ricerca record su chiavi"    // Messaggio utente
ATTACH "but0016" TO oWin:W_CONTROL GET AS PUSHBUTTON "~Stampa"  ; // ATTBUT.TMP
                 AT   22, 368,  22,  56            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||docPr2Exe(PRINT_CURRENT, NIL, NIL, NIL, .F.)}  ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 MESSAGE ""                          // Messaggio utente
ATTACH "but0010" TO oWin:W_CONTROL GET AS PUSHBUTTON "O~k"  ; // ATTBUT.TMP
                 AT   22, 480,  22,  24            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||dbAct2Kbd("wri")}     ; // Funzione di controllo
                 ACTIVE   {||cState $ "am"}        ; // Stato di attivazione
                 MESSAGE "Registra e chiude"         // Messaggio utente
ATTACH "but0011" TO oWin:W_CONTROL GET AS PUSHBUTTON "A~bbandona"  ; // ATTBUT.TMP
                 AT   22, 512,  22,  80            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||dbAct2Kbd("esc")}     ; // Funzione di controllo
                 ACTIVE   {||cState $ "iam"}       ; // Stato di attivazione
                 MESSAGE "Abbandona"                 // Messaggio utente
ATTACH "numdoc" TO oWin:W_CONTROL GET numdoc AT  440, 120  ; // ATTGET.TMP
                 SIZE       {  64,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // GET ALIGNMENT
                 COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT   "Num. doc."              ; // Prompt
                 PROMPTAT  440 ,  40               ; // Coordinate prompt
                 PICTURESAY "@ZE 999,999"          ; // Picture in say
                 CONDITION {|ab|numdoc(ab)}        ; // Funzione When/Valid
                 MESSAGE "Numero documento"        ; // Messaggio
                 VARNAME "numdoc"                  ; //
                 REFRESHID "docven"                ; // Appartiene ai gruppi di refresh
                 ACTIVE {||cState $ "am" }          // Stato di attivazione
ATTACH "datdoc" TO oWin:W_CONTROL GET datdoc AT  418, 120  ; // ATTGET.TMP
                 SIZE       {  72,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // GET ALIGNMENT
                 COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT   "Data doc."              ; // Prompt
                 PROMPTAT  418 ,  40               ; // Coordinate prompt
                 PICTURESAY "99/99/99"             ; // Picture in say
                 CONDITION {|ab|datdoc(ab)}        ; // Funzione When/Valid
                 MESSAGE "Data documento"          ; // Messaggio
                 VARNAME "datdoc"                  ; //
                 REFRESHID "docven"                ; // Appartiene ai gruppi di refresh
                 ACTIVE {||cState $ "am" }          // Stato di attivazione
ATTACH "codcli" TO oWin:W_CONTROL GET codcli AT  396, 120  ; // ATTGET.TMP
                 SIZE       {  72,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // GET ALIGNMENT
                 COLOR  {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT   "Codice cliente"         ; // Prompt
                 PROMPTAT  396 ,   0               ; // Coordinate prompt
                 PICTURESAY "!!!!!!"               ; // Picture in say
                 CONDITION {|ab|codcli(ab)}        ; // Funzione When/Valid
                 MESSAGE "Codice cliente"          ; // Messaggio
                 VARNAME "codcli"                  ; //
                 REFRESHID "docven"                ; // Appartiene ai gruppi di refresh
                 COMBO                             ; // Icona combo
                 ACTIVE {||cState $ "am" }          // Stato di attivazione


M_Normal()                                           // Stato mouse normale

* #COD OAACT0 * #END //  Inizializzazione oggetto oWin

RETURN oWin

*******************************************************************************
FUNCTION docFrmUpw(        ;                         // [ 04 ]  UPDATE WINDOW  Aggiornamento oggetto
                    cDisGrp )                        //  Id. gruppo di visualizzazione
                                                     //  "#" = aggiorna tutti i control
*******************************************************************************
* #COD OBUPW0 * #END //  Update window oggetto oWin

tbDisItm( oWin ,cDisGrp )                            //  funzione di aggiornamento control (vedere Norton Guide)

* #COD OAUPW0 * #END //  Update window oggetto oWin

RETURN NIL

*******************************************************************************
FUNCTION docFrmInk()                                 // [ 05 ] INTERAZIONE CON L'UTENTE
*******************************************************************************
LOCAL cCho

* #COD OBINK0 * #END //  Interazione con l'utente o inkey di tastiera

IF cState!=DE_STATE_INK
   RETURN docFrmGet(cState)
ENDIF

WHILE( !lBreak )

   docFrmGet(cState)                                 //  Visualizza i dati

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
FUNCTION docFrmBrk()                                 // [ 06 ] COMANDA UN BREAK SULL'OGGETTO
*******************************************************************************
* #COD OBBRK0 * #END //  Comanda un break sull'oggetto
lBreak := .T.
* #COD OABRK0 * #END //  Comanda un break sull'oggetto
RETURN NIL

*******************************************************************************
FUNCTION docFrmEnd(         ;                        // [ 07 ] OPERAZIONI DI CHIUSURA
                     cClose  ;                       // Modalita' chiusura oggetto:
                             ;                       // W_OC_RESTORE =  Restore dello screen
                             )                       // W_OC_DESTROY =  Rilascio dell'oggetto
*******************************************************************************
* #COD OBEND0 * #END //  Chiusura e rilascio oggetto oWin

oWin:=tbEnd( oWin , cClose )                         // ( vedere Norton Guide )

* #COD OAEND0 * #END //  Chiusura e rilascio oggetto oWin

RETURN NIL

*******************************************************************************
FUNCTION docFrmGet(           ;                      // [ 08 ]  METODO PER L'INPUT DEI DATI
                    nGetState  ;                     //  Operazione richiesta:
                               ;                     //  DE_STATE_INK =  Consultazione
                               ;                     //  DE_STATE_ADD =  Inserimento
                               )                     //  DE_STATE_MOD =  Modifica
*******************************************************************************
LOCAL  lRet    := .F.                                //  Flag di registrazione dati se .T.
LOCAL  a121Fld := {}                                 //  Array per controllo somma contenuto campi 1:1

* #COD OBGET0 * #END //  Data-entry o ciclo di get


cState := nGetState                                  //  Riassegna statica stato data entry


nRec := docven->(Recno())                            //  Memorizza il record corrente

IF     cState==DE_STATE_ADD
   docven->(dbGoBottom()) ;docven->(dbSkip(1))
ELSEIF cState==DE_STATE_MOD
   IF docven->(EOF()) ;cState:=DE_STATE_INK ;END
ENDIF

* #COD OIGETA * #END Prima della valorizzazione delle variabili

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ VALORIZZAZIONE VARIABILI DI DATA ENTRY  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

numdoc     := docven->numdoc                        // Num. doc.
datdoc     := iif(cState==DE_STATE_ADD ,DATE() ,docven->datdoc)   // Data doc.
codcli     := docven->codcli                        // Codice cliente
* #COD OIGET2 * #END Dopo la valorizzazione delle variabili

IF cState==DE_STATE_ADD
              /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                ³ VALORIZZA I CAMPI EREDITATI DA RELAZIONI 1:N        ³
                ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
   tbInh( oWin ,aInh ,INH_DEF )

ENDIF
* #COD OIGET3 * #END Dopo la valorizzazione dei campi ereditati per 1:1 ed 1:N

docFrmUpw( "#" )                                     //  Visualizza i dati da MEMORIA

IF cState==DE_STATE_INK ;RETU .T. ;END               //  Uscita in stato consultazione dati
IF cState==DE_STATE_ADD ;tbGetTop(oWin) ;END
IF cState==DE_STATE_MOD ;tbGetTop(oWin,.T.) ;END
* #COD OIGET4 * #END Prima della chiamata al modulo gestore delle get " tBget() "

WHILE( .T. )

   IF ! tbGet( oWin ,{||docFrmDcc() } ,cState )      //  Modulo gestore delle get
      * #COD OIGET5 * #END Rinuncia registrazione dati prima di uscire da DO WHILE get
      EXIT
   END

   * #COD OIGET6 * #END Prima della scrittura campi su disco alla conferma dati

   IF cState==DE_STATE_ADD

      * #COD OIGETB * #END Prima calcolo chiavi primarie / univoche

      docven->(dfPkNew( {|x|if(x==NIL,numdoc,numdoc:=x)},  1 ,"numdoc" ,oWin:W_PRIMARYKEY ,1) )

      docven->(dbAppend())
      * #COD OIGETC * #END Dopo calcolo chiavi primarie / univoche

      nRec := docven->(Recno())                      //  Memorizza il nuovo record

      tbInh( oWin ,aInh ,INH_WRI )                   //  Scrive su disco i campi ereditati ( vedere Norton Guide )

   END

   * #COD OIGETD * #END Dopo la scrittura campi ereditati


     /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       ³             REPLACE DEI CAMPI              ³
       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
   docven->(dbGoto(nRec))                            //  Riposiziona prima di scrivere

   docven->numdoc     := numdoc                     // Num. doc.
   docven->datdoc     := datdoc                     // Data doc.
   docven->codcli     := codcli                     // Codice cliente

   * #COD OIGET7 * #END Dopo la scrittura campi su disco alla conferma dati

   docven->(dbCommit())                              //  Aggiorna il record su disco

   * #COD OIGET8 * #END Dopo la scrittura campi da relazioni 1:1

   * #COD OIGET9 * #END Dopo la scrittura transazioni e sblocco semaforo di rete
   lRet := .T.
   EXIT                                              //  Uscita dopo aggiornamento dati

ENDDO
docven->(dbGoto(nRec))                               //  Riposiziona il record


cState := DE_STATE_INK                               //  Imposta stato di consultazione

* #COD OAGET0 * #END //  Data-entry o ciclo di get

RETURN lRet

*******************************************************************************
FUNCTION docFrmDcc()                                 // [ 09 ]  CONTROLLI CONGRUENZA DATI
*******************************************************************************
LOCAL  lRet := .T.

* #COD OBDCC0 * #END //  Controlli di congruenza dati

* #COD OADCC0 * #END //  Controlli di congruenza dati

RETURN lRet

*******************************************************************************
FUNCTION docFrmDel(       ;                          // [ 10 ] CANCELLAZIONE RECORD
                    lAsk   )                         //  .T. chiede conferma prima della cancellazione
*******************************************************************************
* #COD OBDEL0 * #END //  Cancellazione record corrente

DEFAULT lAsk    TO .F.
DEFAULT oWin    TO docFrmAct()

IF lAsk
   IF !dfYesNo( dfStdMsg(MSG_DE_DEL) ,.F.) ;RETURN .F. ;END
ENDIF

* #COD OIDEL1 * #END Prima della cancellazione record corrente

IF docvenDid()                                       // Delete integrity Data (dbRid.prg)
                                                     // Funzione di cancellazione su file
   TbEtr( oWin )                                     // Stabilizza la TBrowse corrente
ENDIF

* #COD OADEL0 * #END //  Cancellazione record corrente
RETURN .T.

*******************************************************************************
FUNCTION docFrmAnr( oLsb ,bBlk )                     // [ 14 ] INSERIMENTO RIGA LIST BOX
*******************************************************************************
LOCAL lRet:=.F.                                      // Flag avvenuto inserimento

* #COD OBANR0 * #END //  Chiamata ad oggetto edit riga per inserimento riga List Box
DEFAULT bBlk TO {||.F.}


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
FUNCTION docFrmMcr( oLsb ,bBlk )                     // [ 15 ] MODIFICA    RIGA LIST BOX
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
FUNCTION docFrmEcr( oLsb ,bBlk )                     // [ 16 ] ELIMINA LA RIGA LIST BOX
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
STATIC FUNCTION numdoc( nPrePost ) // numdoc    , N,   6,   0
*******************************************************************************
LOCAL aDbL ,lRet:=.T.
* #COD IIGSF10012 * #END
DO CASE
   CASE nPrePost == FORM_PREGET

        * #COD IIEDTB0012 * #END
        IF cState==DE_STATE_MOD
           RETURN .F.
        ENDIF
        /*  CHIAVE AUTOMATICA PROGRESSIVA */
        docven->(dfPkNew( {|x|if(x==NIL,numdoc,numdoc:=x)},  1 ,"numdoc" ,oWin:W_PRIMARYKEY ,1) )
        docFrmUpw( "-numdoc-" )

        RETURN .F.

        * #COD IIEDTA0012 * #END

   CASE nPrePost == FORM_POSTGET .OR. nPrePost == FORM_CHKGET

        * #COD IICHKB0012 * #END
        IF !docven->(ddPkChk(  1 ,tbPkExp(oWin), NIL, cState ))
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
STATIC FUNCTION datdoc( nPrePost ) // datdoc    , D,   8,   0
*******************************************************************************
LOCAL aDbL ,lRet:=.T.
* #COD IIGSF10013 * #END
DO CASE
   CASE nPrePost == FORM_PREGET

        * #COD IIEDTB0013 * #END

        * #COD IIEDTA0013 * #END

   CASE nPrePost == FORM_POSTGET .OR. nPrePost == FORM_CHKGET

        * #COD IICHKB0013 * #END
        //  CAMPO OBBLIGATORIO
        IF (lRet) .AND. EMPTY(datdoc)
           dbMsgErr("Data doc.//"+dfStdMsg(MSG_VALID01))
           lRet := .F.
        ENDIF


        * #COD IICHKA0013 * #END

        IF nPrePost == FORM_POSTGET
           * #COD IIGSF50013 * #END
        ENDIF

ENDCASE
* #COD IIGSF90013 * #END

RETURN lRet
*******************************************************************************
STATIC FUNCTION codcli( nPrePost ) // codcli    , C,   6,   0
*******************************************************************************
LOCAL aDbL ,lRet:=.T.
* #COD IIGSF10014 * #END
DO CASE
   CASE nPrePost == FORM_PREGET

        * #COD IIEDTB0014 * #END

        * #COD IIEDTA0014 * #END

   CASE nPrePost == FORM_POSTGET .OR. nPrePost == FORM_CHKGET

        * #COD IICHKB0014 * #END
        aDbl           := ARRAY(LK_ARRAYLEN)
        aDbl[LK_ORDER] := 1                          //  Order (numerico)
        aDbl[LK_SEEK]  := codcli                     //  Chiave di ricerca
        aDbl[LK_VAL]   := {}                         //  Dati da ereditare nel file figlio
        AADD( aDbl[LK_VAL] , { "codcli" ,{||codcli } })
        aDbl[LK_FIELD] := "codcli"                   //  Nome campo relazionato
        aDbl[LK_WIN]   := NIL                        //  Nome finestra
        aDbl[LK_KEY]   := NIL                        //  Chiave finestra
        aDbl[LK_FILTER]:= {||.T.}                    //  Filtro finestra
        aDbl[LK_BREAK] := {||.F.}                    //  Break finestra
        aDbl[LK_TYPE]  := LT_MANDATORY               //  Modalita' Look-Up
        aDbl[LK_EDIT]  := NIL                        //  Nome quadro edit
        aDbl[LK_INS]   := {||.T.}                    //  Abilita edit se...
        aDbl[LK_KBD]   := .T.                        //  Keyboard
        * #COD IIGSF40014 * #END

        IF ! clienti->(dbLooK( aDbl ))
           lRet := .F.
        ELSE
           IF nPrePost == FORM_POSTGET
              codcli     := clienti->codcli
              tbDisRef( oWin ,"codcli" )
           END
        ENDIF


        * #COD IICHKA0014 * #END

        IF nPrePost == FORM_POSTGET
           * #COD IIGSF50014 * #END
        ENDIF

ENDCASE
* #COD IIGSF90014 * #END

RETURN lRet


* #COD OIBOT1 * #END Fine file sorgente per oggetto form

