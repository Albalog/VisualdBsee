//Maudp-LucaC XL 3878 21/03/2013 Aggiunto lForce per fare il refresh forzato sulle listbox (attualmente lo faceva solo in presenza di tag)
//FUNCTION tbDisItm( oWin, cGrp); RETURN oWin:tbDisItm(cGrp)
FUNCTION tbDisItm( oWin, cGrp ,lForce); RETURN oWin:tbDisItm(cGrp,lForce)
FUNCTION tbDisRef( oWin, cRId ); RETURN oWin:tbDisRef(cRId)
FUNCTION tbDisGrp( oWin, cRId ); S2FU(); RETURN NIL
FUNCTION tbDisCal( oWin, cRId ); RETURN oWin:tbDisCal(cRId)
