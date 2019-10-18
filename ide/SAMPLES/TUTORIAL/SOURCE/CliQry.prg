/******************************************************************************
 Progetto       : Tutorial
 Sottoprogetto  : Tutorial
 Programma      : V:\SAMPLES\TUTORIAL\source\CliQry.prg
 Template       : V:\bin\..\tmp\xbase\query.tmp
 Descrizione    : Query Articoli
 Programmatore  : Demo
 Data           : 13-07-06
 Ora            : 16.44.03
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
FUNCTION CliQryExe(                ;               // [ 01 ]  ESECUTORE OPERAZIONI
                     aQryOpt        )              // Array dati in query
*******************************************************************************
LOCAL  lRet    := .F.                                // Flag logico di ritorno

* #COD OBEXE0 * #END //  Esegue le operazioni di base per attivazione oggetto QUERY

PRIVATE  EnvId:="CliQry" ,SubId:=""                  // Variabili di ambiente per oggetto query

nWin++
IF nWin==1

   IF CliQryDbf()                                  // Apre la base dati

      CliQryAct()                                  // Attivazione oggetto
      tbConfig( oWin )                             // Configura oggetto (vedere Norton Guide)
      CliQryUpw( "#" )                             //Visualizza i dati da MEMORIA

      tbGetTop(oWin,.T.)                           //Rende attivo il primo control in modifica (vedere Norton Guide)

      IF (lRet := tbGet( oWin ))                   //Fase di get

         * #COD OIEXE1 * #END Prima assegnamento array delle get
         // Assegna all'array aQryOpt chiave, filtro e break di query
         Clienti->(dfQryOpt( aQuery, aSeq, aQryOpt ))  //Ottimizzatore query
         * #COD OIEXE2 * #END Dopo assegnamento array delle get

      ENDIF

      CliQryEnd( W_OC_RESTORE )                    //Chiusura oggetto
   END

   dfClose( aFile, .F., .T. )                      //Chiusura file

ENDIF
nWin--

* #COD OAEXE0 * #END //  Esegue le operazioni di base per attivazione oggetto QUERY

RETURN lRet

*******************************************************************************
FUNCTION CliQryDbf()                               // [ 02 ] APERTURA DATABASE
*******************************************************************************
* #COD OBDBF0 * #END //  apertura della base dati

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³  MASTER FILE   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !dfUse( "Clienti" ,NIL ,aFile ) ;RETU .F. ;END    // Funzione di apertura file (vedere Norton Guide)



* #COD OADBF0 * #END //  apertura della base dati

RETURN .T.

*******************************************************************************
FUNCTION CliQryAct( )                              // [ 03 ] INIZIALIZZA OGGETTO
*******************************************************************************
* #COD OBACT0 * #END //  Inizializzazione oggetto oWin

IF oWin!=NIL ;RETURN oWin ;END                     // Oggetto gia' inizializzato! Ritorna l'Id dell'oggetto.

aQuery := {}                                        // array dei control in get

ATTACH TO QUERY aQuery DESCRIPTION "Codice Cliente"  ; //  Descrizione
                       BUFFER      SPACE(6)        ; //  Get buffer
                       ALIAS       "Clienti"       ; //  File proprietario
                       FIELD       "CodCli"        ; //  Variabile
                       TYPE        "C"             ; //  Tipo
                       LEN         6               ; //  Lunghezza
                       DEC         0                 //  decimali

ATTACH TO QUERY aQuery DESCRIPTION "Codice Cliente"  ; //  Descrizione
                       BUFFER      SPACE(6)        ; //  Get buffer
                       ALIAS       "Clienti"       ; //  File proprietario
                       FIELD       "CodCli"        ; //  Variabile
                       TYPE        "C"             ; //  Tipo
                       LEN         6               ; //  Lunghezza
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

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Inizializza oggetto ( vedere Norton Guide ) ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

oWin := Clienti->(TbBrwNew( 650                   ,; // Prima  Riga
                         0                        ,; // Prima  Colonna
                       262                        ,; // Ultima Riga
                       300                        ,; // Ultima Colonna
                      W_OBJ_FRM                             ,; // Tipo oggetto ( form )
                      NIL ,; // Label
                      W_COORDINATE_PIXEL                    )) // Gestione in Pixel

oWin:W_TITLE     := "Query Articoli"                 // Titolo oggetto
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
* #COD OIACT1 * #END Dopo inizializzazioni oggetto oWin

/*ÚÄÄÄÄÄÄÄÄÄÄ¿
  ³ Control  ³
  ÀÄÄÄÄÄÄÄÄÄÄÙ*/
ATTACH "box0006" TO oWin:W_CONTROL BOX 01          ; // ATTBOX.TMP
                 AT   60,  22, 109, 248            ; // Coordinate
                 BOXTEXT ""                        ; // BOX Text
                 COORDINATE  W_COORDINATE_PIXEL    ; // Tipo Coordinate
                 BOXTYPE   XBPSTATIC_TYPE_DEFAULT  ; // BOX Type
                 COLOR {"W+/G","B+/G","N/G"}         // Array dei colori
ATTACH "but0001" TO oWin:W_CONTROL GET AS PUSHBUTTON "O^k"  ; // ATTBUT.TMP
                 AT   20,  20,  32,  40            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||dbAct2Kbd("wri")}     ; // Funzione di controllo
                 ACTIVE   {||cState $ "im"}        ; // Stato di attivazione
                 MESSAGE "Registra e chiude"         // Messaggio utente
ATTACH "but0002" TO oWin:W_CONTROL GET AS PUSHBUTTON "A^bbandona"  ; // ATTBUT.TMP
                 AT   20, 190,  32,  80            ; // Coordinate
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR    {"W+/G","N/G","G+/G","B/G","W+/R","G+/R"}  ; // Array dei colori
                 FUNCTION {||dbAct2Kbd("esc")}     ; // Funzione di controllo
                 ACTIVE   {||cState $ "im"}        ; // Stato di attivazione
                 MESSAGE "Abbandona senza formulare la query"    // Messaggio utente
ATTACH "cGet1" TO oWin:W_CONTROL GET aQuery[1,3] AT  121, 161  ; // Campo , Top+Left
                 SIZE       {  72,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR      {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT     "da Codice Cliente:"   ; // Prompt
                 PROMPTAT    121 ,   9             ; // Coordinate prompt
                 PICTURESAY "!!!!!!"               ; // Picture in say
                 CONDITION {|ab|cGet1(ab)}         ; // Funzione When/Valid
                 COMBO                             ; // Icona combo
                 MESSAGE "Codice Cliente"            // Messaggio
ATTACH "cGet2" TO oWin:W_CONTROL GET aQuery[2,3] AT   91, 161  ; // Campo , Top+Left
                 SIZE       {  72,  22}            ; // Dimensioni Campo get
                 COORDINATE  W_COORDINATE_PIXEL    ; // Coordinate in Pixel
                 COLOR      {"N/G","G+/G","N/W*","W+/BG"}  ; // Array dei colori
                 PROMPT     "a Codice Cliente:"    ; // Prompt
                 PROMPTAT     91 ,  17             ; // Coordinate prompt
                 PICTURESAY "!!!!!!"               ; // Picture in say
                 CONDITION {|ab|cGet2(ab)}         ; // Funzione When/Valid
                 COMBO                             ; // Icona combo
                 MESSAGE "Codice Cliente"            // Messaggio


* #COD OAACT0 * #END //  Inizializzazione oggetto oWin

RETURN oWin

*******************************************************************************
FUNCTION CliQryUpw(        ;                       // [ 04 ]  UPDATE WINDOW
                    cDisGrp )                      // Gruppo di visualizzazione
*******************************************************************************
* #COD OBUPW0 * #END //  Update window oggetto oWin

tbDisItm( oWin ,cDisGrp )

* #COD OAUPW0 * #END //  Update window oggetto oWin

RETURN NIL

*******************************************************************************
FUNCTION CliQryEnd(         ;                      // [ 05 ] OPERAZIONI DI CHIUSURA
                     cClose  )                     // Modalita' chiusura oggetto "rcd"
*******************************************************************************
* #COD OBEND0 * #END //  Chiusura e rilascio oggetto oWin

oWin:=tbEnd( oWin , cClose )

* #COD OAEND0 * #END //  Chiusura e rilascio oggetto oWin

RETURN NIL

*******************************************************************************
STATIC FUNCTION cGet1( nPrePost ) // CodCli    , C,   6,   0
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
        aDbl[LK_SEEK]  := aQuery[1,3]                // Chiave di ricerca
        aDbl[LK_VAL]   := {}                       //  Dati da ereditare nel file figlio
        aDbl[LK_FIELD] := ""                       //  Nome campo relazionato
        aDbl[LK_WIN]   := NIL                      //  Nome finestra
        aDbl[LK_KEY]   := NIL                      //  Chiave finestra
        aDbl[LK_FILTER]:= {|| .T.}                 //  Filtro finestra
        aDbl[LK_BREAK] := {|| .F.}                 //  Break finestra
        aDbl[LK_TYPE]  := LT_FREE                  // Modalita'
        aDbl[LK_EDIT]  := NIL                      //  Nome quadro edit
        aDbl[LK_INS]   := NIL                      //  Abilita edit se...
        aDbl[LK_KBD]   := .T.                      //  Keyboard
        * #COD IIGSF40003 * #END

        IF ! Clienti->(dbLooK( aDbl ))
           lRet := .F.
        ELSE
           IF ! Clienti->(eof())
              aQuery[1,3] := Clienti->CodCli
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
STATIC FUNCTION cGet2( nPrePost ) // CodCli    , C,   6,   0
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
        aDbl[LK_SEEK]  := aQuery[2,3]                // Chiave di ricerca
        aDbl[LK_VAL]   := {}                       //  Dati da ereditare nel file figlio
        aDbl[LK_FIELD] := ""                       //  Nome campo relazionato
        aDbl[LK_WIN]   := NIL                      //  Nome finestra
        aDbl[LK_KEY]   := NIL                      //  Chiave finestra
        aDbl[LK_FILTER]:= {|| .T.}                 //  Filtro finestra
        aDbl[LK_BREAK] := {|| .F.}                 //  Break finestra
        aDbl[LK_TYPE]  := LT_FREE                  // Modalita'
        aDbl[LK_EDIT]  := NIL                      //  Nome quadro edit
        aDbl[LK_INS]   := NIL                      //  Abilita edit se...
        aDbl[LK_KBD]   := .T.                      //  Keyboard
        * #COD IIGSF40004 * #END

        IF ! Clienti->(dbLooK( aDbl ))
           lRet := .F.
        ELSE
           IF ! Clienti->(eof())
              aQuery[2,3] := Clienti->CodCli
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

