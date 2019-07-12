/*
** File:    UXFDIF.h
**
** Author:  Ron Hayter
** Date:    93-11-17
**
** Purpose: An export format DLL for Data Interchange Format.
**
** Copyright (c) 1993 Seagate Software Information Management Group, Inc.
*/

#if !defined (UXFDIF_H)
#define UXFDIF_H

#if defined (__cplusplus)
extern "C"
{
#endif

// Set 1-byte structure alignment
#if defined (__BORLANDC__)               // Borland C/C++
  #pragma option -a-
#elif defined (_MSC_VER)                 // Microsoft Visual C++
  #if _MSC_VER >= 900                    // MSVC 2.x and later
    #pragma pack (push)
  #endif
  #pragma pack (1)
#endif 

/********************************************/

#define UXFDIFType              0

typedef struct UXFDIFOptions
{
    WORD structSize;

    BOOL useReportNumberFormat;
    BOOL useReportDateFormat;
}
    UXFDIFOptions;
#define UXFDIFOptionsSize       (sizeof (UXFDIFOptions))

/********************************************/
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

#if defined (__cplusplus)
}
#endif

#endif // UXFDIF_H
