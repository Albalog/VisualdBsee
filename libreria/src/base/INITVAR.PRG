//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Inizializzazione Variabili PUBLIC
//Programmatore  : Baccan Matteo
//*****************************************************************************

* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
PROCEDURE dfInitVar() // Dichiara PUBLIC
* 北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
MEMVAR EnvId, SubId
MEMVAR A, Sa, Act
MEMVAR dfHotFun
//FWH: 2021-03-17
MEMVAR INFOTEL_LAST_MENU_PROMPT

// Help
PUBLIC EnvId := ""
PUBLIC SubId := ""

// Usr
PUBLIC A   := 0      // peso ascii del tasto premuto
PUBLIC Sa  := " "    // caratter minuscolo relativo al tasto premuto
PUBLIC Act := "   "  // azione contenente tre caratteri mnemonici

PUBLIC dfHotFun := "dfCalc" // Funzione associata al tasto caldo

//FWH: 2021-03-17
PUBLIC INFOTEL_LAST_MENU_PROMPT := "" // memorizza il nome dell'ultima voce di menu cliccata

RETURN
