PROCEDURE tbTotal( oTbr, lDisplay )                   // Totali di colonna
   oTbr:tbTotal( lDisplay )
RETURN 

PROCEDURE tbIcv( oTbr )                     // Incremento totali di colonna
   oTbr:tbIcv()
RETURN 

PROCEDURE tbDcv( oTbr )                     // Cancella Totali di colonna
   oTbr:tbDcv()
RETURN 

FUNCTION tbGcv( oTbr, cId )                 // Get Totali di colonna
RETURN oTbr:tbGcv( cId )
