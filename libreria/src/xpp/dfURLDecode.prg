#include "common.ch"
#include "dfStd.ch"

// decodifica un  URL secondo la specifica RFC 1738: Uniform Resource Locators (URL) specification
// "...Only alphanumerics [0-9a-zA-Z], the special characters "$-_.+!*'()," 
// [not including the quotes - ed], and reserved characters used for 
// their reserved purposes may be used unencoded within a URL."

FUNCTION dfURLDecode(cURL)
   LOCAL cRet := ""
   LOCAL n, i, ch

   IF EMPTY(cUrl)
      RETURN ""
   ENDIF

   IF ! "%" $ cUrl
      RETURN cUrl
   ENDIF

   i := LEN(cUrl)
   FOR n := 1 TO i
      ch := DFCHAR(cUrl, n)
      IF ch == "%" .AND. n+2<=i .AND. ;
         DFCHAR(cUrl, n+1) $ "0123456789ABCDEF" .AND. ;
         DFCHAR(cUrl, n+2) $ "0123456789ABCDEF" 

         // prendo prossimi 2 caratteri
         ch := DFCHAR(cUrl, n+1)+DFCHAR(cUrl, n+2)
         
         n+=2
         cRet += CHR(dfHex2Dec(ch))
      ELSE
         cRet += ch
      ENDIF
   NEXT
RETURN cRet

