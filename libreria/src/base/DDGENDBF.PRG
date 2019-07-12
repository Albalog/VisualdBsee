//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per FILE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "dfMsg.ch"

#ifdef __XPP__
   // simone 5/11/04 per correzione problema DBGOTO(0)
   // vedi DBGOTO_XPP
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddGenDbf( cFile, cOut )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aStr, nRec, cDbf, cDriver, cDiskFile, cExt, cActFile, lRet := .T.
LOCAL aPath,cPath 
LOCAL oErr, err

//////////////////////////////////////////////
//Ger. 4164  o Contact  37123
oErr := ERRORBLOCK({|o|dfErrBreak(o)})
BEGIN SEQUENCE
//////////////////////////////////////////////

   dbCfgOpen( "dbdd" )

   dbdd->(DBSEEK("DBF"))
   WHILE UPPER(dbdd->RecTyp) == "DBF" .and. !dbdd->(eof())
      IF dbdd->file_typ = "1"  // table file don't need dbf structur as they are
         dbdd->(DBSKIP(1))     // stored in dbdd file
         LOOP
      ENDIF
      IF cFile#NIL
         IF !(UPPER(ALLTRIM(cFile))==UPPER(ALLTRIM(dbdd->File_name)))
            dbdd->(DBSKIP(1))
            LOOP
         ENDIF
      ENDIF
      cActFile  := UPPER(ALLTRIM(dbdd->File_name))

      nRec      := dbdd->(RECNO())

      cDbf      := ddFileName()              // File
      cDriver   := ddFileDriver()            // RDD
      cExt      := dfDbfExt( cDriver )       // Ext
      IF cOut#NIL .AND. cFile#NIL
         cDiskFile := cOut
      ELSE
         cDiskFile := ddFilePath() +cDbf     // Path +File +EXT
      ENDIF

      /////////////////////////////////////////////////////////////////
      //XbaseUserPathChk=YES     -> ABILITA Meccanismo  -> DEFAULT
      //XbaseUserPathChk=NO      -> Disabilita Meccanismo
      //XbaseUserPathChk=NO_MSG  -> ABILITA Meccanismo senza Messaggi
      //Gerr. 4164
      //Mantis 953
      aPath := dfFNameSplit(cDiskFile)
      cPath := aPath[1]+aPath[2]
      IF !EMPTY(cPath) .AND. !dfChkDir(cPath) .AND. !dfSet("XbaseUserPathChk") == "NO" //dfSet("XbaseUserPathChk") != "NO" 
         IF dfSet("XbaseUserPathChk") == "NO_MSG"
            IF dfMD(cPath) != 0
               lRet := .F.
               RETURN lRet
            ENDIF
         ELSE
            IF dfYesNo( dfStdMsg(MSG_DDGENDBF04) +" " +;
                        aPath[1]+aPath[2]+aPath[3]+cExt   +;
                        dfStdMsg(MSG_DDGENDBF05) )
               IF dfMD(cPath) != 0
                  dbMsgErr(dfStdMsg(MSG_DDGENDBF06) +" " +cPath)
                  lRet := .F.
                  RETURN lRet
               ENDIF
             ELSE
               lRet := .F.
               RETURN lRet
            ENDIF
         ENDIF
      ENDIF
      /////////////////////////////////////////////////////////////////
//Maudp-LucaC 18/05/2011 cDiskFile a volte era gi… con l'estensione altre volte senza ("docprec.dbf" +".dbf")
//      IF !dfRddFile( cDiskFile+cExt, cDriver )  // Se non esiste lo creo
      IF !dfRddFile( aPath[1] + aPath[2] + aPath[3] + cExt, cDriver )  // Se non esiste lo creo
         dfUsrMsg( dfStdMsg(MSG_DDGENDBF03) +" " +cDiskFile )
         dbdd->(DBSEEK("FIE"+cActFile))
         aStr := {}
         WHILE ALLTRIM(UPPER(dbdd->RecTyp+dbdd->file_name)) == "FIE"+cActFile .AND. ;
               !dbdd->(EOF())
            AADD(aStr, {ALLTRIM(dbdd->field_name) ,;
                                dbdd->field_type  ,;
                                dbdd->field_len   ,;
                                dbdd->field_dec   })
            dbdd->(DBSKIP())
         ENDDO

         IF !EMPTY(aStr)

            // Simone 10/09/2007
            // mantis 0001497: Disattivazione dell’accesso alla cartella dati mantenendo l’accesso da Extra.
            // Modifica Luca 07/04/2008
            //IF dfAxsLoaded(cDiskFile)
            IF dfAxsLoaded(cDiskFile,cDriver )
               cDriver := dfAXSDriver()
            ENDIF

            DBCREATE( cDiskFile, aStr, cDriver)

           #ifdef __XPP__
            // Simone 28/11/03 GERR 4019
            IF (dfSet("XbaseADSFIXEmptyDbf") == "YES")
               dfADSFixEmptyDBF(cDiskFile, cDriver, "_TMPADS_")
            ENDIF
           #endif

            // simone 28/11/08
            // supporto DBF criptati con ADS o ALS
            IF dfADSGetPwd(cDiskFile) != NIL
               dfADSTableEncrypt(cDiskFile, .T.)
            ENDIF
         ELSE
            lRet := .F.
            dbMsgErr( dfStdMsg(MSG_DDGENDBF01) +" " +;
                      cActFile                 +" " +;
                      dfStdMsg(MSG_DDGENDBF02) )
         ENDIF
      ENDIF

      dbdd->(DBGOTO(nRec))
      dbdd->(DBSKIP())
      IF cFile#NIL
         EXIT
      ENDIF
   ENDDO

//////////////////////////////////////////////
RECOVER USING err
   IF !EMPTY(cFile)
      dbMsgErr(dfStdMsg(MSG_DDGENDBF07) + "<"+ALLTRIM(cFile)+">")
   ELSE
      dbMsgErr(dfStdMsg(MSG_DDGENDBF07) )
   ENDIF
   lRet := .F.
END SEQUENCE
ERRORBLOCK(oErr)
//////////////////////////////////////////////
//FINE Ger. 4164  o Contact  37123
//////////////////////////////////////////////


RETURN lRet