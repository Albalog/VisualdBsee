//
// File:    uxfrtf.h
//
// Author:  Jin Li
// Date:    2000-07-10
//
// Modified: Jeff Daviss
//
// Purpose: Declarations for exact RTF export format DLL.
//
// Copyright (c) 2000  Crystal Services
//

#ifndef ___UXFRTF_H_
#define ___UXFRTF_H_

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
const DWORD UXFExactRichTextFormatType = 0;

// a #define for backward-compatability with our old rtf exporter
#define UXFRichTextFormatType  UXFExactRichTextFormatType

//=============================================================================
// Format options for exact RTF layout:
typedef struct
{
    WORD structSize;

    BOOL exportPageRange;
    WORD firstPageNo;
    WORD lastPageNo;

} UXFERTFFormatOptions;
#define UXFERTFFormatOptionsSize sizeof( UXFERTFFormatOptions )


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