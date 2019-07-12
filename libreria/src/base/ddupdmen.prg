/******************************************************************************
Project     : dBsee 4.5
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "dfMsg.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE ddUpdMenu()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aFile := {}, aDesc := {}, aTag := {}, nPos

IF dbcfgopen("dbdd")
   //DBDD->(dfS(1,UPPER(dbdd->RecTyp)))
   DBDD->(dfS(1,UPPER("DBF")))
   WHILE !DBDD->(EOF()) .AND. UPPER(dbdd->RecTyp)=="DBF"
      IF !ddFileIsTab()
         AADD( aFile, dbdd->file_name )
         AADD( aDesc, dbdd->field_des )
      ENDIF
      DBDD->(DBSKIP())
   ENDDO

   IF dfArrWin(,,,,aDesc,dfStdMsg(MSG_DDUPDDBF01),,aTag)>0
      AEVAL( aTag, {|n,pos|ddUpdDbf(pos==1,aFile[n])} )
   ENDIF
ENDIF

RETURN
