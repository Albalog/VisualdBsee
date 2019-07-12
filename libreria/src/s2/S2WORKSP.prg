#include "common.ch"
#include "Dbstruct.ch"
#include "dmlb.ch"

#define WS_AREA           1
#define WS_DBE            2
#define WS_FILENAME       3
#define WS_ALIAS          4
#define WS_SHARED         5
#define WS_RECNO          6
#define WS_INDEXARR       7
#define WS_INDEXCURR      8
#define WS_OPENED         9
#define WS_DUPFILENAME   10
#define WS_DUPMEMONAME   11

// Note simone 8/apr/03
// - S2WorkSpaceGet/Set sono da usare per aprire le workarea 
//   in un altro thread, bisognerebbe implementare 
//   la connessione con ADS se Š presente

// Save the current state of all work areas

// The example demonstrates how to save and restore the current
// state of all work areas. The user-defined function SaveWorkSpace()
// saves and RestWorkSpace() restores the state of the work areas.

FUNCTION S2WorkSpaceSave()
   LOCAL aSaved := {}

   WorkSpaceEval( {|| AAdd( aSaved, SaveWorkArea() ) } )

RETURN { aSaved, Select() }

FUNCTION S2WorkAreaSave()
RETURN {{SaveWorkArea()},SELECT()}


STATIC FUNCTION SaveWorkArea()
RETURN  { ;
   {  Select()   , {|x| DbSelectArea(x)} }, ;
   {  OrdNumber(), {|x| OrdSetFocus(x) } }, ;
   {  Recno()    , {|x| Dbgoto_XPP(x)      } }  }


FUNCTION S2WorkSpaceRest( aSaved )

   AEval( aSaved[1] , ;
            {|a| AEval( a, {|aa| Eval( aa[2], aa[1] ) } ) } )

RETURN DbSelectArea( aSaved[2] )


FUNCTION S2WorkSpaceGet()
   LOCAL aSaved := {}

   WorkSpaceEval( {|| AAdd( aSaved, GetWorkArea() ) } )

RETURN { aSaved, Select() }

FUNCTION S2WorkSpaceSet(aSaved)
   LOCAL nOK := 0, nErr :=0

   AEval( aSaved[1], {|a| Open( a, @nOK, @nErr ) })

   IF (aSaved[2])->(USED())
      DbSelectArea( aSaved[2] )
   ENDIF

RETURN nOk == LEN(aSaved[1])

// Chiude tutto e cancella file temp.
FUNCTION S2WorkSpaceDel(aSaved)
   // chiudo tutto
   DBCLOSEALL() 

   // cancello eventuali files creati
   AEVAL(aSaved[1], {|a| a[WS_OPENED]:=.F., DelDupFiles(a)} )
RETURN .T.

STATIC FUNCTION DelDupFiles(a)
   IF a[WS_DUPFILENAME] != NIL .AND. FILE(a[WS_DUPFILENAME])
      FERASE( a[WS_DUPFILENAME] )
   ENDIF

   IF a[WS_DUPMEMONAME] != NIL .AND. FILE(a[WS_DUPMEMONAME])
      FERASE( a[WS_DUPMEMONAME] )
   ENDIF
RETURN NIL


STATIC FUNCTION GetWorkArea()
   LOCAL aRet

   aRet := { Select(), dbInfo(DBO_DBENAME), dbInfo(DBO_FILENAME), ;
            dbInfo(DBO_ALIAS),  dbInfo(DBO_SHARED), Recno(), ;
            dfOrdList_XPP(), OrdNumber(), .F., NIL, NIL}

   IF ! aRet[WS_SHARED] // se apertura esclusiva
      DupTable(aRet)    // faccio una copia dell'archivio
   ENDIF

RETURN aRet

STATIC FUNCTION DupTable(aRet)
   LOCAL aSave     := SaveWorkArea()
   LOCAL oErr      := NIL
   LOCAL aPath     := NIL
   LOCAL cFName    := NIL
   LOCAL cMemoName := NIL
   LOCAL lMemo     := NIL
   LOCAL cRDD      := NIL
   LOCAL err

   oErr      := ERRORBLOCK({|e| break(e)})
   BEGIN SEQUENCE

      cRDD      := dbInfo(DBO_DBENAME)

      // Ci sono campi Memo?
      lMemo     := ASCAN(DBSTRUCT(), {|a|a[DBS_TYPE]=="M"}) > 0

      DBSETORDER(0)

      aPath := dfFNameSplit(dbInfo(DBO_FILENAME))
      cFName := aPath[1]+aPath[2]

      // Creo un file nello stesso path (per ADS)
      FCLOSE( dfFileTemp( @cFName, NIL, NIL, aPath[4] ))

      IF lMemo // Nome del file MEMO
         aPath := dfFNameSplit(cFName)
         cMemoName := aPath[1]+aPath[2]+aPath[3]+dfMemoExt(cRDD)
      ENDIF

      // Copio
      DBEXPORT(cFName, NIL, NIL, NIL, NIL, NIL, NIL, cRDD )


   RECOVER USING err
      err := err  // serve solo per vedere qual Š l'errore in fase di debug

   END SEQUENCE
   ERRORBLOCK(oErr)

   // Ripristino
   AEval( aSave, {|aa| Eval( aa[2], aa[1] ) } ) 

   aRet[WS_DUPFILENAME] := cFName
   aRet[WS_DUPMEMONAME] := cMemoName

RETURN cFName


// Riapre archivio e indici
STATIC FUNCTION Open(a, nOk, nErr)
   LOCAL n
   LOCAL cName := NIL
   LOCAL oErr := ERRORBLOCK({|e| break(e)})
   LOCAL cFName
   LOCAL err

   a[9] := .F.
   BEGIN SEQUENCE

      DBSELECTAREA(a[1])

      DBCLOSEAREA()

      // Se ho COPIATO l'archivio perche era in uso esclusivo, apro quello
      cFName := IIF(a[WS_DUPFILENAME]==NIL, a[WS_FILENAME], a[WS_DUPFILENAME])

      // Apre archivio
      DBUSEAREA(.F., a[WS_DBE], cFName, a[WS_ALIAS], .T., .F.)

      // simone 28/11/08
      // supporto DBF criptati con ADS o ALS
      dfADSDbfSetPwd(cFName)

      // Apertura indici
      FOR n := 1 TO LEN(a[WS_INDEXARR])
         IF cName == NIL .OR. ! cName == a[WS_INDEXARR][n]
            cName := a[WS_INDEXARR][n]
            ORDLISTADD( cName )
         ENDIF
      NEXT  

      ORDSETFOCUS(a[WS_INDEXCURR])

      DBGOTO_XPP(a[WS_RECNO])

      a[WS_OPENED] := .T.

      nOk++
   RECOVER USING err
      err := err  // serve solo per vedere qual Š l'errore in fase di debug
      nErr++
   END SEQUENCE
   ERRORBLOCK(oErr)
RETURN .T.   


