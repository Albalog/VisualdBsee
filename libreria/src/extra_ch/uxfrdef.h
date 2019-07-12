/*
** File:    UXFRDef.h
**
** Author:  Linda Cao
** Date:    96-07-18
**
** Purpose: An export format DLL for report definition
**
** Copyright (c) 1996  Seagate Software
*/

#if !defined (UXFRDEF_H)
#define UXFRDEF_H

// Set 1-byte structure alignment
#if defined (__BORLANDC__)      // Borland C/C++
  #pragma option -a-
#elif defined (_MSC_VER)        // Microsoft Visual C++
  #if _MSC_VER >= 900           // MSVC 2.x and later
    #pragma pack (push)
  #endif
  #pragma pack (1)
#endif

#if defined (__cplusplus)
extern "C"
{
#endif

#define UXFReportDefinitionType     0

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

#endif // UXFRDEF_H
