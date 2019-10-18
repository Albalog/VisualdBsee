/******************************************************************************
 Progetto       : Tutorial
 Sottoprogetto  : Tutorial
 Programma      : V:\SAMPLES\TUTORIAL\source\CliRpt1.prg
 Template       : V:\bin\..\tmp\xbase\report.tmp
 Descrizione    : Report Clienti (Crystal Report)
 Programmatore  : Demo
 Data           : 13-07-06
 Ora            : 16.44.00
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
FUNCTION CliRpt1Exe( ;                             // [ 01 ]  ESECUTORE OPERAZIONI
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
DEFAULT lQry  TO nMode==PRINT_ALL                  // Esegue la query

PRIVATE  EnvId:="CliRpt1" ,SubId:=""               // Variabili di ambiente per report

aBuffer := dfPrnCfg()                              //  Inizializzazione array statico ( vedere Norton Guide )

IF CliRpt1Dbf()                                    // Apertura File
   IF EMPTY( aVRec )
      dfCreateGVR( aVRec )                         // Creazione Record Virtuale
   ENDIF

   * #COD OIEXE0 * #END Prima dell'aggiornamento di chiave, filtro e break

   WHILE .T.
      dfUpdVr( aVRec, nOrder, bKey, bFilter, bBreak )  // Aggiorna chiave, filtro e break per file master
      IF lQry
         CliRpt1Qry()                              //  modulo di query
         IF Act == "esc"
            EXIT
         ENDIF
      ENDIF
      IF RepIni( nUserMenu, cIdPrinter, cIdPort )  // Inizializzazione oggetto report
         * #COD OBEXE1 * #END //                               - // Before Printing
         dfPrnStart( aVRec, nMode )  // Avvia la stampa per l'oggetto report
         * #COD OAEXE1 * #END //                               - // Before Printing
      ELSE
         * #COD OIEXE2 * #END
      ENDIF
      IF !lQry; EXIT; ENDIF
      aBuffer := dfPrnCfg()                        //  Reinizializzazione array statico
   END
ENDIF

dfClose( aFile, .T., .T. )                         // Chiusura file dell'oggetto ( vedere Norton Guide )

* #COD OAEXE0 * #END //  esegue le operazioni elementari dell'oggetto

RETURN .T.

*******************************************************************************
FUNCTION CliRpt1Dbf()                              // [ 02 ] APERTURA DATABASE
*******************************************************************************
* #COD OBDBF0 * #END //  apertura della base dati

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³  MASTER FILE   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !dfUse( "Clienti", 1 ,aFile ) ;RETU .F. ;END


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
VRLoc[VR_NAME  ]    := "Clienti"                    // Nome del file

VRLoc[VR_ORDER ]    := 1                            // Numero indice file principale ( SET ORDER )
VRLoc[VR_EOF_MODE]  := VR_IGNORE                    // modalit… di scansione: ignore
VRLoc[VR_EJECT ]    := .F.                          // Salto pagina dopo raggruppamento


VRLoc[VR_BODY  ]    := {||ClientiBody()}            // Code Block di attivazione banda
VRLoc[VR_ROWBODY  ] := 1                            // Numero di righe banda
VRLoc[VR_BRKBODY  ] := .F.                          // Salto pagina nella banda
VRLoc[VR_EJECTBODY] := .F.                          // Salto pagina dopo banda
VRLoc[VR_BODY2HEAD] := .F.                          // Reintesta con proprio header dopo il salto pagina
VRLoc[VR_BODY2FOOT] := .F.                          // Chiudi con proprio footer prima del salto pagina



* #COD OIVRAA0020 * #END
dfVrAddFle( aVirRec, {}, VRLoc )


* #COD OAVRC0 * #END //  Creazione record virtuale

RETURN

******************************************************************************
STATIC FUNCTION RepIni( nUserMenu, cIdPrinter, cIdPort )  // [ 04 ] INIZIALIZZAZIONE BANDE DI DEFAULT
******************************************************************************
* #COD OBINI0 * #END //  Inizializzazione bande di default

LOCAL lRet := .T.                                  //  Valore di ritorno

aBuffer[ REP_NAME ]          := "Report Clienti (Crystal Report)"  //  Intestazione report
aBuffer[ REP_VREC ]          := aVRec

// Crystal Reports
dfCRWReportSet(aBuffer, dfCRWPath()+"CliRpt1.RPT")


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
STATIC PROCEDURE CliRpt1Qry()                      // Modulo di query
*******************************************************************************
LOCAL aQuery   := {}                               //  Array dei dati in query

* #COD OBQRY0 * #END //  query di report

CliQryExe( aQuery )                                // Attivazione oggetto query CliQry
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
STATIC PROCEDURE ClientiBody()                       // Banda di body file Clienti
******************************************************************************
* #COD OBBAA  * #END // funzione di gestione banda di report
dfReportOutPut(    0,    1, Clienti->CodCli, {"CodCli","C",6,0},"CLIENTI","Clienti->CodCli"  )
dfReportOutPut(    0,    2, Clienti->IndCli, {"IndCli","C",30,0},"CLIENTI","Clienti->IndCli"  )
dfReportOutPut(    0,    3, Clienti->CapCli, {"CapCli","C",5,0},"CLIENTI","Clienti->CapCli"  )
dfReportOutPut(    0,    4, Clienti->CitCli, {"CitCli","C",13,0},"CLIENTI","Clienti->CitCli"  )
dfReportOutPut(    0,    5, Clienti->PrvCli, {"PrvCli","C",2,0},"CLIENTI","Clienti->PrvCli"  )
dfReportOutPut(    0,    6, dftime(), {"exp0006", "C",10,0 },"CLIENTI" )
dfReportOutPut(    0,    7, Clienti->RagCli, {"RagCli","C",30,0},"CLIENTI","Clienti->RagCli"  )
* #COD OABAA  * #END // funzione di gestione banda di report
RETURN


* #COD OIBOT1 * #END Fine file sorgente per oggetto report
