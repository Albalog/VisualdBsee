/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/

#include "FileIO.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfScanIni( cLab, bBlock )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL nHnd
   LOCAL cPATH := dfInitPath()

   cLab := UPPER(ALLTRIM(cLab))
   IF UPPER(Alltrim(cLAB)) == "REPORT"
      cPath     := dfReportINIPath()
   ENDIF 
   IF dfIsIni()
      dfInitSelect(); dfFLocate( "[" +cLab +"]" ); dfFSkip() // Locate sezione
      EVAL( bBlock )
      IF (nHnd:=dfFopen( cPath +cLab +".ini", FO_READ +FO_DENYWRITE,,,.T. ))>0
         EVAL( bBlock, .T. )
         dfFClose(nHnd)
      ENDIF
   ENDIF

RETURN
