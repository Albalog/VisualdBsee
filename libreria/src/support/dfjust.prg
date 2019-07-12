#ifdef _TEST_
FUNCTION MAIN(str, n)
   LOCAL c
   IF EMPTY(str)
      str := "dBsee        e'  uno  standard"  
   ENDIF
   IF n != nil
      n := VAL(n)
   ENDIF

   c := dfJust(str, n)

   ? "<"+str+">"
   ? len(str)
   ? "<"+c+">"
   ? len(c)
   wait
return 0
#endif

// Simone 19/08/2004 gerr 4232
// giustifica una stringa
// tradotta dalla funzione dfJust.c
FUNCTION dfJust(fpBuf, nPad)
   LOCAL fpNewBuf
   LOCAL iLen, iSpace, iPos, iWord, iDiv, iNewPos, iNewLen, iFirst:=0

   iLen := LEN(fpBuf)
   iNewLen := iLen

   IF PCOUNT() > 1
      iNewLen := nPad
   ENDIF

   fpNewBuf := SPACE(iNewLen)

   iWord  := 0
   iPos   := 0
   iSpace := 0

   DO WHILE iPos < iLen 
      DO WHILE  iPos < iLen .AND. fpBuf[1+iPos]==' ' 
         IF iFirst==1 
            iSpace++
         ENDIF
         iPos++
      ENDDO
      iFirst:=1
      DO WHILE ( iPos<iLen .AND. ! fpBuf[1+iPos] == ' ' ) 
         iPos++
      ENDDO
      iWord++
   ENDDO

   IF iNewLen>iLen 
      iSpace += (iNewLen-iLen)
   ENDIF

   iPos:=0
   iNewPos:=0

   IF iWord==0 
      iWord:=1
   ENDIF

   DO WHILE ( iPos<iLen .AND. iNewPos<iNewLen .AND. fpBuf[1+iPos]==' ' ) 
      fpNewBuf[1+iNewPos++] := fpBuf[1+iPos++]
   ENDDO

   DO WHILE ( iNewPos<iNewLen )
      DO WHILE( iPos<iLen .AND. iNewPos<iNewLen .AND. ! fpBuf[1+iPos] == ' ' ) 
         fpNewBuf[1+iNewPos++]=fpBuf[1+iPos++]
      ENDDO
      IF iWord > 1 
        iWord--
      ENDIF

      iDiv:= INT(iSpace/iWord)
      IF iDiv==0 
        iDiv:=1
      ENDIF

      IF iSpace>iDiv 
         iSpace -=iDiv
      ELSE
         iSpace:=0
      ENDIF

      DO WHILE ( iNewPos<iNewLen .AND. iDiv>0 )
         iDiv--
         fpNewBuf[1+iNewPos++]:=' '
      ENDDO
      DO WHILE ( iPos<iLen .AND. fpBuf[1+iPos]==' ' ) 
         iPos++
      ENDDO
   ENDDO

RETURN fpNewBuf
