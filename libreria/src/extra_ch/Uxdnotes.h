/*
** File:    UXDNOTES.h
**
** Author:  Markus Wachowski
** Date:    95-05-29
**
** Purpose: An export destination DLL for Lotus Notes
**
** Copyright (c) 1995  Seagate Software Information Management Group, Inc. 
*/

#if !defined (UXDNOTES_H)
#define UXDNOTES_H

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
#define UXDNotesType             3

typedef struct UXDNotesOptions
{
    WORD structSize;

    char FAR *szDBName;
    char FAR *szFormName;       // should be "Report Form"
    char FAR *szComments;
}
    UXDNotesOptions;
#define UXDNotesOptionsSize      (sizeof (UXDNotesOptions))

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

#endif // UXDNOTES_H





