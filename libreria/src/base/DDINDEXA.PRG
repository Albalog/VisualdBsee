/*******************************************************************************
Progetto       : dBsee 4.3
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
*******************************************************************************/
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddIndexArr()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aIndex := {}

IF dbCfgOpen( "dbDD" )
   dbdd->(DBGOTOP())
   WHILE dbdd->(!EOF())
      IF UPPER(dbdd->rectyp) == "NDX"
         AADD( aIndex, { UPPER(ALLTRIM(dbdd->file_name)) ,;
                         UPPER(ALLTRIM(dbdd->file_ali))  ,;
                         ddindexexp()                    ,;
                         UPPER(dbdd->File_Mode) $ "PU"   }) // inserito Flag per indicare se indice primario/univoco
      ENDIF
      dbdd->(dbSKIP())
   ENDDO
ENDIF

RETURN aIndex
