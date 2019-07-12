//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per STAMPE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Fileio.ch"
#INCLUDE "dfReport.ch" // Struttura Report e Virtual record
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfPrnHEADER( aBuf ) // Stampa il Page HEADER
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
aBuf[REP_ACT_ROW] := 0 // Serve per il banner NON formattato

IF aBuf[REP_ITEMINPAGE]#0
   aBuf[REP_POSINFILE]:=dfStaPos( aBuf )
ENDIF
IF aBuf[REP_ACT_PAGE]==0      // Sono sulla pagina del banner
   aBuf[REP_IS_BANNER]:=.T.
   IF aBuf[REP_BANNER_INPAGE] // Se il banner deve contare le pagine aumento
      aBuf[REP_ACT_PAGE]++    // la corrente di uno
   ENDIF
   IF aBuf[REP_BANNER_FORMAT]
      dfPAGEHEADER( aBuf )
   ENDIF
   aBuf[REP_ITEMINPAGE]:=0

   aBuf[REP_BAN_ROW] := aBuf[REP_ACT_ROW]+1
   IF !EMPTY(aBuf[REP_POSRB]) // >0 .AND. !NIL
      // Evito che un posizionamento fisso possa dare casino
      // se cambio i margini del report
      aBuf[REP_BAN_ROW] := MAX(aBuf[REP_POSRB],aBuf[REP_BAN_ROW])
   ENDIF

   dfPrintBand( aBuf[REP_RB] )
   IF aBuf[REP_BAN_ROW] +aBuf[REP_ROWRB] -1 > aBuf[REP_ACT_ROW]
      dfprint( aBuf[REP_ROWRB]-1 )
   ENDIF
   IF aBuf[REP_ITEMINPAGE]#0
      aBuf[REP_POSINFILE]:=dfStaPos( aBuf )
   ENDIF
   IF aBuf[REP_EJECT_RB]
      dfPrnFOOTER( aBuf )
      dfPAGEHEADER( aBuf )
   ENDIF
ELSE
   dfPAGEHEADER( aBuf )
ENDIF
aBuf[REP_ITEMINPAGE]:=0

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfPAGEHEADER( aBuf )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC nRow := 0
IF ++nRow==1
   dfPushBuffer()
   // Controllo l'altezza di banda per evitare di mettere una
   // riga vuota sui page header vuoti
   aBuf[REP_BAN_ROW] := aBuf[REP_MGN_TOP] +IF(aBuf[REP_ROWPH]>0,1,0)
   aBuf[REP_ACT_ROW] := 0
   IF EVAL(aBuf[REP_CANPH])
      dfPrintBand( aBuf[REP_PH] )            // Print Header
      IF aBuf[REP_BAN_ROW] +aBuf[REP_ROWPH] -1 > aBuf[REP_ACT_ROW]
         dfprint( aBuf[REP_ROWPH]-1 )
      ENDIF
   ENDIF
   dfPopBuffer()
ENDIF
nRow--
RETURN
