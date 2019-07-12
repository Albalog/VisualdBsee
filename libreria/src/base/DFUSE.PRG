//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per FILE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#include "common.ch"
#include "dfStd.ch"
#include "dfSet.ch"

#define USE_NAME   1
#define USE_OPEN   2
#define USE_INDEX  3
#define USE_RECNO  4
#define USE_FILTER  5

#ifdef __XPP__
   // simone 5/11/04 per correzione problema DBGOTO(0)
   // vedi DBGOTO_XPP
   #xtranslate DBGOTO(<x>) => DBGOTO_XPP(<x>)
#endif

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfUse( cFile, nIndex, a2Add, cMode, cAlias, cRDD ) //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL lRet := .T.
LOCAL aFlt := NIL
LOCAL xSave

IF EMPTY cAlias ASSIGN cFile

IF !DFISSELECT( cAlias )        // Se non e' aperto
   lRet := ddUse( cFile, cAlias, nIndex, cMode, cRDD ) // Lo apro
   IF lRet                                    // Se riesco ad Aprirlo
      AADD( a2Add, { cAlias, .T.} )             // lo metto in lista
   ENDIF
ELSE
   xSave := dfSet(AI_SAVEFILTERONUSE)
   IF VALTYPE(xSave)=="L"
      xSave := IIF(xSave, 3, 0)
   ENDIF
   IF xSave > 0
      aFlt := (cAlias)->(dfFilterGet(xSave))
   ENDIF

   AADD( a2Add,{ cAlias, .F.,;
                (cAlias)->(INDEXORD()) ,;
                (cAlias)->(RECNO()   ) ,;
                aFlt}) // lo metto in lista


   // Simone 28/10/09 
   // non uso ORDSETFOCUS_XPP perchè controllo prima (è più veloce)
   IF nIndex#NIL .AND. VALTYPE(nIndex) == "N" .AND. (cAlias)->(ORDNUMBER()) != nIndex
      (cAlias)->(ORDSETFOCUS(nIndex))
   ENDIF
ENDIF
RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfClose( aFile, lPos, lRec, xFlt ) //
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nFile, aSub, cFlt
LOCAL lDis, lDis400

#ifdef __XPP_PROFILE__
LOCAL aList := WorkSpaceList()
#endif

lDis    := !dfSet( AI_DISABLEALLCLOSE )
lDis400 :=  dfSet( AI_AS400DISABLECLOSE )

DEFAULT lPos TO .F.
DEFAULT lRec TO .F.
DEFAULT xFlt TO dfSet(AI_SAVEFILTERONUSE)

IF VALTYPE(xFlt)=="L"
   xFlt := IIF(xFlt, 3, 0)
ENDIF

FOR nFile := LEN(aFile) TO 1 STEP -1
   aSub := aFile[nFile]
#ifdef __XPP_PROFILE__
   IF __ISSELECT1( UPPER(aSub[USE_NAME]), aList ) // Se e' aperto
   //IF __ISSELECT( aSub[USE_NAME] ) // Se e' aperto
      IF aFile[nFile][USE_OPEN]
         // Se devo chiudere
         IF lDis
            // Se e' un AS400 e ho disabilitato la chiusura NON chiudo il file
            IF !( lDis400               .AND.;
                 dfAsDriver( (aSub[USE_NAME])->(__RDDNAME()) ) )
               IF dfSET( AI_CLOSEFILECB )!=NIL
                  EVAL( dfSET( AI_CLOSEFILECB ), aSub[USE_NAME], DATE(), TIME() )
               ENDIF
               // simone 14/1/09
               // spostato dopo valutazione codeblock per correzione problema con TRIGGERS
               (aSub[USE_NAME])->(__DBCLOSEAREA())
            ENDIF
         ENDIF
      ELSE
         IF xFlt > 0 .AND. LEN(aSub) >= USE_FILTER 
            (aSub[USE_NAME])->(dfFilterSet( aSub[USE_FILTER], xFlt ))
         ENDIF
         // Simone 28/10/09 
         // non uso ORDSETFOCUS_XPP perchè controllo prima (è più veloce)
         IF lPos .AND. ((aSub[USE_NAME])->(ORDNUMBER()) != aSub[USE_INDEX]); (aSub[USE_NAME])->(__ORDSETFOCUS(aSub[USE_INDEX])); END
         IF lRec; (aSub[USE_NAME])->(     __DBGOTO(aSub[USE_RECNO])); END
      ENDIF
   ENDIF
#else
   IF DFISSELECT( aSub[USE_NAME] ) // Se e' aperto
      IF aFile[nFile][USE_OPEN]
         // Se devo chiudere
         IF lDis
            // Se e' un AS400 e ho disabilitato la chiusura NON chiudo il file
            IF !(lDis400               .AND.;
                 dfAsDriver( (aSub[USE_NAME])->(RDDNAME()) )      )
               IF dfSET( AI_CLOSEFILECB )!=NIL
                  EVAL( dfSET( AI_CLOSEFILECB ), aSub[USE_NAME], DATE(), TIME() )
               ENDIF
               // simone 14/1/09
               // spostato dopo valutazione codeblock per correzione problema con TRIGGERS
               (aSub[USE_NAME])->(DBCLOSEAREA())
            ENDIF
         ENDIF
      ELSE
         IF xFlt > 0 .AND. LEN(aSub) >= USE_FILTER 
            (aSub[USE_NAME])->(dfFilterSet( aSub[USE_FILTER], xFlt ))
         ENDIF
         // Simone 28/10/09 
         // non uso ORDSETFOCUS_XPP perchè controllo prima (è più veloce)
         IF lPos .AND. ((aSub[USE_NAME])->(ORDNUMBER()) != aSub[USE_INDEX]); (aSub[USE_NAME])->(ORDSETFOCUS(aSub[USE_INDEX])); END
         IF lRec; (aSub[USE_NAME])->(     DBGOTO(aSub[USE_RECNO])); END
      ENDIF
   ENDIF
#endif
NEXT
ASIZE( aFile, 0 )
RETURN

#ifdef __XPP_PROFILE__

PROCEDURE __DBCLOSEAREA(x)
   DBCLOSEAREA(x)
RETURN 

FUNCTION __ORDSETFOCUS(x)
   LOCAL r:= ORDSETFOCUS(x)
RETURN r

PROCEDURE __DBGOTO(x)
   DBGOTO(x)
RETURN 

FUNCTION __RDDNAME()
   LOCAL r:= RDDNAME()
RETURN r

FUNCTION __ISSELECT(x)
   LOCAL r:= SELECT(x)#0
RETURN r

FUNCTION __ISSELECT1(x, aList)
RETURN ASCAN(aList, {|y|y==x}) #0

#endif