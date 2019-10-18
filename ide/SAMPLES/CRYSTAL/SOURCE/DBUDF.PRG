/******************************************************************************
 Progetto       : Esempio Crystal Report
 Sottoprogetto  : Esempio Crystal Report
 Programma      : C:\PROGRA~1\VISUAL~1\SAMPLES\CRYSTAL\source\dbUdf.prg
 Template       : C:\Programmi\VisualdBsee\bin\..\tmp\xbase\dbudf.tmp
 Descrizione    : Funzioni come simboli
 Programmatore  :
 Data           : 12-10-04
 Ora            : 16.06.24
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
#INCLUDE "dfReport.ch"                               //   "       "     "  oggetti Report
* #COD OIUDF0 * #END  Inizio file dbUdf - Punto per dichiarazione INCLUDE e STATIC GLOBALI




PROCEDURE dbeSys()

  /*
   *   Adaption of Sorting order to hosting environment
   */

  SET COLLATION TO ASCII

  /*
   *   The database engines DBFDBE and NTXDBE are loaded "hidden"
   *   and are combined to the abstract database engine DBFNTX
   */
* #COD OIUDF1 * #END  Start RddInit

                                                   // Predispone il link per gli RDD utilizzati

IF ! dfDBESet()

   dfDBFNTX()

ENDIF

DbeSetDefault( "DBFNTX" )                          //  Set up default driver

* #COD OIUDF3 * #END  End RddInit
RETURN

*******************************************************************************
FUNCTION AppSys()
*******************************************************************************
RETURN dbSeeAppSys()

******************************************************************************
EXIT PROCEDURE ExitMenu()
******************************************************************************
* #COD OIUDF2 * #END  Ad inizio funzione ExitMenu()
CLOSE DATA                                         // Chiusura di tutti i file aperti
RETURN



*******************************************************************************
PROCEDURE df2Quit()                                // Chiusura programma
*******************************************************************************
#ifdef __XPP__
S2RealTimeDelAll()
#else
SET COLOR TO                                       // Settaggio colori standard
M_CurOff()                                         // Disattivazione cursore
CLS                                                // Pulizia video
M_CurOn()                                          // Abilitazione cursore
#endif
QUIT
RETURN


* #COD OIEUF1 * #END  End User Function - At the end of dbUdf.prg

