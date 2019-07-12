// Wrapper per NetServerGetInfo su NT, con conversione con caratteri UNICODE

#ifndef UNICODE
#define UNICODE
#endif

#include <windows.h>
#include <lm.h>
#include "xppdef.h"
#include "xpppar.h"
#include "xppcon.h"


XPPRET XPPENTRY DFNETSERVERGETINFONT(XppParamList paramList )
{
   DWORD dwLevel = 101;
   unsigned int uiLen;
   LPSERVER_INFO_101 pBuf = NULL;
   SERVER_INFO_101 serverInfo;
   NET_API_STATUS nStatus;
   LPTSTR pszServerName = NULL;
   LPSTR pTmp = NULL;
   ContainerHandle  chArray = NULLCONTAINER;
   ContainerHandle  chTmp = NULLCONTAINER;
   MomHandle hTmp = MOM_NULLHANDLE, hServerName = MOM_NULLHANDLE;

   // Chiamo il load library NON unicode
   HINSTANCE hlibNETAPI = LoadLibraryA("NETAPI32.DLL");

   FARPROC lpfnNetServerGetInfo = (FARPROC) GetProcAddress(hlibNETAPI, "NetServerGetInfo");

   // Se la piattaforma Š windows occorre allocare il buffer prima
   OSVERSIONINFO o;
   int Success = GetVersionEx((LPOSVERSIONINFO) &o);

   if( o.dwPlatformId==VER_PLATFORM_WIN32_WINDOWS )
      pBuf = &serverInfo;
   // --------------

   if( PCOUNT(paramList)>=1 && XPP_IS_CHAR(_partype(paramList,1)) )
   {

       uiLen = _parclen( paramList, 1 );
       if (uiLen > 0)
       {
          hTmp = _momAlloc( sizeof(char)*(uiLen+1) );
          if( hTmp != MOM_NULLHANDLE )
          {
             pTmp = _momLock( hTmp );
             _parc( pTmp, uiLen +1, paramList, 1);

             hServerName = _momAlloc( sizeof(TCHAR)*(uiLen+1) );
             if( hServerName != MOM_NULLHANDLE )
             {
                pszServerName = (TCHAR *) _momLock( hServerName );
                OemToChar(pTmp, pszServerName);
             }
             if (pTmp != NULL && hTmp != MOM_NULLHANDLE) _momUnlock(hTmp);
             if (hTmp != MOM_NULLHANDLE) _momFree(hTmp);
          }
       }
   }


   //
   // Call the NetServerGetInfo function, specifying level 101.
   //
   nStatus = lpfnNetServerGetInfo(pszServerName,
                              dwLevel,
                              (LPBYTE *)&pBuf);
   //
   // If the call succeeds,
   //
   if (nStatus == NERR_Success)
   {
      chArray = _conNewArray(1, 6);
      chTmp = _conNew(NULLCONTAINER);

      if (chArray != NULLCONTAINER  &&  chTmp != NULLCONTAINER)
      {
          if (_conPutNL(chTmp, pBuf->sv101_platform_id) == chTmp)
             _conArrayPut(chArray, chTmp, 1, 0);

          if (pBuf->sv101_name != NULL) // Questo è in UNICODE.. ho errori in compilazione...
          {
            uiLen=lstrlen(pBuf->sv101_name);
            if (uiLen > 0)
            {
                hTmp = _momAlloc( sizeof(char)*(uiLen+1) );
                pTmp = NULL;
                if( hTmp != MOM_NULLHANDLE )
                {
                  pTmp = _momLock( hTmp );
                  if ( (CharToOem( pBuf->sv101_name, pTmp )) &&
                       (_conPutC(chTmp, pTmp) == chTmp     ) )
                    _conArrayPut(chArray, chTmp, 2, 0);
                }

                if (pTmp != NULL && hTmp != MOM_NULLHANDLE) _momUnlock(hTmp);
                if (hTmp != MOM_NULLHANDLE) _momFree(hTmp);
            }
          }

          if (_conPutNL(chTmp, pBuf->sv101_version_major) == chTmp)
             _conArrayPut(chArray, chTmp, 3, 0);

          if (_conPutNL(chTmp, pBuf->sv101_version_minor) == chTmp)
             _conArrayPut(chArray, chTmp, 4, 0);

          if (_conPutNL(chTmp, pBuf->sv101_type) == chTmp)
             _conArrayPut(chArray, chTmp, 5, 0);

          if (pBuf->sv101_comment != NULL) // Questo è in UNICODE.. ho errori in compilazione...
          {
            uiLen=lstrlen(pBuf->sv101_comment);
            if (uiLen > 0)
            {
                hTmp = _momAlloc( sizeof(char)*(uiLen+1) );
                pTmp = NULL;
                if( hTmp != MOM_NULLHANDLE )
                {
                  pTmp = _momLock( hTmp );
                  if ( (CharToOem( pBuf->sv101_comment, pTmp )) &&
                       (_conPutC(chTmp, pTmp) == chTmp     ) )
                    _conArrayPut(chArray, chTmp, 6, 0);
                }

                if (pTmp != NULL && hTmp != MOM_NULLHANDLE) _momUnlock(hTmp);
                if (hTmp != MOM_NULLHANDLE) _momFree(hTmp);
            }
          }

      }
   }

   //
   // Free the allocated memory.
   //
   if (chTmp != NULLCONTAINER)
     _conRelease( chTmp );

   if (chArray != NULLCONTAINER)
   {
      _conReturn( paramList, chArray );
      _conRelease( chArray );
   }
   else
      _ret(paramList);

   if (pszServerName != NULL && hServerName != MOM_NULLHANDLE) _momUnlock(hServerName);
   if (hServerName != MOM_NULLHANDLE) _momFree(hServerName);

   if (pBuf != NULL){
      if( o.dwPlatformId==VER_PLATFORM_WIN32_NT ){
         // Se riesco a farlo .. chiamo il free, cosi' funziona anche su 9X
         if( hlibNETAPI!=NULL ){
            FARPROC lpfnNetApiBufferFree = (FARPROC) GetProcAddress(hlibNETAPI, "NetApiBufferFree");
            lpfnNetApiBufferFree(pBuf);
         }
      }
   }

   // To check
   FreeLibrary( hlibNETAPI );
}
