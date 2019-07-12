#include "Common.ch"
#include "dmlb.ch"

// Imposta i database engines leggendoli da un file di testo
// (default=DBE.INI).
//
// Esempio d'uso
// PROCEDURE DbeSys()
//    SET COLLATION TO ASCII
//    IF ! dfDBESet()
//       // Imposto i DBE di default
//       dfDbfNtx()
//       dfDbfCdx()
//    ENDIF
// RETURN
//
// Esempio di file DBE.INI:
//
//    ; ------------------------------------------
//    ; DBE.INI
//    ; Definisce i DATABASE ENGINES da utilizzare
//    ; ------------------------------------------
//
//    ; Costruisce DBFNTX
//    LOAD:DBFDBE
//    LOAD:NTXDBE
//    BUILD:DBFNTX,DBFDBE,NTXDBE
//
//    ; Imposta il LOCKDELAY per gestione DBF
//    SETDATA:DBFNTX,1005, 10
//
//    ; Imposta il LOCKRETRY per gestione DBF
//    SETDATA:DBFNTX,1006, 20
//
//    ; Imposta il LOCKDELAY per gestione NTX
//    SETORDER:DBFNTX,1002, 30
//
//    ; Imposta il LOCKRETRY per gestione NTX
//    SETORDER:DBFNTX,1003, 40


FUNCTION dfDBESet(cFile)
   LOCAL lOk := .F.
   LOCAL aCmd := {}
   LOCAL cLine
   LOCAL nLine

   AADD(aCmd, { "LOAD", {|c| LoadDBE(c, .T. ) } })
   AADD(aCmd, { "PUBLOAD", {|c| LoadDBE(c, .F.) } })

   AADD(aCmd, { "BUILD"        , {|c| BuildDBE(c) } })
   AADD(aCmd, { "BUILDDEF"     , {|c| BuildDef(c)} })
   AADD(aCmd, { "SETDATA"      , {|c| SetDBE(c,COMPONENT_DATA)} })
   AADD(aCmd, { "SETORDER"     , {|c| SetDBE(c,COMPONENT_ORDER)} })
   AADD(aCmd, { "SETRELATION"  , {|c| SetDBE(c,COMPONENT_RELATION)} })
   AADD(aCmd, { "SETDICTIONARY", {|c| SetDBE(c,COMPONENT_DICTIONARY)} })
   AADD(aCmd, { "AXSSCANDRIVES", {|c| AXSScanDrives(c)} })


   DEFAULT cFile TO "DBE.INI"

   BEGIN SEQUENCE
      IF ! FILE(cFile); BREAK; ENDIF

      cFile := MEMOREAD(cFile)
      IF EMPTY(cFile); BREAK; ENDIF

      FOR nLine := 1 TO MLCOUNT(cFile, 250)
         cLine := UPPER(ALLTRIM(MEMOLINE(cFile, 250, nLine)))

         // Salto i commenti
         IF EMPTY(cLine) .OR. LEFT(cLine,1) $ "#;"
            LOOP
         ENDIF

         lOk := ExeCmd(cLine, aCmd)

         IF ! lOk
            EXIT
         ENDIF

      NEXT

   END SEQUENCE

RETURN lOk

STATIC FUNCTION ExeCmd(cCmd, aCmd)
   LOCAL nInd
   LOCAL cVal
   LOCAL lRet := .T.

   FOR nInd := 1 TO LEN(aCmd)
      cVal := GetVal(cCmd, aCmd[nInd][1])

      IF ! EMPTY(cVal)
         lRet := EVAL(aCmd[nInd][2], cVal)
         EXIT
      ENDIF
   NEXT
RETURN lRet

STATIC FUNCTION GetVal(cLine, cCmd, cSep)
   LOCAL nLen := LEN(cCmd)
   LOCAL cRet := ""

   DEFAULT cSep TO ":"

   cCmd += cSep
   nLen := LEN(cCmd)

   IF LEFT(cLine, nLen)==cCmd
      cRet := ALLTRIM(SUBSTR(cLine,nLen+1))
   ENDIF
RETURN cRet

STATIC FUNCTION _Str2Arr(c,d)
   LOCAL aRet := dfStr2Arr(c,d)
   IF ! EMPTY(aRet)
      AEVAL(aRet, {|x| x:=ALLTRIM(x) },NIL,NIL,.T.)
   ENDIF
RETURN aRet

// -------
// Comandi
// -------

// Comando: LOAD:nomeComponente
// Esempio: LOAD:DBFDBE
// Esempio: LOAD:NTXDBE
STATIC FUNCTION LoadDBE(c, lHidden)
   LOCAL lRet := DbeLoad(c, lHidden)
   IF ! lRet
      MsgBox("Error loading "+c)
   ENDIF
RETURN lRet

// Comando: BUILD:nomeDBE,data,order,relation,dictionary
// Esempio: BUILD:DBFNTX,DBFDBE,NTXDBE
STATIC FUNCTION BuildDBE(c)
   LOCAL a:=_Str2Arr(c,",")
   LOCAL lRet := .F.
   IF LEN(a) >= 2
      ASIZE(a,5)
      lRet := DbeBuild(a[1],a[2],a[3],a[4],a[5])
      IF ! lRet
         MsgBox("Error building "+c)
      ENDIF
   ENDIF
RETURN lRet

// Comando: BUILDDEF:[DBFNTX|DBFCDX]
STATIC FUNCTION BuildDef(c)
   LOCAL lRet := .F.

   IF c == "DBFNTX"
      lRet := dfDbfNtx()

   ELSEIF c == "DBFCDX"

      // lRet := dfDbfCdx()

   ENDIF

RETURN lRet

// Comando: SETxxx
// Sintassi: SETx:nomeDBE,define,NewSetting
// Esempio: SETDATA:DBFNTX,1005,10    // imposta il LOCKRETRY a 10
// Esempio: SETDATA:DBFNTX,1001,*DBX  // imposta l'estensione per file MEMO.
                                      // "*" vuol dire che il successivo Š una stringa
                                      // altrimenti viene trattato come un numero

STATIC FUNCTION SetDBE(c,n)
   //LOCAL lRet := .F.
   LOCAL aArr := _Str2Arr(c,",")
   LOCAL cRDD
   LOCAL cCurrRdd := DbeSetDefault()

   IF LEN(aArr) >= 3
      cRdd := aArr[1]
      IF EMPTY(cRdd) .OR. cCurrRdd == cRdd
         //lRet := _SetDBE(n,aArr)
         _SetDBE(n,aArr)

      ELSEIF ASCAN(DbeList(), {|x| x[1] == cRdd }) > 0
         DbeSetDefault(cRdd)
         //lRet := _SetDBE(n,aArr)
         _SetDBE(n,aArr)
         DbeSetDefault(cCurrRdd)
      ENDIF
   ENDIF
RETURN .T. //lRet

STATIC FUNCTION AXSScanDrives(c)
   dfAXSScanDrives(c)
RETURN .T.

STATIC FUNCTION _SetDbe(n,aArr)
RETURN DbeInfo(n, VAL(aArr[2]), ;
               IIF(LEFT(aArr[3],1)=="*", SUBSTR(aArr[3],2), VAL(aArr[3]) ))
