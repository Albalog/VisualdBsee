//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' VARIE
//Programmatore  : Baccan Matteo
//*****************************************************************************

#include "Common.ch"
#INCLUDE "FILEIO.CH"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfArrRest( cFileName )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL aRest := {}, nHandle
nHandle:=FOPEN(cFileName, FO_READ +FO_SHARED )
IF nHandle<0
   aRest:=NIL
ELSE
   _dfArrRest( aRest, nHandle )
   FCLOSE(nHandle)
ENDIF
RETURN aRest

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION _dfArrRest( aRest, nHandle )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cType, nCount:=0
LOCAL cSet

cType:=FREADSTR( nHandle, 5 )
ASIZE(aRest,VAL(SUBSTR(cType,2)))
WHILE nCount<LEN(aRest) .AND. !EMPTY( cType:=FREADSTR( nHandle, 1 ) )
   nCount++
   DO CASE
      CASE cType=="A"; FSEEK( nHandle, -1, FS_RELATIVE ); aRest[nCount]:={}; _dfArrRest( aRest[nCount], nHandle )
      CASE cType=="B"  // "BLOCK"
      CASE cType=="C"; aRest[nCount]:=FREADSTR(nHandle, VAL(FREADSTR(nHandle,5)) )
      CASE cType=="D"; aRest[nCount]:=FREADSTR(nHandle,8)
           IF "/"$aRest[nCount] .OR. ;
              "\"$aRest[nCount] .OR. ;
              "."$aRest[nCount] .OR. ;
              "-"$aRest[nCount]
              aRest[nCount]:=CTOD(aRest[nCount])
           ELSE
              cSet := SET( _SET_DATEFORMAT )
              SET DATE FORMAT "dd/mm/yyyy"
              aRest[nCount] := CTOD( SUBSTR(aRest[nCount],7,2)+"/" +;
                                     SUBSTR(aRest[nCount],5,2)+"/" +;
                                     SUBSTR(aRest[nCount],1,4) )
              SET( _SET_DATEFORMAT , cSet )
           ENDIF

      CASE cType=="L"; aRest[nCount]:=FREADSTR(nHandle, 1)=="1"
      CASE cType=="M"  // "MEMO"
      CASE cType=="N"; aRest[nCount]:=VAL(FREADSTR(nHandle, VAL(FREADSTR(nHandle,2)) ))
      CASE cType=="O"  // "OBJECT"
      CASE cType=="U"; aRest[nCount]:=NIL
   ENDCASE
ENDDO
RETURN aRest
