#include "dfWin.ch"
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
PROCEDURE tbSysFooter( oTbr )
* ħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħħ
IF !EMPTY(oTbr:W_SYSFOOTER) .AND. (NEXTKEY()#LASTKEY() .OR. LASTKEY()==0)
   AEVAL( oTbr:W_SYSFOOTER,;
         {|oSub|oSub:FOOTING:=dfAny2Str(EVAL(oSub:WC_FOOTERINFOBLOCK))})
   tbCONFIGURE(oTbr)                           // Riconfiguro la BROWSE
   tbStab( oTbr, .T. )
ENDIF
RETURN
