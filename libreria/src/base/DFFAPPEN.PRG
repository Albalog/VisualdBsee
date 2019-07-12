//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per FILE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "dfFile.ch"
#INCLUDE "fileio.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfFAppend( cStr )      // Append di una riga
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FSEEK( dfFActual()[FL_HANDLE], 0, FS_END )
FWRITE( dfFActual()[FL_HANDLE], cStr +dfFActual()[FL_SEPCHAR] )
RETURN
