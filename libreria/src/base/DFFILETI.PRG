//*****************************************************************************
//Progetto       : dBsee 4.1
//Descrizione    : Funzioni di utilita'
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "directry.ch"
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfFileTime( cFile )
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL aFile, cRet:="00:00:00"
IF cFile != nil
   aFile := DIRECTORY( cFile )
   AEVAL( aFile, {|x|cRet:=x[F_TIME]} )
ENDIF
RETURN cRet
