// PROCEDURE MAIN()
//
//    // typedef struct _MEMORYSTATUS { // mst
//    //     DWORD dwLength;        // sizeof(MEMORYSTATUS)
//    //     DWORD dwMemoryLoad;    // percent of memory in use
//    //     DWORD dwTotalPhys;     // bytes of physical memory
//    //     DWORD dwAvailPhys;     // free physical memory bytes
//    //     DWORD dwTotalPageFile; // bytes of paging file
//    //     DWORD dwAvailPageFile; // free bytes of paging file
//    //     DWORD dwTotalVirtual;  // user bytes of address space
//    //     DWORD dwAvailVirtual;  // free user bytes
//    // } MEMORYSTATUS, *LPMEMORYSTATUS;
//    //
//    //
//    //
//    // dwLength
//    //
//    //    Indicates the size of the structure.
//    //    The calling process should set this member prior
//    //    to calling GlobalMemoryStatus.
//    //
//    // dwMemoryLoad / S2GFR_MEMORYLOAD
//    //
//    //    Specifies a number between 0 and 100 that gives
//    //    a general idea of current memory utilization,
//    //    in which 0 indicates no memory use and 100 indicates full memory use.
//    //
//    // dwTotalPhys / S2GFR_TOTALPHYS
//    //
//    //    Indicates the total number of bytes of physical memory.
//    //
//    // dwAvailPhys / S2GFR_AVAILPHYS
//    //
//    //    Indicates the number of bytes of physical memory available.
//    //
//    // dwTotalPageFile / S2GFR_TOTALPAGEFILE
//    //
//    //    Indicates the total number of bytes that can be stored
//    //    in the paging file. Note that this number does not represent
//    //    the actual physical size of the paging file on disk.
//    //
//    // dwAvailPageFile / S2GFR_AVAILPAGEFILE
//    //
//    //    Indicates the number of bytes available in the paging file.
//    //
//    // dwTotalVirtual / S2GFR_TOTALVIRTUAL
//    //
//    //    Indicates the total number of bytes that can be described
//    //    in the user mode portion of the virtual address space of
//    //    the calling process.
//    //
//    // dwAvailVirtual / S2GFR_AVAILVIRTUAL
//    //
//    //    Indicates the number of bytes of unreserved and
//    //    uncommitted memory in the user mode portion of the virtual
//    //    address space of the calling process.
//
//    LOCAL a := S2GetFreeResource()
//
//    IF EMPTY(a)
//       ? "Error"
//    ELSE
//
//       ? a[S2GFR_AVAILVIRTUAL]
//
//    ENDIF
//
// RETURN

#include "dll.ch"
#include "dfGFRes.ch"

// Declare Function pBGetFreeSystemResources Lib "rsrc32.dll" Alias
//                  "_MyGetFreeSystemResources32@4" _
//                  (ByVal iResType As Integer) As Integer
//
//
// Private Sub cmdGo_Click()
//    Const SR = 0
//    Const GDI = 1
//    Const USR = 2
//
//    lblUser = CStr(pBGetFreeSystemResources(USR))
//    lblSystem = CStr(pBGetFreeSystemResources(SR))
//    lblGDI = CStr(pBGetFreeSystemResources(GDI))
// End Sub

#define _SYS 0
#define _GDI 1
#define _USR 2

FUNCTION S2GetFreeRes95()
   LOCAL nDll
   LOCAL cCall
   LOCAL nUsr
   LOCAL nGDI
   LOCAL nSys
   LOCAL aRet    := NIL

   nDll := DllLoad( "RSRC32.DLL" )

   IF nDll != 0
      cCall := DllPrepareCall( nDLL, DLL_STDCALL, "_MyGetFreeSystemResources32@4")

      IF LEN(cCall) != 0

         nSys := DLLExecuteCall( cCall, _SYS )
         nGDI := DLLExecuteCall( cCall, _GDI )
         nUsr := DLLExecuteCall( cCall, _USR )

         aRet := {nSys, nUsr, nGDI}

      ENDIF

      DllUnLoad(nDll)
   ENDIF

RETURN aRet

FUNCTION S2GetFreeResourcePerc()
    LOCAL aRes := S2GetFreeResource()
    LOCAL aRet := NIL

    IF ! EMPTY(aRes)
       aRet := ARRAY(S2GFRP_NUMELEM)

       aRet[S2GFRP_MEMORYLOAD] := aRes[S2GFR_MEMORYLOAD]
       aRet[S2GFRP_PHYS]       := aRes[S2GFR_AVAILPHYS ]   * 100 / ;
                                  aRes[S2GFR_TOTALPHYS]
       aRet[S2GFRP_PAGEFILE]   := aRes[S2GFR_AVAILPAGEFILE]* 100 / ;
                                  aRes[S2GFR_TOTALPAGEFILE]
       aRet[S2GFRP_VIRTUAL]    := aRes[S2GFR_AVAILVIRTUAL] * 100 / ;
                                  aRes[S2GFR_TOTALVIRTUAL]
    ENDIF
RETURN aRet


FUNCTION S2GetFreeResource()
   LOCAL aBin
   LOCAL cBin
   LOCAL nDll
   LOCAL cCall
   LOCAL nResult := -1
   LOCAL aRet    := NIL

   nDll := DllLoad( "KERNEL32.DLL" )

   IF nDll != 0
      cCall := DllPrepareCall( nDLL, DLL_STDCALL, "GlobalMemoryStatus")

      IF LEN(cCall) != 0

         /*
         typedef struct _MEMORYSTATUS {
             DWORD dwLength;
             DWORD dwMemoryLoad;
             DWORD dwTotalPhys;
             DWORD dwAvailPhys;
             DWORD dwTotalPageFile;
             DWORD dwAvailPageFile;
             DWORD dwTotalVirtual;
             DWORD dwAvailVirtual;
         } MEMORYSTATUS, *LPMEMORYSTATUS;
         */
         cBin := ""
         cBin += CHR(32) +CHR(0) +CHR(0) +CHR(0)
         cBin += CHR(0)  +CHR(0) +CHR(0) +CHR(0)
         cBin += CHR(0)  +CHR(0) +CHR(0) +CHR(0)
         cBin += CHR(0)  +CHR(0) +CHR(0) +CHR(0)
         cBin += CHR(0)  +CHR(0) +CHR(0) +CHR(0)
         cBin += CHR(0)  +CHR(0) +CHR(0) +CHR(0)
         cBin += CHR(0)  +CHR(0) +CHR(0) +CHR(0)
         cBin += CHR(0)  +CHR(0) +CHR(0) +CHR(0)
         nResult := DLLExecuteCall( cCall, @cBin )

         IF ! nResult == 0

            // OK
            aRet := {}
            AADD(aRet, BIN2L(SUBSTR(cBin, 5,4)) )
            AADD(aRet, BIN2L(SUBSTR(cBin, 9,4)) )
            AADD(aRet, BIN2L(SUBSTR(cBin,13,4)) )
            AADD(aRet, BIN2L(SUBSTR(cBin,17,4)) )
            AADD(aRet, BIN2L(SUBSTR(cBin,21,4)) )
            AADD(aRet, BIN2L(SUBSTR(cBin,25,4)) )
            AADD(aRet, BIN2L(SUBSTR(cBin,29,4)) )

         ENDIF
      ENDIF

      DllUnLoad(nDll)
   ENDIF

RETURN aRet
