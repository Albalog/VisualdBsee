/*******************************************************************************
Progetto       : dBsee 4.3
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
*******************************************************************************/
#include "dfstd.ch"
#include "dfwin.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE tbPos( oTbr )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
DO CASE
   CASE oTbr:W_DEFAULTPOSITION==W_POSITIONTOP
        tbTop( oTbr )

   CASE oTbr:W_DEFAULTPOSITION==W_POSITIONBOTTOM
        //DFDISPBEGIN()
        //tbTop( oTbr )    // Calcola i totali
        tbBottom( oTbr, .T. ) // e manda in fondo
        //DFDISPEND()
ENDCASE
RETURN
