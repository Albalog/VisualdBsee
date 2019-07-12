//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per Video
//Programmatore  : Baccan Matteo
//*****************************************************************************
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfScrGetNum(nRow, nCol) // Preleva numero dal video
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nCurCol := nCol
LOCAL cChar   := []
LOCAL lComma  := .f.   // Segnala se ho gia' trovato una virgola
LOCAL cCurChr

M_CurOff()

WHILE .T.
   cCurChr = LEFT(SAVESCREEN( nRow,nCurCol,nRow,nCurCol ),1)
   DO CASE
      CASE VAL(cCurChr) # 0 .OR. cCurChr = [0] .OR. cCurChr = [-]
           cChar := cCurChr + cChar
           RESTSCREEN( nRow,nCurCol,nRow,nCurCol,cCurChr +CHR(112))

      CASE cCurChr = [,] .AND. !lComma
           lComma := .T.
           cChar  := [.]+cChar
           RESTSCREEN( nRow,nCurCol,nRow,nCurCol,cCurChr +CHR(112+8))

      CASE cCurChr = [.]
           RESTSCREEN( nRow,nCurCol,nRow,nCurCol,cCurChr +CHR(112+8))

      OTHERWISE
           exit
   ENDCASE
   nCurCol--
ENDDO

nCurCol = nCol+1
WHILE .T.
   cCurChr = LEFT(SAVESCREEN( nRow,nCurCol,nRow,nCurCol ),1)
   DO CASE
      CASE VAL(cCurChr) # 0 .OR. cCurChr = [0] .OR. cCurChr = [-]
           cChar += cCurChr
           RESTSCREEN( nRow,nCurCol,nRow,nCurCol,cCurChr +CHR(112))

      CASE cCurChr = [,] .AND. !lComma
           lComma := .T.
           cChar  += [.]
           RESTSCREEN( nRow,nCurCol,nRow,nCurCol,cCurChr +CHR(112+8))

      CASE cCurChr = [.]
           RESTSCREEN( nRow,nCurCol,nRow,nCurCol,cCurChr +CHR(112+8))

      OTHERWISE
           EXIT
   ENDCASE
   nCurCol++
ENDDO

M_CurOn()
RETURN VAL(cChar)
