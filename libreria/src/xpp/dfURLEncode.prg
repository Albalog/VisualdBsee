#include "common.ch"
#include "dfStd.ch"

// codifica un  URL secondo la specifica RFC 1738: Uniform Resource Locators (URL) specification
// "...Only alphanumerics [0-9a-zA-Z], the special characters "$-_.+!*'()," 
// [not including the quotes - ed], and reserved characters used for 
// their reserved purposes may be used unencoded within a URL."

FUNCTION dfURLEncode(cURL)
   LOCAL cOK := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ$-_.+!*'(),"
   LOCAL cRet := ""
   LOCAL n, i, ch

   IF EMPTY(cUrl)
      RETURN ""
   ENDIF

   i := LEN(cUrl)
   FOR n := 1 TO i
      ch := DFCHAR(cUrl, n)
      IF UPPER(ch) $ cOK
         cRet += ch
      ELSE
         cRet += "%"+dfByte2Hex(ASC(ch))
      ENDIF
   NEXT
RETURN cRet

