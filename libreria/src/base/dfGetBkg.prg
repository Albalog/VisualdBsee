/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "common.ch"
#include "DFXRES.CH"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfGetBkg( nBkg )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
// I valori vanno da 0 a 99.
LOCAL cRet := ""

DEFAULT nBkg TO 99
nBkg := INT(nBkg)

DO CASE
   CASE nBkg>0 .AND. nBkg<99 //21
        cRet := ALLTRIM(STR( GET_BTN_DOWNARROWBMP +INT(nBkg)        ))

   CASE nBkg==99
        // Random
        cRet := ALLTRIM(STR( GET_BTN_DOWNARROWBMP +INT(dfRnd()*19)+1))
ENDCASE

RETURN cRet
