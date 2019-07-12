

#include "libtdb.ch"
#include "dmlb.ch"
#include "deldbe.ch"
#include "common.ch"
#include "dfNet.ch"
#include "dbstruct.ch"

#if XPPVER < 01900000
#else
#include "activex.ch"
#endif



// Funzioni per importazione di un file XLS in un file DBF
// - converte l'XLS in CSV (tramite activex di EXCEL)
// - importa il CSV in un DBF gi— aperto

#ifdef _TEST_

FUNCTION main(c)
   local aMap
   //   set alternate on
   //   set alternate to test.log

   use anagraf exclusive
   zap
   close

   use anagraf shared

   // importo tutto il XLS (solo colonne con stesso nome dei campi)
   anagraf->(S2xls2dbf(c))

   // importo solo alcune colonne (eventuale gestione del nome diverso in XLS)
   aMap := {}
   S2Xls2dbfMapField(aMap, "RAGSOC1")
   S2Xls2dbfMapField(aMap, "CODANA", "CODICE")

   anagraf->(S2xls2dbf(c, .T., aMap))
return 0

#endif

#DEFINE xlCSV                   6
#DEFINE xlCSVMac               22
#DEFINE xlCSVMSDOS             24
#DEFINE xlCSVWindows           23

#define FIE_DBF_NAME            1
#define FIE_XLS_NAME            2
#define FIE_DEC_SEP             3
#define FIE_THOUS_SEP           4
#define FIE_DATE_FMT            5
#define FIE_CUSTOM_CB           6

#define REC_FIE_NAME            1
#define REC_FIE_VAL             2

// aggiunge la mappatura di un campo
// xDbfField=nome/numero campo del dbf
// xXlsField=nome/numero campo del xls (se lasciato NIL corrisponde al nome campo xDbfField)
FUNCTION S2Xls2DbfMapField(aMap, xDbfField, xXlsField, ;
                           cDecSep, cThousandSep, ;
                           cDateFormat, bCustomFmt)

   DEFAULT cDecSep      TO "," // separatore decimali nel foglio XLS (usato se campo xDbfField=numerico)
   DEFAULT cThousandSep TO "." // separatore migliaia nel foglio XLS (usato se campo xDbfField=numerico)
   DEFAULT cDateFormat  TO "dd/mm/yy" // formato data nel foglio XLS (usato se campo xDbfField=data)

   AADD(aMap, {xDbfField, xXlsField, cDecSep, cThousandSep, cDateFormat, bCustomFmt})
RETURN aMap

// crea automaticamente mappa di importazione su tutti i campi del DBF
FUNCTION S2Xls2DbfAutoMap(aDbStruct)
   LOCAL aMap
   DEFAULT aDbStruct TO DBSTRUCT()

   // copio tutti i campi
   aMap := {}
   AEVAL(aDbStruct, {|f| S2Xls2DbfMapField(aMap, f[DBS_NAME])})
RETURN aMap

// Importa un XLS in un DBF gi… aperto
//
// ritorna il numero di record importati o <0 se errore
//
// cFile = nome file XLS da importare
//
// lFirstLineColName = .T. se la prima riga del foglio XLS contiene i nomi di colonna
//
// xMap = codeblock che ritorna un array costruito con S2Xls2DbfMapField
//        (al codeblock viene passata la struttura del foglio XLS come DBSTRUCT())
//        se il codeblock torna array vuoto non fa importazione
//
//        oppure array  costruito con S2Xls2DbfMapField
//
// es
//  aMap := {}
//  S2Xls2DbfMapField(aMap, "CODANA", 3) // 3^ colonna nel foglio XLS
//  S2Xls2DbfMapField(aMap, "RAGSOC1", "Ragione sociale cliente")
//  S2Xls2DbfMapField(aMap, "TOTDOC", "Totale", ".")
//  S2Xls2DbfMapField(aMap, "DATDOC", "Data docum.", "yyyymmdd")
//
// bFlt = filtro per scrivere il record nel DBF. al bFlt viene passato array di campi (nomecampo, valore)
//



FUNCTION S2Xls2Dbf(cFile, lFirstLineColName, xMap, bFlt)
#if XPPVER < 01900000
RETURN .T.
#else
   LOCAL nRet := -1, i
   LOCAL cAlias := ALIAS()
   LOCAL aDbStruct, cTmp
   LOCAL aXlStruct, aMap
   LOCAL nDbf, nXls, bCvt
   LOCAL xFie, xVal, nCount
   LOCAL aFie, aOld, aRec

   DEFAULT lFirstLineColName TO .T.

   aDbStruct := (cAlias)->(DBSTRUCT())

   DEFAULT xMap TO S2Xls2DbfAutoMap()
   DEFAULT bFlt TO {|aRec| .T. }

   IF EMPTY(xMap)
      RETURN nRet
   ENDIF

   nRet := -2

   // conversione XLS in CSV (file temporaneo)
   cTmp := _Xls2Csv(cFile)

   IF cTmp == NIL .OR. ! FILE(cTmp) 
      RETURN nRet
   ENDIF

   // Importo CSV
   aOld  := {NIL, NIL, NIL}

   aOld[1] := S2DbeInfo("DELDBE", COMPONENT_DATA, DELDBE_DELIMITER_TOKEN, '"')
   aOld[2] := S2DbeInfo("DELDBE", COMPONENT_DATA, DELDBE_DECIMAL_TOKEN, ',' )
   aOld[3] := S2DbeInfo("DELDBE", COMPONENT_DATA, DELDBE_FIELD_TOKEN, ';' )

   USE (cTmp) VIA DELDBE NEW ALIAS __xls

   __xls->(DBGOTOP())

   aXlStruct := {}
   IF lFirstLineColName
      // nomi dei campi
      FOR i := 1 TO __xls->(FCOUNT())
         xVal := __xls->(fieldget_xls(i))
         xVal := UPPER(ALLTRIM(xVal))
         // struttura fittizia compatibile con DBSTRUCT()
         AADD(aXlStruct, {xVal, "C", 1000, 0})
      NEXT

      __xls->(DBSKIP())
   ENDIF
   IF VALTYPE(xMap)=="B" 
      // codeblock per definire la struttura
      xMap := ACLONE( EVAL(xMap, aXlStruct, aDbStruct) )
   ENDIF
   IF ! VALTYPE(xMap)=="A"
      xMap := {}
   ENDIF

   // calcolo numero del campo e codeblock di conversione
   aMap := ACLONE(xMap)

   FOR i := 1 TO LEN(aMap)

      nDbf := NIL
      nXls := NIL
      bCvt := NIL

      aFie := aMap[i]

      xFie := aFie[FIE_DBF_NAME]
      IF VALTYPE(xFie) != "N"
         // cerco numero del campo in file DBF destinazione
         xFie := ASCAN(aDbStruct, {|f| f[DBS_NAME]==xFie})
      ENDIF

      IF VALTYPE(xFie) == "N"
         nDbf := xFie // trovato
      ENDIF

      xFie := aFie[FIE_XLS_NAME]
      IF xFie == NIL .AND. VALTYPE(aFie[FIE_DBF_NAME]) != "N"
         xFie := aFie[FIE_DBF_NAME] // default = nome campo destinazione
      ENDIF

      IF VALTYPE(xFie) != "N"
         // cerco numero del campo in XL
         xFie := ASCAN(aXlStruct, {|f| f[DBS_NAME]==xFie})
      ENDIF
      IF VALTYPE(xFie) == "N"
         nXls := xFie // trovato
      ENDIF

      IF EMPTY(nDbf) .OR. EMPTY(nXls)
         AREMOVE(aMap, i)  // tolgo campo non trovato
         i--
         LOOP
      ENDIF

      IF aFie[FIE_CUSTOM_CB] != NIL
         bCvt := aFie[FIE_CUSTOM_CB]

      ELSEIF aDbStruct[nDbf][DBS_TYPE] $ "CM"

      ELSEIF aDbStruct[nDbf][DBS_TYPE] =="N"
         bCvt := {|xVal, aF| _cvtNum(xVal, aF) }

      ELSEIF aDbStruct[nDbf][DBS_TYPE] =="D"
         bCvt := {|xVal, aF| _cvtDate(xVal, aF) }

      ELSEIF aDbStruct[nDbf][DBS_TYPE] =="L"
         bCvt := {|xVal, aF| !EMPTY(xVal)}

      ENDIF

      // non faccio conversione
      DEFAULT bCvt TO {|xVal, aF| xVal} 

      aFie[FIE_DBF_NAME ] := nDbf
      aFie[FIE_XLS_NAME ] := nXls
      aFie[FIE_CUSTOM_CB] := bCvt
   NEXT

   IF ! EMPTY(aMap)
      nCount := 0

      aRec := ARRAY(LEN(aMap))

      FOR i := 1 TO LEN(aRec)
         aRec[i] := { aDbStruct[ aMap[i][FIE_DBF_NAME] ], NIL} // array nomecampo dbf, valore
      NEXT

      // copio i record
      DO WHILE ! __xls->(EOF())

         // creo array per il filtro
         FOR i := 1 TO LEN(aMap)
            aFie := aMap[i]
            xVal := __xls->(FIELDGET_XLS(aFie[FIE_XLS_NAME]))

            // conversione di tipo
            xVal := EVAL(aFie[FIE_CUSTOM_CB], xVal, aFie, aMap)
            aRec[i][REC_FIE_VAL] := xVal
         NEXT

         // valuto il filtro su record
         IF EVAL(bFlt, aRec) 
            // scrivo il record
            IF WriteRec(cAlias, aMap, aRec) 
               nCount++
            ENDIF
         ENDIF

         __xls->(DBSKIP())
      ENDDO

      nRet := nCount // OK
   ENDIF

   __xls->(DBCLOSEAREA())
   FERASE(cTmp)

   S2DbeInfo("DELDBE", COMPONENT_DATA, DELDBE_DELIMITER_TOKEN, aOld[1])
   S2DbeInfo("DELDBE", COMPONENT_DATA, DELDBE_DECIMAL_TOKEN, aOld[2] )
   S2DbeInfo("DELDBE", COMPONENT_DATA, DELDBE_FIELD_TOKEN, aOld[3] )

RETURN nRet

// scrivo il record
STATIC FUNCTION WriteRec(cAlias, aMap, aRec)
   LOCAL i, lRet := .F.
   IF (cAlias)->(dfNet(NET_APPEND))
      FOR i := 1 TO LEN(aMap)
         (cAlias)->(FIELDPUT(aMap[i][FIE_DBF_NAME], aRec[i][REC_FIE_VAL] ))
      NEXT
      (cAlias)->(dfNet(NET_RECORDUNLOCK))
      lRet := .T.
   ENDIF
RETURN lRet

// traduco eventuale doppio "" in " singolo
STATIC FUNCTION FieldGet_xls(i)
   LOCAL x := FIELDGET(i)
   IF VALTYPE(x) $ "CM"
      x := STRTRAN(x, '""', '"')
   ENDIF
RETURN x

// conversione numeri
STATIC FUNCTION _CvtNum(xVal, aFie)
   LOCAL i
   xVal := ALLTRIM(xVal)
   IF ! EMPTY(aFie[FIE_THOUS_SEP])
      xVal := STRTRAN(xVal, aFie[FIE_THOUS_SEP], "")
   ENDIF
   IF ! EMPTY(aFie[FIE_DEC_SEP])
      xVal := STRTRAN(xVal, aFie[FIE_DEC_SEP], ".")
   ENDIF
   xVal := VAL(xVal)
RETURN xVal

// conversione date
STATIC FUNCTION _CvtDate(xVal, aFie)
  LOCAL xOld := SET( _SET_DATEFORMAT, aFie[FIE_DATE_FMT] )
  xVal := CTOD(xVal)
  SET( _SET_DATEFORMAT, xOld )
RETURN xVal


STATIC FUNCTION _Xls2Csv(cFile, oError)
   LOCAL oExcel, oBook
   LOCAL cTmp, bErr, oErr

   oExcel := CreateObject("Excel.Application", "localhost")
   IF EMPTY( oExcel )
      RETURN NIL
   ENDIF

   oError := NIL // by reference torna l'errore

   cFile := dfFNameBuild(cFile)
   bErr := ERRORBLOCK({|e| dfErrBreak(e)})

   // Conversione XLS in CSV
   BEGIN SEQUENCE

      // Avoid message boxes such as "File already exists". Also,
      // ensure the Excel application is visible.
      oExcel:DisplayAlerts := .F.
      oExcel:visible       := .F.

      oBook  := oExcel:workbooks:Open(cFile)

      FCLOSE( dfFileTemp(@cTmp, NIL, NIL, ".csv") )

      oBook:SaveAs(cTmp, xlCSV, .F.)

      // Quit Excel
      oExcel:Quit()
      oExcel:Destroy()
      oExcel := NIL

   RECOVER USING oErr
      oError := oErr

      IF cTmp != NIL 
         FERASE(cTmp)
      ENDIF
      cTmp := NIL

   END SEQUENCE

   BEGIN SEQUENCE
      IF oExcel != NIL 
         oExcel:Quit()
         oExcel:Destroy()
      ENDIF
   END SEQUENCE

   ERRORBLOCK(bErr)

RETURN cTmp
#endif
