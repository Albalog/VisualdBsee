//*****************************************************************************
//Progetto       : dBsee 4.0
//Descrizione    : Funzioni di utilita' per FILE
//Programmatore  : Baccan Matteo
//*****************************************************************************
#INCLUDE "dfFile.ch"
#INCLUDE "fileio.ch"

* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCTION dfFSkip()               // Esegue uno Skip avanti di una riga
* ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOCAL nPos
LOCAL nLen
LOCAL cBuf
LOCAL nPosSep
LOCAL aActual := dfFActual()

IF !dfFEof()
   WHILE .T.
      IF (nPos := At( aActual[FL_SEPCHAR], aActual[FL_BUFFER] )) == 0    // nessuna riga

         aActual[FL_OFFSET] += aActual[FL_BUFPOS]

         fSeek( aActual[FL_HANDLE], aActual[FL_OFFSET], FS_SET )

         cBuf := SPACE(aActual[FL_RECLEN])
         nLen := fRead( aActual[FL_HANDLE], @cBuf, aActual[FL_RECLEN] ) // Leggo

         aActual[FL_BUFFER] := cBuf

         DO CASE
            CASE nLen == aActual[FL_RECLEN]
                 nPos := At( aActual[FL_SEPCHAR], aActual[FL_BUFFER] )

            CASE nLen > 0
                 aActual[FL_BUFFER] := Left( aActual[FL_BUFFER], nLen )

                 nPos := At( aActual[FL_SEPCHAR], aActual[FL_BUFFER] )
                 IF nPos == 0
                    nPos := nLen +1
                 ENDIF

            OTHERWISE
                 aActual[FL_BUFFER] := ""
                 aActual[FL_EOF] := .T.
                 nPos := 1
         ENDCASE
         IF (nPosSep := RAT( aActual[FL_SEPCHAR], aActual[FL_BUFFER] )) #0
            aActual[FL_BUFPOS] := nPosSep + aActual[FL_SEPLEN]
         ELSE
            aActual[FL_BUFPOS] := nPos
         ENDIF
         aActual[FL_BUFPOS]--
      ENDIF
      aActual[FL_LINE]   := Left( aActual[FL_BUFFER], nPos-1 )
      aActual[FL_BUFFER] := SubStr( aActual[FL_BUFFER], nPos+aActual[FL_SEPLEN] )
      IF aActual[FL_SKIPREM]
         IF aActual[FL_EOF] .OR. !dfFIsRem(aActual[FL_LINE])
            EXIT
         ENDIF
      ELSE
         EXIT
      ENDIF
   ENDDO
ENDIF

RETURN NIL
