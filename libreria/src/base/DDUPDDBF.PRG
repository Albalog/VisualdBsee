//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per FILE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
#include "dbStruct.ch"
#include "dfMsg.ch"
#include "dfStd.ch"
#include "dfSet.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE ddUpdDbf( lReindex, cFileName )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aOldStru, aNewStru, cStr

DEFAULT lReindex TO .T.

IF lReindex
   ddIndexSys( NTX_DBDD ) // Ricostruisce gli indici del dbdd
ENDIF

IF cFileName!=NIL
   cFileName := UPPER(ALLTRIM(cFileName))
ENDIF

IF dbCfgOpen("dbdd")         // Se esiste il dizionario
   dbdd->(DBSEEK("DBF"))
   WHILE UPPER(dbdd->RECTYP)=="DBF" .AND. !dbdd->(EOF()) // Tento di aggiornare
      IF cFileName!=NIL
         IF !(ALLTRIM(UPPER(dbdd->FILE_NAME))==cFileName)
            dbdd->(DBSKIP())
            LOOP
         ENDIF
      ENDIF

      IF !EMPTY( aNewStru:=ddFileStru(dbdd->FILE_NAME) )  // Tutti i file
         dfPushArea()
         cStr := dfStdMsg(MSG_DDUPDDBF01) +" " +ddFilePath() +ALLTRIM(ddFileName())
         __UpdDbf( ALLTRIM(ddFileName()), ddFileDriver(), ddFilePath(), aNewStru, cStr )
         dfPopArea()
      ENDIF
      dbdd->(DBSKIP())
   ENDDO
ENDIF
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION ddFileStru( cFile ) // Restituisce la struttura del database
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aStru := {}
cFile := PADR(UPPER(cFile),8)
dbdd->(dfPushArea())
dbdd->(DBSEEK("FIE"+cFile))
WHILE UPPER(dbdd->RECTYP)=="FIE"    .AND.;
      UPPER(dbdd->FILE_NAME)==cFile .AND.;
      !dbdd->(EOF())
   AADD(aStru, {dbdd->field_name ,;
                dbdd->field_type ,;
                dbdd->field_len  ,;
                dbdd->field_dec  })
   dbdd->(DBSKIP())
ENDDO
IF EMPTY(aStru)
   dbMsgErr( dfStdMsg(MSG_DDGENDBF01) +" " +; // Errore file senza campi
             cFile                    +" " +;
             dfStdMsg(MSG_DDGENDBF02) )
ENDIF
dbdd->(dfPopArea())
RETURN aStru

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION __UpdDbf(cFile, cRDD, cPath, aStru, cStr)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL lToReindex := .F.
   LOCAL lRet

   lRet := dfUpdDbf( cFile, cRDD, cPath, aStru, cStr, @lToReindex )
   IF lToReindex
      IF DBDD->(DBSEEK("NDX"+UPPER(ALLTRIM(cFile)))) // Alzo il flag sugli indici
         WHILE "NDX"+UPPER(PADR(cFile,8)) == UPPER(dBdd->RecTyp+dBdd->file_name) .AND. ;
            !DBDD->(EOF())
            IF dbdd->(DBRLOCK( RECNO() ))
               dbdd->FlgCodNdx := "1"
               dbdd->(DBCOMMIT())
               dbdd->(DBRUNLOCK( RECNO() ))
            ENDIF
            dbdd->(DBSKIP(1))
         END
      ENDIF
   ENDIF
RETURN lRet
