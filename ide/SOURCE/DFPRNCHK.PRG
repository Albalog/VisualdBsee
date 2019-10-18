//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Report tool
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "common.ch"
#include "dfReport.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfPrnChk( nPrinter, nDelay ) // Check the printer
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T., nSec

DEFAULT nPrinter TO PRN_LPT1
DEFAULT nDelay   TO 10

IF !dfPrnChkSub( nPrinter )
   lRet := .F.
   nSec := SECONDS()
   WHILE ABS(SECONDS()-nSec)<nDelay
      IF dfPrnChkSub( nPrinter )
         lRet := .T.
         EXIT
      ENDIF
      IF NEXTKEY()!=0
         dfINKEY() //FW
         EXIT
      ENDIF
   ENDDO
ENDIF

RETURN lRet


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfPrnChkSub( nPrinter )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T., nOpen

#ifdef __XPP__
LOCAL aPorts := {"LPT1", "LPT2", "LPT3", "LPT4", "LPT5", ;
                 "LPT6", "LPT7", "LPT8", "LPT9",         ;
                 "COM1", "COM2", "COM3", "COM4"          }
STATIC bMtd
LOCAL nMtd

// Simone 20/9/06
// mantis 0001144: abilitare percorsi UNC nelle funzioni di stampa diretta DOS
// Xbase can use always ISPRINTER()
IF VALTYPE(nPrinter) $ "CMO" .OR. (nPrinter>=PRN_LPT1 .AND. nPrinter<=PRN_COM4)

   // Simone 4/giu/03 gerr 3816
   IF bMtd == NIL 
      nMtd := dfSet("XbaseCheckPrinter")

      // Default eseguo ISPRINTER()
      bMtd := {|cPort, nPort| ISPRINTER(cPort) }

      IF nMtd == "OPEN"
         // Controllo apertura porta stampante
         bMtd := {|cPort, nPort| nOpen := FOPEN( cPort ), ;
                                 IIF(nOpen>0, FCLOSE(nOpen), .F.), ;
                                 nOpen > 0  }

      ELSEIF nMtd == "TRY"
         // Simone 9/set/03 GERR 3930
         // Controllo usando SET PRINTER
         // Tipo di controllo aggiunto il 9/set/03
         // perch‚ in CITRIX non controllando la porta
         // se la porta non Š effettivamente disponibile
         // ho un errore di runtime sul SET PRINTER TO  
         // nella dfFile2Prn()
         bMtd := {|cPort| _TrySetPrinter(cPort) }

      ELSEIF nMtd == "NO"
         // Salto il controllo
         bMtd := .F.

      ENDIF
   ENDIF
   
   // Simone 20/9/06
   // mantis 0001144: abilitare percorsi UNC nelle funzioni di stampa diretta DOS
   IF VALTYPE(bMtd) == "L" // se non Š un codeblock -> OK
      lRet := .T.

   ELSEIF VALTYPE(nPrinter) $ "O"
      // unico metodo che dovrebbe funzionare con l'oggetto printer
      lRet := _TrySetPrinter(nPrinter)

   ELSEIF VALTYPE(nPrinter) $ "CM"
     lRet := EVAL(bMtd, nPrinter, nPrinter)
   ELSE
     lRet := EVAL(bMtd, aPorts[nPrinter], nPrinter)
   ENDIF
ENDIF

#else

DO CASE
   CASE nPrinter>=PRN_LPT1 .AND. nPrinter<=PRN_LPT3
        lRet := dfisPrn( nPrinter )

   CASE nPrinter>=PRN_LPT4 .AND. nPrinter<=PRN_LPT9
        DO CASE
           CASE nPrinter==PRN_LPT4; nOpen := FOPEN( "LPT4" )
           CASE nPrinter==PRN_LPT5; nOpen := FOPEN( "LPT5" )
           CASE nPrinter==PRN_LPT6; nOpen := FOPEN( "LPT6" )
           CASE nPrinter==PRN_LPT7; nOpen := FOPEN( "LPT7" )
           CASE nPrinter==PRN_LPT8; nOpen := FOPEN( "LPT8" )
           CASE nPrinter==PRN_LPT9; nOpen := FOPEN( "LPT9" )
        ENDCASE
        IF (lRet:=nOpen>0)
           FCLOSE( nOpen )
        ENDIF

   CASE nPrinter>=PRN_COM1 .AND. nPrinter<=PRN_COM4
        DO CASE
           CASE nPrinter==PRN_COM1; nOpen := FOPEN( "COM1" )
           CASE nPrinter==PRN_COM2; nOpen := FOPEN( "COM2" )
           CASE nPrinter==PRN_COM3; nOpen := FOPEN( "COM3" )
           CASE nPrinter==PRN_COM4; nOpen := FOPEN( "COM4" )
        ENDCASE
        IF (lRet:=nOpen>0)
           FCLOSE( nOpen )
        ENDIF
ENDCASE

#endif

RETURN lRet

#ifdef __XPP__

// dato che la __TrySetPrinter Š molto lenta
// tengo una cache dei risultati 
STATIC FUNCTION _TrySetPrinter(cPort)
   STATIC aChk := {}
   LOCAL aPort
   LOCAL  nPos

   nPos := ASCAN(aChk, {|x|x[1]==cPort})
   IF nPos == 0
      // porta non esistente nella cache, aggiungo il controllo
      AADD(aChk, {cPort, .F., NIL, NIL})
      aPort := ATAIL(aChk)
   ELSE
      aPort := aChk[nPos]
   ENDIF

   // Rieseguo il controllo della __TrySetPrinter se
   // l'ultimo controllo era negativo (porta non esistente)
   // oppure se l'ultimo controllo Š stato eseguito il giorno precedente
   // oppure se l'ultimo controllo Š stato eseguito da pi— di 10 secondi
   IF (! aPort[2])      .OR. ; 
      aPort[3] < DATE() .OR. ;
      aPort[4] < SECONDS() 

      aPort[2] := __TrySetPrinter(cPort)
      aPort[3] := DATE()
      aPort[4] := SECONDS()+10
   ENDIF

RETURN aPort[2]

// questo controllo funziona ma Š molto lento
STATIC FUNCTION __TrySetPrinter(cPort)
   LOCAL lRet := .F.
   LOCAL bErr := ERRORBLOCK( {|e|break(e)} )

   BEGIN SEQUENCE
      IF VALTYPE(cPort)=="O"
#if XPPVER < 01900000
#else
         // sintassi valida da Xbase 1.90 
         SET PRINTER TO OBJECT cPort
#endif
      ELSE
      SET PRINTER TO (cPort)
      ENDIF

      SET PRINTER TO
      lRet := .T.
   END SEQUENCE
   ERRORBLOCK(bErr)
RETURN lRet
#endif