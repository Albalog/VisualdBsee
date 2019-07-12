#include "..\extra_ch\zipx.ch"

#ifndef WIN32
#  define WIN32
#endif

#define API

#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>
#include <string.h>
#ifdef __BORLANDC__
#include <dir.h>
#else
#include <direct.h>
#endif
#include "..\extra_ch\zipc.h"
//#include "zipver.h"

#ifdef WIN32
#include <commctrl.h>
#include <winver.h>
#else
#include <ver.h>
#endif


/* Forward References */
_DLL_ZIP ZipArchive;
_ZIP_USER_FUNCTIONS ZipInit;
ZIPSETOPTIONS ZipSetOptions;

//void FreeUpMemory(void);
//int WINAPI DummyPassword(LPSTR, int, LPCSTR, LPCSTR);
//int WINAPI DummyPrint(char far *, unsigned long);
//int WINAPI WINAPI DummyComment(char far *);


#include <windows.h>
#include <winbase.h>
#include <winuser.h>
#include "xppdef.h"
#include "xpppar.h"
#include "xppcon.h"


#define   MAXSIZE 256


// Forward reference
int WINAPI ZIP_DisplayBuf(LPSTR, unsigned long);
int WINAPI ZIP_password(LPSTR, int, LPCSTR, LPCSTR);
int WINAPI ZIP_ServCallBk(LPCSTR, unsigned long);
int WINAPI ZIP_comment(LPSTR);

ContainerHandle chCodeblock;
//HINSTANCE hZipDll;

XPPRET XPPENTRY WIZ_ZIPFILE( XppParamList paramList )
{
  int iRet=0;
  BOOL bOk = TRUE;
  ZIPUSERFUNCTIONS hUserFunctions;
  ZPOPT            hOpt;
  ZCL			   hZip;
  XPPAPIRET        xr=0;
  ContainerHandle  chDLLHandle, 
                   chZipFile, chInFc, chInFv, chDate, chPath, chTmpDir,
                   chfTemp, chfSuffix, chfEncrypt, chfSystem, chfVolume,
                   chfExtra , chfNoDirEntries, chfExcludeDate, chfIncludeDate,
                   chfVerbose, chfQuiet, chfCRLF_LF, chfLF_CRLF, chfJunkDir,
                   chfGrow, chfForce, chfMove, chfDeleteEntries, chfUpdate,
                   chfFreshen, chfJunkSFX, chfLatestTime, chfComment,
                   chfOffsets, chfPrivilege, chfEncryption, chfRecurse,
                   chfRepair, chfLevel;


  ULONG nCopy=0;
  HINSTANCE hZipDll = NULL;
  LONG hDLL=0;
  long lAppo = 0;
  int infc;
  char **infv;
  char sPath[MAXSIZE];
  char sInFv[MAXSIZE];
  char sTmpDir[MAXSIZE];
  char sDate[MAXSIZE];
  MomHandle hNew0, hNew1;
  char *fpStrFN;
  char *fpStr;
  LONG nPar1Len = 0;

  char **index;
  MomHandle hNew2;
  int i;
  int nOffset=0;


  hNew2= NULL;
  infc = 0;
  infv = NULL;

  chCodeblock = NULLCONTAINER;
  hZipDll=NULL;
  //Reads Parameters

  if (bOk)
  {
    int n = 0;

    iRet = -100;

    // PARAMETRO 2 NOME FILE .ZIP
    nPar1Len = _parclen( paramList, 2 )+1;

    hNew0 = _momAlloc( sizeof(char)*(nPar1Len) );
    fpStrFN = _momLock( hNew0 );

    _parc( fpStrFN, nPar1Len, paramList, 2 );

    // PARAMETRO 5 ELENCO FILES DA ZIPPARE
    nPar1Len = _parclen( paramList, 5 )+1;

    hNew1 = _momAlloc( sizeof(char)*(nPar1Len) );
    fpStr = _momLock( hNew1 );

    _parc( fpStr, nPar1Len, paramList, 5 );

    chDLLHandle        = _conParam(paramList, ++n, NULL);

    ++n;
    // chZipFile          = _conParam(paramList, ++n, NULL);  cosi non funzionava
    chCodeblock        = _conParam(paramList, ++n, NULL);
    chInFc             = _conParam(paramList, ++n, NULL);
    // chInFv             = _conParam(paramList, ++n, NULL); cosi non funzionava
    ++n;
    // struttura ZPOPT
    chDate             = _conParam(paramList, ++n, NULL); /* Date to include after */
    chPath             = _conParam(paramList, ++n, NULL); /* Directory to use as base for zipping */
    chTmpDir           = _conParam(paramList, ++n, NULL); /* Temporary directory used during zipping */
    chfTemp            = _conParam(paramList, ++n, NULL); /* Use temporary directory '-b' during zipping */
    chfSuffix          = _conParam(paramList, ++n, NULL); /* include suffixes (not implemented in WiZ) */
    chfEncrypt         = _conParam(paramList, ++n, NULL); /* encrypt files */
    chfSystem          = _conParam(paramList, ++n, NULL); /* include system and hidden files */
    chfVolume          = _conParam(paramList, ++n, NULL); /* Include volume label */
    chfExtra           = _conParam(paramList, ++n, NULL); /* Exclude extra attributes */
    chfNoDirEntries    = _conParam(paramList, ++n, NULL); /* Do not add directory entries */
    chfExcludeDate     = _conParam(paramList, ++n, NULL); /* Exclude files earlier than specified date */
    chfIncludeDate     = _conParam(paramList, ++n, NULL); /* Include only files earlier than specified date */
    chfVerbose         = _conParam(paramList, ++n, NULL); /* Mention oddities in zip file structure */
    chfQuiet           = _conParam(paramList, ++n, NULL); /* Quiet operation */
    chfCRLF_LF         = _conParam(paramList, ++n, NULL); /* Translate CR/LF to LF */
    chfLF_CRLF         = _conParam(paramList, ++n, NULL); /* Translate LF to CR/LF */
    chfJunkDir         = _conParam(paramList, ++n, NULL); /* Junk directory names */
    chfGrow            = _conParam(paramList, ++n, NULL); /* Allow appending to a zip file */
    chfForce           = _conParam(paramList, ++n, NULL); /* Make entries using DOS names (k for Katz) */
    chfMove            = _conParam(paramList, ++n, NULL); /* Delete files added or updated in zip file */
    chfDeleteEntries   = _conParam(paramList, ++n, NULL); /* Delete files from zip file */
    chfUpdate          = _conParam(paramList, ++n, NULL); /* Update zip file--overwrite only if newer */
    chfFreshen         = _conParam(paramList, ++n, NULL); /* Freshen zip file--overwrite only */
    chfJunkSFX         = _conParam(paramList, ++n, NULL); /* Junk SFX prefix */
    chfLatestTime      = _conParam(paramList, ++n, NULL); /* Set zip file time to time of latest file in it */
    chfComment         = _conParam(paramList, ++n, NULL); /* Put comment in zip file */
    chfOffsets         = _conParam(paramList, ++n, NULL); /* Update archive offsets for SFX files */
    chfPrivilege       = _conParam(paramList, ++n, NULL); /* Use privileges (WIN32 only) */
    chfEncryption      = _conParam(paramList, ++n, NULL); /* TRUE if encryption supported, else FALSE.
                                                             this is a read-only flag */
    chfRecurse         = _conParam(paramList, ++n, NULL); /* Recurse into subdirectories. 1 => -r, 2 => -R */
    chfRepair          = _conParam(paramList, ++n, NULL); /* Repair archive. 1 => -F, 2 => -FF */
    chfLevel           = _conParam(paramList, ++n, NULL); /* Compression level (0 - 9) */

    if (chDLLHandle == NULLCONTAINER ||
        chCodeblock == NULLCONTAINER ||
        chPath == NULLCONTAINER    ||
        chInFc == NULLCONTAINER   )
        //|| chZipFile == NULLCONTAINER ||
        // chInFv == NULLCONTAINER    )
        bOk = FALSE;
  }

  if (bOk)
  {
    iRet = -200;
    xr = _conGetNL( chDLLHandle,  &hDLL);
    if (xr != 0)
       bOk=FALSE;

    hZipDll = (HINSTANCE) hDLL;

    // xr = _conGetCL( chZipFile, &nCopy, sZipFile, sizeof(sZipFile)-1);
    // if (xr==0)
    //    sZipFile[nCopy]='\0';
    // else
    //    bOk=FALSE; 

    xr = _conGetNL( chInFc,  &infc);
    if (xr != 0)
       bOk=FALSE;

    // xr = _conGetCL( chInFv, &nCopy, sInFv, sizeof(sInFv)-1);
    // if (xr==0)
    //    sInFv[nCopy]='\0';
    // else
    //    bOk=FALSE;

    xr = _conGetCL( chDate, &nCopy, sDate, sizeof(sDate)-1);
    if (xr==0)
       sDate[nCopy]='\0';
    else
       bOk=FALSE;

    xr = _conGetCL( chPath, &nCopy, sPath, sizeof(sPath)-1);
    if (xr==0)
       sPath[nCopy]='\0';
    else
       bOk=FALSE;

    xr = _conGetCL( chTmpDir, &nCopy, sTmpDir, sizeof(sTmpDir)-1);
    if (xr==0)
       sTmpDir[nCopy]='\0';
    else
       bOk=FALSE;

  }

  if (bOk)
  {
    iRet = -300;

    // Preparo le strutture
    hOpt.Date = sDate;
    hOpt.szRootDir = sPath;
    hOpt.szTempDir = sTmpDir;
    if (_conGetNL(chfTemp              , &hOpt.fTemp             ) != 0) bOk=FALSE;
    if (_conGetNL(chfSuffix            , &hOpt.fSuffix           ) != 0) bOk=FALSE;
    if (_conGetNL(chfEncrypt           , &hOpt.fEncrypt          ) != 0) bOk=FALSE;
    if (_conGetNL(chfSystem            , &hOpt.fSystem           ) != 0) bOk=FALSE;
    if (_conGetNL(chfVolume            , &hOpt.fVolume           ) != 0) bOk=FALSE;
    if (_conGetNL(chfExtra             , &hOpt.fExtra            ) != 0) bOk=FALSE;
    if (_conGetNL(chfNoDirEntries      , &hOpt.fNoDirEntries     ) != 0) bOk=FALSE;
    if (_conGetNL(chfExcludeDate       , &hOpt.fExcludeDate      ) != 0) bOk=FALSE;
    if (_conGetNL(chfIncludeDate       , &hOpt.fIncludeDate      ) != 0) bOk=FALSE;
    if (_conGetNL(chfVerbose           , &hOpt.fVerbose          ) != 0) bOk=FALSE;
    if (_conGetNL(chfQuiet             , &hOpt.fQuiet            ) != 0) bOk=FALSE;
    if (_conGetNL(chfCRLF_LF           , &hOpt.fCRLF_LF          ) != 0) bOk=FALSE;
    if (_conGetNL(chfLF_CRLF           , &hOpt.fLF_CRLF          ) != 0) bOk=FALSE;
    if (_conGetNL(chfJunkDir           , &hOpt.fJunkDir          ) != 0) bOk=FALSE;

    if (_conGetNL(chfGrow              , &hOpt.fGrow             ) != 0) bOk=FALSE;
    if (_conGetNL(chfForce             , &hOpt.fForce            ) != 0) bOk=FALSE;
    if (_conGetNL(chfMove              , &hOpt.fMove             ) != 0) bOk=FALSE;
    if (_conGetNL(chfDeleteEntries     , &hOpt.fDeleteEntries    ) != 0) bOk=FALSE;
    if (_conGetNL(chfUpdate            , &hOpt.fUpdate           ) != 0) bOk=FALSE;
    if (_conGetNL(chfFreshen           , &hOpt.fFreshen          ) != 0) bOk=FALSE;
    if (_conGetNL(chfJunkSFX           , &hOpt.fJunkSFX          ) != 0) bOk=FALSE;
    if (_conGetNL(chfLatestTime        , &hOpt.fLatestTime       ) != 0) bOk=FALSE;
    if (_conGetNL(chfComment           , &hOpt.fComment          ) != 0) bOk=FALSE;
    if (_conGetNL(chfOffsets           , &hOpt.fOffsets          ) != 0) bOk=FALSE;
    if (_conGetNL(chfPrivilege         , &hOpt.fPrivilege        ) != 0) bOk=FALSE;
    if (_conGetNL(chfEncryption        , &hOpt.fEncryption       ) != 0) bOk=FALSE;

    if (_conGetNL(chfRecurse          , &hOpt.fRecurse          ) != 0) bOk=FALSE;
    if (_conGetNL(chfRepair           , &hOpt.fRepair           ) != 0) bOk=FALSE;

    if (_conGetNL(chfLevel            , &lAppo ) != 0) bOk=FALSE;
    hOpt.fLevel =lAppo;

    hUserFunctions.password = ZIP_password;
    hUserFunctions.print = ZIP_DisplayBuf;
    hUserFunctions.comment = ZIP_comment;
    hUserFunctions.ServiceApplication  = ZIP_ServCallBk;

    // Simone 13/5/2005 
    // gerr 4033 mantis 0000729: funzione dfzip() non supporta elenco files da zippare 
    // creo tabella puntatori alla stringa
    hNew2 = _momAlloc( sizeof(char *)*(infc) );
    index = (char **)_momLock( hNew2 );

    for (i = 0; i < infc; i++)
    {
        index[i] = fpStr + nOffset;
        nOffset += strlen(index[i])+1;
    }

    hZip.argc = infc;
    hZip.lpszZipFN = fpStrFN;
    hZip.FNV  = index;

  }

  // if (bOk)
  // {
  //     iRet = ZpSetOptions(&hOpt);
  //
  //     iRet = ZpInit(&hUserFunctions);
  //
  //     iRet = ZpArchive(hZip);
  //
  //     bOk = TRUE;
  // }

  if (bOk)
  {
    bOk = FALSE;
//    hZipDll = LoadLibrary("ZIP32.DLL");

    if (hZipDll != NULL)
    {
      (_DLL_ZIP)ZipArchive = (_DLL_ZIP)GetProcAddress(hZipDll, "ZpArchive");
      (ZIPSETOPTIONS)ZipSetOptions = (ZIPSETOPTIONS)GetProcAddress(hZipDll, "ZpSetOptions");
      (_ZIP_USER_FUNCTIONS)ZipInit = (_ZIP_USER_FUNCTIONS)GetProcAddress(hZipDll, "ZpInit");


      if (ZipArchive && ZipSetOptions && ZipInit)
      {

        iRet = (*ZipInit)(&hUserFunctions);
        iRet = ZipSetOptions(&hOpt);
        iRet = ZipArchive(hZip);
        bOk = TRUE;
      } //else MessageBox(NULL,"NON PRESENTE","PRIMO",MB_OK);
//      FreeLibrary( hZipDll );
    } //else MessageBox(NULL,"NON CARICATA","PRIMO",MB_OK);

  }

  _retnl(paramList, iRet);

  _momUnlock(hNew0);
  _momFree(hNew0);
  _momUnlock(hNew1);
  _momFree(hNew1);

  if (hNew2 != NULL) {
    _momUnlock(hNew2);
    _momFree(hNew2);
  }
 
}


/* Password entry routine - see password.c in the wiz directory for how
   this is actually implemented in WiZ. If you have an encrypted file,
   this will probably give you great pain.
 */
int WINAPI ZIP_password(char *p, int n, const char *m, const char *name)
{

   ContainerHandle  chResult, chID, chP1, chP2, chP3, chP4;
   ULONG  ulType=0;
   XPPAPIRET        xr=0;
   int iRet = 1;

   chResult = _conNew(NULLCONTAINER);
   chID     = _conPutNL(NULLCONTAINER, WIZ_ZIP_CB_ID_PWD);

   chP1     = _conPutC(NULLCONTAINER, p);
   chP2     = _conPutNL(NULLCONTAINER, n);

   // Altro CAST che non so se va bene
   chP3     = _conPutC(NULLCONTAINER, (char *) m);
   chP4     = _conPutC(NULLCONTAINER, (char *) name);

   if (chResult != NULLCONTAINER && chID != NULLCONTAINER &&
       chP1     != NULLCONTAINER && chP2     != NULLCONTAINER &&
       chP3     != NULLCONTAINER && chP4     != NULLCONTAINER        )
   {
      xr = _conEvalB(chResult, chCodeblock, 5, chID, chP1, chP2, chP3, chP4);

      if (xr == 0)
      {
         xr = _conType(chResult, &ulType);
         if (xr == 0)
         {
          if ( XPP_IS_TYPE(ulType, XPP_NUMERIC) )
            xr = _conGetNL( chResult, &iRet);
         }
      }

   }

   if (chP1 != NULLCONTAINER) _conRelease(chP1);
   if (chP2 != NULLCONTAINER) _conRelease(chP2);
   if (chP3 != NULLCONTAINER) _conRelease(chP3);
   if (chP4 != NULLCONTAINER) _conRelease(chP4);

   if (chID != NULLCONTAINER) _conRelease(chID);
   if (chResult != NULLCONTAINER) _conRelease(chResult);

   return iRet;
}

int WINAPI ZIP_comment (LPSTR buf)
{
   ContainerHandle  chResult, chID, chP1;
   ULONG  ulType=0;
   int iRet=0;
   XPPAPIRET        xr=0;

   if (chCodeblock == NULLCONTAINER) return iRet;

   chResult = _conNew(NULLCONTAINER);
   chID     = _conPutNL(NULLCONTAINER, WIZ_ZIP_CB_ID_COMMENT);

   chP1     = _conPutC(NULLCONTAINER, buf);

   if (chResult != NULLCONTAINER && chID != NULLCONTAINER &&
       chP1     != NULLCONTAINER )
   {
      xr = _conEvalB(chResult, chCodeblock, 2, chID, chP1);

      if (xr == 0)
      {
         xr = _conType(chResult, &ulType);
         if (xr == 0)
         {
          if ( XPP_IS_TYPE(ulType, XPP_NUMERIC) )
            xr = _conGetNL( chResult, &iRet);
         }
      }

   }

   if (chP1 != NULLCONTAINER) _conRelease(chP1);

   if (chID != NULLCONTAINER) _conRelease(chID);
   if (chResult != NULLCONTAINER) _conRelease(chResult);

return iRet;
}


/* Dummy "print" routine that simply outputs what is sent from the dll */
int WINAPI ZIP_DisplayBuf(LPSTR buf, unsigned long size)
{
//printf("%s", (char *)buf);
   ContainerHandle  chResult, chID, chP1, chP2;
   ULONG  ulType=0;
   XPPAPIRET        xr=0;

   if (chCodeblock == NULLCONTAINER) return size;

   chResult = _conNew(NULLCONTAINER);
   chID     = _conPutNL(NULLCONTAINER, WIZ_ZIP_CB_ID_PRINT);

   chP1     = _conPutC(NULLCONTAINER, buf);
   chP2     = _conPutNL(NULLCONTAINER, size);
   if (chResult != NULLCONTAINER && chID != NULLCONTAINER &&
       chP1     != NULLCONTAINER && chP2     != NULLCONTAINER )
   {
      xr = _conEvalB(chResult, chCodeblock, 3, chID, chP1, chP2);

      if (xr == 0)
      {
         xr = _conType(chResult, &ulType);
         if (xr == 0)
         {
          if ( XPP_IS_TYPE(ulType, XPP_NUMERIC) )
            xr = _conGetNL( chResult, &size);
         }
      }

   }

   if (chP1 != NULLCONTAINER) _conRelease(chP1);
   if (chP2 != NULLCONTAINER) _conRelease(chP2);

   if (chID != NULLCONTAINER) _conRelease(chID);
   if (chResult != NULLCONTAINER) _conRelease(chResult);

return (unsigned int) size;
}

int WINAPI ZIP_ServCallBk(LPCSTR buf, unsigned long size)
{
//printf("%s", (char *)buf);

   ContainerHandle  chResult, chID, chP1, chP2;
   ULONG  ulType=0;
   XPPAPIRET        xr=0;
   unsigned int iRet=0;

   if (chCodeblock == NULLCONTAINER) return iRet;

   chResult = _conNew(NULLCONTAINER);
   chID     = _conPutNL(NULLCONTAINER, WIZ_ZIP_CB_ID_SVC);

   // altro CAST LPCSTR in LPSTR che non so se va bene
   chP1     = _conPutC(NULLCONTAINER, (LPSTR) buf);
   chP2     = _conPutNL(NULLCONTAINER, size);
   if (chResult != NULLCONTAINER && chID != NULLCONTAINER &&
       chP1     != NULLCONTAINER && chP2     != NULLCONTAINER )
   {
      xr = _conEvalB(chResult, chCodeblock, 3, chID, chP1, chP2);

      if (xr == 0)
      {
         xr = _conType(chResult, &ulType);
         if (xr == 0)
         {
          if ( XPP_IS_TYPE(ulType, XPP_NUMERIC) )
            xr = _conGetNL( chResult, &iRet);
         }
      }

   }

   if (chP1 != NULLCONTAINER) _conRelease(chP1);
   if (chP2 != NULLCONTAINER) _conRelease(chP2);

   if (chID != NULLCONTAINER) _conRelease(chID);
   if (chResult != NULLCONTAINER) _conRelease(chResult);

return iRet;
}
