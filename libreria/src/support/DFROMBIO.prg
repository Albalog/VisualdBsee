/******************************************************************************
Project     : dBsee for Xbase++
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfRomBios()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cRet       := ""
LOCAL nHKey      := "HKEY_LOCAL_MACHINE"
LOCAL cKeyName   := "HARDWARE\DESCRIPTION\System"
LOCAL cEntryName := "SystemBiosDate"

//if dfWinIs95() .OR. dfWinIs98()
if dfOSFamily() == "WIN9X"
   cKeyName   := "Enum\Root\*PNP0C01\0000"
   cEntryName := "BIOSDate"
endif

cRet := dfQueryRegistry(nHKey, cKeyName, cEntryName)

IF LEN(ALLTRIM(cRet))!=8
   cRet := "01/01/80"
ENDIF

RETURN cRet
