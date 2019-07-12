#include "dll.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfDskSer( nDrive )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cVolRoot, cFSName, nVolSerial, nMaxNameLen, nFSFlags
LOCAL nDll, cCall
LOCAL cVolName:=space(128)
LOCAL nResult, aResult

//<nDrive>   Disk drive (1=A:, 2=B:, 3=C:,...0=default drive)

// simone 29/11/06
// mantis 0001175: supportare percorsi UNC
IF VALTYPE(nDrive) $ "CM"
   cVolRoot := dfPathRoot(nDrive) 
ELSEIF nDrive==NIL .OR. nDrive==0
   cVolRoot := dfPathGet() //CurDrive() + ":\"
ELSE
   cVolRoot := CHR(64+nDrive) + ":\"
ENDIF
cVolRoot := dfPathChk(cVolRoot)

cFSName := space(128)
nVolSerial := 0
nMaxNameLen := 0
nFSFlags := 0

//aResult := {}
aResult := 0
/*
 * The call via Prepare/Execute is very useful if you want to call
 * an API, but hide it's interface and instead, process the values
 * more comfortable like Xbase++ understands an interface
 * and / or you need to call the API more than once.
 */
nDll := DllLoad( "KERNEL32.DLL")
IF nDll != 0
   cCall := DllPrepareCall( nDLL, DLL_STDCALL, "GetVolumeInformationA")
   IF len( cCall) != 0

       nResult := DLLExecuteCall( cCall,;
                                  @cVolRoot,;
                                  @cVolName,;
                                  len( cVolName ),;
                                  @nVolSerial,;
                                  @nMaxNameLen,;
                                  @nFSFlags,;
                                  @cFSName,;
                                  len( cFSName ) )
       IF nResult != 0
            //AAdd( aResult, cVolRoot )
            //AAdd( aResult, rtrim(cVolName) )
            /*
             * interpret the serial-number as unsigned long
             */
            //AAdd( aResult, ltrim(str(Bin2U(L2Bin(nVolSerial)))) )
            //AAdd( aResult, ltrim(str(nFSFlags)) )
            //AAdd( aResult, cFSName )
            aResult := Bin2U(L2Bin(nVolSerial))
       ENDIF
   ENDIF
   DllUnload(nDll)
ENDIF
RETURN aResult
