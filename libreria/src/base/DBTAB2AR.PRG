/*******************************************************************************
Project     : Generato dBsee 4.0
Description : Funzioni per tabelle
Programmer  : Baccan Matteo
*******************************************************************************/
#include "dfTab.ch"
#include "Common.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dbTab2Arr( cTabID, aKey )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aRet       := {}
LOCAL aStructure := {}
LOCAL lNewMethod :=  .F.
LOCAL aFie, nFie
LOCAL cRet
dfPushArea()

aKey :=  {}

IF dbCfgOpen( "dbdd" ) .AND. dbCfgOpen( "dbtabd" )
   cTabID  := UPPER(PADR(cTabID, 8))   // Sistemo i parametri

   dbdd->(dfS( 1, "FIE"+ cTabID )) // il campo
   WHILE UPPER(dbdd->RecTyp)=="FIE"     .AND.;
         UPPER(dbdd->File_name)==cTabID .AND.;
         !DBDD->(EOF())
      AADD( aStructure, {dbdd->TabFieSod, dbdd->field_len, dbdd->field_type} )
      dbdd->(DBSKIP())
   ENDDO

   dbtabd->(dbgotop())
   lNewMethod := .F.
   WHILE !dbtabd->(EOF())  
      IF !lNewMethod
         aFie          := dfStr2arr(dbtabd->TabData,TAB_SEPARATORE )
         lNewMethod    := LEN(aFie) > 1
      ENDIF 
      dbtabd->(DBSKIP())
   ENDDO

   IF LEN(aStructure) > 0
      dbtabd->(DBSEEK( cTabID+ TAB_PRK )) // posiziono il record dati
      WHILE !dbtabd->(EOF())             .AND.;
            UPPER(dbTabD->TabId)==cTabId .AND.;
            UPPER(dbTabD->TabPrk)==TAB_PRK
 
         AADD( aRet, ARRAY( LEN(aStructure) ) )

         IF lNewMethod

            ATAIL(aRet)[1] := dfTab2Str(aStructure[1][1],aStructure[1][2],aStructure[1][3])
            aFie  := dfStr2arr(dbTabd->TabData,TAB_SEPARATORE )
            FOR nFie := 2 TO LEN(aStructure) 
                IF LEN(aFie) >= nFie
                   cRet := aFie[nFie-1]
                   cRet := dbTabConv( cRet, aStructure[nFie][3] )
                   ATAIL(aRet)[nFie] := cRet
                ELSE
                   ATAIL(aRet)[nFie] := ""
                ENDIF 
            NEXT 

         ELSE 
            AEVAL( aStructure, ;
               {|aSub,nPos|ATAIL(aRet)[nPos] := dfTab2Str(aSub[1],aSub[2],aSub[3])})
         ENDIF 
         AADD(aKey, dbtabd->TabCode)
         dbtabd->(DBSKIP())
      ENDDO
   ENDIF
ENDIF

dfPopArea()

RETURN aRet


