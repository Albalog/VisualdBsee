/*
** File:    UXDMAPI.h
**
** Author:  Ron Hayter
** Date:    93-05-28
**
** Mods:	Douglas Lankshear
** Date:	93-09-21
** Mods:	Ron Hayter
** Date:	94-02-28
**
** Purpose: An export destination DLL for MAPI.
**
** Copyright (c) 1993, 1994  Seagate Software Information Management Group, Inc.
*/

#if !defined (UXDMAPI_H)
#define UXDMAPI_H

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

#include "MAPI.h"

#define UXDMAPIType             0

typedef struct UXDMAPIOptions
{
    WORD structSize;

    char FAR *toList;           // 'toList' and 'ccList' are ignored
    char FAR *ccList;           // if specifying recipients below.

    char FAR *subject;
    char FAR *message;

    WORD nRecipients;           // 'nRecipients' must be 0 if specifying
    lpMapiRecipDesc recipients; // To and CC lists above.
}
    UXDMAPIOptions;
#define UXDMAPIOptionsSize      (sizeof (UXDMAPIOptions))

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

#endif // UXDMAPI_H
