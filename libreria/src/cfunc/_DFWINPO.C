#include <windows.h>
#include <winspool.h>
#include "xppdef.h"
#include "xpppar.h"
#include "xppcon.h"

// Torna un array con i dati delle porte logiche definite in Windows
// o NIL se c'Š un errore. Necessita WinSpool.lib per il link.

XPPRET XPPENTRY DFWINPORTSGET(XppParamList paramList )
{
   DWORD dwNeeded = 0, dwCount = 0, dwBufferLen=0, nInd=0;
   BOOL bRet;
   PORT_INFO_2 *pPort = NULL;
   ContainerHandle  chArray = NULLCONTAINER;
   ContainerHandle  chTmp = NULLCONTAINER;
   MomHandle hGlobal = MOM_NULLHANDLE;

   bRet = EnumPorts(NULL, 2, (LPBYTE) pPort, dwBufferLen, &dwNeeded, &dwCount );

   if( dwNeeded > 0)
   {
      hGlobal = _momAlloc(dwNeeded);
      if( hGlobal != MOM_NULLHANDLE )
      {
        dwBufferLen = dwNeeded;
        pPort = (PORT_INFO_2 *)_momLock(hGlobal);
        bRet = EnumPorts(NULL, 2, (LPBYTE) pPort, dwBufferLen, &dwNeeded, &dwCount );
      }
   }

   if (bRet != 0 && pPort != NULL)
   {
      chArray = _conNewArray(2, dwCount, 5);
      chTmp = _conNew(NULLCONTAINER);

      if (chArray != NULLCONTAINER  &&  chTmp != NULLCONTAINER)
        for (nInd=0; nInd < dwCount; nInd++)
        {

          if (pPort[nInd].pPortName != NULL)
          {
            if (_conPutC(chTmp, pPort[nInd].pPortName) != chTmp)
              break;
            if (_conArrayPut(chArray, chTmp, nInd+1, 1, 0) != 0)
              break;
          }

          if (pPort[nInd].pMonitorName != NULL)
          {
            if (_conPutC(chTmp, pPort[nInd].pMonitorName) != chTmp)
              break;
            if (_conArrayPut(chArray, chTmp, nInd+1, 2, 0) != 0)
              break;
          }

          if (pPort[nInd].pDescription != NULL)
          {
            if (_conPutC(chTmp, pPort[nInd].pDescription) != chTmp)
              break;
            if (_conArrayPut(chArray, chTmp, nInd+1, 3, 0) != 0)
              break;
          }

          if (_conPutNL(chTmp, pPort[nInd].fPortType) != chTmp)
            break;
          if (_conArrayPut(chArray, chTmp, nInd+1, 4, 0) != 0)
            break;

          if (_conPutNL(chTmp, pPort[nInd].Reserved) != chTmp)
            break;
          if (_conArrayPut(chArray, chTmp, nInd+1, 5, 0) != 0)
            break;

        }

   }

   if (pPort != NULL && hGlobal != MOM_NULLHANDLE) _momUnlock(hGlobal);
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

