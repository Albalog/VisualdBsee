#include "dfXBase.ch"
#include "dll.ch"

//xl4667 
//Mantis 2263 Luca 17/11/2015
FUNCTION dfGetOsver()
   LOCAL nDll, cCall1, cCall2
   LOCAL nResult 
   LOCAL cArray  := ""
   LOCAL cBin    := ""
   LOCAL cFile   := ""
   LOCAL cTxt    := ""
   LOCAL cStr    := ""
   LOCAL nPos1, nPos2
   LOCAL nLen
   LOCAL cVer    := ""

//Maudp 23/12/2015 XL 4684 Utilizzo le funzioni di windows per stabilire la versione del sistema operativo
/*
 RunShell( "/C VER>_VER_.txt",,, .T.)
 Sleep(10)
 IF FILE(dfexepath()+"_VER_.txt")
    cTxt := MEMOREAD(dfexepath()+"_VER_.txt")
    cTxt := Upper(cTxt) 
    IF !"[VERSION" $ cTxt 
       RETURN nResult
    ENDIF 
    nPOS1 := AT("[VERSION",cTxt)
    nPOS1 += LEN("[VERSION")
    nPOS2 := AT("]",cTxt)
    IF nPOS1<=0 .AND. nPOS2 <=0
       RETURN nResult
    ENDIF 
    IF !dfIsDigit(cTxt[nPOS1+1] ) 
       nPOS1++
    ENDIF 
    IF !dfIsDigit(cTxt[nPOS1+1] ) 
       nPOS1++
    ENDIF 
    IF !dfIsDigit(cTxt[nPOS1+1] ) 
       nPOS1++
    ENDIF 
    IF !dfIsDigit(cTxt[nPOS1+1] ) 
       nPOS1++
    ENDIF 
    cStr    := SubStr(cTxt,nPOS1,nPOS2-nPOS1 )

    nResult := cStr
 ENDIF 
 FErase(dfexepath()+"_VER_.txt")
*/

//   nDll := DllLoad( "KERNEL32.DLL")
   nDll := DllLoad( "ntdll.dll")
   IF nDll != 0
      cCall2 := DllPrepareCall( nDLL, DLL_STDCALL, "RtlGetVersion")
      IF LEN( cCall2) != 0
         cArray  := U2BIN(0)+U2BIN(0)+U2BIN(0)+U2BIN(0)+SPACE(128) //{0,0,0,0,0,Space(128)} 
         nLen :=  LEN(U2BIN(0)+cArray)
         cArray := U2BIN(nLen)+cArray

         nResult := DLLExecuteCall( cCall2, @cArray )
      ENDIF

      IF nResult == 0
         //VersioneMaggiore.VersioneMinore.VersioneBuild
         cVer := ALLTRIM(STR(BIN2U(substr(cArray,5,4)))) + "." + ALLTRIM(STR(BIN2U(substr(cArray,9,4))))+"."+ALLTRIM(STR(BIN2U(substr(cArray,13,4))))
      ENDIF

  ENDIF 




RETURN cVer

