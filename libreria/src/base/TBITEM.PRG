//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per BROWSE su ARRAY
//Programmatore  : Baccan Matteo
//*****************************************************************************
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION tbItem( oTbr ) //
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
#ifdef __XPP__
RETURN EVAL( oTbr:GETCOLUMN( oTbr:COLPOS ):DATALINK )
#else
RETURN EVAL( oTbr:GETCOLUMN( oTbr:COLPOS ):BLOCK )
#endif
