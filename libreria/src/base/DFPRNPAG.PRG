//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per Stampe
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "dfReport.ch" // Struttura Report e Virtual record
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfPrnPage()  // Pagina corrente
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
RETURN dfPrnArr()[REP_ACT_PAGE]
