//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' VARIE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "FILEIO.CH"
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfArrSave( aSource, cFileName )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nHandle := FCREATE( cFileName ), lSave:=.T.
IF nHandle<0
   lSave:=.F.
ELSE
   _dfArrSave( aSource, nHandle )
   FCLOSE(nHandle)
ENDIF
RETURN lSave

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC PROCEDURE _dfArrSave( aSource, nHandle )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nActual, nEle:=LEN(aSource), cType
FWRITE( nHandle, "A"+ PADL(nEle,4) )

FOR nActual:=1 TO nEle
   cType:=VALTYPE(aSource[nActual])
   DO CASE
      CASE cType=="A"; _dfArrSave( aSource[nActual], nHandle )
      CASE cType=="B"; cType:="U" // "BLOCK"
      CASE cType=="C"; cType += PADL(LEN(aSource[nActual]),5) +aSource[nActual]
      CASE cType=="D"; cType += DTOS(aSource[nActual])
      CASE cType=="L"; cType += IF( aSource[nActual], "1", "0" )
      CASE cType=="M"; cType:="U" // "MEMO"
      CASE cType=="N"; cType += PADL(LEN(ALLTRIM(STR(aSource[nActual]))),2) +ALLTRIM(STR(aSource[nActual]))
      CASE cType=="O"; cType:="U" // "OBJECT"
      CASE cType=="U"  // NOT IMPORTANT
   ENDCASE
   IF cType#"A"
      FWRITE( nHandle, cType )
   ENDIF
NEXT

RETURN
