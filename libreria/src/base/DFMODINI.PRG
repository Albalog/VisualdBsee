/*******************************************************************************
Progetto       : dBsee 4.3
Descrizione    : Funzioni di utilita'
Programmatore  : Baccan Matteo
*******************************************************************************/

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfModIni( cName, aChange )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nHandle:=0, nHandle1:=0, lRet := .F., cBuf, nPos
nHandle := dfFopen( cName )
IF nHandle>0
   nHandle1:=FCREATE( dfDmm(cName) )
   IF nHandle1>0
      lRet := .T.
      WHILE !dfFEof()
         cBuf := UPPER(dfLeft( dfFread() ))
         IF (nPos:=ASCAN( aChange, {|aSub|UPPER(ALLTRIM(aSub[1]))==cBuf} ))>0
            cBuf := dfLeft(dfFread()) +"=" +aChange[nPos][2]
         ELSE
            cBuf := dfFread()
         ENDIF
         FWRITE( nHandle1, cBuf +CHR(13) +CHR(10) )
         dfFskip()
      ENDDO
      FCLOSE(nHandle1)
      dfFclose()
      nHandle := nHandle1 := 0
      FERASE( dfBak(cName) )
      RENAME (cName)        TO (dfBak(cName))
      RENAME (dfDmm(cName)) TO (cName)
   ENDIF
ENDIF

IF nHandle >0; dfFclose()       ;ENDIF
IF nHandle1>0; FCLOSE(nHandle1) ;ENDIF

RETURN lRet

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfBak( cName )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cNewName := "", nPos
nPos := AT( ".", cName )
IF nPos>0
   cName := LEFT( cName, nPos-1 )
ENDIF
cNewName := cName +".BAK"
RETURN cNewName

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
STATIC FUNCTION dfDmm( cName )
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL cNewName := "", nPos
nPos := AT( ".", cName )
IF nPos>0
   cName := LEFT( cName, nPos-1 )
ENDIF
cNewName := cName +".DMM"
RETURN cNewName
