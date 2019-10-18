/******************************************************************************
 Progetto       : Tutorial
 Sottoprogetto  : Tutorial
 Programma      : V:\SAMPLES\TUTORIAL\source\dbRid.prg
 Template       : V:\bin\..\tmp\xbase\dbrid.tmp
 Descrizione    : Funzioni di integrita' dati e transazioni
 Programmatore  : Demo
 Data           : 13-07-06
 Ora            : 16.43.55
******************************************************************************/

#INCLUDE "Common.ch"
#INCLUDE "dfWin.ch"
#INCLUDE "dfGenMsg.ch"
* #COD OIRID1 * #END  Inizio file dbRid - Punto per dichiarazione INCLUDE e STATIC GLOBALI

/*
   TRANSAZIONI SU FILE
*/

*******************************************************************************
FUNCTION T_BolleTrn( cTrn ,cState )                // TRANSAZIONI Testata Bolle
*******************************************************************************
LOCAL  lRet      := .F.                            //  Valore di ritorno funzione
LOCAL  aFile     := {}                             //  Array dei file aperti dalla funzione
* #COD DITFF0000004 * #END

IF cTrn==NIL ;RETURN .F. ;END                      // Tipo transazione non specificato

cTrn := Lower(cTrn)

DEFAULT cState  TO DE_STATE_INK


BEGIN SEQUENCE

      IF ! dfUse( "P_Bolle" ,NIL ,aFile ) ;BREAK  ;END
       * #COD DITFF1000004 * #END

      IF     cTrn == "ptt"                         // PUT    THE TRANSACTION

          * #COD DITFF2000004 * #END
          * #COD DITFF3000004 * #END

         lRet := .T.
         BREAK

      ELSEIF cTrn == "rtt"                         // REMOVE THE TRANSACTION

          * #COD DITFF4000004 * #END
          * #COD DITFF5000004 * #END

         lRet := .T.
         BREAK

      ELSEIF cTrn == "ltt"                         // LOG    THE TRANSACTION

          * #COD DITFF6000004 * #END
         DO CASE
            CASE cState == DE_STATE_ADD            // Inserimento APPENDE IL RECORD

                 P_Bolle->(dbAppend())             //  Append del record
                 P_Bolle->CodBol     := T_Bolle->CodBol

            CASE cState == DE_STATE_MOD            // Modifica    REPLACE RECORD

                 IF P_Bolle->(dfS( 1,T_Bolle->CodBol))
                 ENDIF

            CASE cState == DE_STATE_DEL            // Cancellazione DELETE

                 IF P_Bolle->(dfS( 1,T_Bolle->CodBol))
                    P_BolleDid( .F. )
                 ENDIF

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

*******************************************************************************
FUNCTION R_BolleTrn( cTrn ,cState )                // TRANSAZIONI Righe Bolle
*******************************************************************************
LOCAL  lRet      := .F.                            //  Valore di ritorno funzione
LOCAL  aFile     := {}                             //  Array dei file aperti dalla funzione
* #COD DITFF0000006 * #END

IF cTrn==NIL ;RETURN .F. ;END                      // Tipo transazione non specificato

cTrn := Lower(cTrn)

DEFAULT cState  TO DE_STATE_INK


BEGIN SEQUENCE

      IF ! dfUse( "Articoli" ,NIL ,aFile ) ;BREAK  ;END
      IF ! dfUse( "Clienti" ,NIL ,aFile ) ;BREAK  ;END
       * #COD DITFF1000006 * #END

      IF     cTrn == "ptt"                         // PUT    THE TRANSACTION

          * #COD DITFF2000006 * #END
         IF Articoli->(dfS( 1,R_Bolle->CodArt))
            Articoli->QtaArt     -= R_Bolle->QtaArt * (IIF(T_Bolle->TipBol =="U",1,-1))
         ENDIF
         IF Clienti->(dfS( 1,(T_BOLLE->(dfs(1,R_Bolle->CodBol)),T_Bolle->CodCli)))
            Clienti->TotFat     += R_Bolle->QtaArt*R_Bolle->PrzArt*(IIF(T_Bolle->TipBol =="U",1,-1))*(IIF(T_Bolle->ScnBol >0, 1-(T_Bolle->ScnBol /100), 1))
         ENDIF
          * #COD DITFF3000006 * #END

         lRet := .T.
         BREAK

      ELSEIF cTrn == "rtt"                         // REMOVE THE TRANSACTION

          * #COD DITFF4000006 * #END
         IF Articoli->(dfS( 1,R_Bolle->CodArt))
            Articoli->QtaArt     += R_Bolle->QtaArt * (IIF(T_Bolle->TipBol =="U",1,-1))
         ENDIF
         IF Clienti->(dfS( 1,(T_BOLLE->(dfs(1,R_Bolle->CodBol)),T_Bolle->CodCli)))
            Clienti->TotFat     -= R_Bolle->QtaArt*R_Bolle->PrzArt*(IIF(T_Bolle->TipBol =="U",1,-1))*(IIF(T_Bolle->ScnBol >0, 1-(T_Bolle->ScnBol /100), 1))
         ENDIF
          * #COD DITFF5000006 * #END

         lRet := .T.
         BREAK

      ELSEIF cTrn == "ltt"                         // LOG    THE TRANSACTION

          * #COD DITFF6000006 * #END
         DO CASE
            CASE cState == DE_STATE_ADD            // Inserimento APPENDE IL RECORD


            CASE cState == DE_STATE_MOD            // Modifica    REPLACE RECORD


            CASE cState == DE_STATE_DEL            // Cancellazione DELETE


         ENDCASE
          * #COD DITFF7000006 * #END

         lRet := .T.
         BREAK

      ENDIF
       * #COD DITFF8000006 * #END

RECOVER

   dfClose( aFile, .T., .T. )                      //  Chiude i file aperti in questa funzione

END

* #COD DITFF9000006 * #END

RETURN lRet


/*
   INTEGRITA' DATI SUI FILE (CANCELLAZIONE RECORD)
*/

*******************************************************************************
FUNCTION ClientiDid()                              // Delete Integrity Data Clienti
*******************************************************************************
LOCAL nRecPos   := 0                               // recno() file corrente
LOCAL nCnt      := 0                               // contatore array di recno()
LOCAL lRet      := .T.                             // valore di ritorno
LOCAL aFile := {}
* #COD DIDFF1000001 * #END

BEGIN SEQUENCE
      IF ! dfUse( "T_Bolle" ,NIL ,aFile ) ;BREAK  ;END
RECOVER
   dfClose( aFile, .T., .T. )                      //  Chiude i file aperti in questa funzione
   RETURN .F.
END


* #COD DIDFF2000001 * #END

// integrita' referenziale in modalita' CASCADE tra file Clienti e T_Bolle

T_Bolle->(OrdSetFocus(2))
T_Bolle->(dbSeek(Clienti->CodCli))
WHILE( T_Bolle->(dfChkDidExp( 2 ,; // Index
   {||Clienti->CodCli} ,; // Key
   {||.T.} ,; // Filter
   {||T_Bolle->CodCli!=Clienti->CodCli} ))) // Break
   nRecPos   := T_Bolle->(recno())                 // salvataggio recno() file corrente
   T_BolleDid()
   T_Bolle->(OrdSetFocus(2))
   T_Bolle->(dbGoto(nRecPos))                      // si ripristina recno() file corrente

   T_Bolle->(dbSkip(1))
ENDDO
// CANCELLAZIONE RECORD CORRENTE
* #COD DIDFF8000001 * #END
Clienti->(dbDelete())
* #COD DIDFF9000001 * #END
dfClose( aFile, .T., .T. )                         //  Chiude i file aperti in questa funzione

RETURN lRet


*******************************************************************************
FUNCTION ProvinceDid()                             // Delete Integrity Data Province
*******************************************************************************
LOCAL nCnt      := 0                               // contatore array di recno()
LOCAL lRet      := .T.                             // valore di ritorno
* #COD DIDFF1000002 * #END



* #COD DIDFF2000002 * #END

// CANCELLAZIONE RECORD CORRENTE
* #COD DIDFF8000002 * #END
Province->(dbDelete())
* #COD DIDFF9000002 * #END

RETURN lRet


*******************************************************************************
FUNCTION ArticoliDid()                             // Delete Integrity Data Articoli
*******************************************************************************
LOCAL nRecPos   := 0                               // recno() file corrente
LOCAL nCnt      := 0                               // contatore array di recno()
LOCAL lRet      := .T.                             // valore di ritorno
LOCAL aFile := {}
* #COD DIDFF1000003 * #END

BEGIN SEQUENCE
      IF ! dfUse( "R_Bolle" ,NIL ,aFile ) ;BREAK  ;END
RECOVER
   dfClose( aFile, .T., .T. )                      //  Chiude i file aperti in questa funzione
   RETURN .F.
END


* #COD DIDFF2000003 * #END

// integrita' referenziale in modalita' CASCADE tra file Articoli e R_Bolle

R_Bolle->(OrdSetFocus(2))
R_Bolle->(dbSeek(Articoli->CodArt))
WHILE( R_Bolle->(dfChkDidExp( 2 ,; // Index
   {||Articoli->CodArt} ,; // Key
   {||.T.} ,; // Filter
   {||R_Bolle->CodArt!=Articoli->CodArt} ))) // Break
   nRecPos   := R_Bolle->(recno())                 // salvataggio recno() file corrente
   R_BolleDid()
   R_Bolle->(OrdSetFocus(2))
   R_Bolle->(dbGoto(nRecPos))                      // si ripristina recno() file corrente

   R_Bolle->(dbSkip(1))
ENDDO
// CANCELLAZIONE RECORD CORRENTE
* #COD DIDFF8000003 * #END
Articoli->(dbDelete())
* #COD DIDFF9000003 * #END
dfClose( aFile, .T., .T. )                         //  Chiude i file aperti in questa funzione

RETURN lRet


*******************************************************************************
FUNCTION T_BolleDid()                              // Delete Integrity Data Testata Bolle
*******************************************************************************
LOCAL nRecPos   := 0                               // recno() file corrente
LOCAL nCnt      := 0                               // contatore array di recno()
LOCAL lRet      := .T.                             // valore di ritorno
LOCAL aFile := {}
* #COD DIDFF1000004 * #END

BEGIN SEQUENCE
      IF ! dfUse( "R_Bolle" ,NIL ,aFile ) ;BREAK  ;END
      IF ! dfUse( "P_Bolle" ,NIL ,aFile ) ;BREAK  ;END
RECOVER
   dfClose( aFile, .T., .T. )                      //  Chiude i file aperti in questa funzione
   RETURN .F.
END


* #COD DIDFF2000004 * #END

// integrita' referenziale in modalita' CASCADE tra file T_Bolle e R_Bolle

R_Bolle->(OrdSetFocus(1))
R_Bolle->(dbSeek(T_Bolle->CodBol))
WHILE( R_Bolle->(dfChkDidExp( 1 ,; // Index
   {||T_Bolle->CodBol} ,; // Key
   {||.T.} ,; // Filter
   {||R_Bolle->CodBol!=T_Bolle->CodBol} ))) // Break
   nRecPos   := R_Bolle->(recno())                 // salvataggio recno() file corrente
   R_BolleDid()
   R_Bolle->(OrdSetFocus(1))
   R_Bolle->(dbGoto(nRecPos))                      // si ripristina recno() file corrente

   R_Bolle->(dbSkip(1))
ENDDO
// integrita' referenziale in modalita' CASCADE tra file T_Bolle e P_Bolle

P_Bolle->(OrdSetFocus(1))
P_Bolle->(dbSeek(T_Bolle->CodBol))
IF !P_Bolle->(EOF())
   nRecPos   := P_Bolle->(recno())                 // salvataggio recno() file corrente
   P_BolleDid()
   P_Bolle->(OrdSetFocus(1))
   P_Bolle->(dbGoto(nRecPos))                      // si ripristina recno() file corrente
ENDIF

// CANCELLAZIONE RECORD CORRENTE
T_BolleTrn( "ltt" ,DE_STATE_DEL )                  // LOG    THE TRANSACTION
* #COD DIDFF8000004 * #END
T_Bolle->(dbDelete())
* #COD DIDFF9000004 * #END
dfClose( aFile, .T., .T. )                         //  Chiude i file aperti in questa funzione

RETURN lRet


*******************************************************************************
FUNCTION P_BolleDid()                              // Delete Integrity Data Piede Bolle
*******************************************************************************
LOCAL nCnt      := 0                               // contatore array di recno()
LOCAL lRet      := .T.                             // valore di ritorno
* #COD DIDFF1000005 * #END



* #COD DIDFF2000005 * #END

// CANCELLAZIONE RECORD CORRENTE
* #COD DIDFF8000005 * #END
P_Bolle->(dbDelete())
* #COD DIDFF9000005 * #END

RETURN lRet


*******************************************************************************
FUNCTION R_BolleDid()                              // Delete Integrity Data Righe Bolle
*******************************************************************************
LOCAL nCnt      := 0                               // contatore array di recno()
LOCAL lRet      := .T.                             // valore di ritorno
* #COD DIDFF1000006 * #END



* #COD DIDFF2000006 * #END

// CANCELLAZIONE RECORD CORRENTE
R_BolleTrn( "rtt" )                                // REMOVE THE TRANSACTION
* #COD DIDFF8000006 * #END
R_Bolle->(dbDelete())
* #COD DIDFF9000006 * #END

RETURN lRet


*******************************************************************************
FUNCTION CategDid()                                // Delete Integrity Data Categorie
*******************************************************************************
LOCAL nCnt      := 0                               // contatore array di recno()
LOCAL lRet      := .T.                             // valore di ritorno
* #COD DIDFF1000007 * #END



* #COD DIDFF2000007 * #END

// CANCELLAZIONE RECORD CORRENTE
* #COD DIDFF8000007 * #END
Categ->(dbDelete())
* #COD DIDFF9000007 * #END

RETURN lRet

* #COD OIRID9 * #END  Fine file dbRid - Punto per inserimento funzioni utente

