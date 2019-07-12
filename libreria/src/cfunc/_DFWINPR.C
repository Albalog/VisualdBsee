#include <windows.h>
#include <winspool.h>
#include "xppdef.h"
#include "xpppar.h"
#include "xppcon.h"

// Torna un array con i dati delle porte logiche definite in Windows
// o NIL se c'Š un errore. Necessita WinSpool.lib per il link.

XPPRET XPPENTRY DFWINPRINTERSGET(XppParamList paramList )
{
   DWORD dwNeeded = 0, dwCount = 0, dwBufferLen=0, nInd=0;
   DWORD dwFlags = PRINTER_ENUM_LOCAL;
   BOOL bRet;
   unsigned int uiLen;
   PRINTER_INFO_2 *pPrinter = NULL;
   LPTSTR pPrinterName = NULL;
   ContainerHandle  chArray = NULLCONTAINER;
   ContainerHandle  chTmp = NULLCONTAINER;
   MomHandle hGlobal = MOM_NULLHANDLE, hPrinterName = MOM_NULLHANDLE;

   if( PCOUNT(paramList)>=1 && XPP_IS_NUM(_partype(paramList,1)) )
       dwFlags = _parnl( paramList, 1);

   if( PCOUNT(paramList)>=2 && XPP_IS_CHAR(_partype(paramList,2)) )
   {

       uiLen = _parclen( paramList, 2 );
       if (uiLen > 0)
       {
          hPrinterName = _momAlloc( sizeof(char)*(uiLen+1) );
          if( hPrinterName != MOM_NULLHANDLE )
          {
             pPrinterName = _momLock( hPrinterName );
            _parc( pPrinterName, uiLen +1, paramList, 2);
          }
       }
   }

   bRet = EnumPrinters(dwFlags, pPrinterName, 2, (LPBYTE) pPrinter,
                       dwBufferLen, &dwNeeded, &dwCount );

   if( dwNeeded > 0)
   {
      hGlobal = _momAlloc(dwNeeded);
      if( hGlobal != MOM_NULLHANDLE )
      {
        dwBufferLen = dwNeeded;
        pPrinter = (PRINTER_INFO_2 *)_momLock(hGlobal);
        bRet = EnumPrinters(dwFlags, pPrinterName, 2, (LPBYTE) pPrinter,
                            dwBufferLen, &dwNeeded, &dwCount );

      }
   }

   if (bRet != 0 && pPrinter != NULL)
   {
      chArray = _conNewArray(2, dwCount, 21); // 21 = num. elementi PRINTER_INFO_2
      chTmp = _conNew(NULLCONTAINER);

      if (chArray != NULLCONTAINER  &&  chTmp != NULLCONTAINER)
        for (nInd=0; nInd < dwCount; nInd++)
        {

          if (pPrinter[nInd].pServerName != NULL)
          {
            if (_conPutC(chTmp, pPrinter[nInd].pServerName) != chTmp)
              break;
            if (_conArrayPut(chArray, chTmp, nInd+1, 1, 0) != 0)
              break;
          }

          if (pPrinter[nInd].pPrinterName != NULL)
          {
            if (_conPutC(chTmp, pPrinter[nInd].pPrinterName) != chTmp)
              break;
            if (_conArrayPut(chArray, chTmp, nInd+1, 2, 0) != 0)
              break;
          }

          if (pPrinter[nInd].pShareName != NULL)
          {
            if (_conPutC(chTmp, pPrinter[nInd].pShareName) != chTmp)
              break;
            if (_conArrayPut(chArray, chTmp, nInd+1, 3, 0) != 0)
              break;
          }

          if (pPrinter[nInd].pPortName != NULL)
          {
            if (_conPutC(chTmp, pPrinter[nInd].pPortName) != chTmp)
              break;
            if (_conArrayPut(chArray, chTmp, nInd+1, 4, 0) != 0)
              break;
          }

          if (pPrinter[nInd].pDriverName != NULL)
          {
            if (_conPutC(chTmp, pPrinter[nInd].pDriverName) != chTmp)
              break;
            if (_conArrayPut(chArray, chTmp, nInd+1, 5, 0) != 0)
              break;
          }

          if (pPrinter[nInd].pComment != NULL)
          {
            if (_conPutC(chTmp, pPrinter[nInd].pComment) != chTmp)
              break;
            if (_conArrayPut(chArray, chTmp, nInd+1, 6, 0) != 0)
              break;
          }

          if (pPrinter[nInd].pLocation != NULL)
          {
            if (_conPutC(chTmp, pPrinter[nInd].pLocation) != chTmp)
              break;
            if (_conArrayPut(chArray, chTmp, nInd+1, 7, 0) != 0)
              break;
          }

          // STRUTTURA DEVMODE, metto sempre 0
          // if (_conPutNL(chTmp, 0) != chTmp)
          //   break;
          // if (_conArrayPut(chArray, chTmp, nInd+1, 8, 0) != 0)
          //   break;

          if (pPrinter[nInd].pSepFile != NULL)
          {
            if (_conPutC(chTmp, pPrinter[nInd].pSepFile) != chTmp)
              break;
            if (_conArrayPut(chArray, chTmp, nInd+1, 9, 0) != 0)
              break;
          }

          if (pPrinter[nInd].pPrintProcessor != NULL)
          {
            if (_conPutC(chTmp, pPrinter[nInd].pPrintProcessor) != chTmp)
              break;
            if (_conArrayPut(chArray, chTmp, nInd+1,10, 0) != 0)
              break;
          }


          if (pPrinter[nInd].pDatatype != NULL)
          {
            if (_conPutC(chTmp, pPrinter[nInd].pDatatype) != chTmp)
              break;
            if (_conArrayPut(chArray, chTmp, nInd+1,11, 0) != 0)
              break;
          }

          if (pPrinter[nInd].pParameters != NULL)
          {
            if (_conPutC(chTmp, pPrinter[nInd].pParameters) != chTmp)
              break;
            if (_conArrayPut(chArray, chTmp, nInd+1,12, 0) != 0)
              break;
          }

          // STRUTTURA SECURITY_DESCRIPTOR, metto sempre 0
          // if (_conPutNL(chTmp, 0) != chTmp)
          //   break;
          // if (_conArrayPut(chArray, chTmp, nInd+1,13, 0) != 0)
          //   break;

          if (_conPutNL(chTmp, pPrinter[nInd].Attributes) != chTmp)
            break;
          if (_conArrayPut(chArray, chTmp, nInd+1,14, 0) != 0)
            break;

          if (_conPutNL(chTmp, pPrinter[nInd].Priority) != chTmp)
            break;
          if (_conArrayPut(chArray, chTmp, nInd+1,15, 0) != 0)
            break;

          if (_conPutNL(chTmp, pPrinter[nInd].DefaultPriority) != chTmp)
            break;
          if (_conArrayPut(chArray, chTmp, nInd+1,16, 0) != 0)
            break;

          if (_conPutNL(chTmp, pPrinter[nInd].StartTime) != chTmp)
            break;
          if (_conArrayPut(chArray, chTmp, nInd+1,17, 0) != 0)
            break;

          if (_conPutNL(chTmp, pPrinter[nInd].UntilTime) != chTmp)
            break;
          if (_conArrayPut(chArray, chTmp, nInd+1,18, 0) != 0)
            break;

          if (_conPutNL(chTmp, pPrinter[nInd].Status) != chTmp)
            break;
          if (_conArrayPut(chArray, chTmp, nInd+1,19, 0) != 0)
            break;

          if (_conPutNL(chTmp, pPrinter[nInd].cJobs) != chTmp)
            break;
          if (_conArrayPut(chArray, chTmp, nInd+1,20, 0) != 0)
            break;

          if (_conPutNL(chTmp, pPrinter[nInd].AveragePPM) != chTmp)
            break;
          if (_conArrayPut(chArray, chTmp, nInd+1,21, 0) != 0)
            break;

        }

   }

   if (pPrinterName != NULL && hPrinterName != MOM_NULLHANDLE) _momUnlock(hPrinterName);
   if (hPrinterName != MOM_NULLHANDLE) _momFree(hPrinterName);

   if (pPrinter != NULL && hGlobal != MOM_NULLHANDLE) _momUnlock(hGlobal);
   if (hGlobal != MOM_NULLHANDLE) _momFree(hGlobal);

   if (chTmp != NULLCONTAINER)
     _conRelease( chTmp );

   if (chArray != NULLCONTAINER)
   {
      if (nInd < dwCount)
        _ret(paramList);
      else
        _conReturn( paramList, chArray );

      _conRelease( chArray );
   }
   else
      _ret(paramList);
}

