//*****************************************************************************
//Progetto       : dBsee 4.1
//Descrizione    : Funzioni di utilita'
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "directry.ch"
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
FUNCTION dfFileDate( cFile )
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
LOCAL aFile, dRet:=ctod("")
IF cFile != nil
   aFile := DIRECTORY( cFile )
   AEVAL( aFile, {|x|dRet:=x[F_DATE]} )
ENDIF
RETURN dRet
