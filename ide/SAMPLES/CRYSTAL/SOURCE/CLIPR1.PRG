/******************************************************************************
 Progetto       : Esempio Crystal Report
 Sottoprogetto  : Esempio Crystal Report
 Programma      : C:\PROGRA~1\VISUAL~1\SAMPLES\CRYSTAL\source\cliPr1.prg
 Template       : C:\Programmi\VisualdBsee\bin\..\tmp\xbase\report.tmp
 Descrizione    : Stampa elenco Clienti
 Programmatore  :
 Data           : 12-10-04
 Ora            : 16.03.17
******************************************************************************/

#INCLUDE "common.ch"
#INCLUDE "dfReport.ch"
#INCLUDE "dfNet.ch"

* #COD OITOP0 * #END Punto di dichiarazione file INCLUDE *.ch per file sorgente
MEMVAR Act, Sa, A, EnvId, SubId, BackFun           //  Variabili di ambiente dBsee

STATIC aFile     := {}                            ,; // Array dei file aperti dall'oggetto
       aBuffer   := {}                            ,; // Array generalizzato per oggetto report
       aVRec     := {}                               // Array del record virtuale



* #COD OITOP1 * #END Punto di dichiarazione STATICHE a livello di file sorgente

      /* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         ³                 TABELLA METODI DELL'OGGETTO REPORT                             ³
         ÃÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
         ³ nø ³ mtd.           ³ Descrizione                                              ³
         ÃÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
         ³  1 ³ exe            ³ Esecutore                                                ³
         ³  2 ³ dbf            ³ Apre la base dati                                        ³
         ³  3 ³ dfCreateGVr    ³ Crea il record virtuale (static function)                ³
         ³  4 ³ repini         ³ Inizializza bande di default (static function)           ³
         ÃÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
         ³                 METODI PRESENTI SOLO SE UTILIZZATI                             ³
         ÃÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
         ³    ³ Qry                                ³ Attiva la chiamata al modulo di query³
         ³    ³ <FILE>Header/body/footer           ³ Funzioni di gestione bande del report³
         ³    ³ <FILE>Clear                        ³ Inizializza le variabili di calcolo  ³
         ³    ³ <FILE>Add                          ³ Incrementa le variabili di calcolo   ³
         ÀÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */


*******************************************************************************
FUNCTION cliPr1Exe( ;                              // [ 01 ]  ESECUTORE OPERAZIONI
                     nMode      ,;                 // nMode = PRINT_ALL     stampa tutto il report
                                 ;                 // nMode = PRINT_CURRENT Stampa il record corrente del file master
                     nUserMenu  ,;                 // Tipo menu di stampa
                                 ;                 // PM_MENU     Menu di configurazione
                                 ;                 // PM_MESSAGE  Warning di stampa
                                 ;                 // PM_NUL      Nessun avviso
                     cIdPrinter ,;                 // Identificatore di stampante
                     cIdPort    ,;                 // Nome porta di uscita
                     lQry       ,;                 // .T. = esegue la query
                     nOrder     ,;                 // Numero indice file master
                     bKey       ,;                 // Chiave di primo posizionamento file master
                     bFilter    ,;                 // Condizione di filtro sul file master
                     bBreak      )                 // Condizione di break sul file master
*******************************************************************************
* #COD OBEXE0 * #END //  esegue le operazioni elementari dell'oggetto

DEFAULT nMode TO PRINT_ALL                         // Stampa l'intero report
DEFAULT lQry  TO .T.                               // Esegue la query

PRIVATE  EnvId:="cliPr1" ,SubId:=""                // Variabili di ambiente per report

aBuffer := dfPrnCfg()                              //  Inizializzazione array statico ( vedere Norton Guide )

IF cliPr1Dbf()                                     // Apertura File
   IF EMPTY( aVRec )
      dfCreateGVR( aVRec )                         // Creazione Record Virtuale
   ENDIF

   * #COD OIEXE0 * #END Prima dell'aggiornamento di chiave, filtro e break

   WHILE .T.
      dfUpdVr( aVRec, nOrder, bKey, bFilter, bBreak )  // Aggiorna chiave, filtro e break per file master
      IF lQry
         cliPr1Qry()                               //  modulo di query
         IF Act == "esc"
            EXIT
         ENDIF
      ENDIF
      IF RepIni( nUserMenu, cIdPrinter, cIdPort )  // Inizializzazione oggetto report
         dfPrnStart( aVRec, nMode )  // Avvia la stampa per l'oggetto report
      ENDIF
      IF !lQry; EXIT; ENDIF
      aBuffer := dfPrnCfg()                        //  Reinizializzazione array statico
   END
ENDIF

dfClose( aFile, .T., .T. )                         // Chiusura file dell'oggetto ( vedere Norton Guide )

* #COD OAEXE0 * #END //  esegue le operazioni elementari dell'oggetto

RETURN .T.

*******************************************************************************
FUNCTION cliPr1Dbf()                               // [ 02 ] APERTURA DATABASE
*******************************************************************************
* #COD OBDBF0 * #END //  apertura della base dati

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³  MASTER FILE   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !dfUse( "clienti", 0 ,aFile ) ;RETU .F. ;END


* #COD OADBF0 * #END //  apertura della base dati

RETURN .T.


******************************************************************************
STATIC PROCEDURE dfCreateGVr( aVirRec )            // [ 03 ] CREAZIONE RECORD VIRTUALE
******************************************************************************
LOCAL VRloc                                        // array del record virtuale
LOCAL aFather                                      // array di supporto
LOCAL aGrp                                         // array di supporto

* #COD OBVRC0 * #END //  Creazione record virtuale


/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³ blocco file master ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

VRLoc := dfVRCreate( )
VRLoc[VR_NAME  ]    := "clienti"                    // Nome del file

VRLoc[VR_ORDER ]    := 1                            // Numero indice file principale ( SET ORDER )
VRLoc[VR_EOF_MODE]  := VR_IGNORE                    // modalit… di scansione: ignore
VRLoc[VR_EJECT ]    := .F.                          // Salto pagina dopo raggruppamento


VRLoc[VR_BODY  ]    := {||clientiBody()}            // Code Block di attivazione banda
VRLoc[VR_ROWBODY  ] := 4                            // Numero di righe banda
VRLoc[VR_BRKBODY  ] := .F.                          // Salto pagina nella banda
VRLoc[VR_EJECTBODY] := .F.                          // Salto pagina dopo banda
VRLoc[VR_BODY2HEAD] := .F.                          // Reintesta con proprio header dopo il salto pagina
VRLoc[VR_BODY2FOOT] := .F.                          // Chiudi con proprio footer prima del salto pagina



* #COD OIVRAA0013 * #END
dfVrAddFle( aVirRec, {}, VRLoc )


* #COD OAVRC0 * #END //  Creazione record virtuale

RETURN

******************************************************************************
STATIC FUNCTION RepIni( nUserMenu, cIdPrinter, cIdPort )  // [ 04 ] INIZIALIZZAZIONE BANDE DI DEFAULT
******************************************************************************
* #COD OBINI0 * #END //  Inizializzazione bande di default

LOCAL lRet := .T.                                  //  Valore di ritorno

aBuffer[ REP_NAME ]          := "Stampa elenco Clienti"  //  Intestazione report
aBuffer[ REP_VREC ]          := aVRec

// ReportManager
dfRepManReportSet(aBuffer, dfCRWPath()+"cliPr1.REP")

aBuffer[ REP_RB   ]          := {|| ReportBanner() }  //  Banner di stampa
aBuffer[ REP_EJECT_RB ]      := .F.                //  Salto pagina dopo banda
aBuffer[ REP_BANNER_FORMAT ] := .T.                //  .T. se vuole PAGEHEADER e PAGEFOOTER
aBuffer[ REP_BANNER_INPAGE ] := .T.                //  .T. se Š nel ciclo di conteggio pagine
aBuffer[ REP_POSRB ]         := 0                  //  Posizionamento banda ( 0=relativo )
aBuffer[ REP_ROWRB ]         := 26                 //  Numero di righe banda

* #COD OIINI0 * #END Dopo inizializzazione bande di default

lRet := dfPrnMenu( aBuffer, nUserMenu, cIdPrinter, cIdPort )  //  Configurazione con parametri di layout

// Elementi dell'array aBuffer che riportano le marginature
// del report configurate nella funzione dfPrnMenu().
//
// Qualora si intenda modificare una o piu' voci, si copino
// quelle interessate opportunamente scommentate nel punto
// di iniezione sottostante.
//
// aBuffer[ REP_PAGELENGHT ] := 0                  //  numero di righe per pagina
// aBuffer[ REP_MGN_TOP ]    := 0                  //  Scostamento Header di pagina
// aBuffer[ REP_MGN_BOTTOM ] := 0                  //  Scostamento Footer di pagina
// aBuffer[ REP_MGN_LEFT ]   := 0                  //  margine sinistro da aggiungere ad ogni nuova riga

* #COD OAINI0 * #END //  Inizializzazione bande di default

RETURN lRet

*******************************************************************************
STATIC PROCEDURE cliPr1Qry()                       // Modulo di query
*******************************************************************************
LOCAL aQuery   := {}                               //  Array dei dati in query

* #COD OBQRY0 * #END //  query di report

cliQryExe( aQuery )                                // Attivazione oggetto query cliQry
IF Act != "esc"

   aBuffer[REP_QRY_DES] := aQuery[QRY_OPT_DESC]    // Espressione letterale della query
   aBuffer[REP_QRY_EXP] := aQuery[QRY_OPT_FLTGET]  // Espressione di filtro

   * #COD OIQRY0 * #END Prima di assegnamento dei parametri di query

   dfUpdVr( aVRec                  ,;              //  Aggiorna su file master di stampa:
            aQuery[QRY_OPT_INDEX ] ,;              //  Indice
            aQuery[QRY_OPT_KEY   ] ,;              //  Chiave
            aQuery[QRY_OPT_FILTER] ,;              //  Filtro
            aQuery[QRY_OPT_BREAK ]  )              //  Break

ENDIF
* #COD OAQRY0 * #END //  query di report

RETURN


******************************************************************************
STATIC PROCEDURE ReportBanner()                      // Banda di banner di report
******************************************************************************
* #COD OBH00  * #END // funzione di gestione banda di report
IF .F.
   dfCRWOutput(    0,    0, "Esempio di stampa di un archivio.", "say0064","" )
ENDIF
IF .F.
   dfCRWOutput(    2,    0, "La banda BODY (visibile in fondo a queste note) e' utilizzata per generare", "say0045","" )
ENDIF
IF .F.
   dfCRWOutput(    3,    0, "un DBF temporaneo che sara' poi stampato dal motore di Crystal Report.", "say0063","" )
ENDIF
IF .F.
   dfCRWOutput(    4,    0, "Per default il report di stampa deve avere lo stesso nome del report dBsee", "say0046","" )
ENDIF
IF .F.
   dfCRWOutput(    5,    0, "(CLIPR1.RPT) e deve essere posto nella cartella contenente l'eseguibile.", "say0047","" )
ENDIF
IF .F.
   dfCRWOutput(    7,    0, "Queste note non fanno parte del DBF generato perche' hanno la caratteristica", "say0049","" )
ENDIF
IF .F.
   dfCRWOutput(    8,    0, "'STAMPA SOLO SE'= .F. altrimenti verrebbero incluse nel DBF temporaneo.", "say0050","" )
ENDIF
IF .F.
   dfCRWOutput(   10,    0, "Per disegnare il report usando Crystal Report:", "say0051","" )
ENDIF
IF .F.
   dfCRWOutput(   11,    0, "- Lanciare l'applicazione dalla cartella EXE con parametro /CRWDESIGN=C:\", "say0052","" )
ENDIF
IF .F.
   dfCRWOutput(   12,    0, "  esempio: dalla cartella C:\CRYSTAL\EXE\ lanciare MENU.EXE /CRWDESIGN=C:\", "say0053","" )
ENDIF
IF .F.
   dfCRWOutput(   13,    0, "  (il parametro /CRWDESIGN=C:\ fa si che il DBF temporaneo venga creato", "say0056","" )
ENDIF
IF .F.
   dfCRWOutput(   14,    0, "  nella cartella C:\ invece che in una cartella temporanea e che non venga", "say0057","" )
ENDIF
IF .F.
   dfCRWOutput(   15,    0, "  cancellato dopo la stampa o l'anteprima)", "say0058","" )
ENDIF
IF .F.
   dfCRWOutput(   16,    0, "- Dal menu Stampa, lanciare la stampa Elenco Clienti e scegliere 'Anteprima'", "say0055","" )
ENDIF
IF .F.
   dfCRWOutput(   17,    0, "- Lanciare Crystal Report ed usare come base dati il file C:\CLIPR1.DBF", "say0054","" )
ENDIF
IF .F.
   dfCRWOutput(   18,    0, "- Disegnare il report e salvarlo in C:\CRYSTAL\EXE\ chiamandolo con lo", "say0059","" )
ENDIF
IF .F.
   dfCRWOutput(   19,    0, "  stesso nome del report (CLIPR1.RPT)", "say0060","" )
ENDIF
IF .F.
   dfCRWOutput(   20,    0, "- Riprovare l'anteprima e verificare che il report disegnato con Crystal", "say0061","" )
ENDIF
IF .F.
   dfCRWOutput(   21,    0, "  Report sia visualizzato correttamente", "say0062","" )
ENDIF
IF .F.
   dfCRWOutput(   23,    0, "Per ulteriori informazioni consultare il come fare a... premendo CTRL-F1", "say0065","" )
ENDIF
IF .F.
   dfCRWOutput(   24,    0, "cercando il testo 'CRYSTAL' oppure leggere le istruzioni indicate nella", "say0066","" )
ENDIF
IF .F.
   dfCRWOutput(   25,    0, "sezione Report Banner del report DocPr2", "say0067","" )
ENDIF
* #COD OAH00  * #END // funzione di gestione banda di report
RETURN


******************************************************************************
STATIC PROCEDURE clientiBody()                       // Banda di body file clienti
******************************************************************************
* #COD OBBAA  * #END // funzione di gestione banda di report
dfCRWOutput(    0,    0, clienti->codcli, {"codcli","C",6,0},"CLIENTI","clienti->codcli"  )
dfCRWOutput(    0,    7, clienti->ragsoc, {"ragsoc","C",40,0},"CLIENTI","clienti->ragsoc"  )
dfCRWOutput(    0,   48, clienti->indiri, {"indiri","C",40,0},"CLIENTI","clienti->indiri"  )
dfCRWOutput(    1,    0, clienti->locali, {"locali","C",40,0},"CLIENTI","clienti->locali"  )
dfCRWOutput(    1,   41, clienti->cap, {"cap","C",5,0},"CLIENTI","clienti->cap"  )
dfCRWOutput(    1,   47, clienti->provi, {"provi","C",2,0},"CLIENTI","clienti->provi"  )
dfCRWOutput(    2,    0, clienti->numtel, {"numtel","C",30,0},"CLIENTI","clienti->numtel"  )
dfCRWOutput(    2,   31, clienti->numfax, {"numfax","C",30,0},"CLIENTI","clienti->numfax"  )
dfCRWOutput(    3,    0, clienti->email, {"email","C",50,0},"CLIENTI","clienti->email"  )
* #COD OABAA  * #END // funzione di gestione banda di report
RETURN


* #COD OIBOT1 * #END Fine file sorgente per oggetto report
