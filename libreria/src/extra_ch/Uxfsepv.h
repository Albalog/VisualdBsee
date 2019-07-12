/*
** File:    UXFSepV.h
**
** Author:  Ron Hayter
** Date:    93-04-08
**
** Purpose: An export format DLL for separated values.
**
** Copyright (c) 1993  Seagate Software Information Management Group, Inc.
*/

#if !defined (UXFSEPV_H)
#define UXFSEPV_H

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

#define UXFCommaSeparatedType   0
#define UXFTabSeparatedType     1
#define UXFCharSeparatedType    2

typedef struct UXFCommaTabSeparatedOptions
{
    WORD structSize;

    BOOL useReportNumberFormat;
    BOOL useReportDateFormat;
}
    UXFCommaTabSeparatedOptions;
#define UXFCommaTabSeparatedOptionsSize (sizeof (UXFCommaTabSeparatedOptions))

typedef struct UXFCharSeparatedOptions
{
    WORD structSize;

    BOOL useReportNumberFormat;
    BOOL useReportDateFormat;
    char stringDelimiter;
    char FAR *fieldDelimiter;
}
    UXFCharSeparatedOptions;
#define UXFCharSeparatedOptionsSize (sizeof (UXFCharSeparatedOptions))

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

#endif // UXFSEPV_H
