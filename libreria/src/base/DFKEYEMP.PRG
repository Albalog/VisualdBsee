//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per INKEY
//Programmatore  : Baccan Matteo
//*****************************************************************************
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfKeyEmpty()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL uVar := VALTYPE( &(ORDKEY(ORDSETFOCUS())) )
LOCAL bRet

DO CASE
   CASE uVar=="C" ;bRet:={||""}
   CASE uVar=="D" ;bRet:={||CTOD("01/01/01")} // MA !!!!!!!!!!!!!!!!!!
   CASE uVar=="N" ;bRet:={||0}
ENDCASE

RETURN bRet
