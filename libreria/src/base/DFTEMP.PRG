/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfTemp()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cTemp := GETENV( "TEMP" )
   LOCAL cDefTemp := dfSet("xBaseDefaultPathTemp")

   //Maudp 20/04/2012 XL 3410 Settaggio per cambiare il percorso di default di creazione file temporanei
   ****************************************************************************
   IF !EMPTY(cDefTemp) 
      cDefTemp := dfPathChk(cDefTemp) + GETENV("USERNAME")
      IF (dfChkDir(cDefTemp) .OR. ;
          dfMD(cDefTemp) == 0)

         cTemp := cDefTemp
      ENDIF
   ENDIF

cTemp := dfPathChk( cTemp )
IF !FILE( cTemp+"NUL" )
   cTemp := dfPathChk( dfExePath() )
ENDIF
RETURN cTemp
