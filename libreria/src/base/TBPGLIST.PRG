//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per tBrowse
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfMsg.ch"
#include "dfWin.ch"
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
PROCEDURE tbPgList( oTbr )         // Array di scelta delle pagine
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
LOCAL nActual
IF LEN(oTbr:W_PAGELABELS)>1     // Visualizzo se ho almeno 2 pagine
   nActual := dfArrWin( NIL,NIL,NIL,NIL,; // Array Centrata a video
                        oTbr:W_PAGELABELS  ,;
                        dfStdMsg( MSG_PGLIST01 ) ,; // Lista delle pagine
                        NIL, NIL, oTbr:W_CURRENTPAGE ) // Pagina attuale
   IF nActual#0
      tbPgGoto( oTbr, nActual )
   ENDIF
ELSE
   dbSouErr()
ENDIF

RETURN
