
#include "dfInt86.ch"
#include "dfSet.ch"
#include "Dbstruct.ch"
#include "Common.ch"
#include "LibApps.ch"
#include "LibSys.ch"
#include "dfMsg.ch"
#include "error.ch"
#include "LibFBin.ch"
#include "dfStd.ch"
#include "NLS.ch"

#include "dbfdbe.ch"
#include "foxdbe.ch"
#include "ntxdbe.ch"
#include "cdxdbe.ch"
#include "class.ch"
#include "directry.ch"

#include "dll.ch"



#ifdef __XPP__
/*
 * The required functions are part of the runtime library.
 */

// ritorna CPU attive (1 bit = 1 CPU)
// per referenza ritorna array di CPU su cui gira l'applicazione (processo)
FUNCTION S2SmpGetCPU(aArr)
#if 1=1  //XPPVER < 01900000
   LOCAL nRet := DllCall("Xpprt1.dll",DLL_CDECL, "_sysGetCPU")
#else
   LOCAL nDll := 0
   LOCAL nRet := 1
   nDll := DLLLoad("asmp10.dll")
   IF nDll != 0 
      nRet := DLLCall(nDll, NIL, "_MPSETCPU")
      DLLUnload(nDll)
   ENDIF
#endif
   aArr := BitSet2Array(nRet)
RETURN nRet

// Imposta la CPU da usare per l'applicazione (processo)
// ritorna
//    0=impossibile imopstare
//  <>0=ok
FUNCTION S2SmpSetCPU(nCpuMask)
   LOCAL rc := 0
   LOCAL nDll := 0
   LOCAL nRet := 1

#if 1=1  //XPPVER < 01900000
   IF ! EMPTY(nCpuMask)
     rc := DllCall("Xpprt1.dll",DLL_CDECL, "_sysSetCPU", nCpuMask)
   ENDIF
#else
   IF ! EMPTY(nCpuMask)
      nDll := DLLLoad("asmp10.dll")
      IF nDll != 0 
         nRet := DLLCall(nDll, NIL, "_MPSETCPU", nCpuMask)
         IF S2SmpGetCpu() == nCpuMask
            rc := 1
         ENDIF
         DLLUnload(nDll)
      ENDIF
   ENDIF
#endif
RETURN rc

STATIC FUNCTION BitSet2Array(n)
   LOCAL i
   LOCAL aSet:= {}
   // transform mask to array
   FOR i:= 1 TO 32
       IF n[i]
           AAdd(aSet, i)
       ENDIF
   NEXT
RETURN aSet

// ritorna il numero di CPU del PC
FUNCTION S2GetCPUMax()
   STATIC nCPU
   LOCAL  n := 0
   LOCAL  nOld
   LOCAL nDll

   IF nCpu == NIL

#if XPPVER < 01900000
      nOld := S2SmpGetCPU()
      DO WHILE .T.
         ++n
         IF S2SmpSetCpu(n+1) == 0
            nCpu := n
            EXIT
         ENDIF
      ENDDO
      S2SmpSetCPU(nOld)
#else
      nCpu := 1

      nDll := DLLLoad("asmp10.dll")
      IF nDll != 0 
         nCpu := DLLCall(nDll, NIL, "_MPNUMPROCESSORS")
         DLLUnload(nDll)
      ENDIF
#endif
   ENDIF
RETURN nCPU

// Cambia in automatico la CPU in uso
// disabilitato, per farlo fare a Windows usare
// nel file di risorse .ARC
//   /*
//    * Allow the process to run on multiple processors
//    */
//   VERSION
//          "ProcAffinity" = "255"
//
//   /*
//    * This value would set the process to CPU 1
//    * VERSION
//    *        "ProcAffinity" = "1"
//    */
//
//FUNCTION S2SetCPUSwitch(n)
//   STATIC oCPU
//   STATIC nCpu := 0
//   IF oCpu == NIL .AND. ! EMPTY(n) .AND. S2GetCPUMax() > 1
//      oCpu := Thread():new()
//      oCpu:setInterval( n )
//      oCpu:start({|| nCPU:=IIF(nCPU < S2GetCPUMax(), nCPU+1, 1), S2SmpSetCpu(nCPU) })
//   ENDIF
//RETURN oCPU
#endif

