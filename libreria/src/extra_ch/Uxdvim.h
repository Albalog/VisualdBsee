/*
** File:    UXDVIM.h
**
** Author:  Douglas Lankshear
** Date:    93-09-16
**
** Purpose: An export destination DLL for VIM.
**
** Copyright (c) 1993  Seagate Software Information Management Group, Inc.
*/

#if !defined (UXDVIM_H)
#define UXDVIM_H

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

#define UXDVIMType             0

typedef struct UXDVIMOptions
{
    WORD structSize;

    char FAR *toList;
    char FAR *ccList;
    char FAR *bccList;
    char FAR *subject;
    char FAR *message;
}
    UXDVIMOptions;
#define UXDVIMOptionsSize      (sizeof (UXDVIMOptions))

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

#endif // UXDVIM_H
