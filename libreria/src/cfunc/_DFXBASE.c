/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function for Alaska Xbase++
Programmer  : Baccan Matteo
******************************************************************************/

#include <windows.h>
#include <xppdef.h>
#include <xpppar.h>
#include <xppcon.h>

XPPRET XPPENTRY DFXBASESTRING( XppParamList paramList ){
   char *nPar = (char *)_parnl( paramList, 1 );
   _retc( paramList, nPar );
}
