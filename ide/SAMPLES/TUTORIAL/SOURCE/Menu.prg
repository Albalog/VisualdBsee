/******************************************************************************
 Progetto       : Tutorial
 Sottoprogetto  : Tutorial
 Programma      : V:\SAMPLES\TUTORIAL\source\Menu.prg
 Template       : V:\bin\..\tmp\xbase\form.tmp
 Descrizione    : Menu applicazione
 Programmatore  : Demo
 Data           : 13-07-06
 Ora            : 16.43.55
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
FUNCTION MenuExe(                                  ; // [ 01 ]  ESECUTORE OPERAZIONI
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

PRIVATE  EnvId:="Menu" ,SubId:=""                    // Identificativi per help
dfSetMain( "Menu" )
IF dfSetMain() == "Menu"
   dfSet( "XbaseApplication", "Visual dBsee - 1.5.1")
   dfSet( "XbaseS2StaticCreateWorkAround", "NO")
   dfSet( AI_XBASEDDKEYMODE, AI_DDKEYMODE_ENH)
   dfInitFont()
   dfSet( AI_XBASETOOLBAROPTIONS, {{AI_TOOLBAR_HEIGHT, 26}})
   dfSet( AI_XBASEPRNMENUNEW, .T. )
   dfSetEuro( .T. )
   dfHlpSetCB({ NIL, ;
                {|cForm,cID| UPPER(ALLTRIM(cForm))+".HTM"}, ;
                dbCfgPath("HelpPath")+"Menu.chm" })
   SET EPOCH TO 1920
   SET DATE ITALIAN                                  // Predispone formato presentazione date
   dfInitScreenOn()
   IF dfChkPar("/UPD")                               // Attivazione dell'aggiornamento archivi
      ddUpdDbf()
   ENDIF
   ddIndex( IDX_CHECK )                              // Ricostruzione indici e creazione archivi
   dfInitScreenOff()
   IF !(cMode$DE_STATE_INK +DE_STATE_ADD +DE_STATE_MOD)
      cMode := DE_STATE_INK
   ENDIF
   dfSet( AI_XBASEREPORTMANTMPFILE, AI_REPORTMANAGER_TEMPFILE_XML)
   dfSet( "XbaseGetComboExternal", "YES")
ENDIF

nWin++
IF nWin==1

   aInh   := arrInh                                  // Riassegna array campi ereditati
   cState := cMode                                   // Riassegna lo stato sulla modalit… operativa

   * #COD OIEXE5 * #END Dopo i settaggi dell'oggetto


   IF MenuDbf()                                      // Apre la base dati

      MenuAct()                                      // Attivazione oggetto


      tbConfig( oWin )                               // Riconfigura i parametri interni dell'oggetto ( vedere Norton Guide )
      * #COD OIEXE7 Dopo caricamento e setup oggetto, prima del display oggetto
      dfAlert("Questo Progetto Š stato creato con Visual dBsee//"+;
              "seguendo esattamente i passi elencati nella documentazione Tutorial.chm//"+;
              "che Š accessibile dal menu Visual dBsee nella sezione '?' -> 'Esercitazione'////"+;
              "Attenzione: per visualizzare le stampe Crystal Š necessario avere installato Crystal Reports 10")
      * #END
      MenuInk() ;MenuEnd(cClose) ;lRet := .T.

   END
   dfClose( aFile, .T., .F. )                        // Chiusura base dati ( vedere Norton Guide )

ENDIF
nWin--

* #COD OAEXE0 * #END //  Esegue le operazioni di base per attivazione oggetto FORM

RETURN lRet

*******************************************************************************
FUNCTION MenuDbf()                                   // [ 02 ] APERTURA DATABASE
*******************************************************************************
* #COD OBDBF0 * #END //  Apertura della base dati




* #COD OADBF0 * #END //  Apertura della base dati

RETURN .T.

*******************************************************************************
FUNCTION MenuAct()                                   // [ 03 ] INIZIALIZZA OGGETTO
*******************************************************************************
LOCAL aPfkItm

* #COD OBACT0 * #END //  Inizializzazione oggetto oWin

lBreak := .F.                                        // Condizione di break su oggetto posta a FALSE

IF oWin!=NIL ;RETURN oWin ;END                       // Si ritorna l'oggetto se gi… inizializzato

M_Cless()                                            // Stato di attesa con mouse a clessidra

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Inizializza oggetto ( vedere Norton Guide ) ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

oWin := 0->(TbBrwNew(  410                        ,; // Prima  Riga
                        16                        ,; // Prima  Colonna
                       502                        ,; // Ultima Riga
                       654                        ,; // Ultima Colonna
                      W_OBJ_FRM                             ,; // Tipo oggetto ( form )
                      NIL ,; // Label
                      W_COORDINATE_PIXEL                    )) // Gestione in Pixel

oWin:W_TITLE     := "Menu applicazione"              // Titolo oggetto
oWin:W_KEY       := NIL                              // Non esegue la seek
oWin:W_FILTER    := {||.T.}                          // CodeBlock per il filtro
oWin:W_BREAK     := {||.F.}                          // CodeBlock per il break
oWin:W_PAGELABELS:= {}                               // Array delle pagine
oWin:W_PAGERESIZE:= {}
ATTACH PAGE LABEL "Pagina n.1" TO oWin:W_PAGELABELS
oWin:W_MENUHIDDEN:= .F.                              // Stato attivazione barra azioni
oWin:W_COLORARRAY[AC_FRM_BACK  ] := "[99-222-255]/[173-222-255]"    // Colore di FONDO
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
        PROMPT   "^Gestione"                       ; // Etichetta
        EXECUTE  {||dbMsgErr( dfStdMsg( MSG_ADDMENUUND ) )}  ; // Funzione
        MESSAGE  "Elenco delle procedure per la gestione del data-entry."  ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0004000001"
ATTACH "11" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "C^lienti"                        ; // Etichetta
        EXECUTE  {||CliFrmExe(DE_STATE_INK)}  ; // Funzione
        MESSAGE  ""                                ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0004000021"
ATTACH "12" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "A^rticoli"                       ; // Etichetta
        EXECUTE  {||ArtFrmExe()}                   ; // Funzione
        MESSAGE  ""                                ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0004000038"
ATTACH "13" TO MENU oWin:W_MENUARRAY AS MN_LINE    ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"") ,MN_SECRET ,MN_HIDDEN )}  ; // Condizione di stato di attivazione
        EXECUTE  {||dbMsgErr( dfStdMsg( MSG_ADDMENUUND ) )}  ; // Funzione
        MESSAGE  ""                                ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0004000081"
ATTACH "14" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Gestione Bolle"                 ; // Etichetta
        SHORTCUT "-gg"                             ; // Shortcut
        EXECUTE  {||BolFrmExe(DE_STATE_INK)}  ; // Funzione
        MESSAGE  ""                                ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0004000082"
ATTACH "2" TO MENU oWin:W_MENUARRAY AS MN_LABEL    ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"iam") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Stampe"                         ; // Etichetta
        EXECUTE  {||dbMsgErr( dfStdMsg( MSG_ADDMENUUND ) )}  ; // Funzione
        MESSAGE  "Elenco delle procedure per la gestione delle stampe."  ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0004000002"
ATTACH "21" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "Stampa ^tabelle"                 ; // Etichetta
        EXECUTE  {||dfTabPrint()}                  ; // Funzione
        MESSAGE  "Stampa delle tabelle del progetto"  ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0004000003"
ATTACH "22" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "Scheda Clienti"                  ; // Etichetta
        EXECUTE  {||CliRptExe()}                   ; // Funzione
        MESSAGE  ""                                ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0004000079"
ATTACH "23" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "Report Clienti"                  ; // Etichetta
        EXECUTE  {||CliRpt1Exe()}                  ; // Funzione
        MESSAGE  ""                                ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0004000080"
ATTACH "24" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "Stampa Testata Dettaglio Bolle (Report Manager)"  ; // Etichetta
        EXECUTE  {||BolRptExe()}                   ; // Funzione
        MESSAGE  ""                                ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0004000083"
ATTACH "25" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "Stampa Testata / Dettaglio bolle (Crystal)"  ; // Etichetta
        EXECUTE  {||T_BRptExe()}                   ; // Funzione
        MESSAGE  ""                                ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0004000084"
ATTACH "3" TO MENU oWin:W_MENUARRAY AS MN_LABEL    ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"iam") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "Se^rvizio"                       ; // Etichetta
        EXECUTE  {||dbMsgErr( dfStdMsg( MSG_ADDMENUUND ) )}  ; // Funzione
        MESSAGE  "Operazioni di manutenzione generale del sistema."  ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0004000005"
ATTACH "31" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Ricostruzione indici"           ; // Etichetta
        EXECUTE  {||ddIndex()}                     ; // Funzione
        MESSAGE  "Ricostruzione periodica indici."  ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0004000006"
ATTACH "32" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "Gestione ^tabelle"               ; // Etichetta
        EXECUTE  {||dfTabDe()}                     ; // Funzione
        MESSAGE  "Gestione archivio tabelle. Inserimento, modifica, cancellazione."  ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0004000007"
ATTACH "4" TO MENU oWin:W_MENUARRAY AS MN_LABEL    ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"iam") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^?"                              ; // Etichetta
        EXECUTE  {||dbMsgErr( dfStdMsg( MSG_ADDMENUUND ) )}  ; // Funzione
        MESSAGE  "Informazioni sul programma"      ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0004000010"
ATTACH "41" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Help"                           ; // Etichetta
        EXECUTE  {||dfHlp()}                       ; // Funzione
        MESSAGE  "Help di programma"               ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0004000011"
ATTACH "42" TO MENU oWin:W_MENUARRAY AS MN_LABEL   ; // ACTMNU.TMP
        BLOCK    {|CHILD,LABEL,ID|if( (cState$"i") ,MN_ON ,MN_OFF )}  ; // Condizione di stato di attivazione
        PROMPT   "^Informazioni"                   ; // Etichetta
        EXECUTE  {||AboutExe()}                    ; // Funzione
        MESSAGE  "Informazioni"                    ; // Messaggio utente
        IMAGES  0                                  ; //
        ID "0004000012"
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
        EXECUTE {||dbAct2Kbd("wri")}               ; //
        WHEN    {|| (cState $ "am") }              ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Conferma i dati (F10)"           ; //
        TOOLTIP "Conferma i dati (F10)"  ; //
        IMAGES  TOOLBAR_WRITE_H                    ; //
        ID "0004000085"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("esc")}               ; //
        WHEN    {|| (cState $ "iam") }             ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Fine operazioni (Esc)"           ; //
        TOOLTIP "Fine operazioni (Esc)"  ; //
        IMAGES  TOOLBAR_ESC_H                      ; //
        ID "0004000086"
ATTACH TOOLSEPARATOR TO oWin                         // ACTTBR.TMP
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("hlp")}               ; //
        WHEN    {|| (cState $ "iam") }             ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Aiuto (F1)"                      ; //
        TOOLTIP "Aiuto (F1)"                       ; //
        IMAGES  TOOLBAR_HELP_H                     ; //
        ID "0004000088"
ATTACH TOOLITEM TO oWin                            ; // ACTTBR.TMP
        EXECUTE {||dbAct2Kbd("ush")}               ; //
        WHEN    {|| (cState $ "iam") }             ; //
        RUNTIME {|cCHILD,cLABEL,cID|.T.}           ; //
        PROMPT   "Aiuto (Shift-F1)"                ; //
        TOOLTIP "Aiuto (Shift-F1)"                 ; //
        IMAGES  TOOLBAR_KEYHELP_H                  ; //
        ID "0004000089"
* #COD OIACT2 * #END Dopo dichiarazione ATTACH del menu per oggetto oWin

* #COD OIACT3 * #END Dopo inizializzazione array  con campi chiave primaria

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Control                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
ATTACH "box0003" TO oWin:W_CONTROL BOX 01          ; // ATTBOX.TMP
                 AT   40, 190, 110, 250            ; // Coordinate
                 BOXTEXT ""                        ; // BOX Text
                 COORDINATE  W_COORDINATE_PIXEL    ; // Tipo Coordinate
                 BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                 COLOR {"W+/G","B+/G","N/G"}         // Array dei colori
ATTACH "box0004" TO oWin:W_CONTROL BOX 01          ; // ATTBOX.TMP
                 AT  160, 190, 260, 250            ; // Coordinate
                 BOXTEXT ""                        ; // BOX Text
                 COORDINATE  W_COORDINATE_PIXEL    ; // Tipo Coordinate
                 BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                 COLOR {"W+/G","B+/G","N/G"}         // Array dei colori
ATTACH "say0001" TO oWin:W_CONTROL SAY "Tutorial" AT   50, 200  ; // ATTSAY.TMP
                 SIZE       { 230,  80}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_DEFAULT        ; // SAY ALIGNMENT
                 FONT      "40.Verdana"            ; // Font Name (XBASE)
                 SHADOWDEPTH 7                     ; // Shadow Depth (XBASE)
                 COLOR    {DFXPPCLRSELECT("5/3","W+/B*")}    // Array dei colori
ATTACH "img0002" TO oWin:W_CONTROL FUNCTION "VDBSEELOGO.BMP" AT  170, 200, 230, 230  ; // ATTEXP.TMP
                 COORDINATE  W_COORDINATE_PIXEL  ; // Coordinate in Pixel
                 COLOR     {NIL,NIL,"N/N",NIL,NIL}  ; // Array dei colori
                 BITMAPOPTION FUN_BMP_STRETCH + FUN_BMP_CENTER   // Bitmap (XBASE)


M_Normal()                                           // Stato mouse normale

* #COD OAACT0 * #END //  Inizializzazione oggetto oWin

RETURN oWin

*******************************************************************************
FUNCTION MenuUpw(        ;                           // [ 04 ]  UPDATE WINDOW  Aggiornamento oggetto
                    cDisGrp )                        //  Id. gruppo di visualizzazione
                                                     //  "#" = aggiorna tutti i control
*******************************************************************************
* #COD OBUPW0 * #END //  Update window oggetto oWin

tbDisItm( oWin ,cDisGrp )                            //  funzione di aggiornamento control (vedere Norton Guide)

* #COD OAUPW0 * #END //  Update window oggetto oWin

RETURN NIL

*******************************************************************************
FUNCTION MenuInk()                                   // [ 05 ] INTERAZIONE CON L'UTENTE
*******************************************************************************
LOCAL cCho

* #COD OBINK0 * #END //  Interazione con l'utente o inkey di tastiera


WHILE( !lBreak )

   MenuUpw()                                         //  Visualizza i dati

   cCho := tbink( oWin )                             //  Inkey di tastiera ( vedere Norton Guide )
   * #COD OIINK1 * #END Dopo inkey di tastiera " cCho:=tbInk( oWin ) "

   IF dfSetMain() == "Menu"
      IF M->Act=="esc" ;QuitExe() ;LOOP ;END         //  Form chiusura programma
   ENDIF

   IF !Empty(cCho)                                   //  Esegue azione sul menu
      EVAL( dfMenuBlock(oWin:W_MENUARRAY,cCho) )    //  dfMenuBlock() ritorna il code block associato
   END    //  alla voce di menu (vedere Norton Guide )
   * #COD OIINK2 * #END Dopo esecuzione scelta di menu

ENDDO

* #COD OAINK0 * #END //  Interazione con l'utente o inkey di tastiera

RETURN NIL

*******************************************************************************
FUNCTION MenuBrk()                                   // [ 06 ] COMANDA UN BREAK SULL'OGGETTO
*******************************************************************************
* #COD OBBRK0 * #END //  Comanda un break sull'oggetto
lBreak := .T.
* #COD OABRK0 * #END //  Comanda un break sull'oggetto
RETURN NIL

*******************************************************************************
FUNCTION MenuEnd(         ;                          // [ 07 ] OPERAZIONI DI CHIUSURA
                     cClose  ;                       // Modalita' chiusura oggetto:
                             ;                       // W_OC_RESTORE =  Restore dello screen
                             )                       // W_OC_DESTROY =  Rilascio dell'oggetto
*******************************************************************************
* #COD OBEND0 * #END //  Chiusura e rilascio oggetto oWin

oWin:=tbEnd( oWin , cClose )                         // ( vedere Norton Guide )

* #COD OAEND0 * #END //  Chiusura e rilascio oggetto oWin

RETURN NIL




* #COD OIBOT1 * #END Fine file sorgente per oggetto form

