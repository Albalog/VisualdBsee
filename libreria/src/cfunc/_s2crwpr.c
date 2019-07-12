#include <windows.h>
#include <winspool.h>
#include "xppdef.h"
#include "xpppar.h"
#include "xppcon.h"
#include "s2crwpri.ch"

// Simone 20/11/03
// aggiunte le funzioni per impostare la struttura PEExportOptions
// e lanciare l'esportazione
// - DFCRW_STARTEXPORT
// - CRWStartExport
// - StartExport

// Estratto da CRPE.H
// tolto il #include "crpe.h" perche nel link 
// viene inclusa anche CRPE32M.lib
// ------------------
//#include "CRPE.h"
#if !defined (CRPE_H)
   #define CRPE_H

   // Set 1-byte structure alignment
   #if defined (__BORLANDC__)               // Borland C/C++
     #pragma option -a-
       #pragma comment (lib, "crpe32.lib")    // Point to Borland Lib File
   #elif defined (_MSC_VER)                 // Microsoft Visual C++
     #if _MSC_VER >= 900                    // MSVC 2.x and later
       #pragma pack (push)
   //    #pragma comment (lib, "crpe32m.lib") // Point to Microsoft Lib File
     #endif
     #pragma pack (1)
   #endif

   #if defined (_WINDLL)
   	#define CRPE_API /* __declspec(dllexport) */ WINAPI
   #else
   	#define CRPE_API WINAPI
   #endif

   #if defined (__cplusplus)
   extern "C"
   {
   #endif

   #define PE_WORD_LEN          2
   #define PE_DLL_NAME_LEN      64
   #define PE_FULL_NAME_LEN     256

   /************************/
   // Controlling print to file and export
   /************************/

   typedef struct PEExportOptions
   {
       WORD StructSize;               // initialize to PE_SIZEOF_EXPORT_OPTIONS

       char formatDLLName [PE_DLL_NAME_LEN];
       DWORD formatType;
       void FAR *formatOptions;
       char destinationDLLName [PE_DLL_NAME_LEN];
       DWORD destinationType;
       void FAR *destinationOptions;
       WORD nFormatOptionsBytes;      // Set by 'PEGetExportOptions'
                                      // ignored by 'PEExportTo'.
       WORD nDestinationOptionsBytes; // Set by 'PEGetExportOptions'
                                      // ignored by 'PEExportTo'.
   }
       PEExportOptions;
   #define PE_SIZEOF_EXPORT_OPTIONS (sizeof (PEExportOptions))

   BOOL CRPE_API PESelectPrinter (short printJob,
                                  const char FAR *driverName,
                                  const char FAR *printerName,
                                  const char FAR *portName,
                                  DEVMODEA FAR *mode
                                  );

   BOOL CRPE_API PEExportTo (short printJob,
                             PEExportOptions FAR *options);

   BOOL CRPE_API PEGetExportOptions (short printJob,
                             PEExportOptions FAR *options);

   BOOL CRPE_API PEStartPrintJob (short printJob,
                                  BOOL waitUntilDone);


   //typedef BOOL (CALLBACK* LPFN)(short, 


   typedef BOOL (CRPE_API *LPFN)(short, 
                            const char FAR *,
                            const char FAR *,
                            const char FAR *,
                            DEVMODEA FAR *);

   typedef BOOL (CRPE_API *LPFN2)(short, 
                                  PEExportOptions FAR *);

   typedef BOOL (CRPE_API *LPFN3)(short, BOOL);

   typedef BOOL (CRPE_API *LPFN4)(short, HWND);


   #if defined (__cplusplus)
   }
   #endif

   // Reset structure alignment
   #if defined (__BORLANDC__)
     #pragma option -a.
   #elif defined (_MSC_VER)
     #if _MSC_VER >= 900
       #pragma pack (pop)
     #else
       #pragma pack ()
     #endif
   #endif

#endif // CRPE_H

#include "Uxdapp.h"
#include "Uxddisk.h"
#include "Uxdmapi.h"
#include "Uxdnotes.h"
#include "Uxdpost.h"
#include "Uxdvim.h"
#include "Uxfcr.h"
#include "Uxfdif.h"
#include "Uxfdoc.h"
#include "Uxfhtml.h"
#include "Uxfodbc.h"
#include "uxfrdef.h"
#include "Uxfrec.h"
#include "Uxfsepv.h"
#include "Uxftext.h"
#include "Uxfwks.h"
#include "Uxfwordw.h"
#include "Uxfxls.h"
#include "uxfxml.h"
#include "crxf_pdf.h"
#include "crxf_rtf.h"


int  StartExport(short printJob, HWND hWnd, 
                 PEExportOptions FAR *lpExportOptions, 
                 BOOL lAsk
                );

BOOL selectPrinter(short printJob,		//handle to print job
                   char FAR *driverName,	//pointer to driver name string
                   char FAR *printerName,	//pointer to printer name string
                   char FAR *portName,	//pointer to port name string
                   DEVMODE FAR *mode);

//LPDEVMODE GetDevMode(HWND hWnd, char *pDevice, DWORD *dwSize);
MomHandle GetDevMode(HWND hWnd, char *pDevice)
{   
   HANDLE      hPrinter;
   LPDEVMODE   pDevMode;
   DWORD       dwNeeded, dwRet;   
   MomHandle   hDevMode = MOM_NULLHANDLE;

   //dwSize=0;

   /* Start by opening the printer */ 
   if (!OpenPrinter(pDevice, &hPrinter, NULL))
       return MOM_NULLHANDLE;   

   /*
    * Step 1:
    * Allocate a buffer of the correct size.
    */ 
   dwNeeded = DocumentProperties(hWnd,
                                 hPrinter,       /* handle to our printer */ 
                                 pDevice,        /* Name of the printer */ 
                                 NULL,           /* Asking for size so */ 
                                 NULL,           /* these are not used. */ 
                                 0);             /* Zero returns buffer size. */ 

   if (dwNeeded <= 0)
   {
       ClosePrinter(hPrinter);
       return MOM_NULLHANDLE;
   }

   hDevMode = _momAlloc(dwNeeded);
   if( hDevMode == MOM_NULLHANDLE )
   {
       ClosePrinter(hPrinter);
       return MOM_NULLHANDLE;
   }

   pDevMode = (LPDEVMODE) _momLock(hDevMode);

   /*
    * Step 2:
    * Get the default DevMode for the printer and
    * modify it for our needs.
    */ 
   dwRet = DocumentProperties(hWnd,
                              hPrinter,
                              pDevice,
                              pDevMode,       /* The address of the buffer to fill. */ 
                              NULL,           /* Not using the input buffer. */ 
                              DM_OUT_BUFFER); /* Have the output buffer filled. */ 

   if (dwRet != IDOK)
   {
       /* if failure, cleanup and return failure */ 
       _momUnlock(hDevMode);
       _momFree(hDevMode);
       ClosePrinter(hPrinter);
       return MOM_NULLHANDLE;
   }   

   _momUnlock(hDevMode);

   ClosePrinter(hPrinter);   
   return hDevMode;   
} 

int UpdDevMode(HWND hWnd, char *pDevice, MomHandle hDevMode, BOOL lSetup)
{
   HANDLE      hPrinter;
   LPDEVMODE   pDevMode=NULL;
   DWORD       dwNeeded, dwRet;   
   ULONG       dwSize=0;
   DWORD       fMode =0;

   /* Start by opening the printer */ 
   if (!OpenPrinter(pDevice, &hPrinter, NULL))
       return -10;   

   /*
    * Step 1:
    * Allocate a buffer of the correct size.
    */ 
   dwNeeded = DocumentProperties(hWnd,
                                 hPrinter,       /* handle to our printer */ 
                                 pDevice,        /* Name of the printer */ 
                                 NULL,           /* Asking for size so */ 
                                 NULL,           /* these are not used. */ 
                                 0);             /* Zero returns buffer size. */ 

   if (dwNeeded <= 0)
   {
       ClosePrinter(hPrinter);
       return -11;
   }

   // Controllo che lo spazio allocato sia sufficiente
   _momSize(hDevMode, &dwSize);

   if (dwSize < dwNeeded)
   {
       ClosePrinter(hPrinter);
       return -12;
   }


   pDevMode = (LPDEVMODE) _momLock(hDevMode);


  /*
   * Step 3:
   * Merge the new settings with the old.
   * This gives the driver a chance to update any private
   * portions of the DevMode structure.
   */ 

   if (lSetup) fMode = DM_IN_PROMPT;

   dwRet = DocumentProperties(hWnd,
                              hPrinter,
                              pDevice,
                              pDevMode,       /* Reuse our buffer for output. */ 
                              pDevMode,       /* Pass the driver our changes. */ 
                              DM_IN_BUFFER |  /* Commands to Merge our changes and */ 
                              DM_OUT_BUFFER | /* write the result. */    /* Done with the printer */ 
                              fMode);

   _momUnlock(hDevMode);

   ClosePrinter(hPrinter);   
   return dwRet;   

}



// Torna un array con i dati delle porte logiche definite in Windows
// o NIL se c'Š un errore. Necessita WinSpool.lib per il link.

XPPRET XPPENTRY S2CRWPRINTER_CREATE(XppParamList paramList )
{
   //BOOL bRet;
   int iOk = 0;
   unsigned int uiLen;
   MomHandle hPrinterName = MOM_NULLHANDLE, hDevMode = MOM_NULLHANDLE;
   LPTSTR pPrinterName = NULL;
   //HANDLE pHandle = NULL;
   HANDLE hWnd=0;

   if( iOk >= 0 && PCOUNT(paramList)>=2 && XPP_IS_CHAR(_partype(paramList,1)) 
       && XPP_IS_NUM(_partype(paramList,2))  )
   {
       uiLen = _parclen( paramList, 1 );
       if (uiLen > 0) 
       {
          uiLen++;
          hPrinterName = _momAlloc( sizeof(char)*(uiLen) );
          if( hPrinterName != MOM_NULLHANDLE )
          {
             pPrinterName = _momLock( hPrinterName );
            _parc( pPrinterName, uiLen, paramList, 1);
          } else iOk = -1;
       } else iOk = -2;

       hWnd= (HANDLE) _parnl(paramList, 2);

   } else iOk = -3;


   hDevMode = GetDevMode(hWnd, pPrinterName);

   if (hPrinterName != MOM_NULLHANDLE) _momUnlock(hPrinterName);
   if (hPrinterName != MOM_NULLHANDLE) _momFree(hPrinterName);

   if (hDevMode != MOM_NULLHANDLE)
   {
      //_retclen(paramList, hGlobal, sizeof(hGlobal));
      _retnl(paramList, (LONG) hDevMode);
   }
   else
      _retnl(paramList, iOk);
}

XPPRET XPPENTRY S2CRWPRINTER_DESTROY(XppParamList paramList )
{
   MomHandle hGlobal = MOM_NULLHANDLE;
   BOOL bOk = TRUE;
   if( bOk && PCOUNT(paramList)>=1 && XPP_IS_NUM(_partype(paramList,1)) )
   {
       hGlobal = (MomHandle) _parnl( paramList, 1 );
      
       if (hGlobal != MOM_NULLHANDLE)
       {
          _momFree(hGlobal);
       } else bOk = FALSE;
   } else bOk = FALSE;

   _retl(paramList, bOk);
}

XPPRET XPPENTRY S2CRWPRINTER_SET(XppParamList paramList )
{
   MomHandle hGlobal = MOM_NULLHANDLE;
   int iParam=0;
   int iSet  =0;
   int iOk = 0;
   //PRINTER_INFO_2 *pPrinter = NULL;
   DEVMODE *pDM=NULL;

   if( iOk >= 0 && PCOUNT(paramList)>=2 && XPP_IS_NUM(_partype(paramList,1)) 
       && XPP_IS_NUM(_partype(paramList, 2)))
   {
       hGlobal = (MomHandle) _parnl( paramList, 1 );
      
       if (hGlobal == MOM_NULLHANDLE)
          iOk = -1;

       iParam = _parnl( paramList, 2 );

   } else iOk = -2;

   if (iOk>=0)
   {
      pDM = (DEVMODE *) _momLock(hGlobal);

      switch (iParam)
      {
          case S2DM_COLLATION:
             if (pDM->dmFields & DM_COLLATE)
             {
                // parametro COLLATE supportato
                _retnl(paramList, pDM->dmCollate);
                if( iOk >= 0 && PCOUNT(paramList)>=3 && XPP_IS_NUM(_partype(paramList,3)) )
                {
		 iSet = _parnl( paramList, 3 );
		 // Imposto
		 pDM->dmCollate = (short) iSet;
                }
		
             } else _ret(paramList);  // non supportato torno NIL
             break;       

          case S2DM_COLOR:
             if (pDM->dmFields & DM_COLOR)
             {
                // parametro COLOR supportato
                _retnl(paramList, pDM->dmColor);
                if( iOk >= 0 && PCOUNT(paramList)>=3 && XPP_IS_NUM(_partype(paramList,3)) )
                {
		 iSet = _parnl( paramList, 3 );
		 // Imposto
		 pDM->dmColor = (short) iSet;
                }
		
             } else _ret(paramList);  // non supportato torno NIL
             break;       

          case S2DM_DUPLEX:
             if (pDM->dmFields & DM_DUPLEX)
             {
                // parametro DUPLEX  supportato
                _retnl(paramList, pDM->dmDuplex);
                if( iOk >= 0 && PCOUNT(paramList)>=3 && XPP_IS_NUM(_partype(paramList,3)) )
                {
		 iSet = _parnl( paramList, 3 );
		 // Imposto
		 pDM->dmDuplex  = (short) iSet;
                }
		
             } else _ret(paramList);  // non supportato torno NIL
             break;       

          case S2DM_FONT:
             if (pDM->dmFields & DM_TTOPTION)
             {
                // parametro TTOPTION supportato
                _retnl(paramList, pDM->dmTTOption);
                if( iOk >= 0 && PCOUNT(paramList)>=3 && XPP_IS_NUM(_partype(paramList,3)) )
                {
		 iSet = _parnl( paramList, 3 );
		 // Imposto
		 pDM->dmTTOption = (short) iSet;
                }
		
             } else _ret(paramList);  // non supportato torno NIL
             break;       

// todo: gestione larghezza/altezza definite dall'utente
          case S2DM_FORMSIZE:
             if (pDM->dmFields & DM_PAPERSIZE)
             {
                // parametro PAPERSIZE supportato
                _retnl(paramList, pDM->dmPaperSize);
                if( iOk >= 0 && PCOUNT(paramList)>=3 && XPP_IS_NUM(_partype(paramList,3)) )
                {
		 iSet = _parnl( paramList, 3 );
		 // Imposto
		 pDM->dmPaperSize = (short) iSet;
                }
		
             } else _ret(paramList);  // non supportato torno NIL
             break;       

          case S2DM_NUMCOPIES:
             if (pDM->dmFields & DM_COPIES)
             {
                // parametro COPIES  supportato
                _retnl(paramList, pDM->dmCopies );
                if( iOk >= 0 && PCOUNT(paramList)>=3 && XPP_IS_NUM(_partype(paramList,3)) )
                {
		 iSet = _parnl( paramList, 3 );
		 // Imposto
		 pDM->dmCopies  = (short) iSet;
                }
		
             } else _ret(paramList);  // non supportato torno NIL
             break;       

          case S2DM_ORIENTATION:
             if (pDM->dmFields & DM_ORIENTATION)
             {
                // parametro ORIENTATION supportato

                _retnl(paramList, pDM->dmOrientation);
                if( iOk >= 0 && PCOUNT(paramList)>=3 && XPP_IS_NUM(_partype(paramList,3)) )
                {
		 iSet = _parnl( paramList, 3 );
		 // Imposto
		 pDM->dmOrientation = (short) iSet;
                }
		
             } else _ret(paramList);  // non supportato torno NIL
             break;       

          case S2DM_PAPERBIN:
             if (pDM->dmFields & DM_DEFAULTSOURCE)
             {
                // parametro PAPERBIN supportato
                _retnl(paramList, pDM->dmDefaultSource);
                if( iOk >= 0 && PCOUNT(paramList)>=3 && XPP_IS_NUM(_partype(paramList,3)) )
                {
		 iSet = _parnl( paramList, 3 );
		 // Imposto
		 pDM->dmDefaultSource = (short) iSet;
                }
		
             } else _ret(paramList);  // non supportato torno NIL
             break;       

          case S2DM_PRINTFILE:
             break;       
//todo

          case S2DM_RESOLUTION1:    // Parametro numerico
             if (pDM->dmFields & DM_PRINTQUALITY)
             {
                // parametro PRINTQUALITY supportato
                _retnl(paramList, pDM->dmPrintQuality);
                if( iOk >= 0 && PCOUNT(paramList)>=3 && XPP_IS_NUM(_partype(paramList,3)) )
                {
		 iSet = _parnl( paramList, 3 );
		 // Imposto
		 pDM->dmPrintQuality = (short) iSet;
                }
		
             } else _ret(paramList);  // non supportato torno NIL
             break;       

// todo: gestione risoluzione definita dall'utente
          case S2DM_RESOLUTION2:    // Parametro array 
             break;       

          default:
            iOk =-3;
            _retnl(paramList, iOk);	
      }	
  
     if (pDM != NULL) _momUnlock(hGlobal);

   } else
     _retnl(paramList, iOk);


}

XPPRET XPPENTRY S2CRWPRINTER_UPDATEDEVMODE(XppParamList paramList )
{
   MomHandle hGlobal = MOM_NULLHANDLE;
   int iOk = 0;
   DEVMODE *pDM=NULL;
   unsigned int uiLen;
   MomHandle hPrinterName = MOM_NULLHANDLE, hDevMode = MOM_NULLHANDLE;
   LPTSTR pPrinterName = NULL;
   HANDLE hWnd=0;
   BOOL bSetupDialog=FALSE;

   if( iOk >= 0 && 
       PCOUNT(paramList)>=3 && 
       XPP_IS_CHAR(_partype(paramList,1)) &&
       XPP_IS_NUM(_partype(paramList,2)) && 
       XPP_IS_NUM(_partype(paramList,3)) &&
       XPP_IS_LOGIC(_partype(paramList,4))
     )
   {
       uiLen = _parclen( paramList, 1 );
       if (uiLen > 0) 
       {
          uiLen++;
          hPrinterName = _momAlloc( sizeof(char)*(uiLen) );
          if( hPrinterName != MOM_NULLHANDLE )
          {
             pPrinterName = _momLock( hPrinterName );
            _parc( pPrinterName, uiLen, paramList, 1);
          } else iOk = -1;
       } else iOk = -2;

       hWnd= (HANDLE) _parnl(paramList, 2);

       hGlobal = (MomHandle) _parnl( paramList, 3 );
      
       if (hGlobal == MOM_NULLHANDLE)
          iOk = -3;

       bSetupDialog = _parl(paramList, 4); 

   } else iOk = -4;


   if (iOk>=0)
   {
      iOk = UpdDevMode(hWnd, pPrinterName, hGlobal, bSetupDialog);
   }

   if (hPrinterName != MOM_NULLHANDLE) _momUnlock(hPrinterName);
   if (hPrinterName != MOM_NULLHANDLE) _momFree(hPrinterName);

  _retnl(paramList, iOk);
}


XPPRET XPPENTRY DFCRW_PESELECTPRINTER(XppParamList paramList )
{
   BOOL bRet=FALSE;
   ContainerHandle chDriver=NULLCONTAINER, 
                   chPrint =NULLCONTAINER, 
                   chPort  =NULLCONTAINER;   /* container handles for strings */
   char *driverName=NULL, *printerName=NULL, *portName=NULL;                /* pointer to passed strings */
   short printJob=0;
   DEVMODE *pDM=NULL;
   MomHandle hGlobal = MOM_NULLHANDLE;
   ULONG uiLen=0;

   if (!XPP_IS_NUM (_partype(paramList,1)) ||        // printjob
       !XPP_IS_CHAR(_partype(paramList,2)) ||        // printer
       !XPP_IS_CHAR(_partype(paramList,3)) ||        // port
       !XPP_IS_CHAR(_partype(paramList,4)) ||        // driver
       !XPP_IS_NUM (_partype(paramList,5)) )         // devmode
   {
      _retl(paramList, bRet);
       return;
   }

   hGlobal = (MomHandle) _parnl( paramList, 5 );
   if (hGlobal == MOM_NULLHANDLE) 
   {
      _retl(paramList, bRet);
       return;
   }
          
   pDM = (DEVMODE *) _momLock(hGlobal);

   printJob= _parnl(paramList, 1);
   chPrint = _conParam(paramList,2,NULL);
   chPort  = _conParam(paramList,3,NULL);
   chDriver= _conParam(paramList,4,NULL);

   if (pDM != NULL &&
       printJob != 0 &&
       chPrint != NULLCONTAINER &&
       chPort  != NULLCONTAINER &&
       chDriver!= NULLCONTAINER )
   {

       if (_conRLockC(chPrint, &printerName, &uiLen) == 0) 
       {
          if (_conRLockC(chPort, &portName, &uiLen) == 0) 
          {
             if (_conRLockC(chDriver,&driverName,&uiLen) == 0) 
             {
                bRet = selectPrinter(printJob, driverName, printerName, 
                                     portName, pDM);
                _conUnlockC(chDriver);
             }
            _conUnlockC(chPort);
          }
         _conUnlockC(chPrint);
       }
   }

   if (pDM != NULL) _momUnlock(hGlobal);

   if (chPrint  != NULLCONTAINER) _conRelease(chPrint );
   if (chPort   != NULLCONTAINER) _conRelease(chPort  );
   if (chDriver != NULLCONTAINER) _conRelease(chDriver);

   _retl(paramList, bRet);
}




BOOL selectPrinter(short printJob,		//handle to print job
                   char FAR *driverName,	//pointer to driver name string
                   char FAR *printerName,	//pointer to printer name string
                   char FAR *portName,	//pointer to port name string
                   DEVMODE FAR *devMode)
{
   BOOL bRet=FALSE;
   HINSTANCE hCRW= NULL;

   hCRW= LoadLibrary("CRPE32.DLL");
   if (hCRW != NULL)
   {
      LPFN lpfnPESelectPrinter = (LPFN) GetProcAddress(hCRW, "PESelectPrinter");
      if (lpfnPESelectPrinter )
      {
         bRet= lpfnPESelectPrinter( printJob,		//handle to print job
                                    driverName,	//pointer to driver name string
                                    printerName,	//pointer to printer name string
	                            portName,	//pointer to port name string
	                            devMode		);
      } //else MessageBox(NULL,"NON PRESENTE","PRIMO",MB_OK);
      FreeLibrary( hCRW );
    } //else MessageBox(NULL,"NON CARICATA","PRIMO",MB_OK);
    return bRet;
}


int CRWStartExport(short nJob, HWND hWnd, 
                DWORD formatType, 
		DWORD destinationType,  
		char * filename,
		BOOL uRNF, BOOL uRDF, // usati in vari tipi
		WORD nLinesPP,        // usati in Paginated
		char *sd, char* fd)
{
   PEExportOptions ExportOptions;
   UXDDiskOptions          DiskOptions;
   UXDApplicationOptions   AppOptions;

   UXFCharSeparatedOptions SeparationOptions;
   UXFPaginatedTextOptions PaginatedOptions;
   UXFDIFOptions           DIFOptions;
   UXFRecordStyleOptions   RecordOptions;
   UXFHTML3Options         HTMLOptions;
   UXFPDFFormatOptions     PDFOptions;
   UXFXmlOptions           XMLOptions;


   int ret=0;
   BOOL lAsk = TRUE;

   ExportOptions.StructSize = PE_SIZEOF_EXPORT_OPTIONS;
   ExportOptions.destinationOptions = NULL;
   ExportOptions.formatOptions = NULL;

    // richiesta all'utente
   if (formatType != S2UXF_ASKUSER) 
   {
      lAsk = FALSE;
      switch(destinationType)  {
          case S2UXDDiskType:
             DiskOptions.structSize = UXDDiskOptionsSize;
             DiskOptions.fileName = filename;

             lstrcpy(ExportOptions.destinationDLLName, "uxddisk.dll");
             ExportOptions.destinationType = UXDDiskType;
             ExportOptions.destinationOptions = &DiskOptions;

             break;

          case S2UXDApplicationType: 

             AppOptions.structSize = sizeof(UXDApplicationOptions);
             AppOptions.fileName = filename;

             lstrcpy(ExportOptions.destinationDLLName,"u2dapp.dll");
             ExportOptions.destinationType = UXDApplicationType;
             ExportOptions.destinationOptions = &AppOptions;


             break;

          default: 
             ret=-1;
      }

      switch(formatType) {
          case S2UXFTextType:  
             lstrcpy(ExportOptions.formatDLLName, "u2ftext.dll");
             ExportOptions.formatType = UXFTextType;
             break;

          case S2UXFCharSeparatedType:  
             SeparationOptions.structSize = UXFCharSeparatedOptionsSize;
             SeparationOptions.useReportNumberFormat = uRNF;
             SeparationOptions.useReportDateFormat = uRDF;
             SeparationOptions.stringDelimiter = *sd;
             SeparationOptions.fieldDelimiter = fd;

             lstrcpy(ExportOptions.formatDLLName, "uxfsepv.dll");
             ExportOptions.formatType = UXFCharSeparatedType;
             ExportOptions.formatOptions = &SeparationOptions;

             break;

          case S2UXFPaginatedTextType:  
             PaginatedOptions.structSize = UXFPaginatedTextOptionsSize;
             PaginatedOptions.nLinesPerPage = nLinesPP;

             lstrcpy(ExportOptions.formatDLLName, "u2ftext.dll");
             ExportOptions.formatType = UXFPaginatedTextType;
             ExportOptions.formatOptions = &PaginatedOptions;
             break;

          case S2UXFRichTextFormatType:  
             lstrcpy(ExportOptions.formatDLLName, "u2frtf.dll");
             ExportOptions.formatType = UXFRichTextFormatType;
             //ExportOptions.formatOptions = &SeparationOptions;
             break;

          case S2UXFTabbedTextType:  
             lstrcpy(ExportOptions.formatDLLName, "u2ftext.dll");
             ExportOptions.formatType = UXFTabbedTextType;
             break;

          case S2UXFXls5Type:  
             lstrcpy(ExportOptions.formatDLLName,"u2fxls.dll");
             ExportOptions.formatType = UXFXls5Type;
             break;

          case S2UXFWordWinType:  
             lstrcpy(ExportOptions.formatDLLName,"u2fwordw.dll");
             ExportOptions.formatType = UXFWordWinType;
             break;

          case S2UXFCrystalReportType:  
             lstrcpy(ExportOptions.formatDLLName,"u2fcr.dll");
             ExportOptions.formatType = UXFCrystalReportType;
             break;

          case S2UXFRecordType:  
             RecordOptions.structSize = sizeof(UXFRecordStyleOptions);
             RecordOptions.useReportNumberFormat = uRNF;
             RecordOptions.useReportDateFormat = uRDF;

             lstrcpy(ExportOptions.formatDLLName,"u2frec.dll");
             ExportOptions.formatType = UXFRecordType;
             ExportOptions.formatOptions = &RecordOptions;
             break;

          case S2UXFDIFType:  
             DIFOptions.structSize = sizeof(UXFDIFOptions );
             DIFOptions.useReportNumberFormat = uRNF;
             DIFOptions.useReportDateFormat = uRDF;

             lstrcpy(ExportOptions.formatDLLName,"u2fdif.dll");
             ExportOptions.formatType = UXFDIFType;
             ExportOptions.formatOptions = &DIFOptions;
             break;

          case S2UXFHTML3Type:  
             HTMLOptions.structSize = sizeof(UXFHTML3Options);
             HTMLOptions.fileName = "file.htm"; //filename;

             lstrcpy(ExportOptions.formatDLLName,"u2fhtml.dll");
             ExportOptions.formatType = UXFHTML3Type;
             ExportOptions.formatOptions = &HTMLOptions;
             break;

          case S2UXFPDFType:
             PDFOptions.structSize = sizeof(UXFPDFFormatOptions);
             PDFOptions.exportPageRange = FALSE;
             PDFOptions.firstPageNo= 0;
             PDFOptions.lastPageNo = 65535;

             lstrcpy(ExportOptions.formatDLLName,"crxf_pdf.dll");
             ExportOptions.formatType = UXFPortableDocumentFormat;
             ExportOptions.formatOptions = &PDFOptions;
             break;      

          case S2UXFXMLType:  
             XMLOptions.structSize = sizeof(UXFXmlOptions);
             XMLOptions.fileName = "file.xml"; //filename;
             XMLOptions.allowMultipleFiles = FALSE;
             lstrcpy(ExportOptions.formatDLLName,"u2fxml.dll");
             ExportOptions.formatType = UXFXMLType;
             //ExportOptions.formatOptions = &HTMLOptions;
             break;      

          default: 
             ret=-1;
      }
   }

   if (ret == 0) {
      ret = StartExport(nJob, hWnd, &ExportOptions, lAsk);
   }

   return ret;
}

int StartExport(short printJob,		//handle to print job
                HWND hWnd, 
                PEExportOptions FAR * lpExportOptions, 
                BOOL lAsk)
{
   int iRet=-3;
   HINSTANCE hCRW= NULL;

   hCRW= LoadLibrary("CRPE32.DLL");
   if (hCRW != NULL)
   {
      LPFN2 lpfnPEExportTo              = (LPFN2) GetProcAddress(hCRW, "PEExportTo");
      LPFN2 lpfnPEGetExportOptions      = (LPFN2) GetProcAddress(hCRW, "PEGetExportOptions");
      LPFN3 lpfnPEStartPrintJob         = (LPFN3) GetProcAddress(hCRW, "PEStartPrintJob");
      LPFN4 lpfnPESetDialogParentWindow = (LPFN4) GetProcAddress(hCRW, "PESetDialogParentWindow");

      iRet = -4;
      if (lpfnPEExportTo && lpfnPEStartPrintJob)
      {
         if ((hWnd != 0) && (lpfnPESetDialogParentWindow != NULL) )
            lpfnPESetDialogParentWindow(printJob, hWnd);

         iRet = -5;

//if (lpfnPEGetExportOptions != NULL) {
//MessageBox(NULL, "peget!=null", "", MB_OK);
//} else {
//MessageBox(NULL, "peget==null", "", MB_OK);
//}

         if ((lAsk) && (lpfnPEGetExportOptions != NULL) )
         {
            iRet = -7;
            lpfnPEGetExportOptions(printJob, lpExportOptions);
         }

         if (lpfnPEExportTo( printJob, lpExportOptions))
         {
           iRet = -6;
           if (lpfnPEStartPrintJob( printJob, TRUE))
              iRet=1;
         }

      } //else MessageBox(NULL,"NON PRESENTE","PRIMO",MB_OK);
      FreeLibrary( hCRW );
    } //else MessageBox(NULL,"NON CARICATA","PRIMO",MB_OK);
    return iRet;
}




XPPRET XPPENTRY DFCRW_STARTEXPORT(XppParamList paramList )
{
   int iRet=0;
   short printJob=0;
   DWORD formatType=0;
   DWORD destinationType=0;
   BOOL  uRNF,uRDF;
   WORD nLinesPP=10;
   HWND hWnd=0;
   ContainerHandle chFile=NULLCONTAINER, 
                   chSD =NULLCONTAINER, 
                   chFD =NULLCONTAINER;   /* container handles for strings */
   char *filename=NULL, *sd=NULL, *fd=NULL;                /* pointer to passed strings */
   
      
   ULONG uiLen=0;

   if (!XPP_IS_NUM (_partype(paramList,1)) ||        // printjob
       !XPP_IS_NUM (_partype(paramList,2)) ||        // hWnd
       !XPP_IS_NUM (_partype(paramList,3)) ||        // formatType
       !XPP_IS_NUM (_partype(paramList,4)) ||        // destinationType
       !XPP_IS_CHAR(_partype(paramList,5)) ||        // filename
       !XPP_IS_LOGIC(_partype(paramList,6))||        // number format
       !XPP_IS_LOGIC(_partype(paramList,7))||        // data format
       !XPP_IS_NUM (_partype(paramList,8)) ||        // lines per page
       !XPP_IS_CHAR(_partype(paramList,9)) ||        // string delimiter
       !XPP_IS_CHAR(_partype(paramList,10)) )        // field delimiter
     
   {
      _retnl(paramList, -2);
       return;
   }

   printJob  = _parnl(paramList, 1);
   hWnd    = (HWND) _parnl(paramList, 2);
   formatType= _parnl(paramList, 3);
   destinationType=_parnl(paramList, 4);
   chFile  = _conParam(paramList,5,NULL);
   uRNF    = _parl(paramList,6);
   uRDF    = _parl(paramList,7);
   nLinesPP=_parnl(paramList, 8);
   chSD    = _conParam(paramList,9,NULL);
   chFD    = _conParam(paramList,10,NULL);

   if (printJob != 0 &&
       chFile != NULLCONTAINER &&
       chSD   != NULLCONTAINER &&
       chFD   != NULLCONTAINER )
   {

       if (_conRLockC(chFile, &filename, &uiLen) == 0) 
       {
          if (_conRLockC(chSD, &sd, &uiLen) == 0) 
          {
             if (_conRLockC(chFD,&fd,&uiLen) == 0) 
             {

                iRet = CRWStartExport(printJob, 
                                   hWnd, 
                                   formatType, 
                                   destinationType,
                                   filename,
                                   uRNF, uRDF,
                                   nLinesPP,
                                   sd,fd);

                _conUnlockC(chFD);
             }
            _conUnlockC(chSD);
          }
         _conUnlockC(chFile);
       }
   }

   
   if (chFile   != NULLCONTAINER) _conRelease(chFile  );
   if (chSD     != NULLCONTAINER) _conRelease(chSD    );
   if (chFD     != NULLCONTAINER) _conRelease(chFD    );

   _retnl(paramList, iRet);
}
