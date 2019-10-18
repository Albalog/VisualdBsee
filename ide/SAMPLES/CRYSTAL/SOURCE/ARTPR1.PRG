/******************************************************************************
 Progetto       : Esempio Crystal Report
 Sottoprogetto  : Esempio Crystal Report
 Programma      : C:\PROGRA~1\VISUAL~1\SAMPLES\CRYSTAL\source\artPr1.prg
 Template       : C:\Programmi\VisualdBsee\bin\..\tmp\xbase\report.tmp
 Descrizione    : Stampa Articoli Standard
 Programmatore  :
 Data           : 12-10-04
 Ora            : 16.03.15
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
FUNCTION artPr1Exe( ;                              // [ 01 ]  ESECUTORE OPERAZIONI
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

PRIVATE  EnvId:="artPr1" ,SubId:=""                // Variabili di ambiente per report

aBuffer := dfPrnCfg()                              //  Inizializzazione array statico ( vedere Norton Guide )

IF artPr1Dbf()                                     // Apertura File
   IF EMPTY( aVRec )
      dfCreateGVR( aVRec )                         // Creazione Record Virtuale
   ENDIF

   * #COD OIEXE0 * #END Prima dell'aggiornamento di chiave, filtro e break

   dfUpdVr( aVRec, nOrder, bKey, bFilter, bBreak )  // Aggiorna chiave, filtro e break per file master
   IF RepIni( nUserMenu, cIdPrinter, cIdPort )     // Inizializzazione Report
      dfPrnStart( aVRec, nMode )                   // Avvia la stampa per l'oggetto report
   ENDIF
ENDIF

dfClose( aFile, .T., .T. )                         // Chiusura file dell'oggetto ( vedere Norton Guide )

* #COD OAEXE0 * #END //  esegue le operazioni elementari dell'oggetto

RETURN .T.

*******************************************************************************
FUNCTION artPr1Dbf()                               // [ 02 ] APERTURA DATABASE
*******************************************************************************
* #COD OBDBF0 * #END //  apertura della base dati

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³  MASTER FILE   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !dfUse( "articol", 1 ,aFile ) ;RETU .F. ;END


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
VRLoc[VR_NAME  ]    := "articol"                    // Nome del file

VRLoc[VR_ORDER ]    := 1                            // Numero indice file principale ( SET ORDER )
VRLoc[VR_EOF_MODE]  := VR_IGNORE                    // modalit… di scansione: ignore
VRLoc[VR_EJECT ]    := .F.                          // Salto pagina dopo raggruppamento

VRLoc[VR_HEADER]    := {||articolHeader()}          // Code Block di attivazione banda
VRLoc[VR_POSHEADER] := 0                            // Posizionamento banda ( 0=relativo )
VRLoc[VR_ROWHEADER] := 5                            // Numero di righe banda
VRLoc[VR_BRKHEADER] := .T.                          // Salto pagina nella banda

VRLoc[VR_BODY  ]    := {||articolBody()}            // Code Block di attivazione banda
VRLoc[VR_ROWBODY  ] := 5                            // Numero di righe banda
VRLoc[VR_BRKBODY  ] := .F.                          // Salto pagina nella banda
VRLoc[VR_EJECTBODY] := .F.                          // Salto pagina dopo banda
VRLoc[VR_BODY2HEAD] := .F.                          // Reintesta con proprio header dopo il salto pagina
VRLoc[VR_BODY2FOOT] := .F.                          // Chiudi con proprio footer prima del salto pagina



* #COD OIVRAA0015 * #END
dfVrAddFle( aVirRec, {}, VRLoc )


* #COD OAVRC0 * #END //  Creazione record virtuale

RETURN

******************************************************************************
STATIC FUNCTION RepIni( nUserMenu, cIdPrinter, cIdPort )  // [ 04 ] INIZIALIZZAZIONE BANDE DI DEFAULT
******************************************************************************
* #COD OBINI0 * #END //  Inizializzazione bande di default

LOCAL lRet := .T.                                  //  Valore di ritorno

aBuffer[ REP_NAME ]          := "Stampa Articoli Standard"  //  Intestazione report
aBuffer[ REP_VREC ]          := aVRec

aBuffer[ REP_RB   ]          := {|| ReportBanner() }  //  Banner di stampa
aBuffer[ REP_EJECT_RB ]      := .F.                //  Salto pagina dopo banda
aBuffer[ REP_BANNER_FORMAT ] := .T.                //  .T. se vuole PAGEHEADER e PAGEFOOTER
aBuffer[ REP_BANNER_INPAGE ] := .T.                //  .T. se Š nel ciclo di conteggio pagine
aBuffer[ REP_POSRB ]         := 0                  //  Posizionamento banda ( 0=relativo )
aBuffer[ REP_ROWRB ]         := 5                  //  Numero di righe banda

aBuffer[ REP_PH ]            := {|| PageHeader()   }  //  Header di pagina
aBuffer[ REP_ROWPH ]         := 3                  //  Numero di righe banda

aBuffer[ REP_RF ]            := {|| ReportFooter() }  //  Footer di stampa
aBuffer[ REP_POSRF ]         := 0                  //  Posizionamento banda ( 0=relativo )

aBuffer[ REP_PF ]            := {|| PageFooter() }  //  Footer di pagina

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



******************************************************************************
STATIC PROCEDURE ReportBanner()                      // Banda di banner di report
******************************************************************************
* #COD OBH00  * #END // funzione di gestione banda di report
dfPrint(    1,    3, "Stampa Articoli Standard",, PRN_NORMAL )
dfPrint(    2,    3, "eventuale condizione di filtro di query:",, PRN_NORMAL )
dfPrint(    3,    3, dfPrnFltDes(), "", PRN_NORMAL, .T.,60, , , ,  )
* #COD OAH00  * #END // funzione di gestione banda di report
RETURN

******************************************************************************
STATIC PROCEDURE ReportFooter()                      // Banda di footer di report
******************************************************************************
* #COD OBF00  * #END // funzione di gestione banda di report
dfPrint(    0,    0, "Fine Report",, PRN_NORMAL )
dfPrint(    0,   14, "Stampa Articoli Standard",, PRN_NORMAL )
* #COD OAF00  * #END // funzione di gestione banda di report
RETURN

******************************************************************************
STATIC PROCEDURE PageHeader()                        // Banda di header di pagina
******************************************************************************
* #COD OBS00  * #END // funzione di gestione banda di report
dfPrint(    0,    2, "Nr. pagina",, PRN_NORMAL )
dfPrint(    0,   15, dfPrnPage(), "9999", PRN_NORMAL )
dfPrint(    0,   60, "Data :",, PRN_NORMAL )
dfPrint(    0,   70, date(), "99/99/99", PRN_NORMAL )
dfPrint(    1,    0, repli("Ä", 81),, PRN_NORMAL )
* #COD OAS00  * #END // funzione di gestione banda di report
RETURN

******************************************************************************
STATIC PROCEDURE PageFooter()                        // Banda di footer di pagina
******************************************************************************
* #COD OBP00  * #END // funzione di gestione banda di report
dfPrint(    0,   10, "Fine Pagina",, PRN_NORMAL )
* #COD OAP00  * #END // funzione di gestione banda di report
RETURN


******************************************************************************
STATIC PROCEDURE articolHeader()                     // Banda di header file articol
******************************************************************************
* #COD OBHAA  * #END // funzione di gestione banda di report
dfPrint(    2,    0, "Cod.",, PRN_NORMAL )
dfPrint(    2,   10, "Descr.",, PRN_NORMAL )
dfPrint(    2,   52, "Immagine",, PRN_NORMAL )
dfPrint(    3,    0, "articolo",, PRN_NORMAL )
dfPrint(    3,   10, "articolo",, PRN_NORMAL )
dfPrint(    4,    0, repli("Ä", 80),, PRN_NORMAL )
* #COD OAHAA  * #END // funzione di gestione banda di report
RETURN


******************************************************************************
STATIC PROCEDURE articolBody()                       // Banda di body file articol
******************************************************************************
* #COD OBBAA  * #END // funzione di gestione banda di report
dfPrint(    0,    0, articol->codart, "!!!!!!", PRN_NORMAL )
dfPrint(    0,   10, articol->dexart, "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", PRN_NORMAL )
dfPrintImage(    0,   52, articol->image, 2, 2 )
* #COD OABAA  * #END // funzione di gestione banda di report
RETURN


* #COD OIBOT1 * #END Fine file sorgente per oggetto report
