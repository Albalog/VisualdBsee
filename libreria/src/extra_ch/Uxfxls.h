/*
** File:    UXFXls.h
**
** Purpose: An export format DLL for Excel Xls.
*/

#if !defined (UXFXLS_H)
#define UXFXLS_H

// Set 1-byte structure alignment
#if !defined(PLAT_UNIX) 
#if defined (__BORLANDC__)      // Borland C/C++
  #pragma option -a-
#elif defined (_MSC_VER)        // Microsoft Visual C++
  #if _MSC_VER >= 900           // MSVC 2.x and later
    #pragma pack (push)
  #endif
  #pragma pack (1)
#endif
#endif

#if defined (__cplusplus)
extern "C"
{
#endif

#define DEFAULT_COLUMN_WIDTH    10

#define UXFXls2Type    0  /* no longer supported -- kept for compatibility */
#define UXFXls3Type    1  /* no longer supported -- kept for compatibility */
#define UXFXls4Type    2  /* no longer supported -- kept for compatibility */
#define UXFXls5Type    3
#define UXFXls5TypeExt 4
#define UXFXls5TypeTab 4  //Same as UXFXls5TypeExt defined in previous version
#define UXFXl7Type     5  
#define UXFXl7TabType  6  
#define UXFXl8Type     7  
#define UXFXl8TabType  8  

typedef struct UXFXlsOptions
{ 
    WORD structSize;
    BOOL bColumnHeadings;   //TRUE -- has column headings, which come from
                            //       "Page Header" and "Report Header" ares.
                            //FALSE -- no clolumn headings. 
                            //The default value is FALSE.
    BOOL bUseConstColWidth; //TRUE -- use constant column width
                            //FALSE -- set column width based on an area
                            //The default value is FALSE.
    double fConstColWidth;    //Column width, when bUseConstColWidth is TRUE
                            //The default value is 9.
    BOOL bTabularFormat;    //TRUE -- tabular format (flatten an area into a row)
                            //FALSE -- non-tabular format
                            //The default value is FALSE.
    WORD baseAreaType;      //One of the 7 Section types defined in "Crpe.h"
                            //The default value is PE_SECT_DETAIL.
    WORD baseAreaGroupNum;  //If baseAreaType is either GroupHeader or
                            //GroupFooter and there are more than one groups, 
                            //we need to give the group number. 
                            //The default value is 1. 
    BOOL bUseWorksheetFunc; //If TRUE, use Excel worksheet functions to represent
                            //subtotal fields in crw.
                            //The default value is TRUE.
     
#if defined (__cplusplus)
public:
    UXFXlsOptions()
    {
        structSize = sizeof(UXFXlsOptions);
        bColumnHeadings=FALSE;
         bUseConstColWidth = FALSE;
        fConstColWidth = DEFAULT_COLUMN_WIDTH;
        bTabularFormat = FALSE;
        baseAreaType = 4; // PE_SECT_DETAIL
        baseAreaGroupNum = 1;
        bUseWorksheetFunc = TRUE;
    };
#endif
}
    UXFXlsOptions;

#define UXFXlsOptionsSize (sizeof (UXFXlsOptions))

#if defined (__cplusplus)
}
#endif

// Reset structure alignment
#if !defined(PLAT_UNIX)
#if defined (__BORLANDC__)
  #pragma option -a.
#elif defined (_MSC_VER)
  #if _MSC_VER >= 900
    #pragma pack (pop)
  #else
    #pragma pack ()
  #endif
#endif
#endif

#endif // UXFXLS_H

