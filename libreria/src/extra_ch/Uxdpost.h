/*
** File:    UXDPost.h
**
** Author:  Mone Hsieh
** Date:    96-04-15
**
** Purpose: An export destination DLL for Exchange Folders.
**
** Copyright (c) 1996  Seagate Software Information Management Group, Inc.
*/
#ifndef UXDPOST_H
#define UXDPOST_H

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

#define UXDExchFolderType 	0

#define UXDPostDocMessage       1011   // for folder messages

typedef struct tag_UXDPostFolderOptions
{
    WORD  structSize;
    LPSTR pszProfile;
    LPSTR pszPassword;
    WORD  wDestType;
    LPSTR pszFolderPath;
} UXDPostFolderOptions, FAR * LPUXDPostFolderOptions;

// pszFolderPath has to be in the following format:
// <Message Store Name>@<Folder Name>@<Folder Name>

#define UXDPostFolderOptionsSize      (sizeof (UXDPostFolderOptions))

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
#endif // UXDPOST_H

