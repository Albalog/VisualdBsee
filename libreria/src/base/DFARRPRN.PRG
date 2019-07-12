//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per STAMPE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
#include "dfStd.ch"
#include "dfreport.ch"
#include "dfWinRep.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfArrPrn( lReload ) // Array delle stampanti
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC aPrn := NIL
LOCAL nPrinter, aPrinterList
LOCAL lIniMsg 

#ifdef __XPP__

// Simone 9/giu/03 gerr3819
// perche In ambiente CITRIX le stampanti non sono visibili immediatamente 
// ma vengono rese disponibili dopo un tot di secondi
DEFAULT lReload TO ReloadPrn()
#else
DEFAULT lReload TO .F.
#endif
IF aPrn==NIL .OR. lReload

   // Reopen the INI
   IF lReload .AND. ! dfIsIni()               
      dfIniOpen()
      lIniMsg := dfSet( AI_INIMESSAGE, .F. ) // disabilito messaggi
   ENDIF

   aPrn := NIL
   IF dfIsIni()           // Ho l'INI aperto
      aPrn := dfIniPrn()     // Lo leggo
   ENDIF

   // Close the INI
   IF lIniMsg != NIL
      IF dfIsIni()
         dfIniClose()
      ENDIF
      dfSet( AI_INIMESSAGE, lIniMsg)
   ENDIF

   #ifndef __XPP__
      IF EMPTY aPrn ASSIGN dfIntPrn() // Prendo i valori interni
   #else
      // Non prendo i default, ma solo le stampanti installate
      IF EMPTY aPrn ASSIGN {} // Prendo i valori interni

      nPrinter     := 1
      aPrinterList := dfWinPrinters()

      // Simone 11/11/05 GERR 4544
      // per gestione stampante default con codice W0
      IF LEN(aPrinterList) > 0 .AND. ;
         dfSet("XbaseAddDefaultPrinter") == "YES" .AND. ;
         ! EMPTY(dfWinPrinterDefault())

         AADD( aPrn, { "W0"                        ,; // PRINTER_ID
                       dfWinPrinterDefault()       ,; // PRINTER_INFO
                       DFWINREP_SETUP              ,; // PRINTER_SETUP
                       DFWINREP_RESET              ,; // PRINTER_RESET
                       DFWINREP_BOLDON             ,; // PRINTER_BOLDON
                       DFWINREP_BOLDOFF            ,; // PRINTER_BOLDOFF
                       DFWINREP_ENLARGEDON         ,; // PRINTER_ENLARGEDON
                       DFWINREP_ENLARGEDOFF        ,; // PRINTER_ENLARGEDOFF
                       DFWINREP_UNDERLINEON        ,; // PRINTER_UNDERLINEON
                       DFWINREP_UNDERLINEOFF       ,; // PRINTER_UNDERLINEOFF
                       DFWINREP_SUPERSCRIPTON      ,; // PRINTER_SUPERSCRIPTON
                       DFWINREP_SUPERSCRIPTOFF     ,; // PRINTER_SUPERSCRIPTOFF
                       DFWINREP_SUBSCRIPTON        ,; // PRINTER_SUBSCRIPTON
                       DFWINREP_SUBSCRIPTOFF       ,; // PRINTER_SUBSCRIPTOFF
                       DFWINREP_CONDENSEDON        ,; // PRINTER_CONDENSEDON
                       DFWINREP_CONDENSEDOFF       ,; // PRINTER_CONDENSEDOFF
                       DFWINREP_ITALICON           ,; // PRINTER_ITALICON
                       DFWINREP_ITALICOFF          ,; // PRINTER_ITALICOFF
                       DFWINREP_NLQON              ,; // PRINTER_NLQON
                       DFWINREP_NLQOFF             ,; // PRINTER_NLQOFF
                       DFWINREP_USER01ON           ,; // PRINTER_USER01ON
                       DFWINREP_USER01OFF          ,; // PRINTER_USER01OFF
                       DFWINREP_USER02ON           ,; // PRINTER_USER02ON
                       DFWINREP_USER02OFF          ,; // PRINTER_USER02OFF
                       DFWINREP_USER03ON           ,; // PRINTER_USER03ON
                       DFWINREP_USER03OFF          ,; // PRINTER_USER03OFF
                       DFWINREP_PAGELENGHT         }) // PRINTER_PAGELENGHT

         // se ho solo 1 stampante allora non aggiungo le altre
         // per evitare il brutto effetto di avere 2 volte la stessa stampante
         IF LEN(aPrinterList) == 1
            nPrinter := 100 // non entro nel do while
         ENDIF
      ENDIF

      WHILE nPrinter<=LEN(aPrinterList)
         AADD( aPrn, { "W"+ALLTRIM(STR(nPrinter))  ,; // PRINTER_ID
                       aPrinterList[nPrinter]      ,; // PRINTER_INFO
                       DFWINREP_SETUP              ,; // PRINTER_SETUP
                       DFWINREP_RESET              ,; // PRINTER_RESET
                       DFWINREP_BOLDON             ,; // PRINTER_BOLDON
                       DFWINREP_BOLDOFF            ,; // PRINTER_BOLDOFF
                       DFWINREP_ENLARGEDON         ,; // PRINTER_ENLARGEDON
                       DFWINREP_ENLARGEDOFF        ,; // PRINTER_ENLARGEDOFF
                       DFWINREP_UNDERLINEON        ,; // PRINTER_UNDERLINEON
                       DFWINREP_UNDERLINEOFF       ,; // PRINTER_UNDERLINEOFF
                       DFWINREP_SUPERSCRIPTON      ,; // PRINTER_SUPERSCRIPTON
                       DFWINREP_SUPERSCRIPTOFF     ,; // PRINTER_SUPERSCRIPTOFF
                       DFWINREP_SUBSCRIPTON        ,; // PRINTER_SUBSCRIPTON
                       DFWINREP_SUBSCRIPTOFF       ,; // PRINTER_SUBSCRIPTOFF
                       DFWINREP_CONDENSEDON        ,; // PRINTER_CONDENSEDON
                       DFWINREP_CONDENSEDOFF       ,; // PRINTER_CONDENSEDOFF
                       DFWINREP_ITALICON           ,; // PRINTER_ITALICON
                       DFWINREP_ITALICOFF          ,; // PRINTER_ITALICOFF
                       DFWINREP_NLQON              ,; // PRINTER_NLQON
                       DFWINREP_NLQOFF             ,; // PRINTER_NLQOFF
                       DFWINREP_USER01ON           ,; // PRINTER_USER01ON
                       DFWINREP_USER01OFF          ,; // PRINTER_USER01OFF
                       DFWINREP_USER02ON           ,; // PRINTER_USER02ON
                       DFWINREP_USER02OFF          ,; // PRINTER_USER02OFF
                       DFWINREP_USER03ON           ,; // PRINTER_USER03ON
                       DFWINREP_USER03OFF          ,; // PRINTER_USER03OFF
                       DFWINREP_PAGELENGHT         }) // PRINTER_PAGELENGHT
         nPrinter++
      ENDDO
   #endif

   IF LEN(aPrn) == 0
      AADD( aPrn, ARRAY(PRINTER_LEN) )
      AEVAL( aPrn[1], {|cSub,nPos|IF(cSub==NIL,aPrn[1][nPos]:="",)} )
   ENDIF
ENDIF
RETURN aPrn

#ifdef __XPP__
// Controlla il settaggio XbasePrinterReload
// che pu• assumere i valori
//  0     = non caricare mai le stampanti (default)
// -1     = carica sempre le stampanti
// nn     = carica le stampanti se chiamato entro
//          i primi nn secondi dall'avvio appl.
//
// sarebbe utile implementare anche..
// nn.xx  = carica le stampanti se chiamato entro
//          i primi nn secondi dall'avvio appl.
//          e se sono passati pi— di xx secondi
//          dall'ultima volta

STATIC FUNCTION ReloadPrn()
   LOCAL nSec
   STATIC nReload := NIL
   STATIC nTimeEnd:= NIL
   //STATIC nEvery  := NIL
   //STATIC nLast   := NIL

   IF nReload == NIL
      nReload := dfSet("XbasePrinterReload")
      nReload := IIF(nReload == NIL, 0, VAL(nReload))
      //nEvery := (nReload - INT(nReload)) 
   ENDIF

   IF nReload == 0
      RETURN .F.     //  0 NON CARICARE le stampanti
   ENDIF

   IF nReload < 0    // -1 CARICA SEMPRE LE STAMPANTI
      RETURN .T.
   ENDIF

   IF nTimeEnd == NIL
      nTimeEnd := SECONDS() + nReload // Prox volta che attivo questa funzione
      //nLast    := SECONDS()
      RETURN .T.
   ENDIF

   nSec := SECONDS()

   // Tempo scaduto
   IF nSec > nTimeEnd
      RETURN .F.
   ENDIF

   // Sono passati almeno nEvery secondi?
//   IF nEvery > 0
//      IF nSec < nLast+nEvery
//         RETURN .F.
//      ENDIF
//      nLast := nSec
//   ENDIF
RETURN .T.
#endif