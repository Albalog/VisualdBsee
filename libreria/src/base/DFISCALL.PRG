/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/
#include "common.ch"

* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfIsCaller( cName, nPos )
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL lIsCaller := .F., cSub

DEFAULT nPos TO 0

cName := UPPER(cName)

WHILE !EMPTY(cSub:=PROCNAME(nPos)) .AND. !lIsCaller
   lIsCaller := (UPPER(cSub)==cName)
   nPos++
ENDDO

RETURN lIsCaller
