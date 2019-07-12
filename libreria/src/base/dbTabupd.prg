/*******************************************************************************
Project     : Generato dBsee 4.0
Description : Funzioni per tabelle
Programmer  : Baccan Matteo
*******************************************************************************/
#include "dfTab.ch"
#include "Common.ch"
#include "dfSet.ch"
//#include "dfMsg.ch"
//#include "dfStd.ch"


//Mantis 2229
//
//
//     Questa funzione permette di convertire/aggiornare la struttura di una 
//     tabella dBsee4 mantenendo i dati salvati e gi… utilizzati in un progetto 
//     esistente. Se si varia la struttura di una tabella dBsee4 senza eseguire 
//     prima tale funzione  si rischia di perdere le informazioni in essa 
//     memorizzate. Per la natura di come sono memorizzati  i dati dentro la 
//     struttura di una tabella dBsee4 non vi Š un riferimento puntuale alla 
//     posizione dei dati modificati, quindi  Š possibile utilizzare un tabella 
//     dBsee4 solo con il dbdd.dbf con cui Š nata la tabella. Se il dBdd.dbf varia 
//     Š necessario aggiornare il riferimento dei valori memorizzati nelle tabelle 
//     dbsee4 con la nuova funzione dbTabUpd() appositamente creata la quale 
//     permette di ovviare a tale problema conoscendo la struttura del vecchio 
//     dBdd.dbf di riferimento. L'aggiornamento delle tabelle dBsee4 non Š 
//     reversibile ed Š necessario effettuare l'aggiornamento non pi— di una 
//     volta per ogni cambio di dbdd.   
//
//!Example:
//
//     LOCAL cPathOldDbdd := "OLDDBDD"
//
//     * #COD OIEXE4 
//     IF dfChkPar("/UPD")    // Attivazione dell'aggiornamento archivi
//        //Da eseguire meglio prima della ddUpdDbf()
//        IF dbTabUpd( cPathOldDbdd ) 
//           //Cancellare il vecchio dBdd.dbf nella cartella "OLDDBDD" 
//	   //per evitare di rifare l'aggiornamento 2 volte con lo stesso dbdd 
//	   //e corrompere i dati della tabella 
//           FErase(cPathOldDbdd+"dbdd.dbf") 
//           FErase(cPathOldDbdd+"dbdd1.ntx") 
//           FErase(cPathOldDbdd+"dbdd2.ntx") 
//        ENDIF 
//     ENDIF
//     * #END Prima della Gestione Login


* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dbTabupd(cOLDDbddPath)
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

//Aggiorna struttura campi con confronto vecchio dbdd
  LOCAL lRet := .F.
  LOCAL aID        := {}
  LOCAL aRet       := {}
  LOCAL aNewStr    := {}
  LOCAL aOldStr    := {}
  LOCAL cNewDBDD   := ""
  LOCAL aData      := {}
  LOCAL aVal       := {}
  LOCAL aOLD       := {}
  LOCAL aNewData   := {}
  LOCAL nTab       := 0
  LOCAL nN         := 0
  LOCAL cFie       := ""
  LOCAL nFie       := 0
  LOCAL nLen       := 0 
  LOCAL cType      := "" 
  LOCAL nPOS       := 0
  LOCAL aStructure := NIL
  LOCAL cTabId
  LOCAL aStru//, nFie
  LOCAL cStr,cSep 
  LOCAL nData
  LOCAL aNew
  LOCAL cPath
  LOCAL cName
  LOCAL cExt 
  LOCAL cFile  
  LOCAL cFileBK
  LOCAL aKey, cKey
  LOCAL tbData //, aRet
  LOCAL cNtx1
  LOCAL nKey , aFie
  LOCAL lNewMethod :=  .F.

////////////////////////////////////////////////////////////////////////////////////////
// MG 02/07/2013 per evitare che in mancanza del vecchio dbdd.dbf entri nel programma
//               e la fase di update si fermi.
IF EMPTY(cOLDDbddPath) .OR. !File(dfPathChk(cOLDDbddPath)+"dbdd.dbf")
   RETURN lRet
EndIF
////////////////////////////////////////////////////////////////////////////////////////

dfPushArea()

IF dbCfgOpen( "dbdd" ) .AND. dbCfgOpen( "dbtabd" )

   cSep := TAB_SEPARATORE //"±"

   dbtabd->(dbgotop())
   lNewMethod := .F.
   WHILE !dbtabd->(EOF())  
      IF ASCAN(aID, {|x|x == UPPER(dbTabD->TabId) }) == 0
         AADD( aID, UPPER(dbTabD->TabId))
      ENDIF 
      IF !lNewMethod
         aFie          := dfStr2arr(dbtabd->TabData,TAB_SEPARATORE )
         lNewMethod    := LEN(aFie) > 1
      ENDIF 
      dbtabd->(DBSKIP())
   ENDDO
   aFie := {}
   FOR nN:= 1 TO LEN(aID)
       cTabID  := UPPER(PADR(aID[nN], 8))   // Sistemo i parametri
       aRet    := {}
       dbdd->(dfS( 1, "FIE"+ cTabID )) // il campo
       WHILE UPPER(dbdd->RecTyp)=="FIE"     .AND.;
             UPPER(dbdd->File_name)==cTabID .AND.;
             !DBDD->(EOF())
          IF dbdd->TabFieSod >0
             AADD( aRet, {dbdd->TabFieSod, dbdd->field_len, dbdd->field_type, dbdd->Field_name} )
          ENDIF 
          dbdd->(DBSKIP())
       ENDDO
       AADD(aNewStr, {nN ,cTabID, Aclone(aRet)})
   NEXT

   IF !EMPTY(cOLDDbddPath)
      cNewDBDD := dbCfgPath( "dbddPath" )

      dbCfgPath( "dbddPath",dfpathchk(cOLDDbddPath) )

      dbCfgClose("dbdd")

      IF dbCfgOpen( "dbdd" ) 

         FOR nN := 1 TO LEN(aID)
             aRet    := {}
             cTabID  := UPPER(PADR(aID[nN], 8))   // Sistemo i parametri
             dbdd->(dfS( 1, "FIE"+ cTabID )) // il campo
             WHILE UPPER(dbdd->RecTyp)=="FIE"     .AND.;
                   UPPER(dbdd->File_name)==cTabID .AND.;
                   !DBDD->(EOF())
                IF dbdd->TabFieSod >0
                   AADD( aRet, {dbdd->TabFieSod, dbdd->field_len, dbdd->field_type, dbdd->Field_name} )
                ENDIF 
                dbdd->(DBSKIP())
             ENDDO
             AADD(aOLDStr, {nN ,cTabID, Aclone(aRet)})


         NEXT

         aData       := {}
         FOR nN      := 1 TO LEN(aID)
             cTabID  := UPPER(Alltrim(aID[nN] ))   // Sistemo i parametri
             aRet    := dbTab2Arr( cTabID, @aKey )
             AADD(aData, {cTabID, Aclone(aKey), Aclone(aRet)})
         NEXT

         dbCfgClose("dbdd")
         Sleep(10)
         dbCfgPath( "dbddPath", cNewDBDD )
      ENDIF 
      dbCfgOpen( "dbdd" ) 
   ENDIF 


   IF EMPTY(aData)
      aData       := {}
      FOR nN      := 1 TO LEN(aID)
          cTabID  := UPPER(Alltrim(aID[nN]))   // Sistemo i parametri
          aRet    := dbTab2Arr( cTabID, @aKey )
          AADD(aData, {cTabID, Aclone(aKey), Aclone(aRet)})
      NEXT
   ENDIF 



   FOR nTab   := 1 TO LEN(aNewStr)
       cTabID := Upper(Alltrim(aNewStr[nTab][2] ))
       aStru  := aNewStr[nTab][3] 
       cStr   := ""
       IF LEN(aStru) >0
          FOR nFie   := 1 TO LEN(aStru)
              cFie   := alltrim(upper(aStru[nFie][4]))
              nLen   := aStru[nFie][2]
              cType  := aStru[nFie][3]

              aOld   := aOLDStr[nTab][3]
              IF EMPTY(aOLD)
                 EXIT
              ENDIF 

              nPOS   := ASCAN(aOLD, {|x| alltrim(upper(x[4])) == cFie } )
              IF nPOS > 0
                 nPOS++
                 FOR nData := 1 TO LEN(aData)
                     IF aData[nData][1]== cTabID
                        aKey := aData[nData][2]
                        //cStr := aData[nData][2][nPos]
                        aVal := aData[nData][3]
                        //cStr := ""
                        aNew   := {}
                        FOR nN := 1 TO LEN(aVal)
                           IF LEN( aVal[nN] ) >= nPOS
                              //////////////////////////////////////////////////////////////////////
                              // MG 03/07/2013 per evitare errori nella successiva istruzione
                              //AADD( aNew, aVal[nN][nPOS] )
                              AADD( aNew, padr(aVal[nN][nPOS],nLen) )
                              //////////////////////////////////////////////////////////////////////

                           ENDIF 
                        NEXT
                        AADD(aNewData, {Alltrim(Upper(cTabID)), Alltrim(Upper(cFie)), Aclone(aKey), Aclone(aNew)})
                     ENDIF 
                 NEXT 
              ELSE 
                 nPOS := ASCAN(aData, {|x|x[1] ==cTabID  })
                 IF nPOS > 0
                    aKey := aData[nPOS][2]
                    aNew := ARRAY(LEN(aKey))
                    aFILL(aNew, "")
                
                    AADD(aNewData, {Alltrim(Upper(cTabID)), Alltrim(Upper(cFie)), Aclone(aKey), Aclone(aNew)})

                 ENDIF 
              ENDIF 
          NEXT
      ELSE
         nPOS := ASCAN(aData, {|x|x[1] ==cTabID  })
         IF nPOS > 0
            aKey := aData[nPOS][2]
            aNew := ARRAY(LEN(aKey))
            aFILL(aNew, "")
        
            AADD(aNewData, {Alltrim(Upper(cTabID)), Alltrim(Upper(cFie)), Aclone(aKey), Aclone(aNew)})

         ENDIF 
      ENDIF 
   NEXT
   dbCfgClose("dbtabd")

   cPath := dfTabPath()
   cName := dfSet(AI_TABNAME)
   cExt  := dfTabExt()

   cFile   := dfpathchk(cPath) + cName+cExt
   cFileBK := dfpathchk(cPath) + "_old_"+cName+".bak"
   cNtx1   := dfpathchk(cPath) + dfSet(AI_TABINDEX1)

   IF !FILE(cFile) .OR. !dfFileCopy(cFile, cFileBK)
      dfalert("Errore in copia file dbTabd.dbf")
      dfPopArea()
      RETURN .F.
   ENDIF 

   IF dfUseFile( cPath +cName +cExt, "dbtabd", .T. ,dfTabRdd() )
      SET INDEX TO (cNtx1)
        // DBFMDX dont' set the index !!!!!!
      SET ORDER TO 1
      

      tbData := {}
      FOR nN   := 1 TO LEN(aNewStr)
          cTabID  := Alltrim(Upper(aNewStr[nN][2]))
          aFie    := aNewStr[nN][3]

          aRet    := {}
          IF LEN(aFie) > 0
             FOR nFie   := 1 TO LEN(aFie)
                 cFie   := Alltrim(upper(aFie[nFie][4]))

                 nPOS  := ASCAN(aNewData, {|x|x[1]== cTabID .AND. x[2] == cFie })
                 IF nPOS > 0
                    //cTabID := aNewData[nPos][1] 
                    //cFie   := aNewData[nPos][2]
                    aKey   := aNewData[nPos][3]
                    aNew   := aNewData[nPos][4]
                    IF EMPTY(aRet)
                       aRet :=  Array(LEN(aKey))
                    ENDIF 

                    FOR nKey := 1 TO LEN(aKey)
                        IF EMPTY(aRet[nKey])
                           aRet[nKey]  := {aKey[nKey] ,"" }
                        ENDIF 
                        //IF !lNewMethod
                           aRet[nKey][2] +=  aNew[nKey]+cSep 
                        //ELSE
                        //   aRet[nKey][2] +=  aNew[nKey]
                        //ENDIF 
                    NEXT 
                 ELSE

                 ENDIF 

             NEXT
             AADD(tbData, {cTabID, aClone(aRet)} )
          ELSE
             aRet  := {}
             nPOS  := ASCAN(aNewData, {|x|x[1]== cTabID })
             IF nPOS > 0
                aKey   := aNewData[nPos][3]
                aRet   := Array(LEN(aKey))
                FOR nKey := 1 TO LEN(aKey)
                    aRet[nKey]  := {aKey[nKey] ,"" }
                NEXT 
                AADD(tbData, {cTabID, aClone(aRet)} )
             ENDIF 
          ENDIF 
      NEXT 

      dbtabd->(DBZAP())

      FOR nN := 1 TO LEN(tbData)
          cTabID  := tbData[nN][1]
          aRet    := tbData[nN][2]

          FOR nKey := 1 TO LEN(aRet)

              dbtabd->(dbappend())
              dbtabd->TabID      := cTabID//jjTabID
              dbtabd->TabPrk     := ""
              dbtabd->TabCode    := aRet[nKey][1]
              dbtabd->Tabdeleted := [*]
              dbtabd->TabData    := aRet[nKey][2] //jjTabData
              dbtabd->Tabupdtime := time()
              dbtabd->Tabupddate := date()
              dbtabd->Tabusrlock := ""
              dbtabd->(dbCommit())

          NEXT 
      NEXT 
      lRet := .T. 
   ENDIF 
   dbCfgClose("dbtabd")

   dbCfgOpen( "dbtabd" )
ENDIF

dfPopArea()

RETURN lRet


