/******************************************************************************
 Progetto       : Esempio Crystal Report
 Sottoprogetto  : Esempio Crystal Report
 Programma      : C:\PROGRA~1\VISUAL~1\SAMPLES\CRYSTAL\source\dbRid.prg
 Template       : C:\Programmi\VisualdBsee\bin\..\tmp\xbase\dbrid.tmp
 Descrizione    : Funzioni di integrita' dati e transazioni
 Programmatore  :
 Data           : 12-10-04
 Ora            : 16.03.00
******************************************************************************/

#INCLUDE "Common.ch"
#INCLUDE "dfWin.ch"
#INCLUDE "dfGenMsg.ch"
* #COD OIRID1 * #END  Inizio file dbRid - Punto per dichiarazione INCLUDE e STATIC GLOBALI

/*
   TRANSAZIONI SU FILE
*/

*******************************************************************************
FUNCTION docvendTrn( cTrn ,cState )                // TRANSAZIONI Doc. vendita - dettaglio
*******************************************************************************
LOCAL  lRet      := .F.                            //  Valore di ritorno funzione
LOCAL  aFile     := {}                             //  Array dei file aperti dalla funzione
* #COD DITFF0000004 * #END

IF cTrn==NIL ;RETURN .F. ;END                      // Tipo transazione non specificato

cTrn := Lower(cTrn)

DEFAULT cState  TO DE_STATE_INK


BEGIN SEQUENCE

      IF ! dfUse( "docven" ,NIL ,aFile ) ;BREAK  ;END
       * #COD DITFF1000004 * #END

      IF     cTrn == "ptt"                         // PUT    THE TRANSACTION

          * #COD DITFF2000004 * #END
         IF docven->(dfS( 1,str(docvend->numdoc,6,0)))
            docven->totdoc     += docvend->totrig
         ENDIF
          * #COD DITFF3000004 * #END

         lRet := .T.
         BREAK

      ELSEIF cTrn == "rtt"                         // REMOVE THE TRANSACTION

          * #COD DITFF4000004 * #END
         IF docven->(dfS( 1,str(docvend->numdoc,6,0)))
            docven->totdoc     -= docvend->totrig
         ENDIF
          * #COD DITFF5000004 * #END

         lRet := .T.
         BREAK

      ELSEIF cTrn == "ltt"                         // LOG    THE TRANSACTION

          * #COD DITFF6000004 * #END
         DO CASE
            CASE cState == DE_STATE_ADD            // Inserimento APPENDE IL RECORD


            CASE cState == DE_STATE_MOD            // Modifica    REPLACE RECORD


            CASE cState == DE_STATE_DEL            // Cancellazione DELETE


         ENDCASE
          * #COD DITFF7000004 * #END

         lRet := .T.
         BREAK

      ENDIF
       * #COD DITFF8000004 * #END

RECOVER

   dfClose( aFile, .T., .T. )                      //  Chiude i file aperti in questa funzione

END

* #COD DITFF9000004 * #END

RETURN lRet


/*
   INTEGRITA' DATI SUI FILE (CANCELLAZIONE RECORD)
*/

*******************************************************************************
FUNCTION clientiDid()                              // Delete Integrity Data Clienti
*******************************************************************************
LOCAL nCnt      := 0                               // contatore array di recno()
LOCAL lRet      := .T.                             // valore di ritorno
* #COD DIDFF1000001 * #END



* #COD DIDFF2000001 * #END

// CANCELLAZIONE RECORD CORRENTE
* #COD DIDFF8000001 * #END
clienti->(dbDelete())
* #COD DIDFF9000001 * #END

RETURN lRet


*******************************************************************************
FUNCTION articolDid()                              // Delete Integrity Data Articoli
*******************************************************************************
LOCAL nCnt      := 0                               // contatore array di recno()
LOCAL lRet      := .T.                             // valore di ritorno
* #COD DIDFF1000002 * #END



* #COD DIDFF2000002 * #END

// CANCELLAZIONE RECORD CORRENTE
* #COD DIDFF8000002 * #END
articol->(dbDelete())
* #COD DIDFF9000002 * #END

RETURN lRet


*******************************************************************************
FUNCTION docvenDid()                               // Delete Integrity Data Documenti di vendita
*******************************************************************************
LOCAL nRecPos   := 0                               // recno() file corrente
LOCAL nCnt      := 0                               // contatore array di recno()
LOCAL lRet      := .T.                             // valore di ritorno
LOCAL aFile := {}
* #COD DIDFF1000003 * #END

BEGIN SEQUENCE
      IF ! dfUse( "docvend" ,NIL ,aFile ) ;BREAK  ;END
RECOVER
   dfClose( aFile, .T., .T. )                      //  Chiude i file aperti in questa funzione
   RETURN .F.
END


* #COD DIDFF2000003 * #END

// integrita' referenziale in modalita' CASCADE tra file docven e docvend

docvend->(OrdSetFocus(1))
docvend->(dbSeek(str(docven->numdoc, 6, 0)))
WHILE( docvend->(dfChkDidExp( 1 ,; // Index
   {||str(docven->numdoc, 6, 0)} ,; // Key
   {||.T.} ,; // Filter
   {||str(docvend->numdoc, 6, 0)!=str(docven->numdoc, 6, 0)} ))) // Break
   nRecPos   := docvend->(recno())                 // salvataggio recno() file corrente
   docvendDid()
   docvend->(OrdSetFocus(1))
   docvend->(dbGoto(nRecPos))                      // si ripristina recno() file corrente

   docvend->(dbSkip(1))
ENDDO
// CANCELLAZIONE RECORD CORRENTE
* #COD DIDFF8000003 * #END
docven->(dbDelete())
* #COD DIDFF9000003 * #END
dfClose( aFile, .T., .T. )                         //  Chiude i file aperti in questa funzione

RETURN lRet


*******************************************************************************
FUNCTION docvendDid()                              // Delete Integrity Data Doc. vendita - dettaglio
*******************************************************************************
LOCAL nCnt      := 0                               // contatore array di recno()
LOCAL lRet      := .T.                             // valore di ritorno
* #COD DIDFF1000004 * #END



* #COD DIDFF2000004 * #END

// CANCELLAZIONE RECORD CORRENTE
docvendTrn( "rtt" )                                // REMOVE THE TRANSACTION
* #COD DIDFF8000004 * #END
docvend->(dbDelete())
* #COD DIDFF9000004 * #END

RETURN lRet

* #COD OIRID9 * #END  Fine file dbRid - Punto per inserimento funzioni utente

