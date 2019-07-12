//*****************************************************************************
//Progetto       : dBsee 4.1
//Descrizione    : Funzioni di utilita' per FILE
//Programmatore  : Baccan Matteo
//*****************************************************************************

// Aggiungere Pentium con BUG

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfCpuId() // Nome della CPU attuale
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nCpu := dfCpu(), cRet := ""
DO CASE
   CASE nCpu==0; cRet:= "8088"
   CASE nCpu==1; cRet:= "8086"
   CASE nCpu==2; cRet:= "80286"
   CASE nCpu==3; cRet:= "80386"
   CASE nCpu==4; cRet:= "80486"
   CASE nCpu==5; cRet:= "Pentium"
ENDCASE
RETURN cRet
