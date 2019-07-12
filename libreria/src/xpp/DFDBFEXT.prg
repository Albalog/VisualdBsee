#include "Dmlb.ch"
#include "DbfDbe.ch"
#include "dfAdsDbe.ch"

FUNCTION dfDbfExt(cRdd)
   LOCAL cRet := ""
   local cADSType := 0
   IF ! VALTYPE(cRdd) == "C"
      cRdd := DbeSetDefault()
   ENDIF

   IF ! EMPTY(cRdd) .AND. ;
      UPPER(ALLTRIM(cRdd)) == ADSRDD

      cRet := ADSRDD_EXT_DBF
      cADSType := S2DbeInfo( ADSRDD, COMPONENT_ORDER, ADSDBE_TBL_MODE)
      //Modificato Luca 16/10/2009 per evitare di dare un runtime error in caso di errata impostazione del Dbdd.ini o dbdd.dbf
      //IF S2DbeInfo( ADSRDD, COMPONENT_ORDER, ADSDBE_TBL_MODE) == ADSDBE_ADT
      IF VALTYPE(cADSType) == "N" .AND.; 
         cADSType == ADSDBE_ADT
         cRet := ADSRDD_EXT_ADT
      ENDIF

   ELSE
      cRet := S2DbeInfo(cRdd, COMPONENT_DATA , DBE_EXTENSION)
   ENDIF

   //Aggiuinto per non avere problemi quando il drivere DBFNTX non Š caricato 
   IF UPPER(cRdd) $ "DBFNTX-DBFCDX"
      cRet := "dbf"
   ENDIF

   IF UPPER(cRdd) == "XML"
      cRet := "xml"
   ENDIF

RETURN "."+cRet
