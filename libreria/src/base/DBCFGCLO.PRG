//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per Configurazioni
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfStd.ch"
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
PROCEDURE dbCfgClose( cfile ) // chiude il file di configurazione
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
IF DFISSELECT( cFile )
   (cFile)->(dbCloseArea())
ENDIF
RETURN
