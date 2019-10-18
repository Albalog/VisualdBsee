/******************************************************************************
 Progetto       : Esempio Crystal Report
 Sottoprogetto  : Esempio Crystal Report
 Programma      : C:\PROGRA~1\VISUAL~1\SAMPLES\CRYSTAL\source\docQry.prg
 Template       : C:\Programmi\VisualdBsee\bin\..\tmp\xbase\query.tmp
 Descrizione    : Selezione documenti
 Programmatore  :
 Data           : 12-10-04
 Ora            : 16.03.45
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
FUNCTION docQryExe(                ;               // [ 01 ]  ESECUTORE OPERAZIONI
                     aQryOpt        )              // Array dati in query
*******************************************************************************
LOCAL  lRet    := .F.                                // Flag logico di ritorno

* #COD OBEXE0 * #END //  Esegue le operazioni di base per attivazione oggetto QUERY

PRIVATE  EnvId:="docQry" ,SubId:=""                  // Variabili di ambiente per oggetto query

nWin++
IF nWin==1

   IF docQryDbf()                                  // Apre la base dati

      docQryAct()                                  // Attivazione oggetto
      tbConfig( oWin )                             // Configura oggetto (vedere Norton Guide)
      docQryUpw( "#" )                             //Visualizza i dati da MEMORIA

      tbGetTop(oWin,.T.)                           //Rende attivo il primo control in modifica (vedere Norton Guide)

      IF (lRet := tbGet( oWin ))                   //Fase di get

         * #COD OIEXE1 * #END Prima assegnamento array delle get
         // Assegna all'array aQryOpt chiave, filtro e break di query
         docven->(dfQryOpt( aQuery, aSeq, aQryOpt ))  //Ottimizzatore query
         * #COD OIEXE2 * #END Dopo assegnamento array delle get

      ENDIF

      docQryEnd( W_OC_RESTORE )                    //Chiusura oggetto
   END

   dfClose( aFile, .F., .T. )                      //Chiusura file

ENDIF
nWin--

* #COD OAEXE0 * #END //  Esegue le operazioni di base per attivazione oggetto QUERY

RETURN lRet

*******************************************************************************
FUNCTION docQryDbf()                               // [ 02 ] APERTURA DATABASE
*******************************************************************************
* #COD OBDBF0 * #END //  apertura della base dati

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³  MASTER FILE   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !dfUse( "docven" ,NIL ,aFile ) ;RETU .F. ;END    // Funzione di apertura file (vedere Norton Guide)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³  LOOK-UP FILE  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !dfUse( "clienti" ,NIL ,aFile ) ;RETU .F. ;END


* #COD OADBF0 * #END //  apertura della base dati

RETURN .T.

*******************************************************************************
FUNCTION docQryAct( )                              // [ 03 ] INIZIALIZZA OGGETTO
*******************************************************************************
* #COD OBACT0 * #END //  Inizializzazione oggetto oWin

IF oWin!=NIL ;RETURN oWin ;END                     // Oggetto gia' inizializzato! Ritorna l'Id dell'oggetto.

aQuery := {}                                        // array dei control in get

ATTACH TO QUERY aQuery DESCRIPTION "Num. doc."  ; //  Descrizione
                       BUFFER      0               ; //  Get buffer
                       ALIAS       "docven"        ; //  File proprietario
                       FIELD       "numdoc"        ; //  Variabile
                       TYPE        "N"             ; //  Tipo
                       LEN         6               ; //  Lunghezza
                       DEC         0                 //  decimali

ATTACH TO QUERY aQuery DESCRIPTION "Num. doc."  ; //  Descrizione
                       BUFFER      0               ; //  Get buffer
                       ALIAS       "docven"        ; //  File proprietario
                       FIELD       "numdoc"        ; //  Variabile
                       TYPE        "N"             ; //  Tipo
                       LEN         6               ; //  Lunghezza
                       DEC         0                 //  decimali

ATTACH TO QUERY aQuery DESCRIPTION "Data doc."  ; //  Descrizione
                       BUFFER      ctod(space(8))  ; //  Get buffer
                       ALIAS       "docven"        ; //  File proprietario
                       FIELD       "datdoc"        ; //  Variabile
                       TYPE        "D"             ; //  Tipo
                       LEN         8               ; //  Lunghezza
                       DEC         0                 //  decimali

ATTACH TO QUERY aQuery DESCRIPTION "Data doc."  ; //  Descrizione
                       BUFFER      ctod(space(8))  ; //  Get buffer
                       ALIAS       "docven"        ; //  File proprietario
                       FIELD       "datdoc"        ; //  Variabile
                       TYPE        "D"             ; //  Tipo
                       LEN         8               ; //  Lunghezza
                       DEC         0                 //  decimali

ATTACH TO QUERY aQuery DESCRIPTION "Codice cliente"  ; //  Descrizione
                       BUFFER      SPACE(6)        ; //  Get buffer
                       ALIAS       "docven"        ; //  File proprietario
                       FIELD       "codcli"        ; //  Variabile
                       TYPE        "C"             ; //  Tipo
                       LEN         6               ; //  Lunghezza
                       DEC         0                 //  decimali

ATTACH TO QUERY aQuery DESCRIPTION "Codice cliente"  ; //  Descrizione
                       BUFFER      SPACE(6)        ; //  Get buffer
                       ALIAS       "docven"        ; //  File proprietario
                       FIELD       "codcli"        ; //  Variabile
                       TYPE        "C"             ; //  Tipo
                       LEN         6               ; //  Lunghezza
                       DEC         0                 //  decimali

ATTACH TO QUERY aQuery DESCRIPTION "Tot. documento"  ; //  Descrizione
                       BUFFER      0               ; //  Get buffer
                       ALIAS       "docven"        ; //  File proprietario
                       FIELD       "totdoc"        ; //  Variabile
                       TYPE        "N"             ; //  Tipo
                       LEN         10              ; //  Lunghezza
                       DEC         2                 //  decimali

ATTACH TO QUERY aQuery DESCRIPTION "Tot. documento"  ; //  Descrizione
                       BUFFER      0               ; //  Get buffer
                       ALIAS       "docven"        ; //  File proprietario
                       FIELD       "totdoc"        ; //  Variabile
                       TYPE        "N"             ; //  Tipo
                       LEN         10              ; //  Lunghezza
                       DEC         2                 //  decimali

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
                        PARAMETER ">="               // maggiore o uguale
ATTACH TO QUERYEXP aSeq TYPE       QRY_LINK        ; // legame logico
                        PARAMETER ".AND."
ATTACH TO QUERYEXP aSeq TYPE       QRY_FIELD       ; // ordinamento query
                        PARAMETER  4                 // per calcolo espressione
ATTACH TO QUERYEXP aSeq TYPE       QRY_COND        ; // condizione
                        PARAMETER "<="               // minore o uguale
ATTACH TO QUERYEXP aSeq TYPE       QRY_LINK        ; // legame logico
                        PARAMETER ".AND."
ATTACH TO QUERYEXP aSeq TYPE       QRY_FIELD       ; // ordinamento query
                        PARAMETER  5                 // per calcolo espressione
ATTACH TO QUERYEXP aSeq TYPE       QRY_COND        ; // condizione
                        PARAMETER ">="               // maggiore o uguale
ATTACH TO QUERYEXP aSeq TYPE       QRY_LINK        ; // legame logico
                        PARAMETER ".AND."
ATTACH TO QUERYEXP aSeq TYPE       QRY_FIELD       ; // ordinamento query
                        PARAMETER  6                 // per calcolo espressione
ATTACH TO QUERYEXP aSeq TYPE       QRY_COND        ; // condizione
                        PARAMETER "<="               // minore o uguale
ATTACH TO QUERYEXP aSeq TYPE       QRY_LINK        ; // legame logico
                        PARAMETER ".AND."
ATTACH TO QUERYEXP aSeq TYPE       QRY_FIELD       ; // ordinamento query
                        PARAMETER  7                 // per calcolo espressione
ATTACH TO QUERYEXP aSeq TYPE       QRY_COND        ; // condizione
                        PARAMETER ">="               // maggiore o uguale
ATTACH TO QUERYEXP aSeq TYPE       QRY_LINK        ; // legame logico
                        PARAMETER ".AND."
ATTACH TO QUERYEXP aSeq TYPE       QRY_FIELD       ; // ordinamento query
                        PARAMETER  8                 // per calcolo espressione
ATTACH TO QUERYEXP aSeq TYPE       QRY_COND        ; // condizione
                        PARAMETER "<="               // minore o uguale

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Inizializza oggetto ( vedere Norton Guide ) ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

oWin := docven->(TbBrwNew( 122                    ,; // Prima  Riga
                        16                        ,; // Prima  Colonna
                       252                        ,; // Ultima Riga
                       584                        ,; // Ultima Colonna
                      W_OBJ_FRM                             ,; // Tipo oggetto ( form )
                      NIL ,; // Label
                      W_COORDINATE_PIXEL                    )) // Gestione in Pixel

oWin:W_TITLE     := "Selezione documenti"            // Titolo oggetto
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
                 AT   22,   8,  22,  24            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||dbAct2Kbd("wri")}     ; // Funzione di controllo
                 ACTIVE   {||cState $ "m"}         ; // Stato di attivazione
                 MESSAGE "Registra e chiude"         // Messaggio utente
ATTACH "but0002" TO oWin:W_CONTROL GET AS PUSHBUTTON "^Abbandona"  ; // ATTBUT.TMP
                 AT   22,  56,  22,  80            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||dbAct2Kbd("esc")}     ; // Funzione di controllo
                 ACTIVE   {||cState $ "m"}         ; // Stato di attivazione
                 MESSAGE "Abbandona senza formulare la query"    // Messaggio utente
ATTACH "cGet1" TO oWin:W_CONTROL GET aQuery[1,3] AT  132, 168  ; // Campo , Top+Left
                 SIZE       {  64,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR      {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT     "da Num. doc."         ; // Prompt
                 PROMPTAT    132 ,  64             ; // Coordinate prompt
                 PICTURESAY "@ZE 999,999"          ; // Picture in say
                 MESSAGE "Numero documento"          // Messaggio
ATTACH "cGet2" TO oWin:W_CONTROL GET aQuery[2,3] AT  132, 320  ; // Campo , Top+Left
                 SIZE       {  64,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR      {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT     "a"                    ; // Prompt
                 PROMPTAT    132 , 304             ; // Coordinate prompt
                 PICTURESAY "@ZE 999,999"          ; // Picture in say
                 MESSAGE "Numero documento"          // Messaggio
ATTACH "cGet3" TO oWin:W_CONTROL GET aQuery[3,3] AT  110, 168  ; // Campo , Top+Left
                 SIZE       {  72,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR      {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT     "da Data doc."         ; // Prompt
                 PROMPTAT    110 ,  64             ; // Coordinate prompt
                 PICTURESAY "99/99/99"             ; // Picture in say
                 CONDITION {|ab|cGet3(ab)}         ; // Funzione When/Valid
                 MESSAGE "Data documento"            // Messaggio
ATTACH "cGet4" TO oWin:W_CONTROL GET aQuery[4,3] AT  110, 320  ; // Campo , Top+Left
                 SIZE       {  72,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR      {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT     "a"                    ; // Prompt
                 PROMPTAT    110 , 304             ; // Coordinate prompt
                 PICTURESAY "99/99/99"             ; // Picture in say
                 CONDITION {|ab|cGet4(ab)}         ; // Funzione When/Valid
                 MESSAGE "Data documento"            // Messaggio
ATTACH "cGet5" TO oWin:W_CONTROL GET aQuery[5,3] AT   88, 168  ; // Campo , Top+Left
                 SIZE       {  72,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR      {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT     "da Codice cliente"    ; // Prompt
                 PROMPTAT     88 ,  24             ; // Coordinate prompt
                 PICTURESAY "!!!!!!"               ; // Picture in say
                 CONDITION {|ab|cGet5(ab)}         ; // Funzione When/Valid
                 COMBO                             ; // Icona combo
                 MESSAGE "Codice cliente"            // Messaggio
ATTACH "cGet6" TO oWin:W_CONTROL GET aQuery[6,3] AT   88, 320  ; // Campo , Top+Left
                 SIZE       {  72,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR      {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT     "a"                    ; // Prompt
                 PROMPTAT     88 , 304             ; // Coordinate prompt
                 PICTURESAY "!!!!!!"               ; // Picture in say
                 CONDITION {|ab|cGet6(ab)}         ; // Funzione When/Valid
                 COMBO                             ; // Icona combo
                 MESSAGE "Codice cliente"            // Messaggio
ATTACH "cGet7" TO oWin:W_CONTROL GET aQuery[7,3] AT   66, 168  ; // Campo , Top+Left
                 SIZE       { 104,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR      {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT     "da Tot. documento"    ; // Prompt
                 PROMPTAT     66 ,  24             ; // Coordinate prompt
                 PICTURESAY "@ZE 9,999,999.99"     ; // Picture in say
                 MESSAGE "Tot. documento"            // Messaggio
ATTACH "cGet8" TO oWin:W_CONTROL GET aQuery[8,3] AT   66, 320  ; // Campo , Top+Left
                 SIZE       { 104,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR      {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT     "a"                    ; // Prompt
                 PROMPTAT     66 , 304             ; // Coordinate prompt
                 PICTURESAY "@ZE 9,999,999.99"     ; // Picture in say
                 MESSAGE "Tot. documento"            // Messaggio


* #COD OAACT0 * #END //  Inizializzazione oggetto oWin

RETURN oWin

*******************************************************************************
FUNCTION docQryUpw(        ;                       // [ 04 ]  UPDATE WINDOW
                    cDisGrp )                      // Gruppo di visualizzazione
*******************************************************************************
* #COD OBUPW0 * #END //  Update window oggetto oWin

tbDisItm( oWin ,cDisGrp )

* #COD OAUPW0 * #END //  Update window oggetto oWin

RETURN NIL

*******************************************************************************
FUNCTION docQryEnd(         ;                      // [ 05 ] OPERAZIONI DI CHIUSURA
                     cClose  )                     // Modalita' chiusura oggetto "rcd"
*******************************************************************************
* #COD OBEND0 * #END //  Chiusura e rilascio oggetto oWin

oWin:=tbEnd( oWin , cClose )

* #COD OAEND0 * #END //  Chiusura e rilascio oggetto oWin

RETURN NIL

*******************************************************************************
STATIC FUNCTION cGet3( nPrePost ) // datdoc    , D,   8,   0
*******************************************************************************
LOCAL aDbL ,lRet:=.T.
* #COD IIGSF10006 * #END
DO CASE
   CASE nPrePost == FORM_PREGET

        * #COD IIEDTB0006 * #END

        * #COD IIEDTA0006 * #END

   CASE nPrePost == FORM_POSTGET .OR. nPrePost == FORM_CHKGET

        * #COD IICHKB0006 * #END

        * #COD IICHKA0006 * #END

        IF nPrePost == FORM_POSTGET
           * #COD IIGSF50006 * #END
        ENDIF

ENDCASE
* #COD IIGSF90006 * #END

RETURN lRet
*******************************************************************************
STATIC FUNCTION cGet4( nPrePost ) // datdoc    , D,   8,   0
*******************************************************************************
LOCAL aDbL ,lRet:=.T.
* #COD IIGSF10008 * #END
DO CASE
   CASE nPrePost == FORM_PREGET

        * #COD IIEDTB0008 * #END

        * #COD IIEDTA0008 * #END

   CASE nPrePost == FORM_POSTGET .OR. nPrePost == FORM_CHKGET

        * #COD IICHKB0008 * #END

        * #COD IICHKA0008 * #END

        IF nPrePost == FORM_POSTGET
           * #COD IIGSF50008 * #END
        ENDIF

ENDCASE
* #COD IIGSF90008 * #END

RETURN lRet
*******************************************************************************
STATIC FUNCTION cGet5( nPrePost ) // codcli    , C,   6,   0
*******************************************************************************
LOCAL aDbL ,lRet:=.T.
* #COD IIGSF10010 * #END
DO CASE
   CASE nPrePost == FORM_PREGET

        * #COD IIEDTB0010 * #END

        * #COD IIEDTA0010 * #END

   CASE nPrePost == FORM_POSTGET .OR. nPrePost == FORM_CHKGET

        * #COD IICHKB0010 * #END
        aDbl           := ARRAY(LK_ARRAYLEN)
        aDbl[LK_ORDER] := 1                        //  Order (numerico)
        aDbl[LK_SEEK]  := aQuery[5,3]              // Chiave di ricerca
        aDbl[LK_VAL]   := {}                       //  Dati da ereditare nel file figlio
        aAdd( aDbl[LK_VAL] , { "codcli" ,{||aQuery[5,3] } })
        aDbl[LK_FIELD] := ""                       //  Nome campo relazionato
        aDbl[LK_WIN]   := NIL                      //  Nome finestra
        aDbl[LK_KEY]   := NIL                      //  Chiave finestra
        aDbl[LK_FILTER]:= {|| .T.}                 //  Filtro finestra
        aDbl[LK_BREAK] := {|| .F.}                 //  Break finestra
        aDbl[LK_TYPE]  := LT_FREE                  // Modalita'
        aDbl[LK_EDIT]  := NIL                      //  Nome quadro edit
        aDbl[LK_INS]   := {||.T.}                  //  Abilita edit se...
        aDbl[LK_KBD]   := .T.                      //  Keyboard
        * #COD IIGSF40010 * #END

        IF ! clienti->(dbLooK( aDbl ))
           lRet := .F.
        ELSE
           IF ! clienti->(eof())
              aQuery[5,3] := clienti->codcli
              tbDisRef( oWin ,"cGet5" )
           ENDIF
        ENDIF


        * #COD IICHKA0010 * #END

        IF nPrePost == FORM_POSTGET
           * #COD IIGSF50010 * #END
        ENDIF

ENDCASE
* #COD IIGSF90010 * #END

RETURN lRet
*******************************************************************************
STATIC FUNCTION cGet6( nPrePost ) // codcli    , C,   6,   0
*******************************************************************************
LOCAL aDbL ,lRet:=.T.
* #COD IIGSF10012 * #END
DO CASE
   CASE nPrePost == FORM_PREGET

        * #COD IIEDTB0012 * #END

        * #COD IIEDTA0012 * #END

   CASE nPrePost == FORM_POSTGET .OR. nPrePost == FORM_CHKGET

        * #COD IICHKB0012 * #END
        aDbl           := ARRAY(LK_ARRAYLEN)
        aDbl[LK_ORDER] := 1                        //  Order (numerico)
        aDbl[LK_SEEK]  := aQuery[6,3]              // Chiave di ricerca
        aDbl[LK_VAL]   := {}                       //  Dati da ereditare nel file figlio
        aAdd( aDbl[LK_VAL] , { "codcli" ,{||aQuery[6,3] } })
        aDbl[LK_FIELD] := ""                       //  Nome campo relazionato
        aDbl[LK_WIN]   := NIL                      //  Nome finestra
        aDbl[LK_KEY]   := NIL                      //  Chiave finestra
        aDbl[LK_FILTER]:= {|| .T.}                 //  Filtro finestra
        aDbl[LK_BREAK] := {|| .F.}                 //  Break finestra
        aDbl[LK_TYPE]  := LT_FREE                  // Modalita'
        aDbl[LK_EDIT]  := NIL                      //  Nome quadro edit
        aDbl[LK_INS]   := {||.T.}                  //  Abilita edit se...
        aDbl[LK_KBD]   := .T.                      //  Keyboard
        * #COD IIGSF40012 * #END

        IF ! clienti->(dbLooK( aDbl ))
           lRet := .F.
        ELSE
           IF ! clienti->(eof())
              aQuery[6,3] := clienti->codcli
              tbDisRef( oWin ,"cGet6" )
           ENDIF
        ENDIF


        * #COD IICHKA0012 * #END

        IF nPrePost == FORM_POSTGET
           * #COD IIGSF50012 * #END
        ENDIF

ENDCASE
* #COD IIGSF90012 * #END

RETURN lRet


* #COD OIBOT1 * #END Fine quadro data-entry

