//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per Stampe
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "dfReport.ch" // Struttura Report e Virtual record
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfVRCreate() // Crea entry per VR
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN { ;
         NIL                              ,; // File Name
         { 1, NIL, {||.T.}, {||.F.}, {} } ,; // Condition
         VR_IGNORE                    ,; // Eof MODE
         .F.                          ,; // Eject After Body
         { ;                             // Code Block
           NIL, 0, .T.,  0 , {||.T.},;   // Header, Righe, Salto pagina, Posizione, CB Permessi
           NIL, 0, .T., .F., NIL, .F., {||.T.}, .F., .F., NIL, NIL, NIL, {||.T.}, NIL, NIL, NIL, {||.T.}, ;  // Body, Righe, Salto pagina, Eject, Fill, Head, row foot, footer
           NIL, 0, .T.,  0 , {||.T.},;   // Footer, Righe, Salto pagina, Posizione, CB Permessi
         }                            ,; // Header / Body / Footer
         {||NIL},; // CALC_CLEAR
            NIL ,; // CALC_ADD
         {||NIL},; // PRECALC_CLEAR
            NIL ,; // PRECALC_ADD
         { }                          ,; // Group
         { }                          ,; // Child
         .F.                          ,; // Stable
         NIL                          ,; // Skip array
         1                             ; // Skip array pos
       }
