/******************************************************************************
 Progetto       : Esempio Crystal Report
 Sottoprogetto  : Esempio Crystal Report
 Programma      : C:\PROGRA~1\VISUAL~1\SAMPLES\CRYSTAL\source\cliQry.prg
 Template       : C:\Programmi\VisualdBsee\bin\..\tmp\xbase\query.tmp
 Descrizione    : Selezione Clienti
 Programmatore  :
 Data           : 12-10-04
 Ora            : 16.03.33
******************************************************************************/

#INCLUDE "Common.ch"
#INCLUDE "dfCtrl.ch"
#INCLUDE "dfGenMsg.ch"
#INCLUDE "dfLook.ch"
#INCLUDE "dfMenu.ch"
#INCLUDE "dfReport.ch"
#INCLUDE "dfSet.ch"
#INCLUDE "dfWin.ch"
* #COD OITOP0 * #END Punto di dichiarazione file INCLUDE *.ch per file sorgente

MEMVAR Act, Sa, A, EnvId, SubId, BackFun           //  Variabili di ambiente dBsee



STATIC aQuery                                     ,; // array dei campi in get
       aSeq                                       ,; // array di ordinamento dei control delle query
       oWin   := NIL                              ,; // Oggetto form
       aFile  := {}                               ,; // Array dei file aperti dall' oggetto
       cState := DE_STATE_MOD                     ,; // Stato della gestione
       nWin   := 0                                   // Flag per impedire la ricorsione

* #COD OITOP1 * #END Punto di dichiarazione STATICHE a livello di file sorgente

         /* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            ³           TABELLA METODI DELL'OGGETTO QUERY          ³
            ÃÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
            ³ nø ³ mtd.³ Descrizione                               ³
            ÃÄÄÄÄÅÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
            ³  1 ³ exe ³ Esecutore                                 ³
            ³  2 ³ dbf ³ Apre la base dati                         ³
            ³  3 ³ act ³ Attivazione oggetto                       ³
            ³  4 ³ upw ³ Update window (aggiorna oggetto)          ³
            ³  5 ³ end ³ Fine operazioni                           ³
            ÀÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

*******************************************************************************
FUNCTION cliQryExe(                ;               // [ 01 ]  ESECUTORE OPERAZIONI
                     aQryOpt        )              // Array dati in query
*******************************************************************************
LOCAL  lRet    := .F.                                // Flag logico di ritorno

* #COD OBEXE0 * #END //  Esegue le operazioni di base per attivazione oggetto QUERY

PRIVATE  EnvId:="cliQry" ,SubId:=""                  // Variabili di ambiente per oggetto query

nWin++
IF nWin==1

   IF cliQryDbf()                                  // Apre la base dati

      cliQryAct()                                  // Attivazione oggetto
      tbConfig( oWin )                             // Configura oggetto (vedere Norton Guide)
      cliQryUpw( "#" )                             //Visualizza i dati da MEMORIA

      tbGetTop(oWin,.T.)                           //Rende attivo il primo control in modifica (vedere Norton Guide)

      IF (lRet := tbGet( oWin ))                   //Fase di get

         * #COD OIEXE1 * #END Prima assegnamento array delle get
         // Assegna all'array aQryOpt chiave, filtro e break di query
         clienti->(dfQryOpt( aQuery, aSeq, aQryOpt ))  //Ottimizzatore query
         * #COD OIEXE2 * #END Dopo assegnamento array delle get

      ENDIF

      cliQryEnd( W_OC_RESTORE )                    //Chiusura oggetto
   END

   dfClose( aFile, .F., .T. )                      //Chiusura file

ENDIF
nWin--

* #COD OAEXE0 * #END //  Esegue le operazioni di base per attivazione oggetto QUERY

RETURN lRet

*******************************************************************************
FUNCTION cliQryDbf()                               // [ 02 ] APERTURA DATABASE
*******************************************************************************
* #COD OBDBF0 * #END //  apertura della base dati

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³  MASTER FILE   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !dfUse( "clienti" ,NIL ,aFile ) ;RETU .F. ;END    // Funzione di apertura file (vedere Norton Guide)



* #COD OADBF0 * #END //  apertura della base dati

RETURN .T.

*******************************************************************************
FUNCTION cliQryAct( )                              // [ 03 ] INIZIALIZZA OGGETTO
*******************************************************************************
* #COD OBACT0 * #END //  Inizializzazione oggetto oWin

IF oWin!=NIL ;RETURN oWin ;END                     // Oggetto gia' inizializzato! Ritorna l'Id dell'oggetto.

aQuery := {}                                        // array dei control in get

ATTACH TO QUERY aQuery DESCRIPTION "Codice cliente"  ; //  Descrizione
                       BUFFER      SPACE(6)        ; //  Get buffer
                       ALIAS       "clienti"       ; //  File proprietario
                       FIELD       "codcli"        ; //  Variabile
                       TYPE        "C"             ; //  Tipo
                       LEN         6               ; //  Lunghezza
                       DEC         0                 //  decimali

ATTACH TO QUERY aQuery DESCRIPTION "Codice cliente"  ; //  Descrizione
                       BUFFER      SPACE(6)        ; //  Get buffer
                       ALIAS       "clienti"       ; //  File proprietario
                       FIELD       "codcli"        ; //  Variabile
                       TYPE        "C"             ; //  Tipo
                       LEN         6               ; //  Lunghezza
                       DEC         0                 //  decimali

ATTACH TO QUERY aQuery DESCRIPTION "Rag. sociale"  ; //  Descrizione
                       BUFFER      SPACE(40)       ; //  Get buffer
                       ALIAS       "clienti"       ; //  File proprietario
                       FIELD       "ragsoc"        ; //  Variabile
                       TYPE        "C"             ; //  Tipo
                       LEN         40              ; //  Lunghezza
                       DEC         0                 //  decimali

ATTACH TO QUERY aQuery DESCRIPTION "Indirizzo"  ; //  Descrizione
                       BUFFER      SPACE(40)       ; //  Get buffer
                       ALIAS       "clienti"       ; //  File proprietario
                       FIELD       "indiri"        ; //  Variabile
                       TYPE        "C"             ; //  Tipo
                       LEN         40              ; //  Lunghezza
                       DEC         0                 //  decimali

ATTACH TO QUERY aQuery DESCRIPTION "Localita"      ; //  Descrizione
                       BUFFER      SPACE(40)       ; //  Get buffer
                       ALIAS       "clienti"       ; //  File proprietario
                       FIELD       "locali"        ; //  Variabile
                       TYPE        "C"             ; //  Tipo
                       LEN         40              ; //  Lunghezza
                       DEC         0                 //  decimali

ATTACH TO QUERY aQuery DESCRIPTION "CAP"           ; //  Descrizione
                       BUFFER      SPACE(5)        ; //  Get buffer
                       ALIAS       "clienti"       ; //  File proprietario
                       FIELD       "cap"           ; //  Variabile
                       TYPE        "C"             ; //  Tipo
                       LEN         5               ; //  Lunghezza
                       DEC         0                 //  decimali

ATTACH TO QUERY aQuery DESCRIPTION "CAP"           ; //  Descrizione
                       BUFFER      SPACE(5)        ; //  Get buffer
                       ALIAS       "clienti"       ; //  File proprietario
                       FIELD       "cap"           ; //  Variabile
                       TYPE        "C"             ; //  Tipo
                       LEN         5               ; //  Lunghezza
                       DEC         0                 //  decimali

ATTACH TO QUERY aQuery DESCRIPTION "Provincia"  ; //  Descrizione
                       BUFFER      SPACE(2)        ; //  Get buffer
                       ALIAS       "clienti"       ; //  File proprietario
                       FIELD       "provi"         ; //  Variabile
                       TYPE        "C"             ; //  Tipo
                       LEN         2               ; //  Lunghezza
                       DEC         0                 //  decimali

ATTACH TO QUERY aQuery DESCRIPTION "Provincia"  ; //  Descrizione
                       BUFFER      SPACE(2)        ; //  Get buffer
                       ALIAS       "clienti"       ; //  File proprietario
                       FIELD       "provi"         ; //  Variabile
                       TYPE        "C"             ; //  Tipo
                       LEN         2               ; //  Lunghezza
                       DEC         0                 //  decimali

ATTACH TO QUERY aQuery DESCRIPTION "Num. telefono"  ; //  Descrizione
                       BUFFER      SPACE(30)       ; //  Get buffer
                       ALIAS       "clienti"       ; //  File proprietario
                       FIELD       "numtel"        ; //  Variabile
                       TYPE        "C"             ; //  Tipo
                       LEN         30              ; //  Lunghezza
                       DEC         0                 //  decimali

ATTACH TO QUERY aQuery DESCRIPTION "Num. fax"      ; //  Descrizione
                       BUFFER      SPACE(30)       ; //  Get buffer
                       ALIAS       "clienti"       ; //  File proprietario
                       FIELD       "numfax"        ; //  Variabile
                       TYPE        "C"             ; //  Tipo
                       LEN         30              ; //  Lunghezza
                       DEC         0                 //  decimali

ATTACH TO QUERY aQuery DESCRIPTION "Email"         ; //  Descrizione
                       BUFFER      SPACE(50)       ; //  Get buffer
                       ALIAS       "clienti"       ; //  File proprietario
                       FIELD       "email"         ; //  Variabile
                       TYPE        "C"             ; //  Tipo
                       LEN         50              ; //  Lunghezza
                       DEC         0                 //  decimali

aSeq := {}                                           //  array di ordinamento control in query
ATTACH TO QUERYEXP aSeq TYPE       QRY_FIELD       ; // ordinamento query
                        PARAMETER  1                 // per calcolo espressione
ATTACH TO QUERYEXP aSeq TYPE       QRY_COND        ; // condizione
                        PARAMETER ">="               // maggiore o uguale
ATTACH TO QUERYEXP aSeq TYPE       QRY_LINK        ; // legame logico
                        PARAMETER ".AND."
ATTACH TO QUERYEXP aSeq TYPE       QRY_FIELD       ; // ordinamento query
                        PARAMETER  2                 // per calcolo espressione
ATTACH TO QUERYEXP aSeq TYPE       QRY_COND        ; // condizione
                        PARAMETER "<="               // minore o uguale
ATTACH TO QUERYEXP aSeq TYPE       QRY_LINK        ; // legame logico
                        PARAMETER ".AND."
ATTACH TO QUERYEXP aSeq TYPE       QRY_FIELD       ; // ordinamento query
                        PARAMETER  3                 // per calcolo espressione
ATTACH TO QUERYEXP aSeq TYPE       QRY_COND        ; // condizione
                        PARAMETER "$"                // contiene
ATTACH TO QUERYEXP aSeq TYPE       QRY_LINK        ; // legame logico
                        PARAMETER ".AND."
ATTACH TO QUERYEXP aSeq TYPE       QRY_FIELD       ; // ordinamento query
                        PARAMETER  4                 // per calcolo espressione
ATTACH TO QUERYEXP aSeq TYPE       QRY_COND        ; // condizione
                        PARAMETER "$"                // contiene
ATTACH TO QUERYEXP aSeq TYPE       QRY_LINK        ; // legame logico
                        PARAMETER ".AND."
ATTACH TO QUERYEXP aSeq TYPE       QRY_FIELD       ; // ordinamento query
                        PARAMETER  5                 // per calcolo espressione
ATTACH TO QUERYEXP aSeq TYPE       QRY_COND        ; // condizione
                        PARAMETER "$"                // contiene
ATTACH TO QUERYEXP aSeq TYPE       QRY_LINK        ; // legame logico
                        PARAMETER ".AND."
ATTACH TO QUERYEXP aSeq TYPE       QRY_FIELD       ; // ordinamento query
                        PARAMETER  6                 // per calcolo espressione
ATTACH TO QUERYEXP aSeq TYPE       QRY_COND        ; // condizione
                        PARAMETER ">="               // maggiore o uguale
ATTACH TO QUERYEXP aSeq TYPE       QRY_LINK        ; // legame logico
                        PARAMETER ".AND."
ATTACH TO QUERYEXP aSeq TYPE       QRY_FIELD       ; // ordinamento query
                        PARAMETER  7                 // per calcolo espressione
ATTACH TO QUERYEXP aSeq TYPE       QRY_COND        ; // condizione
                        PARAMETER "<="               // minore o uguale
ATTACH TO QUERYEXP aSeq TYPE       QRY_LINK        ; // legame logico
                        PARAMETER ".AND."
ATTACH TO QUERYEXP aSeq TYPE       QRY_FIELD       ; // ordinamento query
                        PARAMETER  8                 // per calcolo espressione
ATTACH TO QUERYEXP aSeq TYPE       QRY_COND        ; // condizione
                        PARAMETER ">="               // maggiore o uguale
ATTACH TO QUERYEXP aSeq TYPE       QRY_LINK        ; // legame logico
                        PARAMETER ".AND."
ATTACH TO QUERYEXP aSeq TYPE       QRY_FIELD       ; // ordinamento query
                        PARAMETER  9                 // per calcolo espressione
ATTACH TO QUERYEXP aSeq TYPE       QRY_COND        ; // condizione
                        PARAMETER "<="               // minore o uguale
ATTACH TO QUERYEXP aSeq TYPE       QRY_LINK        ; // legame logico
                        PARAMETER ".AND."
ATTACH TO QUERYEXP aSeq TYPE       QRY_FIELD       ; // ordinamento query
                        PARAMETER  10                // per calcolo espressione
ATTACH TO QUERYEXP aSeq TYPE       QRY_COND        ; // condizione
                        PARAMETER "$"                // contiene
ATTACH TO QUERYEXP aSeq TYPE       QRY_LINK        ; // legame logico
                        PARAMETER ".AND."
ATTACH TO QUERYEXP aSeq TYPE       QRY_FIELD       ; // ordinamento query
                        PARAMETER  11                // per calcolo espressione
ATTACH TO QUERYEXP aSeq TYPE       QRY_COND        ; // condizione
                        PARAMETER "$"                // contiene
ATTACH TO QUERYEXP aSeq TYPE       QRY_LINK        ; // legame logico
                        PARAMETER ".AND."
ATTACH TO QUERYEXP aSeq TYPE       QRY_FIELD       ; // ordinamento query
                        PARAMETER  12                // per calcolo espressione
ATTACH TO QUERYEXP aSeq TYPE       QRY_COND        ; // condizione
                        PARAMETER "$"                // contiene

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Inizializza oggetto ( vedere Norton Guide ) ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

oWin := clienti->(TbBrwNew(  12                   ,; // Prima  Riga
                         0                        ,; // Prima  Colonna
                       362                        ,; // Ultima Riga
                       584                        ,; // Ultima Colonna
                      W_OBJ_FRM                             ,; // Tipo oggetto ( form )
                      NIL ,; // Label
                      W_COORDINATE_PIXEL                    )) // Gestione in Pixel

oWin:W_TITLE     := "Selezione Clienti"              // Titolo oggetto
oWin:W_KEY       := NIL                              // Non esegue la seek
oWin:W_FILTER    := {||.T.}                          // CodeBlock per il filtro
oWin:W_BREAK     := {||.F.}                          // CodeBlock per il break
oWin:W_PAGELABELS:= {}                               // Array delle pagine
ATTACH PAGE LABEL "Pagina Nø1" TO oWin:W_PAGELABELS
oWin:W_MENUHIDDEN:= .T.                              // Stato attivazione barra azioni
oWin:W_COLORARRAY[AC_FRM_BACK  ] := "B+/G"           // Colore di FONDO
oWin:W_COLORARRAY[AC_FRM_BOX   ] := "B+/G"           // Colore di BOX
oWin:W_COLORARRAY[AC_FRM_HEADER] := "RB+/B*"         // Colore di HEADER ON
oWin:W_COLORARRAY[AC_FRM_OPTION] := "W+/BG"          // Colore di ICONE

#ifdef __XPP__
oWin:lCenter := .T.
oWin:icon := APPLICATION_ICON
#endif
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Control                     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oWin:W_MOUSEMETHOD := W_MM_PAGE + W_MM_ESCAPE+ W_MM_MOVE    // Inizializzazione ICONE per mouse
* #COD OIACT1 * #END Dopo inizializzazioni oggetto oWin

/*ÚÄÄÄÄÄÄÄÄÄÄ¿
  ³ Control  ³
  ÀÄÄÄÄÄÄÄÄÄÄÙ*/
ATTACH "but0001" TO oWin:W_CONTROL GET AS PUSHBUTTON "O^K"  ; // ATTBUT.TMP
                 AT   22, 432,  22,  24            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||dbAct2Kbd("wri")}     ; // Funzione di controllo
                 ACTIVE   {||cState $ "m"}         ; // Stato di attivazione
                 MESSAGE "Registra e chiude"         // Messaggio utente
ATTACH "but0002" TO oWin:W_CONTROL GET AS PUSHBUTTON "^Abbandona"  ; // ATTBUT.TMP
                 AT   22, 480,  22,  80            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||dbAct2Kbd("esc")}     ; // Funzione di controllo
                 ACTIVE   {||cState $ "m"}         ; // Stato di attivazione
                 MESSAGE "Abbandona senza formulare la query"    // Messaggio utente
ATTACH "cGet1" TO oWin:W_CONTROL GET aQuery[1,3] AT  242, 168  ; // Campo , Top+Left
                 SIZE       {  56,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR      {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT     "da Codice cliente"    ; // Prompt
                 PROMPTAT    242 ,  24             ; // Coordinate prompt
                 PICTURESAY "!!!!!!"               ; // Picture in say
                 CONDITION {|ab|cGet1(ab)}         ; // Funzione When/Valid
                 COMBO                             ; // Icona combo
                 MESSAGE "Codice cliente"            // Messaggio
ATTACH "cGet2" TO oWin:W_CONTROL GET aQuery[2,3] AT  242, 256  ; // Campo , Top+Left
                 SIZE       {  56,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR      {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT     "a"                    ; // Prompt
                 PROMPTAT    242 , 240             ; // Coordinate prompt
                 PICTURESAY "!!!!!!"               ; // Picture in say
                 CONDITION {|ab|cGet2(ab)}         ; // Funzione When/Valid
                 COMBO                             ; // Icona combo
                 MESSAGE "Codice cliente"            // Messaggio
ATTACH "cGet3" TO oWin:W_CONTROL GET aQuery[3,3] AT  220, 168  ; // Campo , Top+Left
                 SIZE       { 328,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR      {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT     "Rag. sociale"         ; // Prompt
                 PROMPTAT    220 ,  64             ; // Coordinate prompt
                 PICTURESAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  ; // Picture in say
                 MESSAGE "Rag. sociale"              // Messaggio
ATTACH "cGet4" TO oWin:W_CONTROL GET aQuery[4,3] AT  198, 168  ; // Campo , Top+Left
                 SIZE       { 328,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR      {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT     "Indirizzo"            ; // Prompt
                 PROMPTAT    198 ,  88             ; // Coordinate prompt
                 PICTURESAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  ; // Picture in say
                 MESSAGE "Indirizzo"                 // Messaggio
ATTACH "cGet5" TO oWin:W_CONTROL GET aQuery[5,3] AT  176, 168  ; // Campo , Top+Left
                 SIZE       { 328,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR      {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT     "Localita"             ; // Prompt
                 PROMPTAT    176 ,  96             ; // Coordinate prompt
                 PICTURESAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  ; // Picture in say
                 MESSAGE "Localita"                  // Messaggio
ATTACH "cGet6" TO oWin:W_CONTROL GET aQuery[6,3] AT  154, 168  ; // Campo , Top+Left
                 SIZE       {  48,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR      {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT     "da CAP"               ; // Prompt
                 PROMPTAT    154 , 112             ; // Coordinate prompt
                 PICTUREGET "99999"                ; // Picture in get
                 PICTURESAY "!!!!!"                ; // Picture in say
                 MESSAGE "Codice avviamento postale"    // Messaggio
ATTACH "cGet7" TO oWin:W_CONTROL GET aQuery[7,3] AT  154, 256  ; // Campo , Top+Left
                 SIZE       {  48,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR      {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT     "a"                    ; // Prompt
                 PROMPTAT    154 , 240             ; // Coordinate prompt
                 PICTUREGET "99999"                ; // Picture in get
                 PICTURESAY "!!!!!"                ; // Picture in say
                 MESSAGE "Codice avviamento postale"    // Messaggio
ATTACH "cGet8" TO oWin:W_CONTROL GET aQuery[8,3] AT  132, 168  ; // Campo , Top+Left
                 SIZE       {  46,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR      {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT     "da Provincia"         ; // Prompt
                 PROMPTAT    132 ,  64             ; // Coordinate prompt
                 PICTURESAY "!!"                   ; // Picture in say
                 MESSAGE "Provincia"                 // Messaggio
ATTACH "cGet9" TO oWin:W_CONTROL GET aQuery[9,3] AT  132, 256  ; // Campo , Top+Left
                 SIZE       {  46,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR      {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT     "a"                    ; // Prompt
                 PROMPTAT    132 , 240             ; // Coordinate prompt
                 PICTURESAY "!!"                   ; // Picture in say
                 MESSAGE "Provincia"                 // Messaggio
ATTACH "cGet10" TO oWin:W_CONTROL GET aQuery[10,3] AT  110, 168  ; // Campo , Top+Left
                 SIZE       { 248,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR      {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT     "Num. telefono"        ; // Prompt
                 PROMPTAT    110 ,  56             ; // Coordinate prompt
                 PICTURESAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  ; // Picture in say
                 MESSAGE "Num. telefono"             // Messaggio
ATTACH "cGet11" TO oWin:W_CONTROL GET aQuery[11,3] AT   88, 168  ; // Campo , Top+Left
                 SIZE       { 248,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR      {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT     "Num. fax"             ; // Prompt
                 PROMPTAT     88 ,  96             ; // Coordinate prompt
                 PICTURESAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  ; // Picture in say
                 MESSAGE "Num. fax"                  // Messaggio
ATTACH "cGet12" TO oWin:W_CONTROL GET aQuery[12,3] AT   66, 168  ; // Campo , Top+Left
                 SIZE       { 408,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR      {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT     "Email"                ; // Prompt
                 PROMPTAT     66 , 120             ; // Coordinate prompt
                 PICTURESAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  ; // Picture in say
                 MESSAGE "Email"                     // Messaggio


* #COD OAACT0 * #END //  Inizializzazione oggetto oWin

RETURN oWin

*******************************************************************************
FUNCTION cliQryUpw(        ;                       // [ 04 ]  UPDATE WINDOW
                    cDisGrp )                      // Gruppo di visualizzazione
*******************************************************************************
* #COD OBUPW0 * #END //  Update window oggetto oWin

tbDisItm( oWin ,cDisGrp )

* #COD OAUPW0 * #END //  Update window oggetto oWin

RETURN NIL

*******************************************************************************
FUNCTION cliQryEnd(         ;                      // [ 05 ] OPERAZIONI DI CHIUSURA
                     cClose  )                     // Modalita' chiusura oggetto "rcd"
*******************************************************************************
* #COD OBEND0 * #END //  Chiusura e rilascio oggetto oWin

oWin:=tbEnd( oWin , cClose )

* #COD OAEND0 * #END //  Chiusura e rilascio oggetto oWin

RETURN NIL

*******************************************************************************
STATIC FUNCTION cGet1( nPrePost ) // codcli    , C,   6,   0
*******************************************************************************
LOCAL aDbL ,lRet:=.T.
* #COD IIGSF10003 * #END
DO CASE
   CASE nPrePost == FORM_PREGET

        * #COD IIEDTB0003 * #END

        * #COD IIEDTA0003 * #END

   CASE nPrePost == FORM_POSTGET .OR. nPrePost == FORM_CHKGET

        * #COD IICHKB0003 * #END
        aDbl           := ARRAY(LK_ARRAYLEN)
        aDbl[LK_ORDER] := 1                        //  Order (numerico)
        aDbl[LK_SEEK]  := aQuery[1,3]              // Chiave di ricerca
        aDbl[LK_VAL]   := {}                       //  Dati da ereditare nel file figlio
        aDbl[LK_FIELD] := ""                       //  Nome campo relazionato
        aDbl[LK_WIN]   := NIL                      //  Nome finestra
        aDbl[LK_KEY]   := NIL                      //  Chiave finestra
        aDbl[LK_FILTER]:= {|| .T.}                 //  Filtro finestra
        aDbl[LK_BREAK] := {|| .F.}                 //  Break finestra
        aDbl[LK_TYPE]  := LT_FREE                  // Modalita'
        aDbl[LK_EDIT]  := NIL                      //  Nome quadro edit
        aDbl[LK_INS]   := {||.T.}                  //  Abilita edit se...
        aDbl[LK_KBD]   := .T.                      //  Keyboard
        * #COD IIGSF40003 * #END

        IF ! clienti->(dbLooK( aDbl ))
           lRet := .F.
        ELSE
           IF ! clienti->(eof())
              aQuery[1,3] := clienti->codcli
              tbDisRef( oWin ,"cGet1" )
           ENDIF
        ENDIF


        * #COD IICHKA0003 * #END

        IF nPrePost == FORM_POSTGET
           * #COD IIGSF50003 * #END
        ENDIF

ENDCASE
* #COD IIGSF90003 * #END

RETURN lRet
*******************************************************************************
STATIC FUNCTION cGet2( nPrePost ) // codcli    , C,   6,   0
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
        aDbl[LK_ORDER] := 1                        //  Order (numerico)
        aDbl[LK_SEEK]  := aQuery[2,3]              // Chiave di ricerca
        aDbl[LK_VAL]   := {}                       //  Dati da ereditare nel file figlio
        aDbl[LK_FIELD] := ""                       //  Nome campo relazionato
        aDbl[LK_WIN]   := NIL                      //  Nome finestra
        aDbl[LK_KEY]   := NIL                      //  Chiave finestra
        aDbl[LK_FILTER]:= {|| .T.}                 //  Filtro finestra
        aDbl[LK_BREAK] := {|| .F.}                 //  Break finestra
        aDbl[LK_TYPE]  := LT_FREE                  // Modalita'
        aDbl[LK_EDIT]  := NIL                      //  Nome quadro edit
        aDbl[LK_INS]   := {||.T.}                  //  Abilita edit se...
        aDbl[LK_KBD]   := .T.                      //  Keyboard
        * #COD IIGSF40004 * #END

        IF ! clienti->(dbLooK( aDbl ))
           lRet := .F.
        ELSE
           IF ! clienti->(eof())
              aQuery[2,3] := clienti->codcli
              tbDisRef( oWin ,"cGet2" )
           ENDIF
        ENDIF


        * #COD IICHKA0004 * #END

        IF nPrePost == FORM_POSTGET
           * #COD IIGSF50004 * #END
        ENDIF

ENDCASE
* #COD IIGSF90004 * #END

RETURN lRet


* #COD OIBOT1 * #END Fine quadro data-entry

