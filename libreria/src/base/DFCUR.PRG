//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per Disco
//Programmatore  : Baccan Matteo
//*****************************************************************************
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfCurPath() // Torna il curdir + il drive
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
// simone 29/11/06
// mantis 0001175: supportare percorsi UNC
RETURN dfPathGet() //Chr(dfDisk()) +":\" +CurDir()
