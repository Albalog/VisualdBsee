//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' VARIE
//Programmatore  : Baccan Matteo
//*****************************************************************************
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfS( uOrd, uSeek, lSoft )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

// simone 31/01/08 
// ripristinato funzionamento originale perchŠ il PDR 2799 Š risolto da tempo 
// (testato su 1.82 e 1.90)
// e il &(INDEXKEY()) sulla 1.82 d… un IDSC a bellanti GERR 5076
//
//#ifdef __XPP__
//   // Workaround per xBase PDR 109-2799
//   LOCAL lRet
//   ORDSETFOCUS(uOrd)
//
//   IF SET( _SET_EXACT) .OR. ! VALTYPE(uSeek) == "C"
//      lRet := DBSEEK(uSeek,lSoft)
//   ELSE
//      lRet := DBSEEK( LEFT( uSeek, LEN( &(INDEXKEY()) ) ), lSoft )
//   ENDIF
//
//   RETURN lRet
//#else
//   // Funzione standard dbsee
//   RETURN (ORDSETFOCUS(uOrd),DBSEEK(uSeek,lSoft))
//#endif

// Simone 28/10/09 
// non uso ORDSETFOCUS_XPP perchè controllo prima (è più veloce)
IF ORDNUMBER() != uOrd // simone 28/10/09 velocizza su ADS
ORDSETFOCUS(uOrd)
ENDIF
RETURN DBSEEK(uSeek, lSoft)
