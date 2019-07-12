#include "common.ch"
#include "dbstruct.ch"
#include "dfMsg.CH"
#include "dfMsg1.CH"
#include "DMLB.CH"
#include "Fileio.ch"



// --------------------------------------------
// Defines
// --------------------------------------------


#define DBS_TYPE_CHAR    "C"
#define DBS_TYPE_LOGIC   "L"
#define DBS_TYPE_DATE    "D"
#define DBS_TYPE_NUMBER  "N"
#define DBS_TYPE_MEMO    "M"

#define FIELDNAME_MAXLEN  10   // Massima lunghezza nome file
#define ALIAS_MAXLEN       8   // Massima lunghezza nome alias
#define DEFAULT_NUM_LEN   15   // Lughezza di default per NUMERO
#define DEFAULT_DEC_LEN    5   // Lughezza di default per DECIMALI

#define DBS_FLEN_LOGIC     1   // lunghezza FISSA campo LOGICO
#define DBS_FLEN_DATE      8   // lunghezza FISSA campo DATA
#define DBS_FLEN_MEMO     10   // lunghezza FISSA campo MEMO



// aRecord
// Contiene il record corrente
// prima che venga scritto
// ---------------------------
#define REC_ROW       1
#define REC_COLUMN    2
#define REC_VALUE     3
#define REC_STRUCT    4

// aFie
// array generato da dBsee
// -----------------------
#define FIE_FNAME     1
#define FIE_PICT      2
#define FIE_MULTI     3
#define FIE_LEN       3

#define CRW_DEFAULT_NAME  "_CRW_"

#define CRWGES_OBJ       1
#define CRWGES_NOMEBANDA 2
#define CRWGES_NUM_INDEX 3
#define CRWGES_ARR_INDEX 4
#define CRWGES_STR_INDEX 5
#define CRWGES_ARR_FIELD 6

#define CRWGES_TOTAL     6

//STATIC oCrw
STATIC oCrwGes
STATIC XbaseTempStringnewindexkey

STATIC _RDD := NIL // inizializzato nella dfCRWRDD()

// FUNCTION dfCRWPrintMenu( aBuf, nUserMenu, cIdPrinter, cIdPort, oCR )
//    LOCAL lRet := .F.
//    DEFAULT oCR TO oCRW
//    IF ! EMPTY(oCR)
//       lRet := oCR:printMenu( aBuf, nUserMenu, cIdPrinter, cIdPort )
//    ENDIF
// RETURN lRet


//Gerr. 3666 Luca 13/11/03
//Creata la classe dfCRWGES per gestire pi— bande di stampa contemporaneamente
CLASS dfCRWGes
   EXPORTED:
   VAR aCRWObj
   VAR cFName
   VAR cAlias
   VAR cRDD
   VAR lEraseCRW_dbf_File
   VAR oTableGes

   METHOD init, create, destroy, close
   METHOD GetCrwObj, GetCrwNumObj
   METHOD OutPut
   METHOD appendRecord, getFromPict
   METHOD FErase
   METHOD getFName
   METHOD ErasedbfFile
   METHOD createDBStruct

ENDCLASS

METHOD dfCRWGes:init(cDBF, cAlias, cRDD)
   DEFAULT cAlias TO findAlias()
   DEFAULT cRDD   TO dfCRWRdd()
   //DEFAULT cDBF   TO dfCRWTemp()+M->ENVID+dfDbfExt(cRDD)
   DEFAULT cDBF   TO dfReportTemp()+M->ENVID+dfDbfExt(cRDD)

   XbaseTempStringnewindexkey := dfSet("XbaseTempStringnewindexkey")== "YES"
   DEFAULT XbaseTempStringnewindexkey TO .F.


   ::aCRWObj := {}
   ::cFName  := cDBF
   ::cAlias  := cAlias
   ::cRDD    := cRDD
   ::lEraseCRW_dbf_File := .T.

   //Default su DBF
   ::oTableGes := TablesGes():New(::cRdd)
   ::oTableGes := ::oTableGes:GetOBJTablesGes()
RETURN Self

METHOD dfCRWGes:ErasedbfFile(lErase)
   DEFAULT lErase TO .T.
   IF VALTYPE(lErase) == "L"
      ::lEraseCRW_dbf_File := lErase
   ENDIF
RETURN Self


METHOD dfCRWGes:FErase()
   LOCAL nN
   FOR nN := 1 TO LEN(::aCRWObj)
       ::aCRWObj[nN][CRWGES_OBJ]:FErase()
   NEXT
RETURN Self

METHOD dfCRWGes:getFName()
   LOCAL aArrFName:={}
   LOCAL nN

   AEVAL(::aCRWObj, {|x| AADD(aArrFName, x[CRWGES_OBJ]:cFName)})

RETURN aArrFName

STATIC FUNCTION _Get_Index_Struct( cDbf)
   LOCAL nIndex      := (cDbf)->(IndexOrd())
   LOCAL cStrct_Index:= (cDbf)->(IndexKey(nIndex))
   LOCAL aIndex_Field:= {}
   aIndex_Field :=  _Index_Struct(nIndex, cDbf)
RETURN {nIndex, cStrct_Index,aIndex_Field }

STATIC FUNCTION _Index_Struct(nIndex, cDbf)
   LOCAL nRec_dbdd, nIndex_dbdd, aIndex_Field := {}

   IF !dbCfgOpen( "dbDD" )         // Apro il dizionario
      dbMsgErr( dfStdMsg(MSG_TABGET03) )
      RETURN {}
   ENDIF

   nIndex_dbdd := DBDD->(IndexOrd())
   nRec_dbdd   := DBDD->(RecNo())

   cDBF  := ALLTRIM(cDBF)
   cDBF  := UPPER(PADR(cDBF,8))

   dbdd->(ORDSETFOCUS_XPP(1))    // Upper(RecTyp+file_name)+str(NdxIncN,3)
   dbdd->(dbSeek( "KEY" + cDBF +STR(nIndex,3) ) )
   DO WHILE ((!dbdd->(EOF()))                    .AND.;  // Se il file non ha indici
              UPPER(dbdd->RECTYP)    == "KEY"    .AND.;
              UPPER(dbdd->FILE_NAME) == cDBF     .AND.;
              dbdd->NdxIncN          == nIndex           )
              AADD(aIndex_Field,ALLTRIM(UPPER(dbdd->FIELD_NAME)) )
      dbdd->(DBSKIP())
   ENDDO

   //Ripristino posizione e indice dbdd
   dbdd->(DBGOTO_XPP(nRec_dbdd))
   dbdd->(ORDSETFOCUS_XPP(nIndex_dbdd))
RETURN aIndex_Field

//cDbf     --> Nome file dbf Crystal da Creare
//cAlias   --> Alias file dbf Crystal da Creare
//cDbfName --> Alias file dbf di Origine della Banda di Report
METHOD dfCRWGes:Create(cDBFName)
   LOCAL cFname, cAlias, oCRW,  nPos, aArr
   LOCAL aArray := ARRAY(CRWGES_TOTAL)
   LOCAL cAliasBanda, nIndex , aIndex_Field := {}, cStrct_Index := ""
   LOCAL _Arr, nA,aField

   DEFAULT cDBFName TO CRW_DEFAULT_NAME

   ::oTableGes:Create()
   ::oTableGes:SetRDD(::cRDD)

   IF SELECT(cDbfName) >0

      aArr := _Get_Index_Struct(cDbfName)

      nIndex       := aArr[1]
      cStrct_Index := aArr[2]
      aIndex_Field := aArr[3]
   ENDIF

   nPos := ASCAN(::aCRWObj,{|x| UPPER(x[CRWGES_NOMEBANDA]) == UPPER(cDBFName) } )

   IF nPos > 0
     //cFname :=  dfCRWTemp()+cDBFName+dfDbfExt(::cRDD)
     cFname :=  dfReportTemp()+cDBFName+dfDbfExt(::cRDD)
     //cAlias :=  "CRW_"+cDBFName
     //cAlias :=  Alltrim(LEFT("CRW_"+cDBFName, 10))
     // 19:45:34 sabato 19 novembre 2016
     // Non posso fare il PAD a 10, perche' se nel report ci sono
     // nomi di file simili ARTSTAT ARCSTAR, col prefisso vanno a 11
     // e tagliati a 10 i nomi diventano uguali
     // Dato che con dBsee posso fare nomi di file solo fino a 8
     // Scelgo di mettere l'alias C_
     cAlias :=  Alltrim(LEFT("C_"+cDBFName, 10))
   ELSE
     // si Š deciso di utilizzare in ogni caso il nome della banda
     // Prima creava il file temporaneo dbf con il nome del report.
     //cFname :=  dfCRWTemp()+cDBFName+dfDbfExt(::cRDD) //::cFName
     cFname :=  dfReportTemp()+cDBFName+dfDbfExt(::cRDD) //::cFName
     //cAlias :=  "CRW_"+cDBFName                       //::cAlias
     //cAlias :=  Alltrim(LEFT("CRW_"+cDBFName, 10))                       //::cAlias
     // 19:48:36 sabato 19 novembre 2016
     // Modificato per lo stesso motivo di sopra
     cAlias :=  Alltrim(LEFT("C_"+cDBFName, 10))                       //::cAlias
   ENDIF

   oCRW := dfCRWOut():new( cFName, cAlias, ::cRDD, ::oTableGes)
   oCRW:aIndex               := ACLONE(aIndex_Field)
   oCRW:lEraseCRW_dbf_File   := ::lEraseCRW_dbf_File

   aField := {}
   //Mantis 968
   IF XbaseTempStringnewindexkey  .AND. ::cRDD ==  _RDD //dfCRWRdd()
      _Arr   := dfSTR2Arr(cStrct_Index,"+")
      IF LEN(_Arr)>=1 .AND. LEN(aIndex_Field) == LEN(_Arr)
         FOR nA := 1 TO LEN(_Arr)
             IF "STR(" $ UPPER(_Arr[nA]) .OR. "DTOS(" $ UPPER(_Arr[nA])
                 _Arr[nA]          := "_"+UPPER(ALLTRIM(LEFT(aIndex_Field[nA], 8)))+"_"
                 aIndex_Field[nA]  := _Arr[nA]
             ENDIF
         NEXT
         cStrct_Index := ""
         FOR nA := 1 TO LEN(_Arr)
             cStrct_Index +=_Arr[nA] +" + "
             AADD(aField,_Arr[nA])
         NEXT
         cStrct_Index := LEFT(cStrct_Index, LEN(cStrct_Index)-3)
      ENDIF
   ENDIF

   aArray[CRWGES_OBJ       ] := oCRW
   aArray[CRWGES_NOMEBANDA ] := UPPER(cDBFName)
   aArray[CRWGES_NUM_INDEX ] := nIndex
   aArray[CRWGES_ARR_INDEX ] := aIndex_Field
   aArray[CRWGES_STR_INDEX ] := cStrct_Index
   aArray[CRWGES_ARR_FIELD ] := aField
   AADD(::aCRWObj , aArray)

RETURN Self

METHOD dfCRWGes:Destroy()
   LOCAL nN
   FOR nN := 1 TO LEN(::aCRWObj)
       ::aCRWObj[nN][CRWGES_OBJ]:Destroy()
   NEXT
   ::aCRWObj := {}
   ::oTableGes:Destroy()
RETURN Self

// crea la struttura del DB temporaneo
// facendo append dei dati in cache e poi ZAP
METHOD dfCRWGes:createDBStruct()
   AEVAL(::aCRWObj, {|a| a[CRWGES_OBJ]:createDBStruct()} )
RETURN self

METHOD dfCRWGes:Close()
   LOCAL nN,cAlias, cBanda, cFName
   LOCAL cErr, cFields := "", cDBF
   FOR nN := 1 TO LEN(::aCRWObj)
       cBanda := ::aCRWObj[nN][CRWGES_NOMEBANDA]
       cAlias := ::aCRWObj[nN][CRWGES_OBJ]:cAlias //[CRWGES_NOMEBANDA]

       // Scrivo l'ultimo record in cache
       ::aCRWObj[nN][CRWGES_OBJ]:writeBuffer()

       IF LEN(::aCRWObj)>1
          IF ::aCRWObj[nN][CRWGES_NUM_INDEX ] != NIL

             cDBF := IIF(EMPTY(cBanda), "", cBanda+"->")

             IF  _CheckIndex(::aCRWObj[nN][CRWGES_ARR_INDEX ],::aCRWObj[nN][CRWGES_ARR_FIELD ], cDbf, @cFields )

                cErr := dfMsgTran(dfStdMsg1(MSG1_CRW01), ;
                                  "band="+cBanda, ;
                                  "nrel="+ALLTRIM(STR(::aCRWObj[nN][CRWGES_NUM_INDEX ])), ;
                                  "fields="+cFields)
                dbMsgErr(cErr)

             ELSEIF ! EMPTY(cAlias)
               ::oTableGes:CreateIndex(::aCRWObj[nN], cAlias, cBanda)
             ENDIF
          ENDIF
       ENDIF
       ::aCRWObj[nN][CRWGES_OBJ]:CloseDBF()
   NEXT
RETURN Self

STATIC FUNCTION _CheckIndex(aIndex, aField, cDbf, cFields)
   LOCAL nPOS, nN
   cFields := ""
   FOR nN:=1 TO LEN(aIndex)
      nPos := ASCAN(aField,aIndex[nN] )
      IF nPos == 0
          nPos := ASCAN(aField,"_"+ALLTRIM(aIndex[nN])+"_" )
          IF nPos == 0
             cFields += IIF(EMPTY(cFields), "", ", ")+cDbf+aIndex[nN]
          ENDIF
      ENDIF
   NEXT
RETURN ! cFields == ""

METHOD dfCRWGes:GetCRWObj(cDBFName)
   LOCAL nPos
   //DEFAULT cDBFName TO CRW_DEFAULT_NAME
   IF EMPTY(cDBFName)
      IF LEN(::aCRWObj)<1
         cDBFName := CRW_DEFAULT_NAME
      ELSE
         cDBFName := ::aCRWObj[1][CRWGES_NOMEBANDA]
      ENDIF
   ENDIF

   nPos := ASCAN(::aCRWObj,{|x| x[CRWGES_NOMEBANDA]==UPPER(cDBFName) } )
   IF nPos > 0
      RETURN ::aCRWObj[nPos][1]
   ENDIF
RETURN NIL

METHOD dfCRWGes:GetCrwNumObj(cDBFName)
   LOCAL nPos
   IF EMPTY(cDBFName)
      IF LEN(::aCRWObj)<1
         cDBFName := CRW_DEFAULT_NAME
      ELSE
         cDBFName := ::aCRWObj[1][CRWGES_NOMEBANDA]
      ENDIF
   ENDIF
   nPos := ASCAN(::aCRWObj,{|x| x[CRWGES_NOMEBANDA]==UPPER(cDBFName) })
RETURN nPos


//cDbf     --> Nome file dbf Crystal da Creare
//cAlias   --> Alias file dbf Crystal da Creare
//cDbfName --> Alias file dbf di Origine della Banda di Report
FUNCTION dfCRWInit(cDBF, cAlias, cRDD)
   oCRWGes := dfCRWGes():new(cDBF, cAlias, cRDD)
RETURN oCRWGes


FUNCTION dfCRWClose(oCR)
//   DEFAULT oCR TO oCRW
   DEFAULT oCR TO oCRWGes
   IF ! EMPTY(oCR)
      oCR:destroy()
   ENDIF
RETURN NIL

METHOD dfCRWGes:output(nRow, nCol, uVar, aFie, cAliasBanda, cCod)
   LOCAL oCrwOut, cField, cDBF, nPos, aARR_Insert_Field, nNum

   DEFAULT cAliasBanda TO CRW_DEFAULT_NAME
   DEFAULT cCod TO ""

   cAliasBanda := ALLTRIM(UPPER(cAliasBanda))
   cCod        := ALLTRIM(UPPER(cCod))

   oCrwOut  := ::GetCRWObj(cAliasBanda)
   IF EMPTY(oCrwOut)
      ::Create(cAliasBanda)
      oCrwOut := ::GetCRWObj(cAliasBanda)
   ENDIF

   IF cAliasBanda+"->" $ cCod  //Si tratta di campo dell'archivio di Banda
      cField := ALLTRIM(UPPER(SubStr(cCod, AT(cAliasBanda+"->", cCod)+Len(cAliasBanda+"->"))))
      nNum   := ::GetCrwNumObj(cAliasBanda)
      nPos   := ASCAN(::aCRWObj[nNum][CRWGES_ARR_FIELD ], cField )       //Controllo se lo ho inserito nell' array degli elementi da stampare
      IF nPos == 0
         AADD(::aCRWObj[nNum][CRWGES_ARR_FIELD ] , cField)
      ENDIF
   ELSE
      nNum := ::GetCrwNumObj(cAliasBanda)
      //Legato al Gerr 3664: Creava in modo sbagliato il nome del campo duplicato.
      // Intercetto eventuali nome campi duplicati presenti sulla chiave della Banda
      nPos := ASCAN(::aCRWObj[nNum][CRWGES_ARR_INDEX ], UPPER(aFie[FIE_FNAME]) )       //Controllo se lo ho inserito nell' array degli elementi da stampare
      IF nPos > 0
         aFie[FIE_FNAME] := ALLTRIM(aFie[FIE_FNAME])
         IF LEN(aFie[FIE_FNAME]) >= FIELDNAME_MAXLEN
            aFie[FIE_FNAME] := PADR(aFie[FIE_FNAME], FIELDNAME_MAXLEN -1)+"1"
         ELSE
            aFie[FIE_FNAME] +="1"
         ENDIF
      ENDIF
   ENDIF

   oCRWOut:outPut(nRow, nCol, uVar, aFie)

RETURN Self

METHOD dfCRWGes:appendRecord(cDBFName)
RETURN ::GetCRWObj(cDBFName):appendRecord()

METHOD dfCRWGes:getFromPict(aRec, aFie, cDBFName)
RETURN ::GetCRWObj(cDBFName):getFromPict(aRec, aFie)

//FUNCTION dfCRWObject(); RETURN oCRW
FUNCTION dfCRWObject(cDBFName); RETURN oCRWGes:GetCRWObj(cDBFName)

//Inserito per avere nei template un funzione generica sia per Report Manager che per Crystal
FUNCTION dfCRWOutput( nRow    ,; // Riga
                         nCol    ,; // Colonna
                         uVar    ,; // Variabile
                         aFie    ,; // ARRAY DEFINIZIONE VEDI FIE_xxx
                         cDBFName,; // Alias Banda che identifica il dbf da creare
                         cCod     ) // Codice per identificare la variabile stampata
RETURN dfReportOutput( nRow    ,; // Riga
                    nCol    ,; // Colonna
                    uVar    ,; // Variabile
                    aFie    ,; // ARRAY DEFINIZIONE VEDI FIE_xxx
                    cDBFName,; // Alias Banda che identifica il dbf da creare
                    cCod     ) // Codice per identificare la variabile stampata


FUNCTION dfReportOutput( nRow    ,; // Riga
                      nCol    ,; // Colonna
                      uVar    ,; // Variabile
                      aFie    ,; // ARRAY DEFINIZIONE VEDI FIE_xxx
                      cDBFName,; // Alias Banda che identifica il dbf da creare
                      cCod     ) // Codice per identificare la variabile stampata

   STATIC lDisableMulti

   IF ! EMPTY(oCRWGes)

      // Simone 22/12/03
      // Correzione per evitare problemi con report con
      // dfCrwOutput standard e iniezioni di codice senza cDbfName
      IF lDisableMulti == NIL
         lDisableMulti := dfSet("XbaseCRWReportDisableMulti") == "YES"
      ENDIF
      IF lDisableMulti
         cDbfName := NIL
         cCod     := NIL
      ENDIF

      IF EMPTY(cDBFName)
         cDbfName := M->ENVID
      ENDIF

      cDBFName := UPPER(ALLTRIM(cDBFName))
      oCRWGes:outPut(nRow, nCol, uVar, aFie, cDBFName, cCod)
   ENDIF
RETURN NIL

FUNCTION dfReportPath()
   LOCAL cPath := dfSet("XbaseReportPath")
   DEFAULT cPath TO ""
RETURN dfPathChk(cPath)

FUNCTION dfReportManagerPath()
   LOCAL cPath := dfSet("XbaseReportManagerPath")
   DEFAULT cPath TO dfReportPath()
   DEFAULT cPath TO ""
RETURN dfPathChk(cPath)

// Luca 29/10/2004
//Prima di Visaul dBsee 1.0.2
//Create anche le funzioni XbaseReportPath() e dfReportManagerPath()

//FUNCTION dfCRWPath()
//   LOCAL cPath := dfSet("XbaseCRWPath")
//   DEFAULT cPath TO ""
//RETURN dfPathChk(cPath)

FUNCTION dfCRWPath()
   LOCAL cPath := dfSet("XbaseCRWPath")
   DEFAULT cPath TO dfReportPath()
   DEFAULT cPath TO ""
RETURN dfPathChk(cPath)

FUNCTION dfCRWRdd()
//   STATIC _Rdd

   IF _Rdd != NIL
      RETURN _Rdd
   ENDIF

   _Rdd := dfSet("XbaseCRWRdd")
   IF EMPTY(_Rdd)
      _Rdd := DbeSetDefault()
   ENDIF
RETURN _Rdd

FUNCTION dfReportTemp(xNew)
   STATIC cPath := NIL
   IF VALTYPE(xNew) $ "CM"
      cPath := dfPathChk(xNew)
   ENDIF
   IF cPath == NIL
      DEFAULT cPath TO dfSet("XbaseReportTemp")
      DEFAULT cPath TO dfCRWTemp(xNew)// Per compatibilit… con prima
      cPath := dfPathChk(cPath)
   ENDIF
RETURN cPath

//TO Do: non Š ancora utilizzata nelle librerie,  si deve analizzare Š inserire dove necessario
FUNCTION dfReportManagerTemp(xNew)
   STATIC cPath := NIL

   IF VALTYPE(xNew) $ "CM"
      cPath := dfPathChk(xNew)
   ENDIF

   IF cPath == NIL
      dfCRWDesign(@cPath)
      DEFAULT cPath TO dfSet("XbaseReportManagerTemp")
      DEFAULT cPath TO dfTemp()
      cPath := dfPathChk(cPath)
   ENDIF
RETURN cPath

FUNCTION dfCRWTemp(xNew)
   STATIC cPath := NIL

   IF VALTYPE(xNew) $ "CM"
      cPath := dfPathChk(xNew)
   ENDIF

   IF cPath == NIL
      dfCRWDesign(@cPath)
      DEFAULT cPath TO dfSet("XbaseCRWTemp")
      DEFAULT cPath TO dfTemp()
      cPath := dfPathChk(cPath)
   ENDIF
RETURN cPath

// Torna se Š in modailt… DESIGN (non cancella il DBF creato)

// Cerca /CRWDESIGN o /CRWDESIGN=percorso
// Esempio /CRWDESIGN:c:\ imposta il DBF su C:\
FUNCTION dfCRWDesign(cPath)
   STATIC lRet := NIL
   LOCAL nPar, cPar
   IF lRet == NIL
      lRet := .F.
      FOR nPar := 0 TO dfArgC()
         cPar := ALLTRIM(UPPER(dfArgV(nPar)))
         IF LEFT(cPar, 10) == "/CRWDESIGN"
            lRet := .T.
            nPar := AT("=", cPar)
            IF nPar > 0 .AND. nPar < LEN(cPar)
               cPath := dfPathChk( SUBSTR(cPar, nPar+1) )
            ENDIF
            EXIT
         ENDIF
      NEXT
   ENDIF
RETURN lRet

CLASS dfCRWOut

   EXPORTED:
      VAR nLastRow
      VAR nLastCol
      VAR cLastField
      VAR aRecord
      VAR aDB
      VAR aDBMap
      VAR cFName
      VAR cAlias
      VAR cRDD
      VAR cFileNtx
      VAR oTableGes
      ///////////////////////////////////////////
      //Mantis 979
      VAR lNOTConv
      ///////////////////////////////////////////
      //VAR cRpt
      //Gerr. 3438 30/10/03 Luca: Aggiunta la possibilit… di non cancellare il file
      // dbf temporaneo creato.
      VAR lEraseCRW_dbf_File
      VAR aIndex

      METHOD init, create, destroy, close
      METHOD output, appendRecord, getFromPict
      METHOD findFieldName
      //METHOD _checkFName
      METHOD FErase
      INLINE METHOD getFName(); RETURN {::cFName}
      METHOD writeBuffer
      METHOD closeDbf
      METHOD createDBStruct
ENDCLASS

//cFName   --> Nome file dbf Crystal da Creare
//cAlias   --> Alias file dbf Crystal da Creare
//Inizializza
//METHOD dfCRWOut:init(cRpt, cFName, cAlias, cRDD)
METHOD dfCRWOut:init(cFName, cAlias, cRDD,oTableGes )

   DEFAULT cAlias TO findAlias()
   DEFAULT cRDD   TO dfCRWRdd()
   //DEFAULT cFname TO dfCRWTemp()+M->ENVID+dfDbfExt(cRDD)
   DEFAULT cFname TO dfReportTemp()+M->ENVID+dfDbfExt(cRDD)
   XbaseTempStringnewindexkey := dfSet("XbaseTempStringnewindexkey") == "YES"
   DEFAULT XbaseTempStringnewindexkey TO .F.

   ::lNOTConv :=  dfSet("XbaseTempFileCONVTOANSI") == "NO"
   ///////////////////////////////////////////
   //Mantis 979
   DEFAULT ::lNOTConv TO .F.
   ///////////////////////////////////////////
   //Per stampe con filke temporanei DBF per Crystal Report non si deve fare il CONVTOANSI
   IF UPPER(ALLTRIM(cRDD)) != "XML"
      ::lNOTConv := .T.
   ENDIF
   ///////////////////////////////////////////


   //DEFAULT cRPT   TO dfCRWPath()+M->ENVID+".RPT"
//   ::cRPT     := cRPT
   ::cFname     := cFName
   ::cAlias     := cAlias
   ::cRDD       := cRDD
   ::cLastField := NIL
   ::nLastRow   := NIL
   ::nLastCol   := NIL
   ::aRecord    := {}
   ::aDB        := {}
   ::aDBMap     := {}
   ::cFileNtx   := ""
   //Gerr. 3438 30/10/03 Luca: Aggiunta la possibilit… di non cancellare il file
   // dbf temporaneo creato.
   ::lEraseCRW_dbf_File := .T.

   DEFAULT oTableGes TO TablesGes():New(::cRdd)
   ::oTableGes := oTableGes

RETURN self

METHOD dfCRWOut:FErase()
  //Gerr. 4038
  LOCAL cFileDbt
  IF ::lEraseCRW_dbf_File
     ::oTableGes:FErase(::cFName,::cFileNtx )
  ENDIF
RETURN self

METHOD dfCRWOut:destroy()
   ::close()

   // ::cRPT     := ""
   // ::cFname   := ""
   // ::cAlias   := ""
   // ::cRDD     := ""

   ::cLastField := NIL
   ::nLastRow   := NIL
   ::nLastCol   := NIL
   ::aRecord    := {}
   ::aDB        := {}
   ::aDBMap     := {}
RETURN self


// crea la struttura del DB temporaneo
// facendo append dei dati in cache e poi ZAP
METHOD dfCRWOut:createDBStruct(lZap)
   //Ger 4253 Creava sempre un record vuoto e poi non lo cancellava
   //::writeBuffer()
   //(::cAlias)->(DBZAP())
   ::Create()
   ::aRecord  := {}

RETURN .T.

// scrive l'ultimo il record rimasto in cache e chiude
METHOD dfCRWOut:close()
   ::writeBuffer()
RETURN ::closeDbf()

METHOD dfCRWOut:writeBuffer()
   LOCAL lRet := .F.
   // IF ! EMPTY(::aDb)
      // Scrivo l'ultimo record in cache
   //Mantis 674
   IF EMPTY(::aDbMap)
      ::create()
   ENDIF
   IF ::oTableGes:SELECT(::cAlias) > 0
      ::AppendRecord()
      ::aRecord  := {}
   ENDIF
   //ENDIF
RETURN lRet

METHOD dfCRWOut:closeDBF()
   LOCAL lRet := .F.

   IF ::oTableGes:SELECT(::cAlias) > 0
      ::oTableGes:DBCLOSEAREA(::cAlias)
   ENDIF

   lRet := .T.
RETURN lRet

// Salva in una cache (aRecord) il record che sta scrivendo
// se Š un record nuovo (in base a nRow o nCol) scrive il record
// in cache e reinizia
METHOD dfCRWOut:output(nRow, nCol, uVar, aFie)
   LOCAL nPos, xVal

   IF ::nLastRow == NIL
      // Prima riga azzero array cache record
      ::aRecord  := {}
   ELSEIF nRow <0 .OR. nCol <0
      // Gerr. 3581 Luca 13/11/03
      // quando due campi sono erroniamente inseriti da dbsee con coordinate negative vi Š un Runtime Error
      RETURN self
   ELSEIF  (nRow == ::nLastRow .AND. nCol == ::nLastCol .AND. (aFie[FIE_FNAME] == ::cLastField .AND. LEN(::aDB)>1))
      // Gerr. 3581 Luca 13/11/03
      // quando due campi vengono sovraposti allora vi Š un runtime Error
      RETURN self
   ELSEIF ( (nRow < ::nLastRow) .OR. (nRow == ::nLastRow .AND. nCol < ::nLastCol))
      // Cambio riga: scrivo il record in cache e riazzero
      ::writeBuffer()
   //Mantis 776
   ELSEIF  (LEN(::aDB)==1 .AND. LEN(::aRecord)>0 )
      ::writeBuffer()
   ENDIF
   ::nLastRow   := nRow
   ::nLastCol   := nCol
   ::cLastField := aFie[FIE_FNAME]


   ///////////////////////////////////////////
   //Mantis 979
   DEFAULT ::lNOTConv TO .F.
   IF !::lNOTConv .AND. (VALTYPE(uVar) == "C" .OR. VALTYPE(uVar) == "M")
      uVar := CONVTOANSICP(uVar)
   ENDIF
   ///////////////////////////////////////////

   // Gerr. 3581 Luca 13/11/03
   // quando due campi vengono sovraposti allora vi Š un runtime Error
   // nPos := ASCAN(::aRecord, {|x|x[REC_ROW] == nRow .AND. x[REC_COLUMN] == nCol  })
   nPos := ASCAN(::aRecord, {|x|x[REC_ROW] == nRow .AND. x[REC_COLUMN] == nCol .AND. (x[REC_STRUCT][FIE_FNAME]== ::cLastField )  })
   IF nPos == 0
      AADD(::aRecord, {nRow,nCol,uVar,aFie})
   ELSE
      ::aRecord[nPos][REC_VALUE] := uVar
   ENDIF
   //risolti mantis e Gerr.
   //Gerr. 4052
   //Mantis 968
   IF XbaseTempStringnewindexkey  .AND. ::cRDD ==  _RDD //dfCRWRdd()
      IF aFie[2]  != "C"
         nPOS := ASCAN(::aIndex,{|x|ALLTRIM(Upper(aFie[DBS_NAME ])) == ALLTRIM(Upper(x))})
         IF nPOS>0
            aFie     := ACLONE(aFie)
            aFie[2]  := "C"
            aFie[1]  := "_"+ALLTRIM(LEFT(aFie[DBS_NAME ], 8))+"_"
            IF VALTYPE(uVar) == "N"
               xVal     := STR(uVAr,aFie[3],aFie[4])
            ELSEIF VALTYPE(uVar) == "D"
               xVal     := DTOS(uVAr)
            ENDIF
            ::Output(::nLastRow,MAX(LEN(::aRecord), ::nLastCol)+1,xVal,aFie)
            //AADD(::aRecord, {LEN(::aRecord),LEN(::aRecord),xVal,aFie})
         ENDIF
      ENDIF
   ENDIF
RETURN self


METHOD dfCRWOut:AppendRecord()
   LOCAL nOldArea := ::oTableGes:SELECT()
   LOCAL cAlias
   LOCAL nInd
   LOCAL nPos

   IF EMPTY(::aDbMap)
      ::create()
   ENDIF
   IF ! EMPTY(::aDB)
      ::oTableGes:DBSELECTAREA(::cAlias)

      //Ger 4253 Creava sempre un record vuoto e poi non lo cancellava
      //Inizio
      IF EMPTY(::aRecord)
         ::oTableGes:DBSELECTAREA(nOldArea)
         RETURN self
      ENDIF
      //Fine Gerr.
      ::oTableGes:WriteRecord(self)
      ::oTableGes:DBSELECTAREA(nOldArea)
   ENDIF
RETURN self


// Creazione DBF temporaneo in base ai valori
METHOD dfCRWOut:create()
   LOCAL aStruct
   LOCAL nInd
   LOCAL aRec
   LOCAL aMap := {}
   LOCAL aFie
   LOCAL uVar
   aStruct := {}

   FOR nInd := 1 TO LEN(::aRecord)
      uVar := ::aRecord[nInd][REC_VALUE]
      aFie := ::aRecord[nInd][REC_STRUCT]

      IF VALTYPE(aFie) != "A"
         aFie := {aFie}
      ENDIF

      IF LEN(aFie) == DBS_ALEN
         aRec := aFie
      ELSE
         ASIZE(aFie, FIE_LEN)

         // Desumo la struttura in base ai parametri passati
         aRec := ARRAY(DBS_ALEN)
         aRec[DBS_NAME ] := aFie[FIE_FNAME]
         aRec[DBS_TYPE ] := IIF(! EMPTY(aFie[FIE_MULTI]), DBS_TYPE_MEMO, ;
                                VALTYPE(uVar))
         aRec[DBS_DEC  ] := 0

         IF aRec[DBS_TYPE ] == DBS_TYPE_MEMO
            aRec[DBS_LEN  ] := DBS_FLEN_MEMO

         ELSEIF aRec[DBS_TYPE ] == DBS_TYPE_LOGIC
            aRec[DBS_LEN  ] := DBS_FLEN_LOGIC

         ELSEIF aRec[DBS_TYPE ] == DBS_TYPE_DATE
            aRec[DBS_LEN  ] := DBS_FLEN_DATE

         ELSEIF aRec[DBS_TYPE ] == DBS_TYPE_CHAR

            IF EMPTY(aFie[FIE_PICT])
               aRec[DBS_LEN] := LEN(uVar)
            ELSE
               ::GetFromPict(aRec, aFie)
            ENDIF

         ELSEIF aRec[DBS_TYPE ] == DBS_TYPE_NUMBER
            IF EMPTY(aFie[FIE_PICT])
               aRec[DBS_LEN] := DEFAULT_NUM_LEN
               IF ! INT(uVar) == uVar
                  aRec[DBS_DEC] := DEFAULT_DEC_LEN
                  aRec[DBS_LEN] += aRec[DBS_DEC]+1
               ENDIF
            ELSE
               ::GetFromPict(aRec, aFie)
            ENDIF

         ELSE
            aRec := NIL
         ENDIF


      ENDIF

      IF aRec != NIL

         // Normalizzo nome campo ed evito campi duplicati
         aRec[DBS_NAME ] := ::findFieldName(aRec[DBS_NAME ], aStruct)
         IF EMPTY(aRec[DBS_NAME ]) .OR. EMPTY(aRec[DBS_LEN]) .OR. ;
            EMPTY(aRec[DBS_TYPE])  .OR. aRec[DBS_LEN] < 0 //simone 9/12/04 mantis 0000329: Il Report Editor genera stringa di struttura file temporanei errata
            AADD(aMap,0)
         ELSE
            AADD(aStruct, aRec)
            AADD(aMap, LEN(aStruct))
         ENDIF
      ELSE
         AADD(aMap, 0)
      ENDIF
   NEXT

   ::aDBMap := aMap
   ::aDB    := {}

   IF ! EMPTY(aStruct)

      ::oTableGes:DBCREATE( ::cFName, aStruct, ::cRDD)

      IF ::oTableGes:dfUseFile(::cFname, ::cAlias, .T., ::cRDD)
         ::aDb := aStruct
      ENDIF
   ENDIF

RETURN self

// Prende le dimensioni del campo dalla PICTURE che
// pu• essere una picture vera e propria oppure
// una definizione di struttura del tipo
// N10,2 o C200 o C,200 (identica a C200)

METHOD dfCRWOut:GetFromPict(aRec, aFie)
   LOCAL cPict := UPPER(STRTRAN(aFie[FIE_PICT]," ", ""))
   LOCAL cType := aRec[DBS_TYPE]
   LOCAL nLen  := 0
   LOCAL nDec  := 0
   LOCAL cCh   := ""
   LOCAL nInd  := 0
   LOCAL lDec  := .F.
   LOCAL aTmp  := {}

   // Controlla se invece della picture ho messo stringa del tipo
   // C10 oppure C,10 oppure N4 oppure N,10,4

   IF LEFT( cPict, 1) $ ;
      DBS_TYPE_MEMO+DBS_TYPE_CHAR+DBS_TYPE_NUMBER .AND. ;
      (dfIsDigit( SUBSTR(cPict,2,1) ) .OR. ;
         (SUBSTR(cPict,2,1) == "," .AND. dfIsDigit( SUBSTR(cPict,3,1) ) ))

      cType := LEFT( cPict, 1)

      cPict := SUBSTR(cPict,2)
      IF LEFT(cPict,1) ==","
         cPict := SUBSTR(cPict,2)
      ENDIF

      aTmp := dfStr2Arr(cPict, ",")
      IF LEN(aTmp) > 0
         nLen := VAL(aTmp[1])
         nDec := 0

         IF cType == DBS_TYPE_NUMBER .AND. LEN(aTmp) > 1
            nDec := VAL(aTmp[2])
         ENDIF

      ENDIF

   ELSE
      // Capisco la struttura del campo dalla picture
      // esempio @ZE 999,999,999.99 -> N12,2
      lDec := .F.
      FOR nInd := 1 TO LEN(cPict)
         cCh := SUBSTR(cPict, nInd, 1)
         IF cCh $ "9."
            nLen++
            IF lDec // Ho gi… passato punto decimale incremento anche i decimali
               nDec++
            ENDIF
            IF cCh == "."
               lDec := .T.
            ENDIF
         //Gerr. 3601 Luca 3/11/03
         //Se la picture era del tipo XXXX o !!!!! non veniva interpretata dalla
         //funzione e ritornava nLen = 0.
         ELSEIF  cCh $ "Xx!"
            nLen++
         ENDIF
      NEXT

   ENDIF

   aRec[DBS_TYPE] := cType
   aRec[DBS_LEN]  := nLen
   aRec[DBS_DEC]  := nDec

RETURN NIL

// Normalizza nome campo e crea nome campo NON duplicato
METHOD dfCRWOut:findFieldName(cFName, aStruct, cValid)
   LOCAL cIncr := ""
   LOCAL nInc  := 1

   DEFAULT cValid TO "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

   cFName := UPPER(ALLTRIM(PAD(cFName, FIELDNAME_MAXLEN)))

   cIncr := _findUnique({|cInc| _checkFName(aStruct, cFName+cInc)  }, ;
                          FIELDNAME_MAXLEN - LEN(cFName) )
   IF cIncr == NIL
      //Gerr 3664 Creava in modo sbagliato il nome del campo duplicato.
      //cFName := ""
      //Luca 10/12/03
      //cFName += ""
      cIncr := "1"
      DO WHILE .T.
         cFName := LEFT(cFName,FIELDNAME_MAXLEN -1 )+cIncr
         IF _checkFName(aStruct, cFName)
            EXIT
         ENDIF
         cIncr := dfNum2Base(++nInc, cValid)
      ENDDO
   ELSE
      cFName += cIncr
   ENDIF
RETURN cFName

STATIC FUNCTION _checkFName(aStruct, cFName)
RETURN ASCAN(aStruct, {|x| x[DBS_NAME] == cFname }) == 0

// Trova alias univoco
STATIC FUNCTION findAlias()
   LOCAL cBase := "_CRW_"
   LOCAL cIncr := _findUnique( {|cInc| SELECT("_CRW_"+cInc)==0 }, ;
                                 ALIAS_MAXLEN - LEN(cBase) )
   IF cIncr != NIL
      cBase += cIncr
   ELSE
      cBase := Left(cBase,ALIAS_MAXLEN-1)+"1"
   ENDIF
RETURN cBase

// Metodo base per trovare nomi univoci
STATIC FUNCTION _findUnique(bCheck, nMaxLen, cValid)
   LOCAL nInc := 0
   LOCAL cInc := ""

   DEFAULT cValid TO "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

   // Evito nomi duplicati
   DO WHILE .T.
      IF EVAL(bCheck, cInc)
         EXIT
      ENDIF

      cInc := dfNum2Base(++nInc, cValid)

      IF LEN(cInc) > nMaxLen
         cInc   := NIL
         EXIT
      ENDIF
   ENDDO
RETURN cInc

STATIC CLASS TablesGes
   EXPORTED:
      VAR oTablesGes
      METHOD GetOBJTablesGes
      METHOD init
ENDCLASS

METHOD TablesGes:GetOBJTablesGes()
RETURN ::oTablesGes
METHOD TablesGes:init(cRDD)
   DEFAULT cRDD   TO dfCRWRdd()
   IF UPPER(ALLTRIM(cRDD )) == "XML"
      ::oTablesGes := XMLGes():New()
   ELSE
      ::oTablesGes := DBFGes():New()
   ENDIF
RETURN Self


STATIC CLASS GenericTableGes
   EXPORTED:
      VAR cRDD
      METHOD Create
      METHOD Destroy
      METHOD SetRdd
      METHOD GetRdd
ENDCLASS

METHOD GenericTableGes:Create()    ; Return Self
METHOD GenericTableGes:Destroy()   ; Return NIL
METHOD GenericTableGes:SetRdd(cRdd); IIF(!EMPTY(cRDD), ::cRdd := UPPER(Alltrim(cRdd)), NIL); Return ::cRDD
METHOD GenericTableGes:GetRdd()    ; RETURN ::cRDD

STATIC CLASS DBFGes FROM GenericTableGes
   EXPORTED:
      METHOD CreateIndex
      METHOD FErase
      METHOD SELECT
      METHOD DBCLOSEAREA
      METHOD DBSELECTAREA
      METHOD DBAPPEND
      METHOD WriteRecord
      METHOD DBCREATE
      METHOD dfUseFile
ENDCLASS

METHOD DBFGes:CreateIndex(oBanda, cAlias, cBanda)
   LOCAL cFileNTX := ""
   //Crea L'indice
   IF SELECT(cAlias) > 0
     cFileNTX    :=  dfReportTemp()+cBanda+dfIndExt(oBanda[CRWGES_OBJ]:cRdd  )
     FERASE(cFileNTX)

     (cAlias)->(dfMakeInd( oBanda[CRWGES_STR_INDEX] , dfReportTemp()+cBanda ))	 // Creazione indice
     oBanda[CRWGES_OBJ]:cFileNtx := dfReportTemp()+cBanda+dfIndExt(oBanda[CRWGES_OBJ]:cRdd  )
   ENDIF
RETURN .T.

METHOD DBFGes:FErase(cFName,cFileNtx)
  LOCAL cFileDbt
  FERASE(cFName)
  //Gerr. 4038
  //Non cancellava il file dbt nelle stampe Crystal.
  IF !EMPTY(cFName)
     cFileDbt := SUBSTR(ALLTRIM(cFName),1, LEN(ALLTRIM(cFName))-3) +"dbt"
     FERASE(cFileDbt)
  ENDIF
  IF !EMPTY(cFileNtx)
     FERASE(cFileNtx)
  ENDIF
RETURN .T.

METHOD DBFGes:SELECT(cDbf)
RETURN Select(cDBF)

METHOD DBFGes:DBCLOSEAREA(cAlias)
RETURN (cAlias)->(DBCLOSEAREA())

METHOD DBFGes:DBSELECTAREA(cAlias)
RETURN DBSELECTAREA(cAlias)

METHOD DBFGes:DBAPPEND()
RETURN DBAPPEND()

METHOD DBFGes:WriteRecord(oCrw)
  LOCAL nInd, nPos
  LOCAL xVAL, bVal
  //LOCAL aIndex := oCrw:aRecord:aIndex
  LOCAL nLen
  oCrw:oTableGes:DBAPPEND()
  FOR nInd := 1 TO LEN(oCrw:aRecord)
      // Guardo se la colonna corrente Š stata
      // effettivamente creata
      nPos:= oCrw:aDbMap[nInd]
      IF nPos > 0
         xVAL := oCrw:aRecord[nInd][REC_VALUE]
         //IF VALTYPE(xVal) == "B"
         //   nLen := oCrw:aRecord[nInd][REC_STRUCT][DBS_LEN  ]
         //   xVAL  := EVAL(bVal)
         //   IF VALTYPE(xVAL)=="N"
         //      xVAL := ALLTRIM(STR(xVAL,nLen, 0 ))
         //   ENDIF
         //ENDIF
         FIELDPUT(nPos, xVAL)
      ENDIF
  NEXT
RETURN .T.

METHOD DBFGes:DBCREATE( cFName, aStruct, cRDD)
RETURN DBCREATE( cFName, aStruct, cRDD)

METHOD DBFGes:dfUseFile(cFname, cAlias, lExl, cRDD)
RETURN dfUseFile(cFname, cAlias, lExl, cRDD)

///////////////////////////////////////////////////////
// Classe x gestione file in formato XML

STATIC CLASS XMLGes FROM GenericTableGes
   EXPORTED:
      VAR aHandleStack
      //Serve quando viene chiamata Select() per ritornare l'old area di lavoro
      VAR nCurrentHandle

      VAR TrimString
      METHOD Init
      METHOD CreateIndex
      METHOD FErase
      METHOD SELECT
      METHOD DBCLOSEAREA
      METHOD DBSELECTAREA
      METHOD DBAPPEND
      METHOD WriteRecord
      METHOD DBCREATE
      METHOD dfUseFile
      METHOD GetnHandleFromAlias
      METHOD str2Xml
ENDCLASS

METHOD XMLGes:Init()
   ::aHandleStack   := {}
   ::nCurrentHandle := 0
   ::TrimString     := dfSet("XbaseXMLTrimString") == "YES"
   DEFAULT ::TrimString TO .F.
RETURN Self

METHOD XMLGes:CreateIndex();Return .F.

METHOD XMLGes:FErase(cFName,cFileNtx)
   FERASE(cFName)
RETURN .T.

METHOD XMLGes:SELECT(cAlias)
   LOCAL nHanlde
   IF EMPTY(cAlias)
     nHanlde := ::nCurrentHandle
   ELSE
     nHanlde := ::GetnHandleFromAlias(cAlias)
     ::nCurrentHandle  := nHanlde
   ENDIF
RETURN nHanlde

METHOD XMLGes:DBCLOSEAREA(cAlias)
   LOCAL nHandle := ::GetnHandleFromAlias(cAlias)
   LOCAL nPos
   IF nHandle >0
      FWrite( nHandle, "</ROWDATA></DATAPACKET>" )
      FClose( nHandle)
       cAlias := UPPER(ALLTRIM(cAlias))
       nPos := ASCAN(::aHandleStack,{|aArr|aArr[4]==UPPER(ALLTRIM(cAlias))} )
       IF nPOS>0
          ::aHandleStack := aDEL(::aHandleStack,nPos)
          ASize( ::aHandleStack, Len(::aHandleStack)-1 )
       ENDIF
   ENDIF
   ::nCurrentHandle  := 0
RETURN nHandle

METHOD XMLGes:DBSELECTAREA(cAlias)
  LOCAL nPOS
  IF !EMPTY(cAlias)
     IF VALTYPE(cAlias) == "C"
        ::nCurrentHandle := ::GetnHandleFromAlias(cAlias)
     ELSEIF VALTYPE(cAlias) == "N"
        nPos := ASCAN(::aHandleStack,{|aArr|aArr[2]=cAlias} )
        IF nPOS>0
           ::nCurrentHandle := ::aHandleStack[nPos][2]
        ENDIF
     ENDIF
  ENDIF
RETURN ::nCurrentHandle

METHOD XMLGes:DBAPPEND()
RETURN 0

METHOD XMLGes:WriteRecord(oCrw)
  LOCAL nInd, nPos, nN
  LOCAL xVal, xName
  LOCAL nLen, nDec
  LOCAL aRow   := ARRAY(LEN(oCrw:aRecord))
  LOCAL cAlias := oCrw:cAlias
  LOCAL nHandle:= ::GetnHandleFromAlias(cAlias)
  LOCAL cRowString

  IF nHandle>0
     FOR nInd := 1 TO LEN(oCrw:aRecord)
         // Guardo se la colonna corrente Š stata
         // effettivamente creata
         IF !EMPTY(oCrw:aDbMap) .AND. LEN(oCrw:aDbMap)>=nInd
            nPos:= oCrw:aDbMap[nInd]
            IF nPos > 0
               xName := oCrw:aRecord[nInd][REC_STRUCT][FIE_FNAME]
               xVal  := oCrw:aRecord[nInd][REC_VALUE]
               IF  !(xVal == NIL)
                   DO CASE
                      CASE VALTYPE(xVal) $ "CM"
                         IF ::TrimString
                           xVal := Alltrim(xVal)
                           ::str2Xml(@xVal)
                         ELSE
                           ::str2Xml(@xVal)
                         ENDIF
                      CASE VALTYPE(xVal) == "D"
                         xVal := DTOS(xVal)
                      CASE VALTYPE(xVal) == "L"
                         xVal := IIF(xVal,"T","F" )
                      CASE VALTYPE(xVal) == "N"
                         //nLen := oCrw:aRecord[nInd][REC_STRUCT][FIE_FNAME]
                         //nDec :=
                         xVal := STR(xVal)
                         xVal := Alltrim(xVal)
                   ENDCASE
               ELSE
                  xVal := ""
               ENDIF
               //xVal viene convertito in formato stringa per essere scritto nel file Xml
               aRow[nPos] := {xName,xVal}
            ENDIF
         ENDIF
      NEXT
      cRowString := "<ROW "
      FOR nN := 1 TO LEN(aRow)
          //Mantis 863
          IF !EMPTY(aRow[nN]) .AND. LEN(aRow[nN])>1 .AND. aRow[nN][1] != NIL
             IF aRow[nN][2] == NIL
                aRow[nN][2] := ""
             ENDIF
             cRowString += Lower(aRow[nN][1])+'="'+aRow[nN][2]+'" '
          ENDIF
      NEXT
      cRowString += "/>" +Chr(10)
      FWrite( nHandle,cRowString)
  ENDIF
RETURN .T.

//Campi
//Text  ->  "string"
//Numeri Interi -> fieldtype ="i4"     per numeri tra  -999,999,999 e 999,999,999
//                   -> fieldtype ="i8"     per numeri tra - 999,999,999,999,999,999 e 999,999,999, 999,999,999
//Numeri con virgola r8 per numeri la cui somma delle cifre tra interi e decimali e <=15
//Memo ->     fieldtype="bin.hex" SUBTYPE="Text" WIDTH="50"
//Date -> fieldtype ="datetime" e scrivere la data in formato AAAAMMGG


METHOD XMLGes:DBCREATE( cFName, aStruct, cRDD)
   LOCAL nN, aRec
   LOCAL nHandle
   LOCAL aPath := dfFNameSplit(cFName)
      IF !EMPTY(aPath[1]+aPath[2])
         dfMd(aPath[1]+aPath[2])
      ENDIF
      nHandle := FCreate(cFName, FC_NORMAL)
      IF FError() <> 0
         dbMsgErr("Error opening the file:"+ STR(FError()))
      ENDIF
      IF nHandle>0
         FWrite( nHandle, '<?xml version="1.0" standalone="yes" ?><DATAPACKET Version="2.0">'+Chr(10)+'<METADATA><FIELDS>'+Chr(10) )
         FOR nN := 1 TO LEN(aStruct)
             aRec := aStruct[nN]
             DO CASE
                CASE aRec[DBS_TYPE] == DBS_TYPE_MEMO
                    FWrite( nHandle, '<FIELD attrname="'+Lower(Alltrim(aRec[DBS_NAME ])) +'" fieldtype="bin.hex" SUBTYPE="Text" WIDTH="50" />'+Chr(10) )
                CASE aRec[DBS_TYPE] == DBS_TYPE_LOGIC
                   FWrite( nHandle, '<FIELD attrname="'+Lower(Alltrim(aRec[DBS_NAME ])) +'" fieldtype="string" WIDTH="1" />'+Chr(10) )
                CASE aRec[DBS_TYPE] == DBS_TYPE_DATE
                    FWrite( nHandle, '<FIELD attrname="'+Lower(Alltrim(aRec[DBS_NAME ])) +'" fieldtype="dateTime" />'+Chr(10) )
                CASE aRec[DBS_TYPE] == DBS_TYPE_CHAR
                   FWrite( nHandle, '<FIELD attrname="'+Lower(Alltrim(aRec[DBS_NAME ])) +'" fieldtype="string" WIDTH="'+ALLTRIM(STR(aRec[DBS_LEN],3,0))+'" />'+Chr(10) )
                CASE aRec[DBS_TYPE] == DBS_TYPE_NUMBER
                   IF !EMPTY(aRec[DBS_DEC]) .AND. aRec[DBS_DEC]>0
                      //Numero con decimali
                      FWrite( nHandle, '<FIELD attrname="'+Lower(Alltrim(aRec[DBS_NAME ])) +'" fieldtype="r8" />'+Chr(10) )
                   ELSE
                      //Numero senza decimali
                      FWrite( nHandle, '<FIELD attrname="'+Lower(Alltrim(aRec[DBS_NAME ])) +'" fieldtype="i8" />'+Chr(10) )
                   ENDIF
             ENDCASE
         NEXT
         FWrite( nHandle, "</FIELDS></METADATA><ROWDATA>"+Chr(10) )
         AADD(::aHandleStack,{UPPER(ALLTRIM(cFName)),nHandle,aStruct,"" } )
      ENDIF
      ::nCurrentHandle  := nHandle
RETURN nHandle

METHOD XMLGes:dfUseFile(cFname, cAlias, lExl, cRDD)
   LOCAL nPOS
   LOCAL nHandle := 0
   DEFAULT cAlias TO cFname
   cAlias := UPPER(ALLTRIM(cAlias))
   nPos := ASCAN(::aHandleStack,{|aArr|aArr[1]==UPPER(ALLTRIM(cFName))} )
   IF nPOS==0
      nHandle := FOPEN(cFname,FO_READWRITE+FO_DENYWRITE )
      AADD(::aHandleStack,{UPPER(ALLTRIM(cFName)),nHandle,{},cAlias } )
   ELSE
      nHandle := ::aHandleStack[nPos][2]
      ::aHandleStack[nPos][4] := cAlias
   ENDIF
   ::nCurrentHandle  := nHandle
RETURN nHandle>0

METHOD XMLGes:GetnHandleFromAlias(cAlias)
   LOCAL nPOS
   LOCAL nHandle := 0
   IF !EMPTY(cAlias)
      nPos := ASCAN(::aHandleStack,{|aArr|aArr[4]==UPPER(ALLTRIM(cAlias))} )
      IF nPOS>0
         nHandle := ::aHandleStack[nPos][2]
      ENDIF
   ENDIF
RETURN nHandle

// serve per normalizzare il testo compatibile con il formato XML
METHOD XMLGes:str2Xml(cString)
/* ==========================================================
   ATTENZIONE: SE SI MODIFICA QUESTO METODO MODIFICARE ANCHE
   dfRepOutXMLTable:str2Xml() che Š simile
   ==========================================================*/

   //E' da migliorare
   // Simone 20/06/2005
   // mantis  0000775: report creati con Report Manager in formato XML non stampa correttamente i caratteri apice e virgolette
   // spostata la conversione carattere & al primo posto
   ////////////////////////////////////////////
   //Luca xl 4591 02/07/2015
   ////////////////////////////////////////////
   IF CHR(96) $ cString
      cString := STRTRAN(cString,chr(96), "'")
   ENDIF
   ////////////////////////////////////////////

   IF "&" $ cString
   cString := STRTRAN(cString,"&", "&amp;")
   ENDIF
   IF '"' $ cString
   cString := STRTRAN(cString,'"', "&quot;")
   ENDIF
   IF "'" $ cString
   cString := STRTRAN(cString,"'", "&apos;")
   ENDIF
   IF "<" $ cString
   cString := STRTRAN(cString,"<", "&lt;")
   ENDIF
   IF ">" $ cString
   cString := STRTRAN(cString,">", "&gt;")
   ENDIF
RETURN



