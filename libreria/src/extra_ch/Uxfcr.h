/*
** File:    UXFCR.h
**
** Author:  Ron Hayter
** Date:    93-12-13
**
** Purpose: An export format DLL for reports.
**
** Copyright (c) 1993  Crystal Services
*/

#if !defined (UXFCR_H)
#define UXFCR_H

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

#define UXFCrystalReportType    0
#define UXFCrystalReportV7Type  1

// No options.

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

#endif // UXFCR_H

