//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Inizializzazione Variabili PUBLIC
//Programmatore  : Baccan Matteo
//*****************************************************************************

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfInitVar() // Dichiara PUBLIC
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
MEMVAR EnvId, SubId
MEMVAR A, Sa, Act
MEMVAR dfHotFun

// Help
PUBLIC EnvId := ""
PUBLIC SubId := ""

// Usr
PUBLIC A   := 0      // peso ascii del tasto premuto
PUBLIC Sa  := " "    // caratter minuscolo relativo al tasto premuto
PUBLIC Act := "   "  // azione contenente tre caratteri mnemonici

PUBLIC dfHotFun := "dfCalc" // Funzione associata al tasto caldo

RETURN
