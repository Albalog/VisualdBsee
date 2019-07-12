//*****************************************************************************
//Progetto       : Generato dBsee 4.0
//Descrizione    : Utility per le configurazioni
//Programmatore  : Baccan Matteo
//*****************************************************************************

//#include <extend.api>
//#include <fm.api>
//#include <string.h>
#include <windows.h>
#include <xppdef.h>
#include <xpppar.h>
#include <xppcon.h>
#include "dBsee4x.h"

//CLIPPER dfFp2Bin(){
XPPRET XPPENTRY DFFP2BIN( XppParamList paramList ){
   DOUBLE dValue=_parnd(paramList, 1);
   _retclen(paramList, (char*)&dValue,8);
}
