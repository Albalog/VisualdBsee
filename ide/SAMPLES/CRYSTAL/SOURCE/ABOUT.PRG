/******************************************************************************
 Progetto       : Esempio Crystal Report
 Sottoprogetto  : Esempio Crystal Report
 Programma      : C:\PROGRA~1\VISUAL~1\SAMPLES\CRYSTAL\source\About.prg
 Template       : C:\Programmi\VisualdBsee\bin\..\tmp\xbase\form.tmp
 Descrizione    : Informazioni
 Programmatore  :
 Data           : 12-10-04
 Ora            : 16.03.31
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


STATIC lBreak := .F.                              ,; // Uscita  form
       oWin   := NIL                              ,; // Oggetto form
       aInh   := {}                               ,; // Array con campi ereditati da oggetto
       aInhSon:= NIL                              ,; // Array con campi ereditati da ListBox
       aFile  := {}                               ,; // Array dei file aperti dall' oggetto
       nRec   := 0                                ,; // Record corrente
       cState := DE_STATE_INK                     ,; // Stato della gestione
       cDmmVar:= ""                               ,; // Variabile di utilit� per Radio/Check
       nWin   := 0                                   // Flag per evitare la ricorsione dell'oggetto

* #COD OITOP1 * #END Punto di dichiarazione STATICHE a livello di file sorgente

         /* ��������������������������������������������������������Ŀ
            �           TABELLA METODI DELL'OGGETTO FORM             �
            ��������������������������������������������������������Ĵ
            � n� � mtd.� Descrizione                                 �
            ��������������������������������������������������������Ĵ
            �  1 � exe � Esecutore                                   �
            �  2 � dbf � Apre la base dati                           �
            �  3 � act � Attivazione oggetto                         �
            �  4 � upw � Update window ( aggiornamento oggetto )     �
            �  5 � ink � Inkey su tasti e pulsanti                   �
            �  6 � brk � Break  ( forza l'uscita da inkey )          �
            �  7 � end � Fine operazioni                             �
            ��������������������������������������������������������Ĵ
            �          METODI PRESENTI SOLO SE UTILIZZATI            �
            ��������������������������������������������������������Ĵ
            �  8 � get � Immissione dati                             �
            �  9 � dcc � Validazione generale sui dati immessi       �
            � 10 � del � Eliminazione record                         �
            � 11 � ltt � Log the transaction  (transazione append)   �
            � 12 � ptt � Put the transaction  (transazione replace)  �
            � 13 � rtt � Remove the transaction ( eliminazione t.)   �
            ��������������������������������������������������������Ĵ
            �           METODI GENERATI SOLO IN CASO DI              �
            �    PRESENZA DI CONTROL LISTBOX  OPERANTI SU FILE       �
            ��������������������������������������������������������Ĵ
            � 14 � anr � Add New Row        INS   = inserimento riga �
            � 15 � mcr � Modify Current Row BARRA = modifica    riga �
            � 16 � ecr � Erase Current row  CANC  = elimina     riga �
            ���������������������������������������������������������� */

*******************************************************************************
FUNCTION AboutExe(                                 ; // [ 01 ]  ESECUTORE OPERAZIONI
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

DEFAULT cMode  TO DE_STATE_INK                       // Modalit� operativa completa
DEFAULT cClose TO W_OC_RESTORE                       // Modalit� chiusura  restore
DEFAULT arrInh TO {}                                 // Array dei campi ereditati

PRIVATE  EnvId:="About" ,SubId:=""                   // Identificativi per help


nWin++
IF nWin==1

   aInh   := arrInh                                  // Riassegna array campi ereditati
   cState := cMode                                   // Riassegna lo stato sulla modalit� operativa

   * #COD OIEXE5 * #END Dopo i settaggi dell'oggetto


   IF AboutDbf()                                     // Apre la base dati

      AboutAct()                                     // Attivazione oggetto


      tbConfig( oWin )                               // Riconfigura i parametri interni dell'oggetto ( vedere Norton Guide )
      * #COD OIEXE7 * #END Dopo caricamento e setup oggetto, prima del display oggetto
      AboutInk() ;AboutEnd(cClose) ;lRet := .T.

   END
   dfClose( aFile, .T., .F. )                        // Chiusura base dati ( vedere Norton Guide )

ENDIF
nWin--

* #COD OAEXE0 * #END //  Esegue le operazioni di base per attivazione oggetto FORM

RETURN lRet

*******************************************************************************
FUNCTION AboutDbf()                                  // [ 02 ] APERTURA DATABASE
*******************************************************************************
* #COD OBDBF0 * #END //  Apertura della base dati




* #COD OADBF0 * #END //  Apertura della base dati

RETURN .T.

*******************************************************************************
FUNCTION AboutAct()                                  // [ 03 ] INIZIALIZZA OGGETTO
*******************************************************************************
LOCAL aPfkItm

* #COD OBACT0 * #END //  Inizializzazione oggetto oWin

lBreak := .F.                                        // Condizione di break su oggetto posta a FALSE

IF oWin!=NIL ;RETURN oWin ;END                       // Si ritorna l'oggetto se gi� inizializzato

M_Cless()                                            // Stato di attesa con mouse a clessidra

/*���������������������������������������������Ŀ
  � Inizializza oggetto ( vedere Norton Guide ) �
  �����������������������������������������������*/

oWin := 0->(TbBrwNew(  760                        ,; // Prima  Riga
                       120                        ,; // Prima  Colonna
                       320                        ,; // Ultima Riga
                       392                        ,; // Ultima Colonna
                      W_OBJ_FRM                             ,; // Tipo oggetto ( form )
                      NIL ,; // Label
                      W_COORDINATE_PIXEL                    )) // Gestione in Pixel

oWin:W_TITLE     := "Informazioni"                   // Titolo oggetto
oWin:W_KEY       := NIL                              // Non esegue la seek
oWin:W_FILTER    := {||.T.}                          // CodeBlock per il filtro
oWin:W_BREAK     := {||.F.}                          // CodeBlock per il break
oWin:W_PAGELABELS:= {}                               // Array delle pagine
ATTACH PAGE LABEL "Pagina n�1" TO oWin:W_PAGELABELS
oWin:W_MENUHIDDEN:= .T.                              // Stato attivazione barra azioni
oWin:W_COLORARRAY[AC_FRM_BACK  ] := "B+/G"           // Colore di FONDO
oWin:W_COLORARRAY[AC_FRM_BOX   ] := "B+/G"           // Colore di BOX
oWin:W_COLORARRAY[AC_FRM_HEADER] := "RB+/B*"         // Colore di HEADER ON
oWin:W_COLORARRAY[AC_FRM_OPTION] := "W+/BG"          // Colore di ICONE

#ifdef __XPP__
oWin:lCenter := .T.
oWin:icon := APPLICATION_ICON
#endif
/*�����������������������������Ŀ
  � Control                     �
  �������������������������������*/
oWin:W_MOUSEMETHOD := W_MM_PAGE + W_MM_ESCAPE+ W_MM_MOVE    // Inizializzazione ICONE per mouse
* #COD OIACT1 * #END Dopo inizializzazioni oggetto oWin Browse

/*�����������������������������Ŀ
  � Inizializza menu e azioni   �
  �������������������������������*/
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

* #COD OIACT3 * #END Dopo inizializzazione array  con campi chiave primaria

/*�����������������������������Ŀ
  � Control                     �
  �������������������������������*/
ATTACH "box0005" TO oWin:W_CONTROL BOX 02          ; // ATTBOX.TMP
                 AT   90,  10, 130, 360            ; // Coordinate
                 BOXTEXT "Informazioni"            ; // BOX Text
                 COORDINATE  W_COORDINATE_PIXEL    ; // Tipo Coordinate
                 BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                 FILL  " "                         ; // Carattere di riempimento
                 COLOR {"N/G","B+/RB","W+/G"}        // Array dei colori
ATTACH "say0007" TO oWin:W_CONTROL SAY "by Albalog s.r.l." AT  140, 160  ; // ATTSAY.TMP
                 SIZE       { 200,  24}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_HCENTER        ; // SAY ALIGNMENT
                 COLOR    {"BG/RB"}                  // Array dei colori
ATTACH "say0003" TO oWin:W_CONTROL SAY "Programma sviluppato con Visual dBsee" AT  170, 150  ; // ATTSAY.TMP
                 SIZE       { 210,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 ALIGNMENT XBPALIGN_HCENTER        ; // SAY ALIGNMENT
                 COLOR    {"N/G"}                    // Array dei colori
ATTACH "img0006" TO oWin:W_CONTROL FUNCTION DFINITSCREEN_BITMAP AT  100,  26,  92, 104  ; // ATTEXP.TMP
                 COORDINATE  W_COORDINATE_PIXEL  ; // Coordinate in Pixel
                 COLOR     {NIL,NIL,"N/N",NIL,NIL}  ; // Array dei colori
                 BITMAPOPTION FUN_BMP_SCALE + FUN_BMP_CENTER   // Bitmap (XBASE)
ATTACH "but0009" TO oWin:W_CONTROL GET AS PUSHBUTTON "OK"  ; // ATTBUT.TMP
                 AT   42,  22,  22, 344            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||dbAct2Kbd("esc")}     ; // Funzione di controllo
                 ACTIVE   {||cState $ "i"}         ; // Stato di attivazione
                 MESSAGE ""                          // Messaggio utente


M_Normal()                                           // Stato mouse normale

* #COD OAACT0 * #END //  Inizializzazione oggetto oWin

RETURN oWin

*******************************************************************************
FUNCTION AboutUpw(        ;                          // [ 04 ]  UPDATE WINDOW  Aggiornamento oggetto
                    cDisGrp )                        //  Id. gruppo di visualizzazione
                                                     //  "#" = aggiorna tutti i control
*******************************************************************************
* #COD OBUPW0 * #END //  Update window oggetto oWin

tbDisItm( oWin ,cDisGrp )                            //  funzione di aggiornamento control (vedere Norton Guide)

* #COD OAUPW0 * #END //  Update window oggetto oWin

RETURN NIL

*******************************************************************************
FUNCTION AboutInk()                                  // [ 05 ] INTERAZIONE CON L'UTENTE
*******************************************************************************
LOCAL cCho

* #COD OBINK0 * #END //  Interazione con l'utente o inkey di tastiera


WHILE( !lBreak )

   AboutUpw()                                        //  Visualizza i dati

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
FUNCTION AboutBrk()                                  // [ 06 ] COMANDA UN BREAK SULL'OGGETTO
*******************************************************************************
* #COD OBBRK0 * #END //  Comanda un break sull'oggetto
lBreak := .T.
* #COD OABRK0 * #END //  Comanda un break sull'oggetto
RETURN NIL

*******************************************************************************
FUNCTION AboutEnd(         ;                         // [ 07 ] OPERAZIONI DI CHIUSURA
                     cClose  ;                       // Modalita' chiusura oggetto:
                             ;                       // W_OC_RESTORE =  Restore dello screen
                             )                       // W_OC_DESTROY =  Rilascio dell'oggetto
*******************************************************************************
* #COD OBEND0 * #END //  Chiusura e rilascio oggetto oWin

oWin:=tbEnd( oWin , cClose )                         // ( vedere Norton Guide )

* #COD OAEND0 * #END //  Chiusura e rilascio oggetto oWin

RETURN NIL




* #COD OIBOT1 * #END Fine file sorgente per oggetto form

