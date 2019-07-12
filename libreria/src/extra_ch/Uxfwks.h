/*
** File:    UXFWks.h
**
** Author:  Douglas Lankshear
** Date:    93-06-29
**
** Purpose: An export format DLL for Lotus Wks.
**
** Copyright (c) 1993  Seagate Software Information Management Group, Inc.
*/

#if !defined (UXFWKS_H)
#define UXFWKS_H

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

#define UXFLotusWksType    0
#define UXFLotusWk1Type    1
#define UXFLotusWk3Type    2

// No options.

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

#endif // UXFWKS_H
