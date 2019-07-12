// ritorna elenco files di una tabella
// completi di path
// es. dfAliase2Files("ANAGRAF") ->{"c:\anagraf.dbf", "c:\anagraf.dbt", "c:\anagraf1.ntx", "c:\anagraf1.ntx"}
#include "dmlb.ch"
#include "dbstruct.ch"

FUNCTION dfAlias2Files(cAlias)
   LOCAL aFiles := {}
   LOCAL aRet   := {}
   LOCAL cFile
   LOCAL aFname
   LOCAL n
   LOCAL cIdx
   LOCAL cDBF
   LOCAL aIdx

   IF ! ddFilePos(cAlias, .F.)
      RETURN aRet
   ENDIF

   IF ddFileIsTab()
      RETURN aRet
   ENDIF

   cDbf := ddFileName()

   // file
   IF FILE( (cFile := ddFilePath()+cDbf+dfDbfExt(ddFileDriver())) )
      AADD( aRet, cFile )
   ENDIF

   // memo
   IF FILE( (cFile := ddFilePath()+cDbf+dfMemoExt(ddFileDriver())) )
      AADD( aRet, cFile )
   ENDIF
   IF !(dfMemoExt(ddFileDriver())==".DBT") .AND.;
      FILE( (cFile := ddFilePath()+cDbf+".DBT") )
      AADD( aRet, cFile )
   ENDIF

   IF dfUse(cAlias, NIL, aFiles)
      aIdx := dfOrdList_XPP()
      AEVAL(aIdx, {|x| AADD(aRet, x)})

/*
      // mette estensione 
      aFName := dfFNameSplit(cFile)
      IF EMPTY(aFName[4])
         aFName[4] := dfDBFext( RDDNAME() )
      ENDIF
      cFile := aFname[1]+aFName[2]+aFName[3]+aFname[4]

      AADD(aRet, cFile)

      // ha memo?
      IF ASCAN(DBSTRUCT(), {|a| a[DBS_TYPE] == "M"}) > 0
         // copio anche il memo
         AADD(aRet, aFname[1]+aFName[2]+aFName[3]+dfMemoExt( RDDNAME() ))
      ENDIF

      // indici
      n := 0
      DO WHILE .T.
         cIdx := OrdBagName_xpp( ++n, DMLB_QUALIFIED_FILENAME)
         IF EMPTY(cIdx)
            EXIT
         ENDIF
         IF ASCAN(aRet, cIdx) == 0
            AADD(aRet, cIdx)
         ENDIF
      ENDDO
*/
   ENDIF
   dfClose(aFiles, .T., .T.)
RETURN aRet