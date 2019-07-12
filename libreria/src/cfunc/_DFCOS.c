/******************************************************************************
Project     : dBsee 4.6
Description : Utilities Function for Alaska Xbase++
Programmer  : Baccan Matteo
******************************************************************************/

#include <windows.h>
#include <xppdef.h>
#include <xpppar.h>
#include <xppcon.h>

#include <math.h>

XPPRET XPPENTRY DFCOS( XppParamList paramList ){
   _retnd( paramList, cos( _parnd( paramList, 1 ) ) );
}
