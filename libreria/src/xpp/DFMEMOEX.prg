#include "DbfDbe.ch"
#include "FoxDbe.ch"
#include "dfAdsDbe.ch"

FUNCTION dfMemoExt(cRdd)
   LOCAL cRet := ""

   IF ! VALTYPE(cRdd) == "C"
      cRdd := DbeSetDefault()
   ENDIF

   IF ! EMPTY(cRdd) .AND. ;
      UPPER(ALLTRIM(cRdd)) == ADSRDD

      IF S2DbeInfo( ADSRDD, COMPONENT_ORDER, ADSDBE_TBL_MODE) == ADSDBE_CDX
         cRet := ADSRDD_EXT_MEMO_CDX
      ELSEIF S2DbeInfo( ADSRDD, COMPONENT_ORDER, ADSDBE_TBL_MODE) == ADSDBE_ADT
         cRet := ADSRDD_EXT_MEMO_ADT
      ELSE
         cRet := ADSRDD_EXT_MEMO_NTX
      ENDIF

   ELSE
      cRet := _dfMemoExt(cRdd)
   ENDIF

RETURN "."+cRet

STATIC FUNCTION _dfMemoExt(cRdd)
   LOCAL cExt
   LOCAL cComp := S2DbeInfo(cRdd, COMPONENT_DATA, DBE_NAME)

   IF cComp == "DBFDBE"
      cExt := S2DbeInfo(cRdd, COMPONENT_DATA, DBFDBE_MEMOFILE_EXT)

   ELSEIF cComp == "FOXDBE"
      cExt := S2DbeInfo(cRdd, COMPONENT_DATA, FOXDBE_MEMOFILE_EXT)

   ENDIF
RETURN cExt

