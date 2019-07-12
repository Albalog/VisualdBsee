/*
** File:    UXFXml.h
**
** Purpose: An export format DLL for XML.
**
*/

#if !defined (U2FXML_H)
#define U2FXML_H

// Set 1-byte structure alignment
#if !defined(PLAT_UNIX) 
#if defined (__BORLANDC__)      // Borland C/C++
  #pragma option -a-
#elif defined (_MSC_VER)        // Microsoft Visual C++
  #if _MSC_VER >= 900           // MSVC 2.x and later
    #pragma pack (push)
  #endif
  #pragma pack (1)
#endif
#endif

#if defined (__cplusplus)
extern "C"
{
#endif

#define UXFXMLType     0

typedef struct UXFXmlOptions
{ 
    WORD structSize;

	char FAR *fileName;
    short allowMultipleFiles;

}
    UXFXmlOptions;

#define UXFXmlOptionsSize (sizeof (UXFXmlOptions))


#if defined (__cplusplus)
}
#endif

// Reset structure alignment
#if !defined(PLAT_UNIX)
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

#endif // UXFXLS_H

