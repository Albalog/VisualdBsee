#include "Common.ch"
#include "Dmlb.ch"
#include "dfXBase.ch"

// Workaround per ACLONE che se fatto su variabili che non sono array
// in clipper torna NIL e in Xbase da errore
FUNCTION ACLONE_XPP(xArr)
   IF ! VALTYPE(xArr) == "A"; RETURN NIL; ENDIF
RETURN ACLONE(xArr)

// Funzione DBAPPEND_XPP
//
// identica alla DBAPPEND ma ha il parametro logico invece che numerico
// per maggiore compatibilit… con CLIPPER
//
// Workaround per PDR 3061.
FUNCTION DBAPPEND_XPP( lRelease )

   DEFAULT lRelease TO .T.

   IF lRelease
      DbAppend()
   ELSE
      DbAppend(1)
   ENDIF
RETURN NIL

FUNCTION DBCREATE_XPP(cFile, aStruct, cDbe)
   LOCAL lBad := .F.
   LOCAL nInd
   LOCAL aCStruct

   nInd := 0
   DO WHILE ++nInd <= LEN(aStruct)
      IF LEN(aStruct[nInd]) > 4
         lBad := .T.
         EXIT
      ENDIF
   ENDDO

   IF lBad
      aCStruct := ACLONE(aStruct)

      nInd := 0
      DO WHILE ++nInd <= LEN(aCStruct)
         IF LEN(aCStruct[nInd]) > 4
            ASIZE(aCStruct[nInd], 4)
         ENDIF
      ENDDO

      DBCREATE(cFile, aCStruct, cDbe)
   ELSE
      DBCREATE(cFile, aStruct, cDbe)
   ENDIF

RETURN NIL

// FIX per DBEVAL
// "a volte" se alla fine del codeblock da valutare (bBlock)
// l'alias non Š pi— quello iniziale ho un runtime error
//
// Esempio:
//    MATRICO->(DBEVAL({|| DBSELECTAREA("PIPPO") }))
// a volte da un errore

FUNCTION DBEVAL_XPP(bBlock, bFor, bWhile, nCount, xRec, lRest)
   LOCAL nArea := SELECT()
RETURN DBEVAL( {|| EVAL(bBlock), DBSELECTAREA(nArea) }, ;
               bFor, bWhile, nCount, xRec, lRest)

// FIX per DBGOTO con ADSDBE
// dopo un APPEND se utilizzo DBGOTO
// sul record corrente la scrittura successiva
// da un runtime error
//
// Esempio:
//    DBAPPEND()
//    nRec := RECNO()
//    DBGOTO(nRec)
//    FIELD->PIPPO:="CAIO"  // RUNTIME ERROR

PROCEDURE DBGOTO_XPP(xRec)
   LOCAL n:=0

   ///////////////////////////////////
   //Mantis 1108
   IF VALTYPE(xRec) != "N"
      RETURN
   ENDIF
   ///////////////////////////////////

   // Simone 30/08/2005 
   // mantis  0000858: su listbox premendo barra spazio viene messaggio "non ci sono righe da modificare" anche se la riga esiste
   // se BOF o EOF riposiziona per resettare questi status
   IF RECNO() != xRec .OR. BOF() .OR. EOF()
      DBGOTO(xRec)
   ENDIF

   // simone 5/11/04 
   // correzione problema rilevato con ADS e CITRIX
   // Se fai DBGOTO(0) a volte EOF() rimane a .F. 
   // invece DEVE essere a .T.
   IF xRec <= 0 .AND. ! EOF()

      // forzo EOF in diversi modi!
      DBGOTO(-1) // dai test fatti in genere questa funziona

      IF ! EOF()
         DBGOTO(LASTREC()+10000)

         n := SECONDS()+180
         DO WHILE ! EOF() .AND. SECONDS()<n
            sleep(10)
            DBGOBOTTOM()
            DBSKIP()
         ENDDO
         IF ! EOF() // se ancora non sono in EOF()
            n += "DBGOTO FAILED!!!"  // provoco errore di runtime!!
         ENDIF
      ENDIF
   ENDIF
RETURN

// Workaround per DBPOSITION che da un runtime error se uso AXS
// e sei su EOF()
FUNCTION DBPOSITION_XPP()
   LOCAL nRet := 0
   IF ! EOF()
      nRet := DbPosition()
   ENDIF
RETURN nRet

// Funzione DBRLOCKLIST_XPP
//
// identica alla DBRLOCKLIST ma torna un ACLONE
// altrimenti l'array tornato CAMBIA al cambiare dei lock!
// per maggiore compatibilit… con CLIPPER
//
// Esempio
//
// USE AAA SHARED
// A:=DBRLOCKLIST()
// B := ACLONE(DBRLOCKLIST())
//
// ? LEN(a), LEN(b), LEN(DBRLOCKLIST()) //CLIP: 0,0,0 - XPP 0,0,0
// ? RLOCK()
// ? LEN(a), LEN(b), LEN(DBRLOCKLIST()) //CLIP: 0,0,1 - XPP 1,0,1 <- *DIVERSO*

FUNCTION DBRLOCKLIST_XPP()
RETURN ACLONE( DBRLOCKLIST() )

// Correzione per DBSKIP(0) perchŠ in Clipper non sposta il record
// mentre in Xbase lo sposta se il record corrente Š cancellato

FUNCTION DBSKIP_XPP(n)
   DO CASE
      CASE PCOUNT() == 0
         DBSKIP()

      CASE n != NIL .AND. VALTYPE(n) == "N" .AND. n == 0
         DBGOTO( RECNO() )

      OTHERWISE
         DBSKIP(n)
   ENDCASE

RETURN NIL

// Funzione DBUSEAREA_XPP
//
// identica alla DBUSEAREA ma ha un valore di ritorno
// come CLIPPER: NIL se Š OK, diverso da NIL se non ha aperto il file

FUNCTION DBUSEAREA_XPP(lNew, cRdd, cFile, cAlias, lShared, lReadOnly)
   LOCAL bError := ErrorBlock({|e| dfErrBreak(e) })
   LOCAL xRet   := NIL

   BEGIN SEQUENCE
      DBUSEAREA(lNew, cRdd, cFile, cAlias, lShared, lReadOnly)
   RECOVER
      xRet := .F.
   END SEQUENCE

   ErrorBlock(bError)
RETURN xRet

// Workaround per DBDELETE che con Xbase 1.7 e 1.8
// da un runtime error se non fai il lock e sei su EOF()
FUNCTION DBDELETE_XPP()
   IF ! EOF()
      DBDELETE()
   ENDIF
RETURN NIL


FUNCTION dfIsDel()
   DBGOTO(RECNO())
RETURN EOF().OR.DELETED()

FUNCTION FieldBlock_XPP(cField)
RETURN {|x| IIF(x==NIL, FIELDGET(FIELDPOS(cField)), ;
                FIELDPUT(FIELDPOS(cField), x)) }

FUNCTION RddList()
   LOCAL aRdd := {}
   AEVAL(DbeList(), {|x| AADD(aRdd, x[1]) })
   //dfAlert("RDDLIST//"+dfAny2Str(aRdd))
RETURN aRdd

FUNCTION RddName(); RETURN DbInfo(DBO_DBENAME)
FUNCTION SetCursor(); RETURN 0

// WorkAround per errore runtime in Xbase++
// per numeri negativi
FUNCTION SQRT_XPP(n)
RETURN IIF(n < 0, 0, SQRT(n) )

FUNCTION SWPRUNCMD()
RETURN .F.

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE __dbpack()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PACK
RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE __dbzap()
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ZAP
RETURN

/*
 * NetName() -> cWorkStationName
 * returns the name of the workstation the program is running on
 * valid for Windows 95 / NT
 */
FUNCTION NetName()
   LOCAL nHKey      := "HKEY_LOCAL_MACHINE"
   LOCAL cKeyName   := "System\CurrentControlSet\Control\ComputerName\ComputerName"
   LOCAL cEntryName := "ComputerName"
   LOCAL cRet
   cRet := dfQueryRegistry(nHKey, cKeyName, cEntryName)
   cRet := VAR2CHAR(cRet)
RETURN cRet

// Fix per OrdSetFocus su ADS è lenta!
FUNCTION ORDSETFOCUS_XPP(c)
   LOCAL x
   
   IF c==NIL
      c := ORDSETFOCUS()

   ELSEIF VALTYPE(c)=="N" 
      IF ORDNUMBER() != c
         x := ORDSETFOCUS(c)
      ENDIF
   ELSE     
      IF ORDSETFOCUS() != c
         x := ORDSETFOCUS(c)
      ENDIF
   ENDIF
RETURN x

// Simone 22/10/10 XL 2422
// FIX per funzione ORDBAGNAME di alaska che 
// non torna il valore corretto quando
// - si usa ADS 8 o inferiore oppure si usa ADS 9 o superiore e 
//   il flag apertura esclusiva tabella Š disattivo 
//   (per compatibilit… con ADS8 o inferiore)
// - si usa dizionario dati
// - la tabella ha un indice copiato tramite la dfIndexDup()
FUNCTION ORDBAGNAME_XPP(xIdx, nInfo)
   IF dfADSUseDD()
      RETURN dfADSOrdBagName(xIdx, nInfo)
   ENDIF
RETURN ORDBAGNAME(xIdx, nInfo) 
