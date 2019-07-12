/*
** File:    UXFText.h
**
** Author:  Ron Hayter
** Date:    93-05-31
**
** Purpose: An export format DLL for text.
**
** Copyright (c) 1993  Crystal Services
*/

#if !defined (UXFTEXT_H)
#define UXFTEXT_H

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

#define UXFTextType             0
#define UXFTabbedTextType       1
#define UXFPaginatedTextType    2

typedef struct UXFPaginatedTextOptions
{
    WORD structSize;

    WORD nLinesPerPage;
}
    UXFPaginatedTextOptions;
#define UXFPaginatedTextOptionsSize (sizeof (UXFPaginatedTextOptions))

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

#endif // UXFTEXT_H
