/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function for Alaska Xbase++
Programmer  : Baccan Matteo
******************************************************************************/

#include <windows.h>
#include <xppdef.h>
#include <xpppar.h>
#include <xppcon.h>

XPPRET XPPENTRY DFAND( XppParamList paramList ){
   _retnl( paramList, _parnl( paramList, 1 ) & _parnl( paramList, 2 ) );
}
