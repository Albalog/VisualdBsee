//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per Configurazioni
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfStd.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dbCfgClose( cfile ) // chiude il file di configurazione
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
IF DFISSELECT( cFile )
   (cFile)->(dbCloseArea())
ENDIF
RETURN
