//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' VARIE
//Programmatore  : Baccan Matteo
//*****************************************************************************
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfChkDir( cDir )      // Controllo Path
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T.

IF EMPTY( cDir:=ALLTRIM(cDir) )
   lRet := .F.
ENDIF

// simone 29/11/06
// mantis 0001175: supportare percorsi UNC
IF lRet 
   // simone 9/06/2010 per velocizzare controllo prima se esiste la cartella "." es "c:\windows\."
   IF EMPTY( DIRECTORY( dfPathChk(cDir)+"." ,"D" ) ) .AND. ; // velocizza ma non funziona sempre es \\srvconta\shared\.
      EMPTY( DIRECTORY( dfPathChk(cDir) ,"D" ) )

      lRet := .F.
   ENDIF
ENDIF

RETURN lRet
