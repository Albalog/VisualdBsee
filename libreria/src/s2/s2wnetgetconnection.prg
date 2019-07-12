#include "dll.ch"
#include "common.ch"

//#define _TEST_

#ifdef _TEST_
proc main(x)
   LOCAL nERr, cShare
   cShare := S2WNetGetConnection(x, @nErr)
   ? cShare, nErr
return
#endif


// Es: S2WNetGetConnection("H:") -> "\\srv2003\shared"
// Es: S2WNetGetConnection("C:") -> NIL
FUNCTION S2WNetGetConnection(cDrive, @nErr)
LOCAL cRet  := NIL
LOCAL cBuff := SPACE(256)
LOCAL nLen  := LEN(cBuff)

DEFAULT cDrive TO CurDrive()

IF LEN(cDrive)==1 
   cDrive += ":"
ENDIF

nErr := DllCall("MPR.DLL", DLL_STDCALL, "WNetGetConnectionA", cDrive, @cBuff, @nLen)
IF nErr == 0 // NO_ERROR
   cRet := dfGetCString(cBuff) //LEFT(cBuff, nLen)
ENDIF

RETURN cRet