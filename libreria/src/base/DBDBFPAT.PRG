//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per PATH
//Programmatore  : Baccan Matteo
//*****************************************************************************
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dbdbfPath( nPath, cNewPath ) // Ritorna uno dei 99 path dei file dati
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
// L'STR su PADL() non servirebbe ma ... provate a mettere SET FIXED ON
// Quel babbeo di clipper ci mette in coda i .00 e il PADL non va a buon fine
RETURN dbCfgPath( "UserPath" +PADL( ALLTRIM(STR(nPath)) ,2,"0" ), cNewPath )
