//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per STAMPE
//Programmatore  : Baccan Matteo
//*****************************************************************************

#include "dfReport.ch"

// Avvio stampa 
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfPrnStart(aVRec, nMode, bOut)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL aBuffer := dfPrnArr()
   LOCAL xRet

   IF ! EMPTY(aBuffer) .AND. aBuffer[REP_XBASEREPORTTYPE] != NIL
      ///////////////////////////////////////////////////////
      //Luca 20/11/2008
      //Inserito workaround per evitare errore <Nulla da stampare> se si ha da stamapre solo un record!
      // con report manager /crystal e margini di stampa a 0.
      // Succedeva perchä il file di testo temporaneo non veniva incrementato in dimensioni e quindi 
      // nella routine di stampa _dfPrnStart il controllo
      //
      // // NON ho stampato nulla e NON ho nulla in cache
      // IF nAbsPos==dfStaPos( aBuf ) .AND. !dfisPrnBuf()
      //    aBuf[REP_EMPTYREPORT] := .T.
      // ENDIF
      //
      // restituiva .T. ma invece un record c'era!

      aBuffer[REP_MGN_TOP] := Max(aBuffer[REP_MGN_TOP],2)
      ///////////////////////////////////////////////////////

      xRet := aBuffer[REP_XBASEREPORTTYPE]:printStart(aVRec, nMode, bOut)
   ELSE
      xRet := dfRepDbseeStart(aVRec, nMode, bOut)
   ENDIF

RETURN xRet

// Avvio stampa per report dBsee standard
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfRepDbseeStart(aVRec, nMode, bOut)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL xRet
   IF dfSet("XbasePrintThread")=="YES"
      xRet := dfXPrnStart(aVRec, nMode, bOut)
   ELSE
      xRet := _dfPrnStart(aVRec, nMode, bOut)
   ENDIF
RETURN xRet 


// Avvio stampa per report dBsee in thread (DA FARE!)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfXPrnStart(aVRec, nMode, bOut)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL xRet
   // TODO: Attivo un thread separato

   // Chiamo la dfPrnStart originale
   xRet := _dfPrnStart(aVRec, nMode, bOut)

   // TODO: Disattivo il thread

RETURN xRet

//static function _dfprnstart();RETURN NIL
