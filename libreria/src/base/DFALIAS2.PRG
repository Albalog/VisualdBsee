/*******************************************************************************
Progetto       : dBsee 4.4
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
*******************************************************************************/

STATIC aAlias := {}
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROCEDURE dfCngAlias( cAlias, cName )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos

cAlias := UPPER(ALLTRIM(cAlias))
cName  := UPPER(ALLTRIM(cName))

IF !(cAlias==cName)
   nPos := ASCAN( aAlias, {|aSub|aSub[1]==cAlias} )
   IF nPos==0
      AADD( aAlias, {cAlias,cName} )
   ELSE
      aAlias[nPos] := {cAlias,cName}
   ENDIF
ENDIF

RETURN

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfAlias2Name( cAlias )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos, cName := cAlias

cAlias := UPPER(ALLTRIM(cAlias))

nPos := ASCAN( aAlias, {|aSub|aSub[1]==cAlias} )
IF nPos>0
   cName := aAlias[nPos][2]
ENDIF

RETURN cName
