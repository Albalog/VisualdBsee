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

XPPRET XPPENTRY DFSIN( XppParamList paramList ){
   _retnd( paramList, sin( _parnd( paramList, 1 ) ) );
}
