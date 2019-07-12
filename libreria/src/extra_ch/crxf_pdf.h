//
// File:    uxfpdf.h
//
// Author:  Simon Wong
// Date:    98-05-13
//
// Modified: Jeff Daviss
//
// Purpose: Declarations for PDF export format DLL.
//
// Copyright (c) 1998  Crystal Services
//

#ifndef ___UXFPDF_H_
#define ___UXFPDF_H_

// Set 8-byte structure alignment
#if !defined (PLAT_UNIX)
#if defined (__BORLANDC__)      // Borland C/C++
  #pragma option -a-
#elif defined (_MSC_VER)        // Microsoft Visual C++
  #if _MSC_VER >= 900           // MSVC 2.x and later
    #pragma pack (push)
  #endif
  #pragma pack (8)
#endif
#endif

#ifdef __cplusplus
extern "C"
{
#endif

//=============================================================================
// Export types supported by this dll:
const DWORD UXFPortableDocumentFormat = 0;

//=============================================================================
// Format options for PDF:
typedef struct UXFPDFFormatOptions
{
    WORD structSize;

	BOOL exportPageRange;

	WORD firstPageNo;
	WORD lastPageNo;

} UXFPDFFormatOptions;

#define UXFPDFFormatOptionsSize sizeof( UXFPDFFormatOptions )

#ifdef __cplusplus
}
#endif

// Reset structure alignment
#if !defined (PLAT_UNIX)
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

#endif