/******************************************************************************
Progetto       : dBsee 4.0
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
******************************************************************************/

#define QRY_KEY_EXP          1
#define QRY_KEY_ALIASFIELD   2
#define QRY_KEY_FIELD        3

#include "Common.ch"
#include "dfreport.ch"
#include "dfStd.ch"
#include "dfSet.ch"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfQryOpt( aQuery, aSeq, aQryOpt )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cAlias := UPPER(PADR(ALIAS(),8)), aKey := {}, nFound, cGlobalExp

DEFAULT aQryOpt TO {}

ASIZE( aQryOpt, QRY_OPT_LEN )

aQryOpt[QRY_OPT_DESC  ] := dfQryFltDes( aQuery, aSeq )
aQryOpt[QRY_OPT_FLTGET] := dfQryFltExp( aQuery, aSeq )
aQryOpt[QRY_OPT_INDEX ] := INDEXORD()
aQryOpt[QRY_OPT_KEY   ] := NIL
aQryOpt[QRY_OPT_FILTER] := ".T."
aQryOpt[QRY_OPT_BREAK ] := ".F."

// Ottimizzo solo se non vi sono degli OR
IF !".OR."$aQryOpt[QRY_OPT_FLTGET]
   dbdd->(ORDSETFOCUS(1))
   dbdd->(DBSEEK( "NDX" +cAlias +STR(aQryOpt[QRY_OPT_INDEX],3) ))
   // Posiziono per l'espressione globale
   cGlobalExp := ALLTRIM(dbdd->Field_Msg)
   IF EMPTY(cGlobalExp)
      cGlobalExp := "%"
   ENDIF

   dbdd->(DBSEEK( "KEY" +cAlias +STR(aQryOpt[QRY_OPT_INDEX],3) ))
   // Posiziono per i campi componenti
   WHILE UPPER(dbdd->file_name)==UPPER(cAlias) .AND.;
         dbdd->NdxIncN==aQryOpt[QRY_OPT_INDEX] .AND.;
         UPPER(dbdd->RecTyp)=="KEY"            .AND.;
         !dbdd->(EOF())
      AADD( aKey, { ALLTRIM(dbdd->Slot)                     ,;
                    ALLTRIM(UPPER(cAlias)) +"->";
                          +UPPER(ALLTRIM(dbdd->Field_Name)) ,;
                    UPPER(ALLTRIM(dbdd->Field_Name))        })
      dbdd->(DBSKIP())
   ENDDO
   // nFound rappresenta il numero delle chiavi disponibili
   nFound := dfQryValid( aKey, aQryOpt )
   IF nFound>0 .AND. "%"$cGlobalExp
      dfQryIntOpt( aKey, aQryOpt, nFound, cGlobalExp )
   ENDIF
ENDIF

aQryOpt[QRY_OPT_STRKEY   ] := aQryOpt[QRY_OPT_KEY   ] // Filtri SOLO per il
aQryOpt[QRY_OPT_STRFILTER] := aQryOpt[QRY_OPT_FILTER] // MASTER
aQryOpt[QRY_OPT_STRBREAK ] := aQryOpt[QRY_OPT_BREAK ] // Eventuali figli sono
                                       // Filtrati da aQryOpt[QRY_OPT_FLTGET]

IF aQryOpt[QRY_OPT_KEY   ] # NIL
   aQryOpt[QRY_OPT_KEY   ] := DFCOMPILE(aQryOpt[QRY_OPT_KEY   ])
ENDIF
aQryOpt[QRY_OPT_FILTER] := DFCOMPILE(aQryOpt[QRY_OPT_FILTER])
aQryOpt[QRY_OPT_BREAK ] := DFCOMPILE(aQryOpt[QRY_OPT_BREAK ])

RETURN aQryOpt

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfQryValid( aKey, aQryOpt )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nFound, nCount

nFound := 0
FOR nCount := 1 TO LEN(aKey)
   IF aKey[nCount][QRY_KEY_ALIASFIELD]$UPPER(aQryOpt[QRY_OPT_FLTGET]) .AND. ;
      nFound==nCount-1
      nFound := nCount
   ENDIF
NEXT

RETURN nFound

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE dfQryIntOpt( aKey, aQryOpt, nFound, cGlobalExp )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nActual, nPos, aActual, nPosExp, nPosKey, nPosBreak, cBreakCond, cToken
LOCAL cKey    := ""
LOCAL cFilter := ""
LOCAL cBreak  := ""
LOCAL lKey    := .T.
LOCAL lFilter := .T.

FOR nActual := 1 TO nFound
   aActual := aKey[nActual]
   cFilter := aQryOpt[QRY_OPT_FLTGET]
   WHILE aActual[QRY_KEY_ALIASFIELD]$UPPER(cFilter)
      nPosExp := AT( aActual[QRY_KEY_ALIASFIELD], UPPER(cFilter) )
      nPos    := nPosExp + LEN( aActual[QRY_KEY_ALIASFIELD] )
      nPosKey := nPosBreak := nPos
      cBreakCond  := ""
      DO CASE
         CASE SUBSTR( cFilter, nPos, 2 ) == ">="
              nPosKey+=2

         CASE SUBSTR( cFilter, nPos, 1 ) == ">"
              nPosKey++

         CASE SUBSTR( cFilter, nPos, 2 ) == "<="
              nPosBreak+=2
              cBreakCond := ">"

         CASE SUBSTR( cFilter, nPos, 1 ) == "<"
              nPosBreak++
              cBreakCond := ">="

         CASE SUBSTR( cFilter, nPos, 2 ) == "=="
              nPosKey+=2
              nPosBreak+=2
              cBreakCond := "#"

         CASE SUBSTR( cFilter, nPos, 1 ) == "="
              nPosKey++
              nPosBreak++
              cBreakCond := "#"
      ENDCASE
      // Disabilitando il filter optimizer
      // l'ottimizzazione di Key e Break solo sul primo elemento
      IF dfSet(AI_FILTEROPTIMIZER)
         lKey := lFilter := .T.
      ENDIF

      IF nPosKey#nPos .AND. lKey
         cToken := dfQryToken( cFilter, nPosKey )
         cToken := dfQryKey( cToken, aActual )
         cKey   +=  cToken +"+"
         lKey   := .F.
      ENDIF
      IF nPosBreak#nPos .AND. lFilter
         cBreak += SUBSTR( cFilter, nPosExp, nPos-nPosExp )
         cBreak += cBreakCond
         cBreak += dfQryToken( cFilter, nPosBreak ) +".AND."
         lFilter:= .F.
      ENDIF
      cFilter := LEFT( cFilter, nPosExp-1 ) +"()" +RIGHT( cFilter, LEN(cFilter)-nPos+1 )
   ENDDO
NEXT

aQryOpt[QRY_OPT_KEY  ] := LEFT( cKey  , LEN(cKey  )-1 )
aQryOpt[QRY_OPT_BREAK] := LEFT( cBreak, LEN(cBreak)-5 )
IF !EMPTY(aQryOpt[QRY_OPT_KEY  ])
   aQryOpt[QRY_OPT_KEY  ] := dfPkExp( cGlobalExp, aQryOpt[QRY_OPT_KEY  ] )
ENDIF

IF EMPTY(aQryOpt[QRY_OPT_KEY  ]); aQryOpt[QRY_OPT_KEY  ] :=   NIL ; ENDIF
IF EMPTY(aQryOpt[QRY_OPT_BREAK]); aQryOpt[QRY_OPT_BREAK] := ".F." ; ENDIF

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfQryToken( cExp, nPos )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nLastPos := LEN(cExp), nActualPos, nTonde := 0
FOR nActualPos := nPos TO LEN(cExp)
   DO CASE
      CASE nLastPos#LEN(cExp)

      CASE SUBSTR( cExp, nActualPos, 4 ) == ".OR."
           nLastPos := nActualPos-1

      CASE SUBSTR( cExp, nActualPos, 5 ) == ".AND."
           nLastPos := nActualPos-1

      CASE SUBSTR( cExp, nActualPos, 1 ) == "("
           nTonde++

      CASE SUBSTR( cExp, nActualPos, 1 ) == ")"
           nTonde--
           IF nTonde<0
              nLastPos := nActualPos-1
           ENDIF
   ENDCASE
NEXT
RETURN SUBSTR( cExp, nPos, nLastPos-nPos+1 )

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfQryKey( cToken, aActual )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
RETURN STRTRAN( UPPER(aActual[QRY_KEY_EXP]), aActual[QRY_KEY_FIELD], cToken )
