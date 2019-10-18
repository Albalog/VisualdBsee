/******************************************************************************
 Progetto       : Esempio Crystal Report
 Sottoprogetto  : Esempio Crystal Report
 Programma      : C:\PROGRA~1\VISUAL~1\SAMPLES\CRYSTAL\source\docPr2.prg
 Template       : C:\Programmi\VisualdBsee\bin\..\tmp\xbase\report.tmp
 Descrizione    : Stampa
 Programmatore  :
 Data           : 12-10-04
 Ora            : 16.03.24
******************************************************************************/

#INCLUDE "common.ch"
#INCLUDE "dfReport.ch"
#INCLUDE "dfNet.ch"

* #COD OITOP0 * #END Punto di dichiarazione file INCLUDE *.ch per file sorgente
MEMVAR Act, Sa, A, EnvId, SubId, BackFun           //  Variabili di ambiente dBsee

STATIC aFile     := {}                            ,; // Array dei file aperti dall'oggetto
       aBuffer   := {}                            ,; // Array generalizzato per oggetto report
       aVRec     := {}                               // Array del record virtuale


/*
  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ dichiarazione variabili di calcolo ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

STATIC qtamov                                      //  Somma

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
FUNCTION docPr2Exe( ;                              // [ 01 ]  ESECUTORE OPERAZIONI
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

PRIVATE  EnvId:="docPr2" ,SubId:=""                // Variabili di ambiente per report

aBuffer := dfPrnCfg()                              //  Inizializzazione array statico ( vedere Norton Guide )

IF docPr2Dbf()                                     // Apertura File
   IF EMPTY( aVRec )
      dfCreateGVR( aVRec )                         // Creazione Record Virtuale
   ENDIF

   * #COD OIEXE0 * #END Prima dell'aggiornamento di chiave, filtro e break

   WHILE .T.
      dfUpdVr( aVRec, nOrder, bKey, bFilter, bBreak )  // Aggiorna chiave, filtro e break per file master
      IF lQry
         docPr2Qry()                               //  modulo di query
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
FUNCTION docPr2Dbf()                               // [ 02 ] APERTURA DATABASE
*******************************************************************************
* #COD OBDBF0 * #END //  apertura della base dati

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³  MASTER FILE   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !dfUse( "docven", 1 ,aFile ) ;RETU .F. ;END

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³  RELATION FILE ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !dfUse( "docvend", 1 ,aFile ) ;RETU .F. ;END
IF !dfUse( "clienti", 1 ,aFile ) ;RETU .F. ;END
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
VRLoc[VR_NAME  ]    := "docven"                     // Nome del file

VRLoc[VR_ORDER ]    := 1                            // Numero indice file principale ( SET ORDER )
VRLoc[VR_EOF_MODE]  := VR_IGNORE                    // modalit… di scansione: ignore
VRLoc[VR_EJECT ]    := .F.                          // Salto pagina dopo raggruppamento





* #COD OIVRAA0019 * #END
dfVrAddFle( aVirRec, {}, VRLoc )


/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³ blocco file relazionato ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
VRLoc := dfVRCreate( )
VRLoc[VR_NAME  ]    := "docvend"                    // Nome del file

VRLoc[VR_KEY   ]    := {||str(docven->numdoc, 6, 0)}   // chiave
VRLoc[VR_FILTER]    := {||.T.}                      // filtro
VRLoc[VR_BREAK ]    := {||str(docvend->numdoc, 6, 0)!=str(docven->numdoc, 6, 0)}   // break di relazione
VRLoc[VR_EOF_MODE]  := VR_IGNORE                    // modalit… di scansione: ignore
VRLoc[VR_EJECT ]    := .T.                          // Salto pagina dopo raggruppamento


VRLoc[VR_BODY  ]    := {||docvendBody()}            // Code Block di attivazione banda
VRLoc[VR_ROWBODY  ] := 10                           // Numero di righe banda
VRLoc[VR_BRKBODY  ] := .F.                          // Salto pagina nella banda
VRLoc[VR_EJECTBODY] := .F.                          // Salto pagina dopo banda
VRLoc[VR_BODY2HEAD] := .F.                          // Reintesta con proprio header dopo il salto pagina
VRLoc[VR_BODY2FOOT] := .F.                          // Chiudi con proprio footer prima del salto pagina


VRLoc[VR_CALC_CLEAR]    := {||docvendClear( PRN_FILE_LEVEL, PRN_CALC )}  // funzione di azzeramento calcoli
VRLoc[VR_CALC_ADD]      := {||docvendAdd  ( PRN_FILE_LEVEL, PRN_CALC )}  // funzione di totalizzazione calcoli
aFather := {}
aAdd( aFather , "docven" )
* #COD OIVRBA0019 * #END
dfVrAddFle( aVirRec, aFather, VRLoc )

* #COD OAVRC0 * #END //  Creazione record virtuale

RETURN

******************************************************************************
STATIC FUNCTION RepIni( nUserMenu, cIdPrinter, cIdPort )  // [ 04 ] INIZIALIZZAZIONE BANDE DI DEFAULT
******************************************************************************
* #COD OBINI0 * #END //  Inizializzazione bande di default

LOCAL lRet := .T.                                  //  Valore di ritorno

aBuffer[ REP_NAME ]          := "Stampa"           //  Intestazione report
aBuffer[ REP_VREC ]          := aVRec

// Crystal Reports
dfCRWReportSet(aBuffer, dfCRWPath()+"docPr2.RPT")

aBuffer[ REP_RB   ]          := {|| ReportBanner() }  //  Banner di stampa
aBuffer[ REP_EJECT_RB ]      := .F.                //  Salto pagina dopo banda
aBuffer[ REP_BANNER_FORMAT ] := .T.                //  .T. se vuole PAGEHEADER e PAGEFOOTER
aBuffer[ REP_BANNER_INPAGE ] := .T.                //  .T. se Š nel ciclo di conteggio pagine
aBuffer[ REP_POSRB ]         := 0                  //  Posizionamento banda ( 0=relativo )
aBuffer[ REP_ROWRB ]         := 17                 //  Numero di righe banda

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
STATIC PROCEDURE docPr2Qry()                       // Modulo di query
*******************************************************************************
LOCAL aQuery   := {}                               //  Array dei dati in query

* #COD OBQRY0 * #END //  query di report

docQryExe( aQuery )                                // Attivazione oggetto query docQry
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
   dfCRWOutput(    0,    0, "Esempio di stampa di archivi tipo testata/dettaglio.", "say0023","" )
ENDIF
IF .F.
   dfCRWOutput(    2,    0, "Per stampare archivi in relazione 1:N e' necessario attivare solamente", "say0024","" )
ENDIF
IF .F.
   dfCRWOutput(    3,    0, "la banda di BODY sull'archivio di dettaglio e in questa banda includere", "say0025","" )
ENDIF
IF .F.
   dfCRWOutput(    4,    0, "i campi di testata e di dettaglio, oltre ai campi degli archivi in", "say0026","" )
ENDIF
IF .F.
   dfCRWOutput(    5,    0, "relazione di lookup (come ad esempio la ragione sociale del cliente e", "say0027","" )
ENDIF
IF .F.
   dfCRWOutput(    6,    0, "la descrizione degli articoli).", "say0028","" )
ENDIF
IF .F.
   dfCRWOutput(    7,    0, "In questa banda e' NECESSARIO includere almeno i campi che compongono la", "say0030","" )
ENDIF
IF .F.
   dfCRWOutput(    8,    0, "chiave dell'archivio di testata (in questo caso il solo campo NUMDOC)", "say0031","" )
ENDIF
IF .F.
   dfCRWOutput(   10,    0, "In Crystal Report il report deve essere disegnato aggiungendo un gruppo", "say0029","" )
ENDIF
IF .F.
   dfCRWOutput(   11,    0, "sul campo chiave (NUMDOC) e nelle sezioni di Intestazione di Gruppo e/o", "say0032","" )
ENDIF
IF .F.
   dfCRWOutput(   12,    0, "di footer di Gruppo vanno messi i campi appartenti all'archivio di testata.", "say0033","" )
ENDIF
IF .F.
   dfCRWOutput(   14,    0, "Per ulteriori informazioni consultare il come fare a... premendo CTRL-F1", "say0034","" )
ENDIF
IF .F.
   dfCRWOutput(   15,    0, "cercando il testo 'CRYSTAL' oppure leggere le istruzioni indicate nella", "say0036","" )
ENDIF
IF .F.
   dfCRWOutput(   16,    0, "sezione Report Banner del report CliPr1", "say0035","" )
ENDIF
* #COD OAH00  * #END // funzione di gestione banda di report
RETURN


******************************************************************************
STATIC PROCEDURE docvendBody()                       // Banda di body file docvend
******************************************************************************
* #COD OBBBA  * #END // funzione di gestione banda di report
dfCRWOutput(    0,    0, docven->numdoc, {"numdoc","N",6,0},"DOCVEND","docven->numdoc"  )
dfCRWOutput(    0,    8, docven->datdoc, {"datdoc","D",8,0},"DOCVEND","docven->datdoc"  )
dfCRWOutput(    0,   17, docven->codcli, {"codcli","C",6,0},"DOCVEND","docven->codcli"  )
dfCRWOutput(    0,   24, docven->totdoc, {"totdoc","N",10,2},"DOCVEND","docven->totdoc"  )
clienti->(dfS(1, docven->codcli))
dfCRWOutput(    1,   17, clienti->ragsoc, {"ragsoc","C",40,0},"DOCVEND","clienti->ragsoc"  )
clienti->(dfS(1, docven->codcli))
dfCRWOutput(    2,   17, clienti->indiri, {"indiri","C",40,0},"DOCVEND","clienti->indiri"  )
clienti->(dfS(1, docven->codcli))
dfCRWOutput(    3,   17, clienti->locali, {"locali","C",40,0},"DOCVEND","clienti->locali"  )
clienti->(dfS(1, docven->codcli))
dfCRWOutput(    3,   58, clienti->cap, {"cap","C",5,0},"DOCVEND","clienti->cap"  )
clienti->(dfS(1, docven->codcli))
dfCRWOutput(    3,   64, clienti->provi, {"provi","C",2,0},"DOCVEND","clienti->provi"  )
clienti->(dfS(1, docven->codcli))
dfCRWOutput(    4,   17, clienti->numtel, {"numtel","C",30,0},"DOCVEND","clienti->numtel"  )
clienti->(dfS(1, docven->codcli))
dfCRWOutput(    4,   48, clienti->numfax, {"numfax","C",30,0},"DOCVEND","clienti->numfax"  )
clienti->(dfS(1, docven->codcli))
dfCRWOutput(    5,   17, clienti->email, {"email","C",50,0},"DOCVEND","clienti->email"  )
dfCRWOutput(    7,    5, docvend->numrig, {"numrig","N",4,0},"DOCVEND","docvend->numrig"  )
dfCRWOutput(    7,   11, docvend->codart, {"codart","C",6,0},"DOCVEND","docvend->codart"  )
dfCRWOutput(    7,   18, docvend->qtamov, {"qtamov","N",9,2},"DOCVEND","docvend->qtamov"  )
dfCRWOutput(    7,   29, docvend->valuni, {"valuni","N",8,2},"DOCVEND","docvend->valuni"  )
dfCRWOutput(    7,   39, docvend->totrig, {"totrig","N",10,2},"DOCVEND","docvend->totrig"  )
articol->(dfS(1, docvend->codart))
dfCRWOutput(    7,   52, articol->dexart, {"dexart","C",40,0},"DOCVEND","articol->dexart"  )
dfCRWOutput(    8,   29, round(docvend->valuni*docvend->qtamov*20/100,2), {"impIVA", "N",10,0 },"DOCVEND" )
dfCRWOutput(    8,   52, qtamov, {"prcQtaMov","9999999.99"},"DOCVEND",""  )
* #COD OABBA  * #END // funzione di gestione banda di report
RETURN

******************************************************************************
STATIC PROCEDURE docvendClear( nGroupLev, lIsPre )    // Azzera variabili di calcolo
                                                     // file docvend
******************************************************************************
* #COD OBCLBA * #END //  Azzera variabili di calcolo
IF lIsPre
   IF nGroupLev == PRN_FILE_LEVEL                  // File docvend
   ENDIF
ELSE
   IF nGroupLev == PRN_FILE_LEVEL                  // File docvend
      qtamov     := 0
   ENDIF
ENDIF
* #COD OACLBA * #END //  Azzera variabili di calcolo
RETURN

******************************************************************************
STATIC PROCEDURE docvendAdd( nGroupLev, lIsPre )     //  Incrementa variabili di calcolo
                                                     //  file docvend
******************************************************************************
* #COD OBADBA * #END //  Incrementa variabili di calcolo
IF lIsPre
   IF nGroupLev == PRN_FILE_LEVEL                  // File docvend
   ENDIF
ELSE
   // Somma
   qtamov     += (docvend->qtamov)

ENDIF
* #COD OAADBA * #END //  Incrementa variabili di calcolo
RETURN


* #COD OIBOT1 * #END Fine file sorgente per oggetto report
