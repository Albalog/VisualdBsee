#include "Common.ch"
#include "dfReport.ch"


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfIsPrn( nPort )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL lRet := .F.
   LOCAL nOpen := 0

   DEFAULT nPort TO  PRN_LPT1

   DO CASE
      CASE nPort == PRN_LPT1
         lRet := ISPRINTER()

      CASE nPort == PRN_LPT2
         lRet := ISPRINTER("LPT2")
         // nOpen := FOPEN("LPT2")
         // 
         // IF (lRet:=nOpen>0)
         //    FCLOSE( nOpen )
         // ENDIF

      CASE nPort == PRN_LPT3
         lRet := ISPRINTER("LPT3")
         // nOpen := FOPEN("LPT3")
         // 
         // IF (lRet:=nOpen>0)
         //    FCLOSE( nOpen )
         // ENDIF

   ENDCASE

RETURN lRet

