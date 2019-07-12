//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Funzioni di Utilita' per APP
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "dfUsr.ch"
#INCLUDE "dfSet.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfSetApp(aApp)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
#ifndef __XPP__
M_CurOff()
DO CASE
   CASE EMPTY(aApp[AI_CONSOLELINES])
   CASE aApp[AI_CONSOLELINES]==25 ; SETMODE( 25, MAXCOL()+1)
   CASE aApp[AI_CONSOLELINES]==50 ; SETMODE( 50, MAXCOL()+1)
ENDCASE
dfArrUsr()[USR_TOP]   := MAXROW()
dfArrUsr()[USR_RIGHT] := MAXCOL()
M_CurOn()
#endif
RETURN
