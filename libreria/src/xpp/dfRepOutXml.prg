#include "common.ch"

#include "fileio.ch"
#include "dbstruct.ch"

#define DBS_TYPE_CHAR    "C"
#define DBS_TYPE_LOGIC   "L"
#define DBS_TYPE_DATE    "D"
#define DBS_TYPE_NUMBER  "N"
#define DBS_TYPE_MEMO    "M"

// aFie
// array generato da dBsee
// -----------------------
#define FIE_FNAME     1


// Gestione dfRepOutput in XML per Report Manager
// pió veloce del metodo standard (vedi dfCRWOutput())
//

*======================================================
CLASS dfRepOutXML
*======================================================
EXPORTED:
   VAR aTbl

   METHOD init()
   METHOD getFName()
   METHOD close()
   METHOD ferase()

   METHOD clear()
   METHOD addTable()
   METHOD createDBStruct()
ENDCLASS

METHOD dfRepOutXML:init()
   ::clear()
RETURN self

METHOD dfRepOutXML:clear()
   ::aTbl := {}
RETURN self

METHOD dfRepOutXML:addTable(oTbl)
   AADD(::aTbl, oTbl)
RETURN oTbl

METHOD dfRepOutXML:getFname()
   LOCAL aRet := {}
   AEVAL(::aTbl, {|o|AADD(aRet, o:cFName)})
RETURN aRet

METHOD dfRepOutXML:createDBStruct()
   AEVAL(::aTbl, {|o|o:dbcreate()})
RETURN .T.

METHOD dfRepOutXML:ferase()
   AEVAL(::aTbl, {|o|o:ferase()})
RETURN .T.

METHOD dfRepOutXML:close()
   AEVAL(::aTbl, {|o|o:dbclosearea()})
RETURN .T.

*======================================================
CLASS dfRepOutXMLTable
*======================================================
   PROTECTED:
      VAR oFilterColumn

   EXPORTED:
      VAR nHandle
      VAR aStruct
      VAR cFName

      //VAR TrimString
      METHOD Init
      METHOD FErase
      METHOD DBCLOSEAREA
      METHOD DBCREATE
      METHOD addRecord

//      METHOD dfUseFile
      //METHOD GetnHandleFromAlias
      CLASS METHOD str2Xml

      METHOD setFilterColumn
      METHOD GetAllColumns

      //METHOD loadFilterColumn
ENDCLASS

METHOD dfRepOutXMLTable:Init(cFname, aStruct)
   DEFAULT cFName  TO "FILE.XML"
   DEFAULT aStruct TO {}

   cFName := dfFNameBuild(cFName, dfReportTemp(), ".XML")

   ::nHandle := 0
   ::cFName  := cFName
   ::aStruct := aStruct
//   ::TrimString     := dfSet("XbaseXMLTrimString") == "YES"
//   DEFAULT ::TrimString TO .F.

RETURN Self

METHOD dfRepOutXMLTable:FErase(cFName,cFileNtx)
   FERASE(::cFName)
RETURN .T.

METHOD dfRepOutXMLTable:DBCLOSEAREA()
   LOCAL nHandle := ::nHandle
   LOCAL nPos
   IF nHandle >0
      FWrite( nHandle, "</ROWDATA></DATAPACKET>" )
      FClose( nHandle)
   ENDIF
   ::nHandle  := 0
RETURN nHandle

METHOD dfRepOutXMLTable:addRecord(aRow)
  LOCAL nInd, nPos, nN
  LOCAL xVal, xName
  LOCAL nLen, nDec
  LOCAL nHandle:= ::nHandle
  LOCAL aStruct

  LOCAL cRowString

  IF nHandle<=0
     RETURN .F.
  ENDIF

  aStruct := ::aStruct

  IF ! EMPTY(::oFilterColumn)
     aRow := ::oFilterColumn:filterColumn(aRow)
     aStruct:= ::oFilterColumn:filterColumn(aStruct)
  ENDIF

  cRowString := "<ROW "
  //Mantis 2166 Luca 3/10/2011 
  //FOR nInd := 1 TO LEN(aRow)
  FOR nInd := 1 TO MIN(LEN(aRow),LEN(aStruct))
      xName := aStruct[nInd][FIE_FNAME]
      xVal  := aRow[nInd]
      DO CASE
         CASE xVal == NIL
            xVal := ""

         CASE VALTYPE(xVal) $ "CM"
//            IF ::TrimString
//              xVal := dfStr2Xml(Alltrim(xVal)) //::Normalizza_XML(Alltrim(xVal))
//            ELSE
//              xVal := dfStr2Xml(xVal) //::Normalizza_XML(xVal)
//            ENDIF

            // faccio sempre alltrim altrimenti non funziona la 
            // relazione 1:n in reportmanager
            xVal := ALLTRIM(xVal) 
            ::Str2Xml(@xVal) //::Normalizza_XML(xVal)

         CASE VALTYPE(xVal) == "D"
            xVal := DTOS(xVal)

         CASE VALTYPE(xVal) == "L"
            xVal := IIF(xVal,"T","F" )

         CASE VALTYPE(xVal) == "N"
            xVal := ALLTRIM( STR(xVal) )
      ENDCASE
      cRowString += LOWER(xName)+'="'+xVal+'" '
   NEXT
   cRowString += "/>" +Chr(10)
   FWrite( nHandle, cRowString)
RETURN .T.

//Campi
//Text  ->  "string"
//Numeri Interi -> fieldtype ="i4"     per numeri tra  -999,999,999 e 999,999,999
//                   -> fieldtype ="i8"     per numeri tra - 999,999,999,999,999,999 e 999,999,999, 999,999,999
//Numeri con virgola r8 per numeri la cui somma delle cifre tra interi e decimali e <=15
//Memo ->     fieldtype="bin.hex" SUBTYPE="Text" WIDTH="50"
//Date -> fieldtype ="datetime" e scrivere la data in formato AAAAMMGG

METHOD dfRepOutXMLTable:DBCREATE( cFName, aStruct, cRDD)
   LOCAL nN, aRec
   LOCAL nHandle
   LOCAL aPath
   LOCAL aStructApp
   LOCAL aTmpStruct

   DEFAULT cFName  TO ::cFName
   DEFAULT aStruct TO ::aStruct

   // se era aperto chiudo!
   ::dbCloseArea()

   cFName := dfFNameBuild(cFName, dfReportTemp(), ".XML")
   aPath := dfFNameSplit(cFName)
   IF !EMPTY(aPath[1]+aPath[2])
      dfMd(aPath[1]+aPath[2])
   ENDIF

   nHandle := FCreate(cFName, FC_NORMAL)
   IF FError() <> 0
      dbMsgErr("Error opening the file:"+ STR(FError()))
   ENDIF
   IF nHandle>0

   //Maudp XL 3634 26/09/2012 Se ho un filtro per le colonne impostato
   //procedo con la gestione della struttura
   ******************************************************************************************
      aTmpStruct := aStruct
      IF ! EMPTY(::oFilterColumn)

         // abilito lettura da file con prefisso NOMETABELLA_
         // per congruenza con il file REPOUT utilizzato per l'esportazione EXCEL
         aStructApp := ::getAllColumns(.T.)

         //Salvo la struttura
         ::oFilterColumn:setStruct(aStructApp)

         // ricalcolo la struttura del corpo filtrata
         aTmpStruct := ::oFilterColumn:filterColumn(aTmpStruct)
      ENDIF
   ******************************************************************************************
      FWrite( nHandle, '<?xml version="1.0" standalone="yes" ?><DATAPACKET Version="2.0">'+Chr(10)+'<METADATA><FIELDS>'+Chr(10) )
      FOR nN := 1 TO LEN(aTmpStruct)
         aRec := aTmpStruct[nN]
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
      //AADD(::aHandleStack,{UPPER(ALLTRIM(cFName)),nHandle,aStruct,"" } )
   ******************************************************************************************
      ::aStruct := aStruct
      ::cFName  := cFName
      ::nHandle := nHandle
   ENDIF
RETURN nHandle

/*
METHOD dfRepOutXMLTable:dfUseFile(cFname, cAlias, lExl, cRDD)
RETURN ::nHandle >0

*/

// serve per normalizzare il testo compatibile con il formato XML
// ed ä pió veloce della dfStr2Xml() (fa meno cose!)

CLASS METHOD dfRepOutXMLTable:str2Xml(cString)
//   cString := CONVTOANSICP(dfStr2Xml(cString))
//return 
/* ==========================================================
   ATTENZIONE: SE SI MODIFICA QUESTO METODO MODIFICARE ANCHE
   XmlGes:str2Xml() che ä simile 
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
   cString := CONVTOANSICP(cString)

RETURN 

//Maudp XL 3634 26/09/2012 Ripresi metodi dalla dfRepOutXls della LIBGIOIA per gestire
//la configurazione dei campi esportati sul file STAT.xml per la creazione del report con
//report manager
******************************************************************************************

// Imposta la classe di filtro x colonna

METHOD dfRepOutXMLTable:setFilterColumn(o)
   ::oFilterColumn:=o
RETURN self

//Metodo per aggiungere o togliere dalla struttura il prefisso della tabella
//ES: STAT_MATRICOLA oppure MATRICOLA all'interno del file STAT.XML
METHOD dfRepOutXMLTable:getAllColumns(lAddTableName)
   LOCAL aCols := {}
   LOCAL n, cTableName, nPos
   LOCAL aParentCols
   LOCAL aXMLParent := {}

   DEFAULT lAddTableName TO .T.

   AADD(aXMLParent, self)
   
   cTableName:= ""

   // aggiungo le colonne di struttura di tutte le tabelle padri
   FOR n := 1 TO LEN(aXMLParent)
      IF lAddTableName
         cTableName := dfFindName(aXMLParent[n]:cFName)+"_"
      ENDIF
      aParentCols := ACLONE(aXMLParent[n]:aStruct)
      // aggiungo nome tabella al nome campo cioä da ANNOCON a CONTRAT_ANNOCON
      FOR nPos := 1 TO LEN(aParentCols)
         aParentCols[nPos][DBS_NAME] := cTableName+aParentCols[nPos][DBS_NAME]
      NEXT
      AEVAL(aParentCols, {|x| AADD(aCols,  x)})
   NEXT
RETURN aCols
******************************************************************************************
