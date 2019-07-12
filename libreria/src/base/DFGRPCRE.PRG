//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per Stampe
//Programmatore  : Baccan Matteo
//*****************************************************************************
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfGrpCreate() // Crea un gruppo per VR
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN { ;
         {||NIL}        ,; // Blocco
         NIL, 0, .T., 0 , {||.T.},; // Header, row, break, pos, condition
         NIL, 0, .T., 0 , {||.T.},; // Footer, row, break, pos, condition
         .F.            ,; // Eject After footer
         {||NIL}, NIL   ,; // Precal clear, add
         {||NIL}        ,; // Calcl clear
         NIL             } // Compare
