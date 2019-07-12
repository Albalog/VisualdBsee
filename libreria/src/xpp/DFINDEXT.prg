#include "DbfDbe.ch"
#include "common.ch"
#include "dfAdsDbe.ch"

FUNCTION dfIndExt(cRdd)
   LOCAL cRet := ""

   IF ! VALTYPE(cRdd) == "C"
      cRdd := DbeSetDefault()
   ENDIF

   IF ! EMPTY(cRdd) .AND. ;
      UPPER(ALLTRIM(cRdd)) == ADSRDD

      IF S2DbeInfo( ADSRDD, COMPONENT_ORDER, ADSDBE_TBL_MODE) == ADSDBE_CDX
         cRet := ADSRDD_EXT_NDX_CDX
      ELSEIF S2DbeInfo( ADSRDD, COMPONENT_ORDER, ADSDBE_TBL_MODE) == ADSDBE_ADT
         cRet := ADSRDD_EXT_NDX_ADT
      ELSE
         cRet := ADSRDD_EXT_NDX_NTX
      ENDIF

   ELSE
      cRet := S2DbeInfo(cRdd, COMPONENT_ORDER, DBE_EXTENSION)
   ENDIF

RETURN "."+cRet
