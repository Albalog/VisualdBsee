/******************************************************************************
Project     : dBsee 4.4
Description : Utilities Function
Programmer  : Baccan Matteo
******************************************************************************/

#include "dbStruct.ch"
#include "common.ch"
// Simone 26/3/10
// aggiunti parametri
// cFile=tabella da esaminare default=alias corrente
// lStructFromDBDD= se prende struttura fisica da tabella aperta o da DBDD
// bOtherInfo= codeblock per aggiungere altre informazioni da dBDD
// lField_FRM= SE .T. permette di estrarre solo i campi che  sono gestiti in dbdd in From 
// lFiled_Win= SE .T. permette di estrarre solo i campi che  sono gestiti in dbdd in Ricerca 
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddFileStruct(cFile, lStructFromDBDD, bOtherInfo, lField_FRM, lField_Win) // Carico l'array con la struttura con Description e PICTURE
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//LOCAL cFile:=UPPER(PADR(ALIAS(),8)), nPos, aStruct := DBSTRUCT()
LOCAL aStruct := {}
LOCAL nPos

DEFAULT cFile TO ALIAS()
DEFAULT lStructFromDBDD TO .F.


/////////////////////////////////////////////////////////////////////////////////////////////
//Mantis 2203
/////////////////////////////////////////////////////////////////////////////////////////////
//Abilitata la possibilit… di estrarre solo la strututra dei campi  in from o Ricerca da dbdd 
//////////////////////////////////////////////////////////////////////////////
IF (lField_FRM <> NIL .AND. lField_FRM) .OR.;
   (lField_WIN <> NIL .AND. lField_WIN)
   lStructFromDBDD := .T.
ENDIF 
//////////////////////////////////////////////////////////////////////////////



IF lStructFromDBDD
   aStruct := {}
ELSE
   aStruct := (cFile)->(DBSTRUCT())
   AEVAL( aStruct, {|aSub|ASIZE(aSub,LEN(aSub)+4)} )
ENDIF

cFile := UPPER(PADR(cFile,8))

DBDD->(DBSEEK("FIE"+cFile))
WHILE UPPER(dBdd->RecTyp+dbdd->file_name)=="FIE"+cFile .AND. !DBDD->(EOF())
   //////////////////////////////////////////////////////////////////////////////
   //Mantis 2203
   //////////////////////////////////////////////////////////////////////////////
   //Abilitata la possibilit… di estrarre solo la strututra dei campi  in from o Ricerca da dbdd 
   //////////////////////////////////////////////////////////////////////////////
   IF lField_FRM <> NIL .AND. lField_FRM  .AND. dbdd->field_FRM <> "1"
      DBDD->(DBSKIP())
      LOOP
   ENDIF 
   IF lField_WIN <> NIL .AND. lField_WIN  .AND. dbdd->field_WIN <> "1"
      DBDD->(DBSKIP())
      LOOP
   ENDIF 
   //////////////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////////////


   IF lStructFromDBDD
      AADD(aStruct, {UPPER(ALLTRIM(dbdd->FIELD_NAME)), dbdd->FIELD_TYPE, ;
                     dbdd->FIELD_LEN, dbdd->FIELD_DEC, NIL, NIL, NIL, NIL })
      nPos := LEN(aStruct)
   ELSE
      nPos := ASCAN( aStruct, {|cSub|cSub[DBS_NAME]==UPPER(ALLTRIM(DBDD->Field_Name))} )
   ENDIF
   IF nPos>0
      aStruct[nPos][DBS_ALEN+1] :=  ALLTRIM(dbdd->Field_Pic)
      aStruct[nPos][DBS_ALEN+2] :=  DBDD->Field_Des
      aStruct[nPos][DBS_ALEN+3] :=  DBDD->Field_msg

      IF ! EMPTY(bOtherInfo)
         aStruct[nPos][DBS_ALEN+4] :=  EVAL(bOtherInfo)
      ENDIF
   ENDIF
   DBDD->(DBSKIP())
ENDDO

RETURN aStruct
