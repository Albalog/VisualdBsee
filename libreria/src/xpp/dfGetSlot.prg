#include "Common.ch"
#include "dfStd.ch"
#include "error.ch"


FUNCTION ddGetSlot(cStr,cSep,nPos)
  LOCAL cRET := ""

  IF AT("±",cSep)  > 0    .AND. ;
     dBsee4AXS()          .AND. ;
     AT("±",cStr)  ==  0  .AND. ;
     AT(Chr(221) ,cStr ) > 0 
     cSep := StrTran(cSep,"±", Chr(221) )
  ENDIF 

  cRET := dfToken(cStr,cSep,nPos)   

RETURN cRet 