//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per FILE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "Common.ch"
#include "dfmsg.ch"
#include "dfstd.ch"
#include "dfset.ch"

//FWH: 2021-10-29
// se valorizzata contiene il nome della finestra da aprire quando si chiama la funzione ddwin
MEMVAR INFOTEL_DEFAULT_WIN 

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddFilePos( cFile, lErrMsg )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T.

DEFAULT lErrMsg TO .T.

cFile:=UPPER(PADR(cFile,8))    // Normalizza il FILE
dbdd->(DBSEEK( "DBF"+cFile ))  // Posiziono il file su dBdd
IF !dbdd->(FOUND())
   IF lErrMsg
      dbMsgErr( dfStdMsg(MSG_DDUSE01)+cFile)
   ENDIF
   lRet := .F.
ENDIF
RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddFileDriver()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cDriver := UPPER(ALLTRIM(dbdd->Field_Name))
IF EMPTY(cDriver) .OR. ASCAN( RDDLIST(), {|cSubDriver|cSubDriver==cDriver} )==0
   cDriver := RDDSETDEFAULT()
ENDIF
RETURN cDriver        // Driver

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddFileName()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cFile := "", cVarName
DO CASE
   CASE EMPTY(dbdd->file_ali)                  // alias non impostato in dBsee
        cFile := dbdd->file_name               // prendo il NOME

   CASE LEFT(dbdd->file_ali,1) == "@"          // nome da variabile
        cVarName := SUBSTR(dbdd->File_Ali,2)   // la prendo
        IF TYPE( cVarName ) # "C"              // controllo il tipo
           dbMsgErr( dfStdMsg(MSG_DDUSE02) +TRIM(dbdd->file_name)+"//"+;
                     dfStdMsg(MSG_DDUSE03) +cVarName       )
        ELSE
           cFile := &cVarName                  // NOME
        ENDIF

   OTHERWISE
        cFile := dbdd->file_ali                // NOME
ENDCASE
RETURN UPPER(ALLTRIM(cFile))                   // Nome del File

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddFileIsTab()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN dbdd->FILE_TYP=="1"                     // E' tabella

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddFilePath()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cPath 

// simone 13/11/06 
// mantis 0001165: aggiungere possibilit… di mappare un singolo dbf in un path specifico
cPath := dfSet("UserPath_"+ALLTRIM(dbdd->file_name))
IF EMPTY(cPath)
   cPath := dbDbfPath(VAL(dbdd->File_Path)) // Path del file da dbstart.ini
ELSEIF LEFT(cPath, 1)=="@"
   cPath := dbDbfPath(VAL(SUBSTR(cPath, 2))) // Path del file formato UserPath_NOMEDBF=@12 = 12øpath da dbstart.ini
ELSE
   cPath := dfPathChk(cPath)                 // Path del file formato UserPath_NOMEDBF=c:\pippo
ENDIF
IF dfASDriver( ddFileDriver() )                // Se e' un file su AS400
   cPath := LEFT( cPath, LEN(cPath)-1 )           // Rimuovo lo slash \ finale
   IF RIGHT(cPath,1)#":" .AND. LEN(cPath)>1       // Se ho un path
      cPath += ":"                                   // Aggiungo i : finali
   ENDIF
ENDIF
RETURN cPath

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddFilePathNum()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  LOCAL xRet := dbdd->File_Path
  IF dfIsDigit(Alltrim(xRet)) 
     xRet := VAL(Alltrim(xRet))
  ELSE 
     xRet := 0
  ENDIF 
RETURN xRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddFileDACConnID()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cPath
LOCAL cID
LOCAL nPath

// simone 13/11/06
// mantis 0001165: aggiungere possibilit… di mappare un singolo dbf in un path specifico
cPath := dfSet("UserPath_"+ALLTRIM(dbdd->file_name))
IF EMPTY(cPath)
   nPath := VAL(dbdd->File_Path)
ELSEIF LEFT(cPath, 1)=="@"
   nPath := (VAL(SUBSTR(cPath, 2))) // Path del file formato UserPath_NOMEDBF=@12 = 12øpath da dbstart.ini
ENDIF
IF nPath == NIL
   RETURN NIL
ENDIF
RETURN dfDACConnIDBuild(nPath)



* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddFileDesc()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cName := dbdd->Field_des
IF EMPTY(cName)
   cName := dbdd->File_Name
ENDIF
RETURN ALLTRIM(cName)

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddIndexExp()                          // Espressione di Indice
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   LOCAL cNdxExp
   LOCAL cKey

   IF ! dfSet(AI_INDEXSTRUCTDYN) // funzionamento standard?
      // Simone 29/3/07
      // mantis 0001215: se la struttura di un indice Š troppo lunga in creazione indice si possono avere errori runtime o indici errati
      RETURN ALLTRIM(dbdd->Field_Pic) +ALLTRIM(dbdd->Field_Pico)
   ENDIF


   // Simone 29/3/07
   // mantis 0001215: se la struttura di un indice Š troppo lunga in creazione indice si possono avere errori runtime o indici errati
   // ricalcolo la chiave dai singoli campi
   cNdxExp := ""

   dbdd->(dfPushArea())
   cKey := UPPER("key"+dbdd->FILE_NAME+STR(dbdd->NDXINCN, 3, 0))

   dbdd->(dfS(1, cKey ))
   DO WHILE ! dbdd->(EOF()) .AND. ;
            UPPER(dbdd->RECTYP+dbdd->FILE_NAME+STR(dbdd->NDXINCN, 3, 0)) == cKey
            //Mantis 1665. Luca 29/11/2007
            //UPPER("key"+dbdd->FILE_NAME+STR(dbdd->NDXINCN, 3, 0)) == cKey

      IF ! EMPTY(dbdd->SLOT)
         cNdxExp += "+"+ALLTRIM(dbdd->SLOT)
      ENDIF

      dbdd->(dbSkip())
   ENDDO
   dbdd->(dfPopArea())

   cNdxExp := SUBSTR(cNdxExp, 2) // salto "+" iniziale

   IF ! EMPTY(dbdd->FIELD_MSG)
      cNdxExp  := tStrTran(Alltrim(dbdd->FIELD_MSG) ,;
                           Alltrim(cNdxExp) )
   ENDIF
RETURN cNdxExp

// funzione tStrTran()
// presa da sorgenti Visual dBsee file TF.PRG
*******************************************************************************
STATIC FUNCTION tStrTran(      ; // SOSTITUISCE NELLA STRINGA1 IL % CON LA STRINGA2
                   cS1 ,; // Stringa 1
                   cS2 ,; // Stringa 2
                   cS3 ,; // Stringa 3  (Opzionale)
                   cS4  ) // Stringa 4  (Opzionale)

// esempio nr. 1:
//          cExp := tStrTran( cKeyExp ,alltrim(dd_sym->SYM_NAM) )
//  con  ckeyExp = "upper(%)"

// esempio nr. 2:
//          cExp := tStrTran( cKeyExp, alltrim(dd_sym->SYM_NAM), alltrim(str(dd_sym->SYM_LEN)), alltrim(str(dd_sym->SYM_DEC)) )
//  con  ckeyExp = "str(%N, %L, %D)"

*******************************************************************************
LOCAL cRet := ""

IF EMPTY( cS1 ); RETURN cS2; ENDIF
//## 12/12/96 Matteo ottimizzato
IF !("%"$cS1)  ; RETURN cS1; ENDIF

DEFAULT cS3 TO ""
DEFAULT cS4 TO ""

IF "%N" $ cS1 
   cS1 := StrTran( cS1 ,"%N" ,cS2 )
ENDIF
IF "%L" $ cS1
   cS1 := StrTran( cS1 ,"%L" ,cS3 )
ENDIF
IF "%D" $ cS1
   cS1 := StrTran( cS1 ,"%D" ,cS4 )
ENDIF
IF "%n" $ cS1 
   cS1 := StrTran( cS1 ,"%n" ,cS2 )
ENDIF
IF "%l" $ cS1
   cS1 := StrTran( cS1 ,"%l" ,cS3 )
ENDIF
IF "%d" $ cS1
   cS1 := StrTran( cS1 ,"%d" ,cS4 )
ENDIF
IF "%" $ cS1
   cS1 := StrTran( cS1 ,"%" ,cS2 )
ENDIF
RETURN cS1



* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddIndexWin()                          // Finestra sull'indice
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

//FWH: 2021-10-29
// la finestra alternativa viene visualizzata solo se
// INFOTEL_DEFAULT_WIN non e' vuota
// i primi 6 caratteri del nome della finestra alternativa sono uguali a quelli
//     impostati attraverso l'indice (es. ANAWIN e ANAWIN1)
IF .not. empty(INFOTEL_DEFAULT_WIN) 
	IF LEFT(ALLTRIM(INFOTEL_DEFAULT_WIN),6) = LEFT(ALLTRIM(dbdd->Field_Chk),6)
		RETURN ALLTRIM(INFOTEL_DEFAULT_WIN)
	ENDIF
ENDIF

RETURN ALLTRIM(dbdd->Field_Chk)

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddIndexName( cFileName )              // Nome dell'indice
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cRet

DEFAULT cFileName TO ""

IF LEFT(dbdd->FILE_ALI,1) = "@"  // nome file variabile
   cRet := SUBSTR(dbdd->file_ali,2)
   IF TYPE( cRet ) # "C"
      dbMsgErr( dfStdMsg(MSG_DDINDEX13) +cFileName +"//" +;
                dfStdMsg(MSG_DDINDEX14) +cRet             )
   ENDIF
   cRet := UPPER(&cRet)
ELSE
   cRet := ALLTRIM(dbdd->FILE_ALI)
ENDIF

RETURN cRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddFldLOOK()                           // LookUp sul campo
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN ddGetSlot( dbdd->SLOT, "±±", 1)

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddFldFLLOOK()                         // Destinazione del Lookup
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN UPPER(ddGetSlot( dbdd->SLOT, "±±", 3))

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION ddFldFLInh()                          // Campo da ereditare
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN UPPER(ddGetSlot( dbdd->SLOT, "±±", 6))