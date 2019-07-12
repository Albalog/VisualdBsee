/******************************************************************************
Progetto       : dBsee 4.3
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/
#include "Fileio.ch"
#include "dfMsg.ch"
#include "common.ch"

#define STR_LEN       4096
#define STR_PROT_LEN     8

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfIsPirate( lAsk )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC cProtect := "dnx‚Œ– ª"
LOCAL nHandle, cNewStr, nPos, lRet:=.T., cBuf:=SPACE(STR_LEN), cOldStr:=""

DEFAULT lAsk TO .T. 

// Make string to protect file
cNewStr := dfRomBios()
FOR nPos := 1 TO STR_PROT_LEN
   cNewStr := LEFT(cNewStr,nPos-1) +CHR(ASC(SUBSTR(cNewStr,nPos,1))+30+nPos) +RIGHT(cNewStr,STR_PROT_LEN-nPos)
   cOldStr += CHR(100 +((nPos-1)*10) )
NEXT

DO CASE
   CASE cProtect==cOldStr // To protect
        IF ! lAsk .OR. dfYesNo( dfStdMsg(MSG_DFISPIRATE01) )
           nHandle := FOPEN( dfExeName(), FO_READWRITE +FO_SHARED )
           IF (lRet:=(nHandle>F_ERROR))
              WHILE FREAD( nHandle, @cBuf, STR_LEN )>0
                 IF (nPos:=AT(cOldStr,cBuf))>0
                    FSEEK( nHandle, -STR_LEN, FS_RELATIVE )
                    lRet := (FWRITE( nHandle, LEFT(cBuf,nPos-1) +cNewStr +SUBSTR(cBuf,nPos+STR_PROT_LEN), STR_LEN )==STR_LEN)
                    IF lRet
                       lRet := (FERROR()==0)
                    ENDIF
                    EXIT
                 ENDIF
                 FSEEK( nHandle, -STR_PROT_LEN, FS_RELATIVE )
              END
              FCLOSE( nHandle )
           ENDIF
           IF !lRet
              dbMsgErr( dfStdMsg(MSG_DFISPIRATE02) )
           ENDIF
           lRet := !lRet
        ELSE
           dbMsgErr( dfStdMsg(MSG_DFISPIRATE03) )
           lRet := .F.
        ENDIF

   CASE cProtect==cNewStr // already protect
        lRet := .F.

   OTHERWISE              // Pirate !!!!!!!!!!!!!!!!!!!!!
        dbMsgErr( dfStdMsg(MSG_DFISPIRATE04) )
        lRet := .T.
ENDCASE

RETURN lRet
