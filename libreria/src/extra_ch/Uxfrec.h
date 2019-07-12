/*
** File:    UXFRec.h
**
** Author:  Jinshi Xia
** Date:    93-10-12
**
** Purpose: An export format DLL for record style.
**
** Copyright (c) 1993  Seagate Software Information Management Group, Inc.
*/

#if !defined (UXFREC_H)
#define UXFREC_H

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

#define UXFRecordType   0

typedef struct UXFRecordStyleOptions
{
    WORD structSize;

    BOOL useReportNumberFormat;
    BOOL useReportDateFormat;
}
    UXFRecordStyleOptions;

#define UXFRecordStyleOptionsSize (sizeof (UXFRecordStyleOptions))

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
