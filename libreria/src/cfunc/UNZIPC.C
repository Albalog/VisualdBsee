// _conEvalB()
/*
   Executes a code block passed as a parameter, passing it a single
   argument.
*/

#include "..\unzipx.ch"

#ifndef WIN32   /* this code is currently only tested for 32-bit console */
#  define WIN32
#endif

#if defined(__WIN32__) && !defined(WIN32)
#  define WIN32
#endif

#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>
#include <string.h>

#include <windows.h>
#ifdef __RSXNT__
#  include "../win32/rsxntwin.h"
#endif
#include <assert.h>    /* required for all Windows applications */
#include <stdlib.h>
#include <stdio.h>
#include <commdlg.h>
#ifndef __RSXNT__
#  include <dlgs.h>
#endif
#include <windowsx.h>

#include "structs.h"

/* Defines */

typedef int (WINAPI * _DLL_UNZIP)(int, char **, int, char **,
                                  LPDCL, LPUSERFUNCTIONS);
typedef int (WINAPI * _USER_FUNCTIONS)(LPUSERFUNCTIONS);


/* Global functions */

extern _DLL_UNZIP Wiz_SingleEntryUnzip;


#ifdef WIN32
#  include <winver.h>
#else
#  include <ver.h>
#endif

#include <windows.h>
#include <winbase.h>
#include <winuser.h>
#include "xppdef.h"
#include "xpppar.h"
#include "xppcon.h"

#define   MAXSIZE 256

// Forward reference
int WINAPI UNZIP_DisplayBuf(LPSTR, unsigned long);
int WINAPI UNZIP_GetReplaceDlgRetVal(char *);
int WINAPI UNZIP_password(char *, int, const char *, const char *);
void WINAPI UNZIP_sound(void);
int WINAPI UNZIP_ServCallBk(LPCSTR, unsigned long);
void WINAPI UNZIP_ReceiveDllMessage(unsigned long, unsigned long, unsigned,
                              unsigned, unsigned, unsigned, unsigned, unsigned,
                              char, LPSTR, LPSTR, unsigned long, char);

_DLL_UNZIP Wiz_SingleEntryUnzip;

ContainerHandle chCodeblock;

XPPRET XPPENTRY WIZ_UNZIPFILE( XppParamList paramList )
{
  XPPAPIRET        xr=0;
  ContainerHandle  chDLLHandle, chZipFile, chPath, chResult, chx,
                   chInFc, chInFv, chExFc, chExFv;
  ContainerHandle  chExtractOnlyNewer , chSpaceToUnderscore,
                   chPromptToOverwrite , chfQuiet , chncflag ,
                   chntflag , chnvflag , chnfflag , chnzflag ,
                   chndflag , chnoflag , chnaflag , chnZIflag ,
                   chC_flag , chfPrivilege ;
  int iRet=0;
  int exfc, infc;
  char **exfv, **infv;
  char sZipFile[MAXSIZE];
  char sPath[MAXSIZE];
  char sExFv[MAXSIZE];
  char sInFv[MAXSIZE];
  DCL hDCL;
  USERFUNCTIONS hUserFunctions;

  ULONG nCopy=0;
  BOOL bOk = TRUE;
  //PATCHCALLBACK CallBackPtr = CallBack;
  HINSTANCE hUnzipDll = NULL;
  LONG hDLL=0;

  infc = 0;
  infv = NULL;
  exfc = 0;
  exfv = NULL;

  chCodeblock = NULLCONTAINER;

  /*
    Reads Parameters
  */
  if (bOk)
  {
    int n = 0;
    iRet = -100;

    chDLLHandle = _conParam(paramList, ++n, NULL);
    chZipFile   = _conParam(paramList, ++n, NULL);
    chPath      = _conParam(paramList, ++n, NULL);
    chCodeblock = _conParam(paramList, ++n, NULL);
    chInFc      = _conParam(paramList, ++n, NULL);
    chInFv      = _conParam(paramList, ++n, NULL);
    chExFc      = _conParam(paramList, ++n, NULL);
    chExFv      = _conParam(paramList, ++n, NULL);

    chExtractOnlyNewer = _conParam(paramList, ++n, NULL);   // true for "update" without interaction
                                                            // (extract only newer/new files, without queries)
    chSpaceToUnderscore = _conParam(paramList, ++n, NULL);  // true if convert space to underscore
    chPromptToOverwrite = _conParam(paramList, ++n, NULL);  // true if prompt to overwrite is wanted
    chfQuiet = _conParam(paramList, ++n, NULL);             // quiet flag. 1 = few messages, 2 = no messages, 0 = all messages
    chncflag = _conParam(paramList, ++n, NULL);             // write to stdout if true
    chntflag = _conParam(paramList, ++n, NULL);             // test zip file
    chnvflag = _conParam(paramList, ++n, NULL);             // verbose listing
    chnfflag = _conParam(paramList, ++n, NULL);             // "freshen" (replace existing files by newer versions)
    chnzflag = _conParam(paramList, ++n, NULL);             // display zip file comment
    chndflag = _conParam(paramList, ++n, NULL);             // all args are files/dir to be extracted
    chnoflag = _conParam(paramList, ++n, NULL);             // true if you are to always over-write files, false if not
    chnaflag = _conParam(paramList, ++n, NULL);             // do end-of-line translation
    chnZIflag = _conParam(paramList, ++n, NULL);            // get zip info if true
    chC_flag = _conParam(paramList, ++n, NULL);             // be case insensitive if TRUE
    chfPrivilege = _conParam(paramList, ++n, NULL);         // 1 => restore Acl's, 2 => Use privileges

    if (chDLLHandle == NULLCONTAINER ||
        chCodeblock == NULLCONTAINER ||
        chZipFile == NULLCONTAINER ||
        chPath == NULLCONTAINER    ||
        chInFc == NULLCONTAINER    ||
        chInFv == NULLCONTAINER    ||
        chExFc == NULLCONTAINER    ||
        chExFv == NULLCONTAINER    )
      bOk = FALSE;
  }

  if (bOk)
  {
    iRet = -200;

    xr = _conGetNL( chDLLHandle,  &hDLL);
    if (xr != 0)
       bOk=FALSE;

    hUnzipDll = (HINSTANCE) hDLL;

    xr = _conGetCL( chZipFile, &nCopy, sZipFile, sizeof(sZipFile)-1);
    if (xr==0)
       sZipFile[nCopy]='\0';
    else
       bOk=FALSE;

    xr = _conGetCL( chPath, &nCopy, sPath, sizeof(sPath)-1);
    if (xr==0)
       sPath[nCopy]='\0';
    else
       bOk=FALSE;

    xr = _conGetNL( chInFc,  &infc);
    if (xr != 0)
       bOk=FALSE;

    xr = _conGetCL( chInFv, &nCopy, sInFv, sizeof(sInFv)-1);
    if (xr==0)
       sInFv[nCopy]='\0';
    else
       bOk=FALSE;

    xr = _conGetNL( chExFc,  &exfc);
    if (xr != 0)
       bOk=FALSE;

    xr = _conGetCL( chExFv, &nCopy, sExFv, sizeof(sExFv)-1);
    if (xr==0)
       sExFv[nCopy]='\0';
    else
       bOk=FALSE;

  }
  if (bOk)
  {
    iRet = -300;

    // Preparo le strutture
    hDCL.lpszZipFN  = sZipFile;   // ZIP filename
    hDCL.lpszExtractDir = sPath;  //Directory to extract to. This should be NULL if you
                                  //   are extracting to the current directory.

    if (_conGetNL(chExtractOnlyNewer    , &hDCL.ExtractOnlyNewer  ) != 0) bOk=FALSE;
    if (_conGetNL(chSpaceToUnderscore   , &hDCL.SpaceToUnderscore ) != 0) bOk=FALSE;
    if (_conGetNL(chPromptToOverwrite   , &hDCL.PromptToOverwrite ) != 0) bOk=FALSE;
    if (_conGetNL(chfQuiet              , &hDCL.fQuiet            ) != 0) bOk=FALSE;
    if (_conGetNL(chncflag              , &hDCL.ncflag            ) != 0) bOk=FALSE;
    if (_conGetNL(chntflag              , &hDCL.ntflag            ) != 0) bOk=FALSE;
    if (_conGetNL(chnvflag              , &hDCL.nvflag            ) != 0) bOk=FALSE;
    if (_conGetNL(chnfflag              , &hDCL.nfflag            ) != 0) bOk=FALSE;
    if (_conGetNL(chnzflag              , &hDCL.nzflag            ) != 0) bOk=FALSE;
    if (_conGetNL(chndflag              , &hDCL.ndflag            ) != 0) bOk=FALSE;
    if (_conGetNL(chnoflag              , &hDCL.noflag            ) != 0) bOk=FALSE;
    if (_conGetNL(chnaflag              , &hDCL.naflag            ) != 0) bOk=FALSE;
    if (_conGetNL(chnZIflag             , &hDCL.nZIflag           ) != 0) bOk=FALSE;
    if (_conGetNL(chC_flag              , &hDCL.C_flag            ) != 0) bOk=FALSE;
    if (_conGetNL(chfPrivilege          , &hDCL.fPrivilege        ) != 0) bOk=FALSE;

    // hDCL.ExtractOnlyNewer = 0;   // true for "update" without interaction
    //                              // (extract only newer/new files, without queries)
    // hDCL.SpaceToUnderscore = 0;  // true if convert space to underscore
    // hDCL.PromptToOverwrite = 0;  // true if prompt to overwrite is wanted
    // hDCL.fQuiet = 0;             // quiet flag. 1 = few messages, 2 = no messages, 0 = all messages
    // hDCL.ncflag = 0;             // write to stdout if true
    // hDCL.ntflag = 0;             // test zip file
    // hDCL.nvflag = 0;             // verbose listing
    // hDCL.nfflag = 0;             // "freshen" (replace existing files by newer versions)
    // hDCL.nzflag = 0;             // display zip file comment
    // hDCL.ndflag = 1;             // all args are files/dir to be extracted
    // hDCL.noflag = 1;             // true if you are to always over-write files, false if not
    // hDCL.naflag = 0;             // do end-of-line translation
    // hDCL.nZIflag = 0;            // get zip info if true
    // hDCL.C_flag = 1;             // be case insensitive if TRUE
    // hDCL.fPrivilege = 0;         // 1 => restore Acl's, 2 => Use privileges

    hUserFunctions.password = UNZIP_password;
    hUserFunctions.print = UNZIP_DisplayBuf;
    hUserFunctions.sound = UNZIP_sound;
    hUserFunctions.replace = UNZIP_GetReplaceDlgRetVal;
    hUserFunctions.SendApplicationMessage = UNZIP_ReceiveDllMessage;
    hUserFunctions.ServCallBk  = UNZIP_ServCallBk;
  }

  if (bOk)
  {
    iRet = -400;
    bOk = FALSE;
    //hUnzipDll = LoadLibrary("UNZIP32.DLL");

    if (hUnzipDll != NULL)
    {
      _DLL_UNZIP Wiz_SingleEntryUnzip = (_DLL_UNZIP) GetProcAddress(hUnzipDll, "Wiz_SingleEntryUnzip");

      iRet = -500;
      if (Wiz_SingleEntryUnzip)
      {

         // dovrebbe andare pi— o meno bene ma se non faccio
         // il cast ho dei warning
         infv = (char **) &sInFv;
         exfv = (char **) &sExFv;
         //infv = NULL;
         //exfv = NULL;

         iRet = (*Wiz_SingleEntryUnzip)(infc, infv, exfc, exfv, &hDCL,
                                        &hUserFunctions);

         //iRet = (*Wiz_SingleEntryUnzip)(infc, infv, exfc, exfv, lpDCL,
         //                               lpUserFunctions);

         bOk = TRUE;
      } //else MessageBox(NULL,"NON PRESENTE","PRIMO",MB_OK);
      //FreeLibrary( hUnzipDll );
    } //else MessageBox(NULL,"NON CARICATA","PRIMO",MB_OK);

  }


  _retnl(paramList, iRet);
}

// -------------------------------------------------------------
// Questa funzioni chiamano il codeblock passandogli i parametri
// -------------------------------------------------------------


int WINAPI UNZIP_GetReplaceDlgRetVal(char *filename)
{
/* This is where you will decide if you want to replace, rename etc existing
   files.
 */
   ContainerHandle  chResult, chID, chP1;
   ULONG  ulType=0;
   XPPAPIRET        xr=0;
   int iRet = 1;

   if (chCodeblock == NULLCONTAINER) return iRet;

   chResult = _conNew(NULLCONTAINER);
   chID     = _conPutNL(NULLCONTAINER, WIZ_UNZIP_CB_ID_REPLACE);

   chP1     = _conPutC(NULLCONTAINER, filename);

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

/* This is a very stripped down version of what is done in Wiz. Essentially
   what this function is for is to do a listing of an archive contents. It
   is actually never called in this example, but a dummy procedure had to
   be put in, so this was used.
 */
void WINAPI UNZIP_ReceiveDllMessage(unsigned long ucsize, unsigned long csiz,
    unsigned cfactor,
    unsigned mo, unsigned dy, unsigned yr, unsigned hh, unsigned mm,
    char c, LPSTR filename, LPSTR methbuf, unsigned long crc, char fCrypt)
{
   ContainerHandle  chResult, chID, chP1, chP2, chP3, chP4, chP5, chP6,
                    chP7, chP8, chP9, chP10, chP11, chP12, chP13;
   ULONG  ulType=0;
   XPPAPIRET        xr=0;

   if (chCodeblock == NULLCONTAINER) return;

   chResult = _conNew(NULLCONTAINER);
   chID     = _conPutNL(NULLCONTAINER, WIZ_UNZIP_CB_ID_MESSAGE);

   chP1     = _conPutNL(NULLCONTAINER, ucsize);
   chP2     = _conPutNL(NULLCONTAINER, csiz);
   chP3     = _conPutNL(NULLCONTAINER, cfactor);
   chP4     = _conPutNL(NULLCONTAINER, mo);
   chP5     = _conPutNL(NULLCONTAINER, dy);
   chP6     = _conPutNL(NULLCONTAINER, yr);
   chP7     = _conPutNL(NULLCONTAINER, hh);
   chP8     = _conPutNL(NULLCONTAINER, mm);
   chP9     = _conPutNL(NULLCONTAINER, c);
   chP10    = _conPutC(NULLCONTAINER, filename);
   chP11    = _conPutC(NULLCONTAINER, methbuf);
   chP12    = _conPutNL(NULLCONTAINER, crc);
   chP13    = _conPutNL(NULLCONTAINER, fCrypt);

   if (chResult != NULLCONTAINER && chID != NULLCONTAINER &&
       chP1     != NULLCONTAINER && chP2     != NULLCONTAINER &&
       chP3     != NULLCONTAINER && chP4     != NULLCONTAINER &&
       chP5     != NULLCONTAINER && chP6     != NULLCONTAINER &&
       chP7     != NULLCONTAINER && chP8     != NULLCONTAINER &&
       chP9     != NULLCONTAINER && chP10    != NULLCONTAINER &&
       chP11    != NULLCONTAINER && chP12    != NULLCONTAINER &&
       chP13    != NULLCONTAINER )
   {
      xr = _conEvalB(chResult, chCodeblock, 14, chID,
                     chP1, chP2, chP3, chP4, chP5, chP6, chP7, chP8,
                     chP9, chP10, chP11, chP12, chP13);
   }

   if (chP1 != NULLCONTAINER) _conRelease(chP1);
   if (chP2 != NULLCONTAINER) _conRelease(chP2);
   if (chP3 != NULLCONTAINER) _conRelease(chP3);
   if (chP4 != NULLCONTAINER) _conRelease(chP4);
   if (chP5 != NULLCONTAINER) _conRelease(chP5);
   if (chP6 != NULLCONTAINER) _conRelease(chP6);
   if (chP7 != NULLCONTAINER) _conRelease(chP7);
   if (chP8 != NULLCONTAINER) _conRelease(chP8);
   if (chP9 != NULLCONTAINER) _conRelease(chP9);
   if (chP10 != NULLCONTAINER) _conRelease(chP10);
   if (chP11 != NULLCONTAINER) _conRelease(chP11);
   if (chP12 != NULLCONTAINER) _conRelease(chP12);
   if (chP13 != NULLCONTAINER) _conRelease(chP13);

   if (chID != NULLCONTAINER) _conRelease(chID);
   if (chResult != NULLCONTAINER) _conRelease(chResult);

}

/* Password entry routine - see password.c in the wiz directory for how
   this is actually implemented in WiZ. If you have an encrypted file,
   this will probably give you great pain.
 */
int WINAPI UNZIP_password(char *p, int n, const char *m, const char *name)
{

   ContainerHandle  chResult, chID, chP1, chP2, chP3, chP4;
   ULONG  ulType=0;
   XPPAPIRET        xr=0;
   int iRet = 1;

   if (chCodeblock == NULLCONTAINER) return iRet;

   chResult = _conNew(NULLCONTAINER);
   chID     = _conPutNL(NULLCONTAINER, WIZ_UNZIP_CB_ID_PWD);

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

void WINAPI UNZIP_sound(void)
{
   ContainerHandle  chResult, chID;
   XPPAPIRET        xr=0;

   if (chCodeblock == NULLCONTAINER) return ;

   chResult = _conNew(NULLCONTAINER);
   chID     = _conPutNL(NULLCONTAINER, WIZ_UNZIP_CB_ID_SOUND);

   if (chResult != NULLCONTAINER && chID != NULLCONTAINER)
   {
      xr = _conEvalB(chResult, chCodeblock, 1, chID);
   }
   if (chID != NULLCONTAINER) _conRelease(chID);
   if (chResult != NULLCONTAINER) _conRelease(chResult);
}


/* Dummy "print" routine that simply outputs what is sent from the dll */
int WINAPI UNZIP_DisplayBuf(LPSTR buf, unsigned long size)
{
   ContainerHandle  chResult, chID, chP1, chP2;
   ULONG  ulType=0;
   XPPAPIRET        xr=0;

   if (chCodeblock == NULLCONTAINER) return size;

   chResult = _conNew(NULLCONTAINER);
   chID     = _conPutNL(NULLCONTAINER, WIZ_UNZIP_CB_ID_PRINT);

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

int WINAPI UNZIP_ServCallBk(LPCSTR buf, unsigned long size)
{

   ContainerHandle  chResult, chID, chP1, chP2;
   ULONG  ulType=0;
   XPPAPIRET        xr=0;
   unsigned int iRet=0;

   if (chCodeblock == NULLCONTAINER) return iRet;

   chResult = _conNew(NULLCONTAINER);
   chID     = _conPutNL(NULLCONTAINER, WIZ_UNZIP_CB_ID_SVC);

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

