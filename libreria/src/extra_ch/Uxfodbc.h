/*
** File:    UXFODBC.h
**
** Author:  Hercules Cheng
** Date:    95-10-30
**
** Purpose: An export format DLL for ODBC.
**
** Copyright (c) 1995  Crystal Services
*/

#if !defined (UXFODBC_H)
#define UXFODBC_H

// Set 1-byte structure alignment
#if defined (__BORLANDC__)      // Borland C/C++
  #pragma option -a-
#elif defined (_MSC_VER)        // Microsoft Visual C++
  #if _MSC_VER >= 900           // MSVC 2.x and later
    #pragma pack (push)
  #endif
  #pragma pack (1)
#endif

#if defined (__cplusplus)
extern "C"
{
#endif

#define UXFODBCType             0

typedef struct UXFODBCOptions
{
    WORD structSize;

    char FAR *dataSourceName;
    char FAR *dataSourceUserID;
    char FAR *dataSourcePassword;
    char FAR *exportTableName;
#if defined (__cplusplus)
public :
	UXFODBCOptions()
	{
		structSize = sizeof(UXFODBCOptions);
		dataSourceName = NULL;
		dataSourceUserID = NULL;
		dataSourcePassword = NULL;
		exportTableName = NULL;
	};
#endif
}
    UXFODBCOptions;

#define UXFODBCOptionsSize (sizeof (UXFODBCOptions))

#if defined (__cplusplus)
}
#endif

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

#endif // UXFODBC_H
