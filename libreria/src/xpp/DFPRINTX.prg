#include "dfReport.ch"
#include "dfWinRep.ch"
#include "dfReport.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfPrint( nRow  ,; // Riga
                   nCol  ,; // Colonna
                   uVar  ,; // Variabile
                   cPic  ,; // Picture
                   nAtr  ,; // Attributo
                   lMul  ,; // Multiriga
                   nLen  ,; // Lunghezza
                   cPre  ,; // Carattere che precede i MULTIRIGA
                   cPost ,; // Carattare che segue i MULTIRIGA
                   cFill ,; // Carattere di FILL per i MULTIRIGA
                   cFont )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

   // Se non Š una stampante windows disabilito la stampa
   IF ! EMPTY(cFont) .AND. CanPrint()
      nAtr := {DFWINREP_FONTON+cFont+";", ;
               DFWINREP_FONTOFF}
   ENDIF

//    dfPrintAttr( nRow  ,; // Riga
//                 nCol  ,; // Colonna
//                 uVar  ,; // Variabile
//                 cPic  ,; // Picture
//                 nAtr  ,; // Attributo
//                 lMul  ,; // Multiriga
//                 nLen  ,; // Lunghezza
//                 cPre  ,; // Carattere che precede i MULTIRIGA
//                 cPost ,; // Carattare che segue i MULTIRIGA
//                 cFill )  // Carattere di FILL per i MULTIRIGA

   _dfPrint( nRow  ,; // Riga
            nCol  ,; // Colonna
            uVar  ,; // Variabile
            cPic  ,; // Picture
            nAtr  ,; // Attributo
            lMul  ,; // Multiriga
            nLen  ,; // Lunghezza
            cPre  ,; // Carattere che precede i MULTIRIGA
            cPost ,; // Carattare che segue i MULTIRIGA
            cFill )  // Carattere di FILL per i MULTIRIGA



RETURN

STATIC FUNCTION CanPrint()
   LOCAL lRet
   LOCAL aBuf := dfPrnArr()
   IF EMPTY( aBuf[REP_XBASEPRINTDISP  ] )
      lRet := aBuf[REP_PRINTERPORT]=="VIDEO" .OR. dfIsWinPrinter(aBuf)
   ELSE
      lRet := aBuf[REP_XBASEPRINTDISP  ]:canSupportFont()
   ENDIF
RETURN lRet

// // Come la dfPrint ma se l'attributo Š un array lo usa per
// // inserire nel file di output gli attributi definiti
// * ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
// PROCEDURE dfPrintAttr( nRow  ,; // Riga
//                    nCol  ,; // Colonna
//                    uVar  ,; // Variabile
//                    cPic  ,; // Picture
//                    xAtr  ,; // ATTRIBUTO STANDARD o ARRAY Attributi ON/OFF
//                    lMul  ,; // Multiriga
//                    nLen  ,; // Lunghezza
//                    cPre  ,; // Carattere che precede i MULTIRIGA
//                    cPost ,; // Carattare che segue i MULTIRIGA
//                    cFill  ) // Carattere di FILL per i MULTIRIGA
// * ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
// 
// LOCAL aSave
// LOCAL aBuf := dfPrnArr()
// 
// IF VALTYPE(xAtr)=="A" .AND. LEN(xAtr) == 2
//    aSave := {aBuf[REP_USER3ON], aBuf[REP_USER3OFF]}
//    aBuf[REP_USER3ON]  := xAtr[1]
//    aBuf[REP_USER3OFF] := xAtr[2]
//    xAtr := PRN_USER03
// ENDIF
// 
// _dfPrint( nRow  ,; // Riga
//           nCol  ,; // Colonna
//           uVar  ,; // Variabile
//           cPic  ,; // Picture
//           xAtr  ,; // Attributo
//           lMul  ,; // Multiriga
//           nLen  ,; // Lunghezza
//           cPre  ,; // Carattere che precede i MULTIRIGA
//           cPost ,; // Carattare che segue i MULTIRIGA
//           cFill )  // Carattere di FILL per i MULTIRIGA
// 
// IF aSave != NIL
//    aBuf[REP_USER3ON]  := aSave[1]
//    aBuf[REP_USER3OFF] := aSave[2]
// ENDIF
// RETURN

// * ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
// PROCEDURE dfPrint( nRow  ,; // Riga
//                    nCol  ,; // Colonna
//                    uVar  ,; // Variabile
//                    cPic  ,; // Picture
//                    nAtr  ,; // Attributo
//                    lMul  ,; // Multiriga
//                    nLen  ,; // Lunghezza
//                    cPre  ,; // Carattere che precede i MULTIRIGA
//                    cPost ,; // Carattare che segue i MULTIRIGA
//                    cFill ,; // Carattere di FILL per i MULTIRIGA
//                    cFont )
// * ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
// LOCAL aSave
// LOCAL aBuf := dfPrnArr()
//
// IF ! EMPTY(cFont)
//    aSave := {aBuf[REP_USER3ON], aBuf[REP_USER3OFF]}
//    aBuf[REP_USER3ON]  := DFWINREP_FONTON+cFont+";"
//    aBuf[REP_USER3OFF] := DFWINREP_FONTOFF
//    nAtr := PRN_USER03
// ENDIF
//
// _dfPrint( nRow  ,; // Riga
//           nCol  ,; // Colonna
//           uVar  ,; // Variabile
//           cPic  ,; // Picture
//           nAtr  ,; // Attributo
//           lMul  ,; // Multiriga
//           nLen  ,; // Lunghezza
//           cPre  ,; // Carattere che precede i MULTIRIGA
//           cPost ,; // Carattare che segue i MULTIRIGA
//           cFill )  // Carattere di FILL per i MULTIRIGA
//
// IF ! EMPTY(cFont)
//    aBuf[REP_USER3ON]  := aSave[1]
//    aBuf[REP_USER3OFF] := aSave[2]
// ENDIF
// RETURN


