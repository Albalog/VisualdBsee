/*
** File:    UXDApp.h
**
** Purpose: Application Export Destination DLL for Seagate Crystal Reports.
**
** Copyright (c) 1998  Seagate Software, Inc.
*/

#if !defined (UXDAPPLICATION_H)
#define UXDAPPLICATION_H

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

#define UXDApplicationType             0

typedef struct UXDApplicationOptions
{
    WORD structSize;

    char FAR *fileName;
}
    UXDApplicationOptions;
#define UXDApplicationOptionsSize      (sizeof (UXDApplicationOptions))

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

#endif // UXDAPPLICATION_H

