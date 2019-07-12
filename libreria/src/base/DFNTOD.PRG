/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "Set.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfNtoD( nDD, nMM, nYY )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL dDate, cOld

cOld := SET( _SET_DATEFORMAT, "dd/mm/yyyy" )
dDate := CTOD( PADL(nDD,2,"0") +"/" +PADL(nMM,2,"0") +"/" +PADL(nYY,4,"0") )
SET( _SET_DATEFORMAT, cOld )

RETURN dDate
