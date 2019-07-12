//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per Stampe
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "Common.ch"
#INCLUDE "dfReport.ch" // Struttura Report e Virtual record
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfVRGet( aVRec, cFile ) // Prende un VR ad un record aggiunto
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos         // Posizione del file nel record virtuale
LOCAL aRet

nPos := aScan( aVRec, {|aRow| aRow[VR_NAME] == UPPER(PADR(cFile,8)) } )
IF nPos==0
   DO WHILE ++nPos<=LEN(aVRec) .AND. EMPTY(aRet)
      aRet := dfVRGet( aVRec[nPos][VR_CHILD], cFile )
   END
ELSE
   aRet := aVRec[nPos]
END

RETURN aRet
